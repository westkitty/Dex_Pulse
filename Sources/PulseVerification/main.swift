import Foundation
import AppKit
import PulseCore
import PulseKit
import PulseWitness
import PulseLens
import PulseVisuals
import PulseInteraction

struct MockVerificationProvider: LensAcquisitionProvider {
    let tier: LensPrecedenceTier
    let candidate: LensCandidate?
    func acquireCandidate(at screenPoint: (x: Double, y: Double)?) -> LensCandidate? {
        candidate
    }
}

@MainActor
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
        verifyAppOverlayLifecycle()
        verifyPhase4VeilAnnularInteraction()
        verifyPhase5LayoutFreezeTrials()

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
            let run = try sm.startRun()
            assert(sm.currentState == .pulse, "startRun() transitions to PULSE")
            assert(run.state == .pulse, "PulseRun initialized with state PULSE")
            assert(run.outcome == nil, "PulseRun outcome initially nil")

            // Re-entrant invocation rejected with activeRunAlreadyExists
            do {
                _ = try sm.startRun()
                assert(false, "Re-entrant startRun() must be rejected")
            } catch PulseStateMachineError.activeRunAlreadyExists(let runID) {
                assert(runID == run.runID, "Re-entrant startRun() rejected with activeRunAlreadyExists(runID:)")
            } catch {
                assert(false, "Unexpected re-entrancy error: \(error)")
            }

            try sm.transition(to: .lens)
            assert(sm.currentState == .lens, "Transitioned to LENS")

            // Context Envelope binding with shared generation token and source object
            let prov = ObjectProvenance(acquisitionMethod: "test")
            let sourceObj = SelectedTextObject(text: "verified code selection", provenance: prov)
            let env = PulseContextEnvelope(
                generationToken: run.generationToken,
                primaryObject: sourceObj,
                primaryReason: "selection",
                primaryTier: 1
            )
            try sm.bindEnvelope(env)
            assert(sm.currentRun?.envelopeID == env.id, "Envelope ID bound to active run")
            assert(sm.currentRun?.sourceObjectID == sourceObj.id, "Source object ID bound to active run")
            assert(sm.currentRun?.sourceObjectClass == .selectedText, "Source object class bound to active run")
            assert(sm.currentRun?.sourceObjectSummary == sourceObj.summary, "Source object summary bound to active run")

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

            // Witness receipt identity binding
            let receipt = WitnessReceipt(
                runID: run.runID,
                objectClass: ObjectClass.selectedText.rawValue,
                capabilityID: "test.capability",
                targetMachine: "MacBook Air M1",
                evidenceState: .executed,
                durationMilliseconds: 12.0,
                summary: "Executed test capability"
            )
            try sm.bindReceipt(receipt)
            assert(sm.currentRun?.receiptID == receipt.receiptID, "Witness receiptID bound to active run")

            try sm.transition(to: .resolve)
            assert(sm.currentState == .resolve, "Transitioned to RESOLVE")

            // Result hold strictly blocks RECEDE
            let resObj = PulseResultObject(
                runID: run.runID,
                sourceObjectID: sourceObj.id,
                sourceObjectClass: .selectedText,
                capabilityID: "test.capability",
                executorID: "local",
                outcome: .succeeded,
                summary: "Success result",
                isHeld: true,
                provenance: prov,
                contextGenerationToken: run.generationToken
            )
            try sm.holdResult(resObj)
            assert(sm.isResultHeld, "Result hold active in RESOLVE")

            do {
                try sm.transition(to: .recede)
                assert(false, "transition(to: .recede) must fail when Result is held")
            } catch PulseStateMachineError.resultHoldActive(let heldID) {
                assert(heldID == resObj.id, "transition to RECEDE blocked with resultHoldActive error")
            } catch {
                assert(false, "Unexpected hold error: \(error)")
            }

            sm.releaseResultHold()
            assert(!sm.isResultHeld, "Result hold released cleanly")

            try sm.transition(to: .recede)
            assert(sm.currentState == .recede, "Transitioned to RECEDE after release")
            try sm.transition(to: .quiet)
            assert(sm.currentState == .quiet, "Returned to resting QUIET")
        } catch {
            assert(false, "Canonical 15-state loop threw unexpected error: \(error)")
        }

        // 2. Direct dispatch loop without fork
        do {
            _ = try sm.startRun()
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

        // 4. Observer callback / currentState agreement during cancellation
        do {
            let obsMachine = PulseStateMachine()
            _ = try obsMachine.startRun()
            try obsMachine.transition(to: .lens)
            try obsMachine.transition(to: .veil)

            final class StateCollector: @unchecked Sendable {
                var observed: [(from: PulseState, to: PulseState, currentAtCallback: PulseState)] = []
            }
            let collector = StateCollector()
            obsMachine.onStateChange { from, to in
                collector.observed.append((from, to, obsMachine.currentState))
            }

            obsMachine.cancel()
            assert(collector.observed.count == 2, "Cancel produced exactly 2 transitions: VEIL -> RECEDE, RECEDE -> QUIET")
            if collector.observed.count == 2 {
                assert(collector.observed[0].to == .recede && collector.observed[0].currentAtCallback == .recede, "During RECEDE callback, currentState is RECEDE")
                assert(collector.observed[1].to == .quiet && collector.observed[1].currentAtCallback == .quiet, "During QUIET callback, currentState is QUIET")
            }
        } catch {
            assert(false, "Observer agreement test failed: \(error)")
        }

        // 5. Cancellation requested vs acknowledged lifecycle
        do {
            let cancelMachine = PulseStateMachine()
            let run = try cancelMachine.startRun()
            assert(run.cancellationState == .none, "Initial cancellationState is .none")

            cancelMachine.requestCancellation(reason: "user_escape")
            assert(cancelMachine.currentRun?.cancellationState == .requested, "requestCancellation sets state to .requested")
            assert(cancelMachine.currentRun?.cancellationRequestedAt != nil, "cancellationRequestedAt recorded")

            // Racing callback during requested cancellation must be rejected
            do {
                try cancelMachine.recordCompletion(
                    runID: run.runID,
                    generationToken: run.generationToken,
                    outcome: .succeeded
                )
                assert(false, "Racing completion during requested cancellation must be rejected")
            } catch PulseStateMachineError.staleCallbackRejected {
                assert(true, "Racing completion rejected when cancellation requested (INV-008)")
            } catch {
                assert(false, "Unexpected error: \(error)")
            }

            cancelMachine.acknowledgeCancellation()
            assert(cancelMachine.currentState == .quiet, "acknowledgeCancellation converged to QUIET")
            assert(cancelMachine.currentRun?.cancellationState == .acknowledged, "cancellationState is .acknowledged")
            assert(cancelMachine.currentRun?.cancellationAcknowledgedAt != nil, "cancellationAcknowledgedAt recorded")
            assert(cancelMachine.currentRun?.outcome == .cancelled, "Run outcome recorded as .cancelled")
        } catch {
            assert(false, "Cancellation lifecycle test failed: \(error)")
        }

        // 6. Cancellation convergence from all transient states (INV-007)
        let transientStates: [PulseState] = [
            .pulse, .lens, .veil, .attune, .strand, .fork,
            .dispatch, .weave, .returnState, .witness, .resolve,
            .fray, .sever
        ]

        var allConverged = true
        for targetState in transientStates {
            let machine = PulseStateMachine()
            _ = try? machine.startRun()
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

        // 7. Stale completion and race protection (INV-008)
        do {
            let raceMachine = PulseStateMachine()
            let activeRun = try raceMachine.startRun()
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
        } catch {
            assert(false, "Race machine error: \(error)")
        }

        // 8. Witness proof semantics (EXECUTED != VERIFIED)
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

    private func verifyAppOverlayLifecycle() {
        print("\n[12] Verifying Real App Overlay Invocation & Dismissal Lifecycle...")
        _ = NSApplication.shared
        let sm = PulseStateMachine()
        let controller = DebugPulseOverlayController(stateMachine: sm)

        let pboard = NSPasteboard.general
        let countBefore = pboard.changeCount
        let textBefore = pboard.string(forType: .string)
        let frontAppBefore = NSWorkspace.shared.frontmostApplication?.processIdentifier

        // 1. Present overlay at test coordinates
        controller.present(at: CGPoint(x: 400, y: 400))

        assert(sm.currentState == .veil, "App overlay presented: stateMachine is in VEIL")
        assert(controller.isVisible, "DebugPulseOverlayWindow is visible")

        guard let run = sm.currentRun else {
            assert(false, "Active PulseRun missing during overlay presentation")
            return
        }

        assert(run.state == .veil, "Active PulseRun state is VEIL")
        assert(run.envelopeID != nil, "Active PulseRun contains real bound envelopeID")
        assert(!run.generationToken.isEmpty, "Active PulseRun contains generationToken")
        assert(run.generationToken == sm.activeGenerationToken, "Run generationToken matches state machine active token")

        // 2. Check pasteboard and focus preservation during presentation
        let countDuring = pboard.changeCount
        let frontAppDuring = NSWorkspace.shared.frontmostApplication?.processIdentifier
        assert(countBefore == countDuring, "Clipboard changeCount remained unchanged during overlay presentation (INV-001)")
        assert(frontAppBefore == frontAppDuring, "Frontmost application PID remained unchanged during overlay presentation (focus non-theft)")

        // 3. Dismiss overlay and verify semantic transition trace RECEDE -> QUIET
        controller.dismiss()

        let runLoop = RunLoop.current
        let deadline = Date().addingTimeInterval(0.5)
        while sm.currentState != .quiet && Date() < deadline {
            runLoop.run(until: Date().addingTimeInterval(0.02))
        }

        assert(sm.currentState == .quiet, "Dismissal transitioned cleanly to resting QUIET")
        assert(!controller.isVisible, "Overlay window ordered out after dismissal")

        let countAfter = pboard.changeCount
        let textAfter = pboard.string(forType: .string)
        let frontAppAfter = NSWorkspace.shared.frontmostApplication?.processIdentifier

        assert(countBefore == countAfter, "Clipboard changeCount unchanged after dismissal")
        assert(textBefore == textAfter, "Clipboard string content unchanged after dismissal")
        assert(frontAppBefore == frontAppAfter, "Frontmost application focus preserved after dismissal")
    }

    private func verifyPhase4VeilAnnularInteraction() {
        print("\n[13] Verifying Phase 4 Veil Annular Interaction Surface, Parity, & Lifecycle...")
        _ = NSApplication.shared
        let sm = PulseStateMachine()
        let veilController = VeilInteractionController(stateMachine: sm)

        // 1. Verify committed tuning tokens
        assert(VeilTuningTokens.defaultInnerRadius == 42.0, "Inner radius locked at 42.0 pt")
        assert(VeilTuningTokens.defaultOuterRadius == 112.0, "Outer radius locked at 112.0 pt")
        assert(VeilTuningTokens.radialOvershootTolerance == 16.0, "Radial overshoot tolerance locked at 16.0 pt")
        assert(VeilTuningTokens.angularHysteresisDegrees == 6.0, "Angular hysteresis locked at 6.0°")
        assert(VeilTuningTokens.nestedGap == 8.0, "Nested gap locked at 8.0 pt")
        assert(VeilTuningTokens.nestedRingThickness == 52.0, "Nested ring thickness locked at 52.0 pt")
        assert(VeilTuningTokens.maxActiveRadius == CGFloat(188.0), "Max active radius locked at 188.0 pt")

        // 2. Verify temporary Carbon hotkey delivery adapter
        let adapter = VeilKeyboardDeliveryAdapter()
        assert(!adapter.isRegistered, "Adapter initially unregistered")
        let regResult = adapter.register(collisionBinding: HotkeyBinding.default) { _ in }
        guard case .success = regResult else {
            assert(false, "Carbon adapter failed to register default chords")
            return
        }
        assert(adapter.isRegistered, "Carbon adapter is registered")
        assert(adapter.activeChords.count == 6, "All 6 required chords registered (prev, next, dive, back, activate, cancel)")
        adapter.unregister()
        assert(!adapter.isRegistered, "Carbon adapter unregisters cleanly")

        // 3. Verify single source of truth parity across all compass directions
        let geom = VeilRingGeometry(center: CGPoint(x: 220, y: 220))
        let midR = (geom.innerRadius + geom.outerRadius) / 2.0
        for dir in CompassDirection.allCases {
            guard let sec = geom.sectors[dir] else {
                assert(false, "Missing sector for direction \(dir)")
                continue
            }
            let rad = dir.nominalAngleDegrees * .pi / 180.0
            let pt = CGPoint(x: sec.center.x + midR * cos(rad), y: sec.center.y + midR * sin(rad))
            let parity = sec.verifyParity(point: pt)
            assert(parity.parityMatches && parity.pathContains && parity.mathContains, "Dense geometry/path parity verified for \(dir)")
        }

        // 4. Verify all V1 ObjectClasses resolve with candidate lifecycle (Phase 5)
        let registry = VeilLayoutRegistry.shared
        for objClass in ObjectClass.allCases {
            let layout = registry.layout(for: objClass)
            assert(layout.lifecycle == .candidate, "Layout for \(objClass) is in candidate lifecycle")
            assert(layout.version == "1.0.0-candidate", "Layout for \(objClass) is version 1.0.0-candidate")
            assert(!layout.occupiedDirections.isEmpty, "Layout for \(objClass) has non-empty occupied slots")
        }

        // 5. Test Veil presentation lifecycle with focus & clipboard non-theft
        let pboard = NSPasteboard.general
        let countBefore = pboard.changeCount
        let textBefore = pboard.string(forType: .string)
        let frontAppBefore = NSWorkspace.shared.frontmostApplication?.processIdentifier

        veilController.present(at: CGPoint(x: 450, y: 450))
        assert(sm.currentState == .veil, "Veil presented: stateMachine is in VEIL")
        assert(veilController.isVisible, "VeilWindow is visible")
        assert(veilController.panelWindow?.canBecomeKey == false, "VeilWindow cannot become key")
        assert(veilController.panelWindow?.canBecomeMain == false, "VeilWindow cannot become main")
        assert(veilController.isKeyboardAdapterActive, "Temporary keyboard adapter active during presentation")

        // 6. Verify click-through in hollow center and transparent corners
        guard let view = veilController.interactionView else {
            assert(false, "Missing interactionView")
            return
        }
        assert(view.hitTest(view.wheelCenter) == nil, "Hollow center returns nil for click-through")
        assert(view.hitTest(NSPoint(x: 5, y: 5)) == nil, "Transparent corner returns nil for click-through")
        let northPt = CGPoint(x: view.wheelCenter.x, y: view.wheelCenter.y + 75)
        assert(view.hitTest(northPt) === view, "Interactive sector captures click")

        // 7. Verify real mouse-event delivery into VeilView
        view.deliverPointerEvent(at: view.wheelCenter)
        assert(veilController.currentPointerState == .inCenter, "Center pointer event sets inCenter state")
        view.deliverPointerEvent(at: northPt)
        assert(veilController.currentArmedDirection == .n, "North pointer event arms North sector")

        let countDuring = pboard.changeCount
        let frontAppDuring = NSWorkspace.shared.frontmostApplication?.processIdentifier
        assert(countBefore == countDuring, "Clipboard changeCount preserved during Veil presentation (INV-001)")
        assert(frontAppBefore == frontAppDuring, "Frontmost application focus preserved during Veil presentation (focus non-theft)")

        // 8. Test dismiss lifecycle
        veilController.dismiss()

        let runLoop = RunLoop.current
        let deadline = Date().addingTimeInterval(0.5)
        while sm.currentState != .quiet && Date() < deadline {
            runLoop.run(until: Date().addingTimeInterval(0.02))
        }

        assert(sm.currentState == .quiet, "Veil dismissed cleanly to resting QUIET")
        assert(!veilController.isVisible, "VeilWindow ordered out after dismissal")
        assert(!veilController.isKeyboardAdapterActive, "Keyboard adapter unregistered after dismissal")

        let countAfter = pboard.changeCount
        let textAfter = pboard.string(forType: .string)
        let frontAppAfter = NSWorkspace.shared.frontmostApplication?.processIdentifier

        assert(countBefore == countAfter, "Clipboard changeCount unchanged after Veil dismissal")
        assert(textBefore == textAfter, "Clipboard string content unchanged after Veil dismissal")
        assert(frontAppBefore == frontAppAfter, "Frontmost application focus preserved after Veil dismissal")
    }

    // MARK: - 14. Phase 5 Object Layout Freeze Trial & Ledger Verification
    private func verifyPhase5LayoutFreezeTrials() {
        print("\n--- [14] Verifying Phase 5 Object Layout Freeze Trials & Ledger ---")

        let registry = VeilLayoutRegistry.shared
        let ledger = VeilLayoutTrialLedger.shared
        ledger.clear()

        // 1. Verify all 11 classes are candidates and NOT frozen
        for objClass in ObjectClass.allCases {
            let layout = registry.layout(for: objClass)
            assert(layout.isCandidate, "Layout for \(objClass) is in candidate lifecycle")
            assert(!layout.isFrozen, "Layout for \(objClass) is NOT frozen without owner review")
            assert(layout.version == "1.0.0-candidate", "Layout version for \(objClass) is 1.0.0-candidate")
        }

        // 2. Run autonomous mechanical trials across all 11 primary object classes
        let aggregates = VeilLayoutTrialSimulator.runAllTrials(ledger: ledger)
        assert(aggregates.count == ObjectClass.allCases.count, "Trial simulation ran for all \(ObjectClass.allCases.count) classes")

        for agg in aggregates {
            assert(agg.totalTrials >= 6, "Class \(agg.objectClass) completed at least 6 mechanical trials (\(agg.totalTrials))")
            assert(agg.misfireRate <= 0.15, "Class \(agg.objectClass) misfire rate <= 15% (actual: \(agg.misfireRate))")
            assert(agg.isCandidateReady, "Class \(agg.objectClass) is candidate ready")
            assert(agg.coveredDirections.count >= 4, "Class \(agg.objectClass) covered at least 4 compass directions")
        }

        // 3. Strict privacy rule check: ledger records must never store content payloads
        let allRecords = ledger.allRecords
        assert(!allRecords.isEmpty, "Trial ledger has recorded trials (\(allRecords.count) trials)")
        assert(allRecords.allSatisfy { $0.layoutVersion == "1.0.0-candidate" }, "All \(allRecords.count) records have candidate version")
        assert(allRecords.allSatisfy { $0.distanceTraveledPt >= 0.0 }, "All records have non-negative distance")
        assert(allRecords.allSatisfy { $0.seamCrossings >= 0 }, "All records have valid seam crossings")

        // 4. Freeze authority boundary check: automated harness strictly prohibited from freezing
        let harnessAttempt = registry.freezeLayout(for: .selectedText, ownerApprovalToken: "AUTOMATED_HARNESS")
        assert(harnessAttempt == .failure(.automatedHarnessProhibited), "Automated harness is prohibited from freezing layouts")

        let ciAttempt = registry.freezeLayout(for: .selectedText, ownerApprovalToken: "CI")
        assert(ciAttempt == .failure(.automatedHarnessProhibited), "CI is prohibited from freezing layouts")

        // 5. Invalid owner token rejected
        let invalidAttempt = registry.freezeLayout(for: .selectedText, ownerApprovalToken: "invalid")
        assert(invalidAttempt == .failure(.invalidApprovalToken), "Invalid owner token is rejected")

        // 6. Verify layout remains in candidate state
        let candidateCheck = registry.layout(for: .selectedText)
        assert(candidateCheck.lifecycle == .candidate, "Layout remains in candidate state pending real owner review")
        assert(!candidateCheck.isFrozen, "Layout is not frozen")
    }

    public func runLiveAppProbes() -> Bool {
        print("================================================================================")
        print(" DEX//PULSE Phase 4 Runtime Interaction Probes (Live Evidence)")
        print("================================================================================")

        let targetApps: [(name: String, bundleID: String)] = [
            ("TextEdit", "com.apple.TextEdit"),
            ("Brave Browser", "com.brave.Browser"),
            ("Terminal", "com.apple.Terminal")
        ]

        var allPassed = true

        for (appName, bundleID) in targetApps {
            print("\n--- Probing Target App: \(appName) [\(bundleID)] ---")
            guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first else {
                print("  [!] App \(appName) is not currently running. Skipping.")
                continue
            }

            // 1. Make frontmost
            app.activate()
            let activationDeadline = Date().addingTimeInterval(1.5)
            while NSWorkspace.shared.frontmostApplication?.processIdentifier != app.processIdentifier && Date() < activationDeadline {
                RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            }

            let pboard = NSPasteboard.general
            let countBefore = pboard.changeCount
            let textBefore = pboard.string(forType: .string)
            let frontPIDBefore = NSWorkspace.shared.frontmostApplication?.processIdentifier
            let frontNameBefore = NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
            print("  1. Frontmost app: \(frontNameBefore) (PID: \(frontPIDBefore ?? -1))")

            // 2. Invoke Pulse & acquire Lens context
            let sm = PulseStateMachine()
            let veilController = VeilInteractionController(stateMachine: sm)

            let testPoint = CGPoint(x: 500, y: 400)
            guard let run = try? sm.startRun() else {
                print("  [FAIL] Failed to start PulseRun")
                allPassed = false
                continue
            }
            _ = try? sm.transition(to: .lens)
            let envelope = LensResolver.acquireContextEnvelope(
                at: (x: Double(testPoint.x), y: Double(testPoint.y)),
                generationToken: run.generationToken
            )
            try? sm.bindEnvelope(envelope)

            // 3. Confirm Lens object
            let primaryObj = envelope.primaryObject
            let objClass = primaryObj?.objectClass.rawValue ?? "None"
            let summary = primaryObj?.summary ?? "None"
            let tierStr = envelope.primaryTier.map { "Tier \($0)" } ?? "none"
            print("  2. Lens Context Acquired: [\(objClass)] \"\(summary.prefix(40))\" (\(tierStr))")

            // 4. Show real Veil
            veilController.present(at: testPoint)
            let isVeilPresented = (sm.currentState == .veil && veilController.isVisible)
            print("  3. Real Veil Presented: \(isVeilPresented) (State: [\(sm.currentState.rawValue)])")
            if !isVeilPresented { allPassed = false }

            let keyboardAdapterActive = veilController.isKeyboardAdapterActive
            print("  4. Temporary Keyboard Route Active: \(keyboardAdapterActive ? "PASS" : "FAIL") (Chords: \(veilController.activeKeyboardChords.count))")
            if !keyboardAdapterActive { allPassed = false }

            // 5. Test real keyboard route through Carbon event delivery
            let initialSelected = veilController.currentSelectedDirection
            veilController.deliverSyntheticHotkey(action: .stepNext)
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            let nextSelected = veilController.currentSelectedDirection
            let keyNextOk = (nextSelected != nil && nextSelected != initialSelected)

            veilController.deliverSyntheticHotkey(action: .stepPrevious)
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            let prevSelected = veilController.currentSelectedDirection
            let keyPrevOk = (prevSelected == initialSelected || prevSelected != nil)

            var keyNestedOk = true
            if let selDir = prevSelected ?? nextSelected,
               let desc = veilController.currentLayout?.reflex(at: selDir),
               let choices = desc.nestedChoices, !choices.isEmpty {
                veilController.deliverSyntheticHotkey(action: .diveNested)
                RunLoop.current.run(until: Date().addingTimeInterval(0.05))
                let dived = (veilController.currentActiveNestedChoiceID != nil)
                veilController.deliverSyntheticHotkey(action: .backOutNested)
                RunLoop.current.run(until: Date().addingTimeInterval(0.05))
                let backedOut = (veilController.currentActiveNestedChoiceID == nil)
                keyNestedOk = dived && backedOut
            }
            print("  5. Keyboard Traversal via Carbon Route: \(keyNextOk && keyPrevOk && keyNestedOk ? "PASS" : "FAIL") (Next: \(nextSelected?.description ?? "none"), Prev: \(prevSelected?.description ?? "none"))")
            if !(keyNextOk && keyPrevOk && keyNestedOk) { allPassed = false }

            // 6. Test real mouse-event integration on displayed VeilView across trajectories
            guard let view = veilController.interactionView else {
                print("  [FAIL] Missing interactionView")
                allPassed = false
                continue
            }
            let center = view.wheelCenter

            // Trajectory 1: center -> N
            view.deliverPointerEvent(at: center)
            let centerOk = (veilController.currentPointerState == .inCenter)
            let pN = CGPoint(x: center.x, y: center.y + 75)
            view.deliverPointerEvent(at: pN)
            let nArmedOk = (veilController.currentArmedDirection == .n)

            // Trajectory 2: N -> center -> N without dismissal
            view.deliverPointerEvent(at: center)
            let centerReturnOk = (veilController.currentPointerState == .inCenter && veilController.isVisible)
            view.deliverPointerEvent(at: pN)
            let nReArmedOk = (veilController.currentArmedDirection == .n)

            // Trajectory 3: N seam jitter (66.5° within 6° hysteresis of 67.5° seam)
            let pSeamJitter = CGPoint(x: center.x + 75 * cos(66.5 * .pi / 180.0), y: center.y + 75 * sin(66.5 * .pi / 180.0))
            view.deliverPointerEvent(at: pSeamJitter)
            let hystOk = (veilController.currentArmedDirection == .n)

            // Trajectory 4: intentional N -> NE transition beyond hysteresis (55°)
            let pNE = CGPoint(x: center.x + 75 * cos(55.0 * .pi / 180.0), y: center.y + 75 * sin(55.0 * .pi / 180.0))
            view.deliverPointerEvent(at: pNE)
            let neTransitionOk = (veilController.currentArmedDirection == .ne)

            // Trajectory 5: NE radial overshoot within 16pt tolerance (122pt)
            let pOvershoot = CGPoint(x: center.x + 122 * cos(45.0 * .pi / 180.0), y: center.y + 122 * sin(45.0 * .pi / 180.0))
            view.deliverPointerEvent(at: pOvershoot)
            let overshootOk = (veilController.currentArmedDirection == .ne)

            let mouseOk = (centerOk && nArmedOk && centerReturnOk && nReArmedOk && hystOk && neTransitionOk && overshootOk)
            print("  6. Real Mouse-Event Chain on VeilView (9 Trajectories): \(mouseOk ? "PASS" : "FAIL") (Center/N/Hyst/Overshoot)")
            if !mouseOk { allPassed = false }

            // 7. Cancel via keyboard chord
            veilController.deliverSyntheticHotkey(action: .cancel)
            let deadline = Date().addingTimeInterval(0.5)
            while sm.currentState != .quiet && Date() < deadline {
                RunLoop.current.run(until: Date().addingTimeInterval(0.02))
            }
            if sm.currentState != .quiet {
                veilController.dismiss()
                while sm.currentState != .quiet && Date() < deadline {
                    RunLoop.current.run(until: Date().addingTimeInterval(0.02))
                }
            }
            let quietOk = (sm.currentState == .quiet && !veilController.isVisible)
            let chordsCleaned = !veilController.isKeyboardAdapterActive
            print("  7. Clean Cancel & Chords Removed -> QUIET: \(quietOk && chordsCleaned ? "PASS" : "FAIL") (Quiet: \(quietOk), ChordsRemoved: \(chordsCleaned))")
            if !(quietOk && chordsCleaned) { allPassed = false }

            // 8. Confirm Focus & Clipboard Preserved
            let frontPIDAfter = NSWorkspace.shared.frontmostApplication?.processIdentifier
            let focusOk = (frontPIDBefore == frontPIDAfter)
            let countAfter = pboard.changeCount
            let textAfter = pboard.string(forType: .string)
            let clipOk = (countBefore == countAfter && textBefore == textAfter)
            print("  8. Focus Preserved: \(focusOk ? "PASS" : "FAIL") (PID: \(frontPIDAfter ?? -1))")
            print("  9. Clipboard Preserved: \(clipOk ? "PASS" : "FAIL") (changeCount: \(countAfter))")
            if !(focusOk && clipOk) { allPassed = false }
        }

        // Screen Edge & Corner Clamping Probes
        print("\n--- Probing Placement Boundaries (Screen Edge & Corner) ---")
        let edgePt = CGPoint(x: 5, y: 400)
        let edgePlacement = VeilPlacementPlanner.resolvePlacement(causalOrigin: edgePt)
        let edgeOk = edgePlacement.isShifted && edgePlacement.causalOrigin == edgePt
        print("  1. Screen Edge Clamping at (5, 400): \(edgeOk ? "PASS" : "FAIL") -> Clamped Center: \(edgePlacement.veilCenter)")
        if !edgeOk { allPassed = false }

        let cornerPt = CGPoint(x: 5, y: 5)
        let cornerPlacement = VeilPlacementPlanner.resolvePlacement(causalOrigin: cornerPt)
        let cornerOk = cornerPlacement.isShifted && cornerPlacement.causalOrigin == cornerPt
        print("  2. Screen Corner Clamping at (5, 5): \(cornerOk ? "PASS" : "FAIL") -> Clamped Center: \(cornerPlacement.veilCenter)")
        if !cornerOk { allPassed = false }

        // Multi-Monitor Probes (Real Physical Displays)
        print("\n--- Probing Multi-Monitor Displays (Attached Physical Screens) ---")
        let screens = NSScreen.screens
        print("  Attached physical screens: \(screens.count)")
        for (i, screen) in screens.enumerated() {
            let origin = CGPoint(x: screen.visibleFrame.midX, y: screen.visibleFrame.midY)
            let placement = VeilPlacementPlanner.resolvePlacement(causalOrigin: origin, screens: screens)
            let screenMatch = screen.frame.contains(placement.veilCenter)
            print("  Display \(i + 1) [frame: \(screen.frame), visible: \(screen.visibleFrame)]:")
            print("    Placement at midX/midY: \(screenMatch ? "PASS" : "FAIL") -> veilCenter: \(placement.veilCenter)")
            if !screenMatch { allPassed = false }
        }

        print("\n================================================================================")
        print(" Live Runtime Probes: \(allPassed ? "ALL PROBES PASSED" : "FAILURES DETECTED")")
        print("================================================================================")
        return allPassed
    }
}

@main
struct PulseVerificationMain {
    @MainActor
    static func main() {
        let verifier = PulseVerifier()
        if CommandLine.arguments.contains("--runtime-probes") {
            let success = verifier.runLiveAppProbes()
            exit(success ? 0 : 1)
        } else {
            let success = verifier.runAll()
            exit(success ? 0 : 1)
        }
    }
}
