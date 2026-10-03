import Foundation
import ApplicationServices
import AppKit
import PulseCore

/// Provider for Tier 1: Explicit selected files (e.g. from Finder or file browser).
public struct SelectedFileProvider: LensAcquisitionProvider {
    public let tier: LensPrecedenceTier = .selectedContent

    public init() {}

    public func acquireCandidate(at screenPoint: (x: Double, y: Double)?) -> LensCandidate? {
        guard AccessibilityAuthorizer.checkStatus() == .authorized else {
            return nil
        }

        let frontmost = NSWorkspace.shared.frontmostApplication
        guard let bundleID = frontmost?.bundleIdentifier, bundleID == "com.apple.finder" else {
            return nil
        }

        let frontPID = frontmost?.processIdentifier
        let appName = frontmost?.localizedName ?? "Finder"

        guard let pid = frontPID else { return nil }
        let appElement = AXUIElementCreateApplication(pid)
        AXTimeoutHelper.applyTimeout(to: appElement)

        // Query focused element or window
        var focusedRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedRef) == .success,
              let focused = focusedRef else {
            return nil
        }
        let focusedElement = (focused as! AXUIElement)
        AXTimeoutHelper.applyTimeout(to: focusedElement)

        var selectedPaths: [String] = []

        // 1. Try kAXSelectedRowsAttribute (List, Outline, Table views)
        var selectedRowsRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(focusedElement, "AXSelectedRows" as CFString, &selectedRowsRef) == .success,
           let rows = selectedRowsRef as? [AXUIElement] {
            for row in rows.prefix(50) {
                AXTimeoutHelper.applyTimeout(to: row)
                if let path = findFilePathInTree(from: row) {
                    selectedPaths.append(path)
                }
            }
        }

        // 2. Try kAXSelectedChildrenAttribute (Icon, Column, Desktop views)
        if selectedPaths.isEmpty {
            var selectedChildrenRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(focusedElement, "AXSelectedChildren" as CFString, &selectedChildrenRef) == .success,
               let children = selectedChildrenRef as? [AXUIElement] {
                for child in children.prefix(50) {
                    AXTimeoutHelper.applyTimeout(to: child)
                    if let path = findFilePathInTree(from: child) {
                        selectedPaths.append(path)
                    }
                }
            }
        }

        // 3. Try directly on focusedElement
        if selectedPaths.isEmpty {
            if let path = extractFilePath(from: focusedElement) {
                selectedPaths.append(path)
            }
        }

        guard !selectedPaths.isEmpty else {
            return nil
        }

        let prov = ObjectProvenance(
            sourceAppBundle: bundleID,
            sourcePID: frontPID,
            acquisitionMethod: "accessibility.finder.selected_files"
        )

        let object = SelectedFileObject(
            filePaths: selectedPaths,
            provenance: prov,
            privacyClass: .ordinary,
            confidence: 1.0
        )

        return LensCandidate(
            tier: .selectedContent,
            object: object,
            confidence: 1.0,
            acquisitionReason: "Explicit file selection in \(appName) (\(selectedPaths.count) items)"
        )
    }

    private func extractFilePath(from element: AXUIElement) -> String? {
        AXTimeoutHelper.applyTimeout(to: element)
        var urlRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, "AXURL" as CFString, &urlRef) == .success,
           let ref = urlRef {
            let urlString: String?
            if let u = ref as? URL {
                urlString = u.absoluteString
            } else if let s = ref as? String {
                urlString = s
            } else {
                urlString = nil
            }
            if let s = urlString, let u = URL(string: s) {
                if let resolved = (u as NSURL).filePathURL?.path {
                    return resolved
                } else if u.isFileURL {
                    return u.path
                }
            }
        }

        var filenameRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, "AXFilenames" as CFString, &filenameRef) == .success,
           let filenames = filenameRef as? [String], let first = filenames.first {
            return first
        }

        return nil
    }

    private func findFilePathInTree(from element: AXUIElement, depth: Int = 0) -> String? {
        if let direct = extractFilePath(from: element) {
            return direct
        }
        guard depth < 3 else { return nil }

        var childrenRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &childrenRef) == .success,
           let children = childrenRef as? [AXUIElement] {
            for child in children.prefix(15) {
                if let found = findFilePathInTree(from: child, depth: depth + 1) {
                    return found
                }
            }
        }
        return nil
    }
}
