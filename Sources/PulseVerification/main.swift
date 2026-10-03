import Foundation
import PulseCore
import PulseKit
import PulseWitness
import PulseLens
import PulseVisuals

final class PulseVerifier {
    private var passed = 0
    private var failed = 0

    func assert(_ condition: Bool, _ message: String) {
        if condition {
            print("  ✓ PASS: \(message)")
            passed += 1
        } else {
            print("  ✗ FAIL: \(message)")
            failed += 1
        }
    }

    func runAll() -> Bool {
        print("================================================================================")
        print(" DEX//PULSE Phase 0/1 Headless Verification Runner")
        print("================================================================================")

        verifyBuildIdentity()
        verifyStateMachine()
        verifyCentralPolicy()
        verifyConfiguration()
        verifyLensPrecedence()
        verifyVisualThemeTokens()
        verifyVisualFixtures()

        print("================================================================================")
        print(" Summary: \(passed) passed, \(failed) failed")
        print("================================================================================")
        return failed == 0
    }

    private func verifyBuildIdentity() {
        print("\n[1] Verifying Build Identity...")
        assert(BuildIdentity.productName == "DEX//PULSE", "Product name matches DEX//PULSE")
        assert(BuildIdentity.bundleIdentifier == "com.westkitty.dexpulse", "Bundle ID matches")
        assert(!BuildIdentity.version.isEmpty, "Version is non-empty")
    }

    private func verifyStateMachine() {
        print("\n[2] Verifying Semantic State Machine...")
        let sm = PulseStateMachine()
        assert(sm.currentState == .quiet, "Initial state is QUIET")

        // Valid transition quiet -> pulse -> veil
        do {
            try sm.transition(to: .pulse)
            assert(sm.currentState == .pulse, "Transitioned to PULSE")
            try sm.transition(to: .veil)
            assert(sm.currentState == .veil, "Transitioned to VEIL")
            try sm.transition(to: .recede)
            assert(sm.currentState == .recede, "Transitioned to RECEDE")
            try sm.transition(to: .quiet)
            assert(sm.currentState == .quiet, "Returned to QUIET")
        } catch {
            assert(false, "Valid state transitions threw error: \(error)")
        }

        // Invalid transition quiet -> veil directly should throw
        do {
            try sm.transition(to: .veil)
            assert(false, "Invalid transition QUIET -> VEIL should fail")
        } catch PulseStateMachineError.invalidTransition {
            assert(true, "Invalid transition QUIET -> VEIL rejected deterministically")
        } catch {
            assert(false, "Unexpected error: \(error)")
        }

        // Cancellation safety: from PULSE, cancel() must reach QUIET
        _ = try? sm.transition(to: .pulse)
        let stateAfterCancel = sm.cancel()
        assert(stateAfterCancel == .quiet, "cancel() from PULSE returns to QUIET")
        assert(sm.currentState == .quiet, "State machine is resting in QUIET after cancellation")
    }

    private func verifyCentralPolicy() {
        print("\n[3] Verifying Central Policy Invariants (INV-002)...")
        let destructiveCap = CapabilityDescriptor(
            capabilityID: "test.destructive.format",
            displayName: "Dangerous Format",
            acceptedObjectClasses: [.file],
            riskClass: .destructiveFuture
        )

        let safeCap = CapabilityDescriptor(
            capabilityID: "test.safe.inspect",
            displayName: "Safe Inspect",
            acceptedObjectClasses: [.file],
            riskClass: .readOnly
        )

        let dummyFile = FileObject(path: "/tmp/sample.txt", provenance: ObjectProvenance(acquisitionMethod: "test"))

        // Policy MUST block destructive capability
        let destructiveResult = PulsePolicy.validateExecution(capability: destructiveCap, for: dummyFile)
        switch destructiveResult {
        case .failure(.destructiveCapabilityBlocked(let capID)):
            assert(capID == "test.destructive.format", "Central policy rejected destructiveFuture capability before executor entry")
        default:
            assert(false, "Destructive capability was not blocked by central policy")
        }

        // Safe capability should pass
        let safeResult = PulsePolicy.validateExecution(capability: safeCap, for: dummyFile)
        switch safeResult {
        case .success:
            assert(true, "Central policy permitted readOnly capability for matching object")
        case .failure(let err):
            assert(false, "Safe capability rejected unexpectedly: \(err)")
        }

        // Incompatible object class should be rejected
        let dummyText = SelectedTextObject(text: "sample text", provenance: ObjectProvenance(acquisitionMethod: "test"))
        let mismatchResult = PulsePolicy.validateExecution(capability: safeCap, for: dummyText)
        switch mismatchResult {
        case .failure(.unsupportedObjectClass):
            assert(true, "Policy rejected object class mismatch (expected [.file], got .selectedText)")
        default:
            assert(false, "Object class mismatch was not caught by policy")
        }
    }

    private func verifyConfiguration() {
        print("\n[4] Verifying Configuration & Hotkey Defaults...")
        let config = PulseConfiguration.default
        assert(config.hotkey.keyCode == 49, "Default hotkey keycode is 49 (Space)")
        assert(config.hotkey.modifiers.contains(.command), "Default hotkey includes Command")
        assert(config.hotkey.modifiers.contains(.shift), "Default hotkey includes Shift")
        assert(config.hotkey.displayString == "⇧⌘Space", "Display string is ⇧⌘Space")

        // JSON Roundtrip
        do {
            let data = try config.encode()
            let decoded = PulseConfiguration.decode(from: data)
            assert(decoded == config, "PulseConfiguration successfully roundtrips through JSON")
        } catch {
            assert(false, "Configuration encoding threw error: \(error)")
        }
    }

    private func verifyLensPrecedence() {
        print("\n[5] Verifying Lens Precedence Hierarchy (INV-003)...")
        let prov = ObjectProvenance(acquisitionMethod: "test")
        let c1 = LensCandidate(tier: .clipboardFallback, object: ClipboardObject(changeCount: 1, types: [], provenance: prov), acquisitionReason: "clipboard")
        let c2 = LensCandidate(tier: .pointerUIElement, object: UIElementObject(role: "AXButton", title: "Submit", applicationName: "Demo", provenance: prov), acquisitionReason: "pointer")
        let c3 = LensCandidate(tier: .selectedContent, object: SelectedTextObject(text: "Selected text", provenance: prov), acquisitionReason: "selection")

        let primary = LensResolver.resolvePrimary(from: [c1, c2, c3])
        assert(primary?.tier == .selectedContent, "Selected content (tier 1) outranks pointer UI element and clipboard")

        let primaryWithoutSelection = LensResolver.resolvePrimary(from: [c1, c2])
        assert(primaryWithoutSelection?.tier == .pointerUIElement, "Pointer UI element (tier 2) outranks clipboard (tier 5)")
    }

    private func verifyVisualThemeTokens() {
        print("\n[6] Verifying Visual Theme Tokens...")
        assert(PulseVisualsTheme.cornerRadius == 12.0, "Corner radius token verified")
        assert(PulseVisualsTheme.pulsePointDiameter == 16.0, "Pulse point diameter token verified")
    }

    private func verifyVisualFixtures() {
        print("\n[7] Verifying Visual Fixture Manifest & Files...")
        let cwd = FileManager.default.currentDirectoryPath
        let sumsPath = "\(cwd)/fixtures/visual-references/SHA256SUMS.txt"

        if FileManager.default.fileExists(atPath: sumsPath) {
            assert(true, "Visual reference SHA256SUMS.txt exists on disk")
        } else {
            assert(false, "Visual reference SHA256SUMS.txt missing at \(sumsPath)")
        }

        let originals = [
            "grok_video_2026-04-10-03-54-13.mp4",
            "grok_video_2026-04-10-03-59-49.mp4",
            "grok_video_2026-04-10-04-01-42.mp4",
            "grok_video_2026-04-10-04-05-20.mp4"
        ]

        for video in originals {
            let path = "\(cwd)/fixtures/visual-references/original/\(video)"
            let exists = FileManager.default.fileExists(atPath: path)
            assert(exists, "Canonical original video fixture present: \(video)")
        }
    }
}

let verifier = PulseVerifier()
let success = verifier.runAll()
exit(success ? 0 : 1)
