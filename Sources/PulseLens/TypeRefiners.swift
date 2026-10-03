import Foundation
import PulseCore

/// Deterministic type refiners that specialize generic SelectedTextObjects into
/// rich domain objects (URL, Path, JSON, ErrorLog, CodeSnippet) while preserving
/// full parent provenance and interaction IDs.
public struct TypeRefiners: Sendable {

    /// Deterministically refines a PulseObject if applicable, preserving parent provenance.
    public static func refine(object: any PulseObject) -> any PulseObject {
        guard let textObj = object as? SelectedTextObject else {
            return object
        }

        // Never refine secure blocked objects
        if textObj.privacyClass == .secureBlocked {
            return textObj
        }

        let raw = textObj.text
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. JSON Refinement (Strict validation)
        if (trimmed.hasPrefix("{") && trimmed.hasSuffix("}")) ||
           (trimmed.hasPrefix("[") && trimmed.hasSuffix("]")) {
            if let data = trimmed.data(using: .utf8),
               let parsed = try? JSONSerialization.jsonObject(with: data) {
                let isArray = parsed is [Any]
                let prov = ObjectProvenance(
                    timestamp: textObj.provenance.timestamp,
                    sourceAppBundle: textObj.provenance.sourceAppBundle,
                    sourcePID: textObj.provenance.sourcePID,
                    acquisitionMethod: "\(textObj.provenance.acquisitionMethod).refined_json",
                    windowTitle: textObj.provenance.windowTitle,
                    axRole: textObj.provenance.axRole,
                    parentObjectID: textObj.id.uuidString
                )
                return JSONTextObject(
                    source: textObj.source,
                    jsonString: trimmed,
                    isArray: isArray,
                    parentObjectID: textObj.id.uuidString,
                    provenance: prov,
                    privacyClass: textObj.privacyClass,
                    confidence: 1.0,
                    contextGenerationToken: textObj.contextGenerationToken,
                    createdAt: textObj.createdAt
                )
            }
        }

        // 2. URL Refinement
        if !trimmed.contains("\n") && (trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") || trimmed.hasPrefix("file://")) {
            if let url = URL(string: trimmed), url.scheme != nil {
                let prov = ObjectProvenance(
                    timestamp: textObj.provenance.timestamp,
                    sourceAppBundle: textObj.provenance.sourceAppBundle,
                    sourcePID: textObj.provenance.sourcePID,
                    acquisitionMethod: "\(textObj.provenance.acquisitionMethod).refined_url",
                    windowTitle: textObj.provenance.windowTitle,
                    axRole: textObj.provenance.axRole,
                    parentObjectID: textObj.id.uuidString
                )
                return URLObject(
                    source: textObj.source,
                    url: url,
                    rawText: trimmed,
                    parentObjectID: textObj.id.uuidString,
                    provenance: prov,
                    privacyClass: textObj.privacyClass,
                    confidence: 1.0,
                    contextGenerationToken: textObj.contextGenerationToken,
                    createdAt: textObj.createdAt
                )
            }
        }

        // 3. Filesystem Path Refinement
        if !trimmed.contains("\n") && (trimmed.hasPrefix("/") || trimmed.hasPrefix("~/") || trimmed.hasPrefix("./")) {
            let expanded = (trimmed as NSString).expandingTildeInPath
            let exists = FileManager.default.fileExists(atPath: expanded)
            let prov = ObjectProvenance(
                timestamp: textObj.provenance.timestamp,
                sourceAppBundle: textObj.provenance.sourceAppBundle,
                sourcePID: textObj.provenance.sourcePID,
                acquisitionMethod: "\(textObj.provenance.acquisitionMethod).refined_path",
                windowTitle: textObj.provenance.windowTitle,
                axRole: textObj.provenance.axRole,
                parentObjectID: textObj.id.uuidString
            )
            return PathObject(
                source: textObj.source,
                path: expanded,
                existsOnDisk: exists,
                parentObjectID: textObj.id.uuidString,
                provenance: prov,
                privacyClass: textObj.privacyClass,
                confidence: exists ? 1.0 : 0.85,
                contextGenerationToken: textObj.contextGenerationToken,
                createdAt: textObj.createdAt
            )
        }

        // 4. Error Log Refinement
        let errorMarkers = [
            "fatalError",
            "SIGSEGV",
            "EXC_BAD_ACCESS",
            "Exception in thread",
            "Traceback (most recent call last):",
            "Assertion failed:",
            "Error:",
            "FATAL:"
        ]
        var foundMarkers: [String] = []
        for marker in errorMarkers {
            if trimmed.contains(marker) {
                foundMarkers.append(marker)
            }
        }
        if !foundMarkers.isEmpty {
            let prov = ObjectProvenance(
                timestamp: textObj.provenance.timestamp,
                sourceAppBundle: textObj.provenance.sourceAppBundle,
                sourcePID: textObj.provenance.sourcePID,
                acquisitionMethod: "\(textObj.provenance.acquisitionMethod).refined_error_log",
                windowTitle: textObj.provenance.windowTitle,
                axRole: textObj.provenance.axRole,
                parentObjectID: textObj.id.uuidString
            )
            return ErrorLogObject(
                source: textObj.source,
                logText: raw,
                detectedKeywords: foundMarkers,
                parentObjectID: textObj.id.uuidString,
                provenance: prov,
                privacyClass: textObj.privacyClass,
                confidence: 0.9,
                contextGenerationToken: textObj.contextGenerationToken,
                createdAt: textObj.createdAt
            )
        }

        // 5. Code Snippet Refinement
        let codeKeywords = [
            "func ", "struct ", "class ", "import ", "def ", "return ",
            "let ", "var ", "const ", "public func", "private func",
            "fn ", "impl ", "package ", "namespace "
        ]
        var codeMatches = 0
        for keyword in codeKeywords {
            if trimmed.contains(keyword) {
                codeMatches += 1
            }
        }
        if codeMatches >= 1 || (trimmed.contains("{") && trimmed.contains("}") && trimmed.contains(";")) {
            let langHint: String?
            if trimmed.contains("func ") || trimmed.contains("struct ") || trimmed.contains("import Swift") {
                langHint = "swift"
            } else if trimmed.contains("def ") || trimmed.contains("import ") && trimmed.contains(":") {
                langHint = "python"
            } else if trimmed.contains("const ") || trimmed.contains("function ") {
                langHint = "javascript"
            } else {
                langHint = nil
            }

            let prov = ObjectProvenance(
                timestamp: textObj.provenance.timestamp,
                sourceAppBundle: textObj.provenance.sourceAppBundle,
                sourcePID: textObj.provenance.sourcePID,
                acquisitionMethod: "\(textObj.provenance.acquisitionMethod).refined_code",
                windowTitle: textObj.provenance.windowTitle,
                axRole: textObj.provenance.axRole,
                parentObjectID: textObj.id.uuidString
            )
            return CodeSnippetObject(
                source: textObj.source,
                code: raw,
                languageHint: langHint,
                parentObjectID: textObj.id.uuidString,
                provenance: prov,
                privacyClass: textObj.privacyClass,
                confidence: 0.9,
                contextGenerationToken: textObj.contextGenerationToken,
                createdAt: textObj.createdAt
            )
        }

        return textObj
    }
}
