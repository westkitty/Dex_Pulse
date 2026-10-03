import Foundation
import AppKit
import PulseCore
import PulseKit
import PulseWitness
import PulseLens
import PulseVisuals
struct MockVerificationProvider: LensAcquisitionProvider {
    let tier: LensPrecedenceTier
    let candidate: LensCandidate?
    func acquireCandidate(at screenPoint: (x: Double, y: Double)?) -> LensCandidate? {
        candidate
    }
}

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
        print(" DEX//PULSE Headless Verification Runner (Phase 0/1/2/3)")
        print("================================================================================")

        verifyBuildIdentity()
        verifyStateMachine()
        verifyCentralPolicy()
        verifyConfiguration()
        verifyLensPrecedence()
        verifyLensCoordinates()
        verifyLensAuthorizer()
        verifyLensTypeRefiners()
        verifyLensSecureFieldGuard()
        verifyLensStaleContext()
        verifyLensClipboardImmutability()
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
        print("\n[2] Verifying Semantic State Machine & Lifecycle (Phase 3)...")
        let sm = PulseStateMachine()
        assert(sm.currentState == .quiet, "Initial state is QUIET")

        // 1. Full 15-state canonical primary loop
        do {
            let run = sm.startRun()
            assert(sm.currentState == .pulse, "startRun() transitions to PULSE")
            assert(run.state == .pulse, "PulseRun initialized with state PULSE")
            assert(run.outcome == nil, "PulseRun outcome initially nil")

            try sm.transition(to: .lens)
            assert(sm.currentState == .lens, "Transitioned to LENS")
            try sm.transition(to: .veil)
            assert(sm.currentState == .veil, "Transitioned to VEIL")
            try sm.transition(to: .attune)
            assert(sm.currentState == .attune, "Transitioned to ATTUNE")
            try sm.transition(to: .strand)
            assert(sm.currentState == .strand, "Transitioned to STRAND")
            try sm.transition(to: .fork)
            assert(sm.currentState == .fork, "Transitioned to FORK")
            try sm.transition(to: .dispatch)
            assert(sm.currentState == .dispatch, "Transitioned to DISPATCH")
            try sm.transition(to: .weave)
            assert(sm.currentState == .weave, "Transitioned to WEAVE")
            try sm.transition(to: .returnState)
            assert(sm.currentState == .returnState, "Transitioned to RETURN")
            try sm.transition(to: .witness)
            assert(sm.currentState == .witness, "Transitioned to WITNESS")
            try sm.transition(to: .resolve)
            assert(sm.currentState == .resolve, "Transitioned to RESOLVE")
            try sm.transition(to: .recede)
            assert(sm.currentState == .recede, "Transitioned to RECEDE")
            try sm.transition(to: .quiet)
            assert(sm.currentState == .quiet, "Returned to resting QUIET")
        } catch {
            assert(false, "Canonical 15-state loop threw unexpected error: \(error)")
        }

        // 2. Direct dispatch loop without fork
        do {
            _ = sm.startRun()
            try sm.transition(to: .lens)
            try sm.transition(to: .veil)
            try sm.transition(to: .attune)
            try sm.transition(to: .strand)
            try sm.transition(to: .dispatch)
            assert(sm.currentState == .dispatch, "Direct STRAND -> DISPATCH permitted")
            sm.cancel()
        } catch {
            assert(false, "Direct dispatch loop failed: \(error)")
        }

        // 3. Invalid transitions rejected deterministically
        do {
            try sm.transition(to: .veil)
            assert(false, "Invalid transition QUIET -> VEIL should fail")
        } catch PulseStateMachineError.invalidTransition {
            assert(true, "Invalid transition QUIET -> VEIL rejected deterministically")
        } catch {
            assert(false, "Unexpected error: \(error)")
        }

        do {
            try sm.transition(to: .dispatch)
            assert(false, "Invalid transition QUIET -> DISPATCH should fail")
        } catch PulseStateMachineError.invalidTransition {
            assert(true, "Invalid transition QUIET -> DISPATCH rejected deterministically")
        } catch {
            assert(false, "Unexpected error: \(error)")
        }

        // 4. Cancellation convergence from all transient states (INV-007)
        let transientStates: [PulseState] = [
            .pulse, .lens, .veil, .attune, .strand, .fork,
            .dispatch, .weave, .returnState, .witness, .resolve,
            .fray, .sever
        ]

        var allConverged = true
        for targetState in transientStates {
            let machine = PulseStateMachine()
            _ = machine.startRun()
            // Helper to reach targetState
            reachState(machine, targetState)
            let resultState = machine.cancel()
            if resultState != .quiet || machine.currentState != .quiet {
                allConverged = false
            }
            if machine.currentRun?.outcome != .cancelled {
                allConverged = false
            }
        }
        assert(allConverged, "Cancellation from all \(transientStates.count) transient states strictly converges to QUIET (INV-007)")

        // 5. Stale completion and race protection (INV-008)
        let raceMachine = PulseStateMachine()
        let activeRun = raceMachine.startRun()
        let staleRunID = UUID()
        let activeToken = activeRun.generationToken

        // Stale run ID
        do {
            try raceMachine.recordCompletion(
                runID: staleRunID,
                generationToken: activeToken,
                outcome: .succeeded
            )
            assert(false, "Stale run ID completion must be rejected")
        } catch PulseStateMachineError.staleCallbackRejected {
            assert(true, "Stale run ID rejected with staleCallbackRejected (INV-008)")
        } catch {
            assert(false, "Unexpected error: \(error)")
        }

        // Stale generation token
        do {
            try raceMachine.recordCompletion(
                runID: activeRun.runID,
                generationToken: "stale-generation-token-999",
                outcome: .succeeded
            )
            assert(false, "Stale generation token completion must be rejected")
        } catch PulseStateMachineError.staleCallbackRejected {
            assert(true, "Stale generation token rejected with staleCallbackRejected (INV-008)")
        } catch {
            assert(false, "Unexpected error: \(error)")
        }

        // Late callback after cancel()
        raceMachine.cancel()
        assert(raceMachine.currentState == .quiet, "Cancelled machine is QUIET")
        do {
            try raceMachine.recordCompletion(
                runID: activeRun.runID,
                generationToken: activeToken,
                outcome: .succeeded
            )
            assert(false, "Late callback after cancel must be rejected")
        } catch PulseStateMachineError.staleCallbackRejected {
            assert(true, "Late callback after cancel() rejected without resurrection (INV-008)")
        } catch {
            assert(false, "Unexpected error: \(error)")
        }

        // 6. Result hold semantics (pauses auto-recede while inspectable)
        let holdMachine = PulseStateMachine()
        let holdRun = holdMachine.startRun()
        _ = try? holdMachine.transition(to: .lens)
        _ = try? holdMachine.transition(to: .veil)
        _ = try? holdMachine.transition(to: .dispatch)
        _ = try? holdMachine.transition(to: .witness)
        _ = try? holdMachine.transition(to: .resolve)

        let resultObj = PulseResultObject(
            runID: holdRun.runID,
            sourceObjectID: UUID(),
            sourceObjectClass: .code,
            capabilityID: "test.capability",
            executorID: "local.executor",
            outcome: .succeeded,
            summary: "Result test output",
            isHeld: true,
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            privacyClass: .ordinary
        )

        do {
            try holdMachine.holdResult(resultObj)
            assert(holdMachine.isResultHeld, "Result hold active (pauses auto-recede)")
            assert(holdMachine.heldResult?.summary == "Result test output", "Held result inspectable in memory")
            holdMachine.releaseResultHold()
            assert(!holdMachine.isResultHeld, "Result hold released cleanly")
        } catch {
            assert(false, "Result hold threw error: \(error)")
        }
        holdMachine.cancel()

        // 7. Witness proof semantics (EXECUTED != VERIFIED)
        let execReceipt = WitnessReceipt(
            objectClass: "CodeObject",
            capabilityID: "git.diff",
            targetMachine: "MacBook Air M1",
            evidenceState: .executed,
            outcome: .succeeded,
            durationMilliseconds: 42.0,
            summary: "Executed git diff command"
        )
        assert(execReceipt.isExecutedOnly, "Witness records EXECUTED evidence state")
        assert(!execReceipt.isVerified, "Executed receipt is NOT verified without corroboration")

        let verReceipt = WitnessReceipt(
            objectClass: "CodeObject",
            capabilityID: "git.status",
            targetMachine: "MacBook Air M1",
            evidenceState: .verified,
            outcome: .succeeded,
            durationMilliseconds: 18.0,
            summary: "Verified git status clean"
        )
        assert(verReceipt.isVerified, "Witness records VERIFIED evidence state with corroboration")
    }

    private func reachState(_ machine: PulseStateMachine, _ target: PulseState) {
        switch target {
        case .quiet:
            break
        case .pulse:
            break // already in pulse from startRun
        case .lens:
            _ = try? machine.transition(to: .lens)
        case .veil:
            _ = try? machine.transition(to: .lens)
            _ = try? machine.transition(to: .veil)
        case .attune:
            reachState(machine, .veil)
            _ = try? machine.transition(to: .attune)
        case .strand:
            reachState(machine, .attune)
            _ = try? machine.transition(to: .strand)
        case .fork:
            reachState(machine, .strand)
            _ = try? machine.transition(to: .fork)
        case .dispatch:
            reachState(machine, .strand)
            _ = try? machine.transition(to: .dispatch)
        case .weave:
            reachState(machine, .dispatch)
            _ = try? machine.transition(to: .weave)
        case .returnState:
            reachState(machine, .weave)
            _ = try? machine.transition(to: .returnState)
        case .witness:
            reachState(machine, .returnState)
            _ = try? machine.transition(to: .witness)
        case .resolve:
            reachState(machine, .witness)
            _ = try? machine.transition(to: .resolve)
        case .recede:
            reachState(machine, .resolve)
            _ = try? machine.transition(to: .recede)
        case .fray:
            reachState(machine, .veil)
            _ = try? machine.transition(to: .fray)
        case .sever:
            reachState(machine, .veil)
            _ = try? machine.transition(to: .sever)
        }
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
        let c1 = LensCandidate(tier: .selectedContent, object: SelectedTextObject(text: "Selected text", provenance: prov), acquisitionReason: "selection")
        let c2 = LensCandidate(tier: .pointerUIElement, object: UIElementObject(role: "AXButton", title: "Submit", applicationName: "Demo", provenance: prov), acquisitionReason: "pointer")
        let c3 = LensCandidate(tier: .focusedAXElement, object: FocusedElementObject(role: "AXTextField", title: "Input", applicationName: "Demo", provenance: prov), acquisitionReason: "focus")
        let c4 = LensCandidate(tier: .frontmostAppOrWindow, object: ApplicationObject(applicationName: "Terminal", pid: 100, provenance: prov), acquisitionReason: "frontmost")
        let c5 = LensCandidate(tier: .clipboardFallback, object: ClipboardObject(changeCount: 1, types: [], provenance: prov), acquisitionReason: "clipboard")

        let p1 = LensResolver.resolvePrimary(from: [c5, c4, c3, c2, c1])
        assert(p1?.tier == .selectedContent, "Selected content (tier 1) outranks all other tiers")

        let p2 = LensResolver.resolvePrimary(from: [c5, c4, c3, c2])
        assert(p2?.tier == .pointerUIElement, "Pointer element (tier 2) outranks tiers 3, 4, 5")

        let p3 = LensResolver.resolvePrimary(from: [c5, c4, c3])
        assert(p3?.tier == .focusedAXElement, "Focused element (tier 3) outranks tiers 4, 5")

        let p4 = LensResolver.resolvePrimary(from: [c5, c4])
        assert(p4?.tier == .frontmostAppOrWindow, "Frontmost app/window (tier 4) outranks tier 5")

        let p5 = LensResolver.resolvePrimary(from: [c5])
        assert(p5?.tier == .clipboardFallback, "Clipboard fallback (tier 5) resolves when higher tiers absent")

        // Verify lazy acquisition: Tier 1 candidate present -> Tier 5 clipboard never evaluated
        let mockT1 = MockVerificationProvider(tier: .selectedContent, candidate: c1)
        let mockT5 = MockVerificationProvider(tier: .clipboardFallback, candidate: c5)
        let lazyEnv = LensResolver.acquireContextEnvelope(providers: [mockT1, mockT5])
        assert(lazyEnv.primaryTier == 1, "Lazy acquisition stopped at Tier 1")
        assert(lazyEnv.fallbackObject == nil, "Fallback object is nil when higher tier succeeds alone")
        assert(lazyEnv.evaluatedCandidates.count == 1, "Only Tier 1 candidate retained in envelope when Tier 1 succeeds")
        assert(!lazyEnv.evaluatedCandidates.contains { $0.tierRawValue == 5 }, "Clipboard candidate excluded from envelope when Tier 1 succeeds")
    }

    private func verifyLensCoordinates() {
        print("\n[6] Verifying Lens Coordinate Translation...")
        let height: CGFloat = 1080.0
        let pt = CGPoint(x: 100, y: 200)
        let cgPt = LensCoordinates.toCG(appKitPoint: pt, primaryHeight: height)
        assert(cgPt.x == 100 && cgPt.y == 880, "AppKit point translated to CG correctly (Y inverted)")

        let roundtripPt = LensCoordinates.toAppKit(cgPoint: cgPt, primaryHeight: height)
        assert(roundtripPt.x == pt.x && roundtripPt.y == pt.y, "Coordinate roundtrip is lossless")

        let rect = NSRect(x: 20, y: 50, width: 300, height: 100)
        let cgRect = LensCoordinates.toCG(appKitRect: rect, primaryHeight: height)
        assert(cgRect.origin.y == 930 && cgRect.height == 100, "Rect translation accurately maps origin and bounds")
    }

    private func verifyLensAuthorizer() {
        print("\n[7] Verifying Accessibility Authorizer...")
        let status = AccessibilityAuthorizer.checkStatus()
        assert(status == .authorized || status == .denied, "AccessibilityAuthorizer returns valid non-blocking status: \(status.rawValue)")

        AccessibilityAuthorizer.overrideStatus = .denied
        let deniedEnv = LensResolver.acquireContextEnvelope()
        assert(deniedEnv.accessibilityStatus == "denied", "Injectable authorizer override correctly sets accessibilityStatus to denied")
        assert(deniedEnv.degradationReasons.contains(.accessibilityPermissionDenied), "Envelope records accessibilityPermissionDenied degradation reason")
        AccessibilityAuthorizer.overrideStatus = nil
    }

    private func verifyLensTypeRefiners() {
        print("\n[8] Verifying Lens Type Refiners...")
        let prov = ObjectProvenance(sourceAppBundle: "com.apple.Terminal", sourcePID: 123, acquisitionMethod: "test")
        let urlText = SelectedTextObject(text: "https://example.com/api/v1", provenance: prov)
        let refinedURL = TypeRefiners.refine(object: urlText)
        assert(refinedURL.objectClass == .url, "Refined valid URL text to URLObject")
        assert((refinedURL as? URLObject)?.parentObjectID == urlText.id.uuidString, "Preserved parent provenance ID in URLObject")

        let jsonText = SelectedTextObject(text: "{\"key\": \"val\"}", provenance: prov)
        let refinedJSON = TypeRefiners.refine(object: jsonText)
        assert(refinedJSON.objectClass == .jsonText, "Refined valid JSON text to JSONTextObject")

        let errText = SelectedTextObject(text: "fatalError: unreachable branch\nSIGSEGV (11)", provenance: prov)
        let refinedErr = TypeRefiners.refine(object: errText)
        assert(refinedErr.objectClass == .errorLog, "Refined error markers to ErrorLogObject")
    }

    private func verifyLensSecureFieldGuard() {
        print("\n[9] Verifying Secure Field Privacy Guard (SEC-001)...")
        let prov = ObjectProvenance(acquisitionMethod: "test", axRole: "AXSecureTextField")
        let secureObj = SelectedTextObject(text: "", provenance: prov, privacyClass: .secureBlocked)
        assert(secureObj.privacyClass == .secureBlocked, "Secure field marked as .secureBlocked")

        let refined = TypeRefiners.refine(object: secureObj)
        assert(refined.privacyClass == .secureBlocked, "Refiners never downgrade or mutate .secureBlocked objects")
        assert((refined as? SelectedTextObject)?.text.isEmpty == true, "Secret payload is strictly empty/redacted")
    }

    private func verifyLensStaleContext() {
        print("\n[10] Verifying Stale Context Validation...")
        let tokenA = "token-alpha"
        let tokenB = "token-beta"
        let prov = ObjectProvenance(sourceAppBundle: "com.apple.finder", sourcePID: ProcessInfo.processInfo.processIdentifier, acquisitionMethod: "test")
        let obj = FileObject(path: "/tmp", provenance: prov, contextGenerationToken: tokenA)

        let pass = StaleContextValidator.validate(object: obj, activeGenerationToken: tokenA)
        assert(pass == .valid, "Valid matching generation token accepted")

        let fail = StaleContextValidator.validate(object: obj, activeGenerationToken: tokenB)
        assert(fail == .staleGenerationToken, "Mismatched generation token rejected as stale")
    }

    private func verifyLensClipboardImmutability() {
        print("\n[11] Verifying Clipboard Immutability (INV-001)...")
        let pboard = NSPasteboard.general
        let countBefore = pboard.changeCount
        let provider = ClipboardFallbackProvider()
        _ = provider.acquireCandidate(at: nil)
        let countAfter = pboard.changeCount
        assert(countBefore == countAfter, "Clipboard changeCount remained identical before and after acquisition")
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
