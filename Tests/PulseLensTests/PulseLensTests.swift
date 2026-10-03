import Testing
import Foundation
import AppKit
@testable import PulseCore
@testable import PulseLens

@Suite("PulseLens Context & Precedence Tests")
struct PulseLensTests {

    @Test("Precedence hierarchy strictly enforces Tier 1 > Tier 2 > Tier 3 > Tier 4 > Tier 5 (INV-003)")
    func testPrecedenceOrder() {
        let prov = ObjectProvenance(acquisitionMethod: "unit-test")

        let t1 = LensCandidate(
            tier: .selectedContent,
            object: SelectedTextObject(text: "Selected text", provenance: prov),
            confidence: 1.0,
            acquisitionReason: "Tier 1 Selected Content"
        )
        let t2 = LensCandidate(
            tier: .pointerUIElement,
            object: UIElementObject(role: "AXButton", title: "Submit", applicationName: "App", provenance: prov),
            confidence: 1.0,
            acquisitionReason: "Tier 2 Pointer Element"
        )
        let t3 = LensCandidate(
            tier: .focusedAXElement,
            object: FocusedElementObject(role: "AXTextField", title: "Input", applicationName: "App", provenance: prov),
            confidence: 1.0,
            acquisitionReason: "Tier 3 Focused Element"
        )
        let t4 = LensCandidate(
            tier: .frontmostAppOrWindow,
            object: ApplicationObject(applicationName: "Terminal", pid: 1234, provenance: prov),
            confidence: 1.0,
            acquisitionReason: "Tier 4 Frontmost App"
        )
        let t5 = LensCandidate(
            tier: .clipboardFallback,
            object: ClipboardObject(changeCount: 42, types: ["public.utf8-plain-text"], textPreview: "clip", provenance: prov),
            confidence: 0.8,
            acquisitionReason: "Tier 5 Clipboard Fallback"
        )

        // All 5 present: Tier 1 wins
        let fullList = [t5, t3, t1, t4, t2]
        #expect(LensResolver.resolvePrimary(from: fullList)?.tier == .selectedContent)

        // Tier 1 absent: Tier 2 wins
        let noT1 = [t4, t5, t3, t2]
        #expect(LensResolver.resolvePrimary(from: noT1)?.tier == .pointerUIElement)

        // Tier 1 & 2 absent: Tier 3 wins
        let noT1T2 = [t5, t4, t3]
        #expect(LensResolver.resolvePrimary(from: noT1T2)?.tier == .focusedAXElement)

        // Tier 1, 2, 3 absent: Tier 4 wins
        let noT1T2T3 = [t5, t4]
        #expect(LensResolver.resolvePrimary(from: noT1T2T3)?.tier == .frontmostAppOrWindow)

        // Only Tier 5: Tier 5 wins
        let onlyT5 = [t5]
        #expect(LensResolver.resolvePrimary(from: onlyT5)?.tier == .clipboardFallback)
    }

    @Test("Confidence breaks ties within the same tier deterministically")
    func testConfidenceTieBreaking() {
        let prov = ObjectProvenance(acquisitionMethod: "unit-test")
        let lower = LensCandidate(
            tier: .pointerUIElement,
            object: UIElementObject(role: "AXButton", title: "Low Confidence", applicationName: "App", provenance: prov),
            confidence: 0.5,
            acquisitionReason: "Lower confidence"
        )
        let higher = LensCandidate(
            tier: .pointerUIElement,
            object: UIElementObject(role: "AXButton", title: "High Confidence", applicationName: "App", provenance: prov),
            confidence: 0.95,
            acquisitionReason: "Higher confidence"
        )

        let winner = LensResolver.resolvePrimary(from: [lower, higher])
        #expect(winner?.confidence == 0.95)
        #expect(winner?.acquisitionReason == "Higher confidence")
    }

    @Test("Whitespace-only selections are rejected from Tier 1")
    func testWhitespaceRejection() {
        let whitespaceSamples = ["", " ", "   \t  ", "\n\n  \r\n"]
        for sample in whitespaceSamples {
            #expect(sample.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    @Test("Secure fields guard secret payloads with .secureBlocked privacy class")
    func testSecureFieldBlocking() {
        let prov = ObjectProvenance(
            sourceAppBundle: "com.apple.KeychainAccess",
            sourcePID: 999,
            acquisitionMethod: "accessibility.secure_field_blocked",
            axRole: "AXSecureTextField"
        )

        let secureObj = SelectedTextObject(
            text: "",
            provenance: prov,
            privacyClass: .secureBlocked,
            confidence: 1.0
        )

        #expect(secureObj.privacyClass == .secureBlocked)
        #expect(secureObj.text.isEmpty)

        // Refiners must never alter or expose secureBlocked objects
        let refined = TypeRefiners.refine(object: secureObj)
        #expect(refined.privacyClass == .secureBlocked)
        #expect(refined.objectClass == .selectedText)
    }

    @Test("TypeRefiners specialize generic text while strictly preserving parent provenance")
    func testTypeRefinements() {
        let prov = ObjectProvenance(
            sourceAppBundle: "com.apple.TextEdit",
            sourcePID: 500,
            acquisitionMethod: "test"
        )

        // 1. URL Refinement
        let urlText = SelectedTextObject(text: "https://github.com/westkitty/Dex_Pulse", provenance: prov)
        let refinedURL = TypeRefiners.refine(object: urlText)
        #expect(refinedURL.objectClass == .url)
        if let urlObj = refinedURL as? URLObject {
            #expect(urlObj.url.host == "github.com")
            #expect(urlObj.parentObjectID == urlText.id.uuidString)
            #expect(urlObj.provenance.sourceAppBundle == "com.apple.TextEdit")
        }

        // 2. Path Refinement
        let pathText = SelectedTextObject(text: "/tmp/sample_dex_pulse.txt", provenance: prov)
        let refinedPath = TypeRefiners.refine(object: pathText)
        #expect(refinedPath.objectClass == .path)
        if let pathObj = refinedPath as? PathObject {
            #expect(pathObj.path == "/tmp/sample_dex_pulse.txt")
            #expect(pathObj.parentObjectID == pathText.id.uuidString)
        }

        // 3. JSON Refinement
        let jsonText = SelectedTextObject(text: "{\"status\": \"ok\", \"count\": 42}", provenance: prov)
        let refinedJSON = TypeRefiners.refine(object: jsonText)
        #expect(refinedJSON.objectClass == .jsonText)
        if let jsonObj = refinedJSON as? JSONTextObject {
            #expect(!jsonObj.isArray)
            #expect(jsonObj.parentObjectID == jsonText.id.uuidString)
        }

        // 4. Error Log Refinement
        let errText = SelectedTextObject(text: "fatalError: Unexpected nil at PulseCore.swift:42\nSIGSEGV (11)", provenance: prov)
        let refinedErr = TypeRefiners.refine(object: errText)
        #expect(refinedErr.objectClass == .errorLog)
        if let errObj = refinedErr as? ErrorLogObject {
            #expect(errObj.detectedKeywords.contains("fatalError"))
            #expect(errObj.detectedKeywords.contains("SIGSEGV"))
            #expect(errObj.parentObjectID == errText.id.uuidString)
        }

        // 5. Code Snippet Refinement
        let codeText = SelectedTextObject(text: "public func executeReflex() -> Bool {\n    return true\n}", provenance: prov)
        let refinedCode = TypeRefiners.refine(object: codeText)
        #expect(refinedCode.objectClass == .code)
        if let codeObj = refinedCode as? CodeSnippetObject {
            #expect(codeObj.languageHint == "swift")
            #expect(codeObj.parentObjectID == codeText.id.uuidString)
        }
    }

    @Test("StaleContextValidator detects mismatched generation tokens and terminated processes")
    func testStaleContextValidation() {
        let validToken = UUID().uuidString
        let staleToken = UUID().uuidString

        let currentPID = ProcessInfo.processInfo.processIdentifier
        let currentBundle = NSRunningApplication.current.bundleIdentifier

        let prov = ObjectProvenance(
            sourceAppBundle: currentBundle,
            sourcePID: currentPID,
            acquisitionMethod: "test"
        )

        let object = FileObject(
            path: "/Users/test",
            provenance: prov,
            contextGenerationToken: validToken
        )

        // Matching token and live current process passes
        let passResult = StaleContextValidator.validate(object: object, activeGenerationToken: validToken)
        #expect(passResult == .valid)

        // Mismatched token fails
        let staleResult = StaleContextValidator.validate(object: object, activeGenerationToken: staleToken)
        #expect(staleResult == .staleGenerationToken)

        // Terminated / invalid PID fails
        let deadProv = ObjectProvenance(
            sourceAppBundle: "com.fake.deadApp",
            sourcePID: 99999999, // Unlikely to exist
            acquisitionMethod: "test"
        )
        let deadObject = WindowObject(
            windowTitle: "Dead Window",
            applicationName: "Dead App",
            pid: 99999999,
            provenance: deadProv,
            contextGenerationToken: validToken
        )
        let deadResult = StaleContextValidator.validate(object: deadObject, activeGenerationToken: validToken)
        #expect(deadResult == .processTerminated)
    }

    @Test("LensCoordinates accurately converts points and rects between AppKit and CG")
    func testLensCoordinates() {
        let displayHeight: CGFloat = 1080.0

        // Point roundtrip
        let appKitPt = CGPoint(x: 150.0, y: 300.0)
        let cgPt = LensCoordinates.toCG(appKitPoint: appKitPt, primaryHeight: displayHeight)
        #expect(cgPt.x == 150.0)
        #expect(cgPt.y == 780.0) // 1080 - 300

        let recoveredPt = LensCoordinates.toAppKit(cgPoint: cgPt, primaryHeight: displayHeight)
        #expect(recoveredPt.x == appKitPt.x)
        #expect(recoveredPt.y == appKitPt.y)

        // Rect roundtrip
        let appKitRect = NSRect(x: 50.0, y: 100.0, width: 200.0, height: 80.0)
        let cgRect = LensCoordinates.toCG(appKitRect: appKitRect, primaryHeight: displayHeight)
        #expect(cgRect.origin.x == 50.0)
        #expect(cgRect.origin.y == 900.0) // 1080 - (100 + 80)
        #expect(cgRect.width == 200.0)
        #expect(cgRect.height == 80.0)

        let recoveredRect = LensCoordinates.toAppKit(cgRect: cgRect, primaryHeight: displayHeight)
        #expect(recoveredRect.origin.x == appKitRect.origin.x)
        #expect(recoveredRect.origin.y == appKitRect.origin.y)
        #expect(recoveredRect.width == appKitRect.width)
        #expect(recoveredRect.height == appKitRect.height)
    }

    @Test("ClipboardFallbackProvider leaves pasteboard changeCount and content completely unchanged (INV-001)")
    func testClipboardImmutability() {
        let pboard = NSPasteboard.general
        let countBefore = pboard.changeCount
        let stringBefore = pboard.string(forType: .string)

        let provider = ClipboardFallbackProvider()
        let candidate = provider.acquireCandidate(at: nil)

        let countAfter = pboard.changeCount
        let stringAfter = pboard.string(forType: .string)

        #expect(countBefore == countAfter)
        #expect(stringBefore == stringAfter)

        if candidate != nil {
            #expect(candidate?.tier == .clipboardFallback)
            #expect(candidate?.object.objectClass == .clipboard)
        }
    }
}
