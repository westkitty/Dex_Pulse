import Testing
import Foundation
@testable import PulseCore
import PulseWitness

@Suite("PulseCore Tests — Phase 3 Semantic State Machine")
struct PulseCoreTests {

    @Test("Initial state is QUIET and resting")
    func stateMachineInitialStateIsQuiet() {
        let sm = PulseStateMachine()
        #expect(sm.currentState == .quiet)
        #expect(sm.currentState.isResting)
        #expect(!sm.currentState.isTransient)
    }

    @Test("Canonical 15-state forward loop succeeds")
    func canonicalForwardLoop() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        #expect(sm.currentState == .pulse)
        #expect(run.state == .pulse)
        #expect(run.outcome == nil)

        try sm.transition(to: .lens)
        #expect(sm.currentState == .lens)

        try sm.transition(to: .veil)
        #expect(sm.currentState == .veil)

        try sm.transition(to: .attune)
        #expect(sm.currentState == .attune)

        try sm.transition(to: .strand)
        #expect(sm.currentState == .strand)

        try sm.transition(to: .fork)
        #expect(sm.currentState == .fork)

        try sm.transition(to: .dispatch)
        #expect(sm.currentState == .dispatch)

        try sm.transition(to: .weave)
        #expect(sm.currentState == .weave)

        try sm.transition(to: .returnState)
        #expect(sm.currentState == .returnState)

        try sm.transition(to: .witness)
        #expect(sm.currentState == .witness)

        try sm.transition(to: .resolve)
        #expect(sm.currentState == .resolve)

        try sm.transition(to: .recede)
        #expect(sm.currentState == .recede)

        try sm.transition(to: .quiet)
        #expect(sm.currentState == .quiet)
        #expect(sm.currentState.isResting)
    }

    @Test("Direct dispatch without fork is permitted")
    func directDispatchPath() throws {
        let sm = PulseStateMachine()
        try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .attune)
        try sm.transition(to: .strand)
        try sm.transition(to: .dispatch)
        #expect(sm.currentState == .dispatch)
        sm.cancel()
        #expect(sm.currentState == .quiet)
    }

    @Test("Fray recovery and escalation paths")
    func frayAndSeverTransitions() throws {
        let sm = PulseStateMachine()
        try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)

        // Enter recoverable fray
        try sm.transition(to: .fray)
        #expect(sm.currentState == .fray)

        // Retry back to veil
        try sm.transition(to: .veil)
        #expect(sm.currentState == .veil)

        // Re-enter fray and escalate to sever
        try sm.transition(to: .fray)
        try sm.transition(to: .sever)
        #expect(sm.currentState == .sever)

        try sm.transition(to: .recede)
        try sm.transition(to: .quiet)
        #expect(sm.currentState == .quiet)
    }

    @Test("Invalid transitions throw PulseStateMachineError")
    func invalidTransitionsThrow() {
        let sm = PulseStateMachine()
        #expect(throws: PulseStateMachineError.self) {
            try sm.transition(to: .veil)
        }
        #expect(throws: PulseStateMachineError.self) {
            try sm.transition(to: .dispatch)
        }
        #expect(throws: PulseStateMachineError.self) {
            try sm.transition(to: .strand)
        }
        #expect(throws: PulseStateMachineError.self) {
            try sm.transition(to: .resolve)
        }
    }

    @Test("Re-entrant invocation is rejected with activeRunAlreadyExists")
    func reentrantInvocationRejection() throws {
        let sm = PulseStateMachine()
        let runA = try sm.startRun()
        #expect(sm.currentState == .pulse)

        #expect(throws: PulseStateMachineError.self) {
            try sm.startRun()
        }

        do {
            _ = try sm.startRun()
            #expect(Bool(false), "Must throw activeRunAlreadyExists")
        } catch PulseStateMachineError.activeRunAlreadyExists(let existingID) {
            #expect(existingID == runA.runID)
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }

        sm.cancel()
        #expect(sm.currentState == .quiet)

        // Once quiet, starting a new run succeeds cleanly
        let runB = try sm.startRun()
        #expect(runB.runID != runA.runID)
        sm.cancel()
    }

    @Test("Run, Envelope, and Source Object identity binding")
    func runEnvelopeIdentityBinding() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)

        let prov = ObjectProvenance(acquisitionMethod: "unit-test")
        let sourceObj = SelectedTextObject(text: "func execute()", provenance: prov)
        let env = PulseContextEnvelope(
            generationToken: run.generationToken,
            primaryObject: sourceObj,
            primaryReason: "explicit selection",
            primaryTier: 1
        )

        try sm.bindEnvelope(env)
        #expect(sm.currentRun?.envelopeID == env.id)
        #expect(sm.currentRun?.sourceObjectID == sourceObj.id)
        #expect(sm.currentRun?.sourceObjectClass == .selectedText)
        #expect(sm.currentRun?.sourceObjectSummary == sourceObj.summary)
        #expect(sm.currentRun?.generationToken == run.generationToken)

        sm.cancel()
    }

    @Test("Result hold genuinely blocks RECEDE until released")
    func resultHoldBlocksRecede() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .dispatch)
        try sm.transition(to: .witness)
        try sm.transition(to: .resolve)

        let result = PulseResultObject(
            runID: run.runID,
            sourceObjectID: UUID(),
            sourceObjectClass: .code,
            capabilityID: "test.inspect",
            executorID: "local",
            outcome: .succeeded,
            summary: "Verified output",
            isHeld: true,
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: run.generationToken
        )

        try sm.holdResult(result)
        #expect(sm.isResultHeld)

        // Attempting to transition to RECEDE while held MUST throw resultHoldActive
        #expect(throws: PulseStateMachineError.self) {
            try sm.transition(to: .recede)
        }

        do {
            try sm.transition(to: .recede)
            #expect(Bool(false), "Must not allow recede while held")
        } catch PulseStateMachineError.resultHoldActive(let heldID) {
            #expect(heldID == result.id)
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }

        // Release hold, then recede succeeds
        sm.releaseResultHold()
        #expect(!sm.isResultHeld)
        try sm.transition(to: .recede)
        #expect(sm.currentState == .recede)
        try sm.transition(to: .quiet)
        #expect(sm.currentState == .quiet)
    }

    @Test("Observer callbacks observe actual synchronous current states")
    func observerCallbackCurrentStateAgreement() throws {
        let sm = PulseStateMachine()
        _ = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)

        final class StateCollector: @unchecked Sendable {
            var observed: [(from: PulseState, to: PulseState, stateAtCallback: PulseState)] = []
        }
        let collector = StateCollector()
        sm.onStateChange { from, to in
            collector.observed.append((from, to, sm.currentState))
        }

        sm.cancel()

        #expect(collector.observed.count == 2)
        if collector.observed.count == 2 {
            #expect(collector.observed[0].from == .veil)
            #expect(collector.observed[0].to == .recede)
            #expect(collector.observed[0].stateAtCallback == .recede)

            #expect(collector.observed[1].from == .recede)
            #expect(collector.observed[1].to == .quiet)
            #expect(collector.observed[1].stateAtCallback == .quiet)
        }
    }

    @Test("Cancellation requested vs acknowledged lifecycle states")
    func cancellationRequestedVsAcknowledged() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        #expect(run.cancellationState == .none)

        sm.requestCancellation(reason: "user_escape")
        #expect(sm.currentRun?.cancellationState == .requested)
        #expect(sm.currentRun?.cancellationRequestedAt != nil)

        // Racing callback while requested is rejected
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(
                runID: run.runID,
                generationToken: run.generationToken,
                outcome: .succeeded
            )
        }

        sm.acknowledgeCancellation()
        #expect(sm.currentState == .quiet)
        #expect(sm.currentRun?.cancellationState == .acknowledged)
        #expect(sm.currentRun?.cancellationAcknowledgedAt != nil)
        #expect(sm.currentRun?.outcome == .cancelled)
    }

    @Test("Cancellation from every transient state strictly converges to QUIET (INV-007)")
    func cancellationConvergenceAcrossAllTransientStates() {
        let transientStates: [PulseState] = [
            .pulse, .lens, .veil, .attune, .strand, .fork,
            .dispatch, .weave, .returnState, .witness, .resolve,
            .fray, .sever
        ]

        for state in transientStates {
            let sm = PulseStateMachine()
            _ = try? sm.startRun()
            transitionToState(sm, target: state)
            #expect(sm.currentState == state)

            let finalState = sm.cancel()
            #expect(finalState == .quiet)
            #expect(sm.currentState == .quiet)
            #expect(sm.currentState.isResting)
            #expect(sm.currentRun?.outcome == .cancelled)
        }
    }

    // MARK: - 8 Terminal Outcome Lifecycle Tests

    @Test("Terminal Outcome: Succeeded full lifecycle")
    func terminalOutcomeSucceeded() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)

        let prov = ObjectProvenance(acquisitionMethod: "unit-test")
        let sourceObj = SelectedTextObject(text: "target text", provenance: prov)
        let env = PulseContextEnvelope(generationToken: run.generationToken, primaryObject: sourceObj)
        try sm.bindEnvelope(env)

        try sm.transition(to: .veil)
        try sm.transition(to: .attune)
        try sm.transition(to: .strand)
        try sm.transition(to: .dispatch)
        try sm.transition(to: .weave)
        try sm.transition(to: .returnState)
        try sm.transition(to: .witness)

        let receipt = WitnessReceipt(
            runID: run.runID,
            objectClass: "SelectedTextObject",
            capabilityID: "test.echo",
            targetMachine: "local",
            evidenceState: .executed,
            durationMilliseconds: 10.0,
            summary: "Executed echo"
        )
        try sm.bindReceipt(receipt)
        #expect(sm.currentRun?.receiptID == receipt.receiptID)
        #expect(receipt.isExecutedOnly)
        #expect(!receipt.isVerified)

        try sm.transition(to: .resolve)

        let result = PulseResultObject(
            runID: run.runID,
            sourceObjectID: sourceObj.id,
            sourceObjectClass: sourceObj.objectClass,
            capabilityID: "test.echo",
            executorID: "local",
            outcome: .succeeded,
            summary: "Echo succeeded",
            isHeld: false,
            provenance: prov,
            contextGenerationToken: run.generationToken
        )
        try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded, result: result)
        #expect(sm.currentRun?.outcome == .succeeded)
        #expect(sm.currentRun?.resultID == result.id)

        try sm.transition(to: .recede)
        try sm.transition(to: .quiet)
        #expect(sm.currentState == .quiet)

        // Late callback rejected
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)
        }
    }

    @Test("Terminal Outcome: Cancelled lifecycle")
    func terminalOutcomeCancelled() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        sm.requestCancellation(reason: "user_dismiss")
        #expect(sm.currentRun?.cancellationState == .requested)

        // Racing callback rejected
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)
        }

        sm.acknowledgeCancellation()
        #expect(sm.currentState == .quiet)
        #expect(sm.currentRun?.outcome == .cancelled)

        // Subsequent callback rejected
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)
        }
    }

    @Test("Terminal Outcome: Blocked lifecycle (policy block before dispatch)")
    func terminalOutcomeBlocked() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)

        // Security/policy block occurs
        try sm.transition(to: .sever)
        #expect(sm.currentState == .sever)

        let result = PulseResultObject(
            runID: run.runID,
            sourceObjectID: UUID(),
            sourceObjectClass: .file,
            capabilityID: "destructive.operation",
            executorID: "policy",
            outcome: .blocked,
            summary: "Operation blocked by safety policy",
            isHeld: false,
            provenance: ObjectProvenance(acquisitionMethod: "policy"),
            contextGenerationToken: run.generationToken
        )
        try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .blocked, result: result)
        #expect(sm.currentRun?.outcome == .blocked)

        try sm.transition(to: .recede)
        try sm.transition(to: .quiet)
        #expect(sm.currentState == .quiet)

        // Cannot mutate after terminal outcome
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)
        }
    }

    @Test("Terminal Outcome: Unavailable lifecycle (target unreachable)")
    func terminalOutcomeUnavailable() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .sever)

        try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .unavailable)
        #expect(sm.currentRun?.outcome == .unavailable)

        try sm.transition(to: .recede)
        try sm.transition(to: .quiet)
        #expect(sm.currentState == .quiet)
    }

    @Test("Terminal Outcome: TimedOut lifecycle and distinctness from failed")
    func terminalOutcomeTimedOut() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .dispatch)
        try sm.transition(to: .sever)

        try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .timedOut)
        #expect(sm.currentRun?.outcome == .timedOut)
        #expect(sm.currentRun?.outcome != .failed)
        #expect(sm.currentRun?.outcome != .cancelled)

        try sm.transition(to: .recede)
        try sm.transition(to: .quiet)

        // Late success after timeout is strictly rejected
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)
        }
    }

    @Test("Terminal Outcome: Failed lifecycle (no auto-retry)")
    func terminalOutcomeFailed() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .dispatch)
        try sm.transition(to: .sever)

        try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .failed)
        #expect(sm.currentRun?.outcome == .failed)

        try sm.transition(to: .recede)
        try sm.transition(to: .quiet)
        #expect(sm.currentState == .quiet)
    }

    @Test("Terminal Outcome: Interrupted lifecycle")
    func terminalOutcomeInterrupted() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .sever)

        try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .interrupted)
        #expect(sm.currentRun?.outcome == .interrupted)

        try sm.transition(to: .recede)
        try sm.transition(to: .quiet)
    }

    @Test("Terminal Outcome: Unknown lifecycle")
    func terminalOutcomeUnknown() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .sever)

        try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .unknown)
        #expect(sm.currentRun?.outcome == .unknown)

        try sm.transition(to: .recede)
        try sm.transition(to: .quiet)
    }

    // MARK: - 9 Stale / Race / Cross-Run Scenarios

    @Test("Stale 1: Run A cancelled, then late success arrives")
    func staleScenario1CancelledRunLateCallback() throws {
        let sm = PulseStateMachine()
        let runA = try sm.startRun()
        try sm.transition(to: .lens)
        sm.cancel()

        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: runA.runID, generationToken: runA.generationToken, outcome: .succeeded)
        }
    }

    @Test("Stale 2: Run A completes, Run B begins, completion for A arrives")
    func staleScenario2CrossRunCompletion() throws {
        let sm = PulseStateMachine()
        let runA = try sm.startRun()
        try sm.transition(to: .lens)
        sm.cancel()

        let runB = try sm.startRun()
        try sm.transition(to: .lens)

        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: runA.runID, generationToken: runA.generationToken, outcome: .succeeded)
        }
        #expect(sm.currentRun?.runID == runB.runID)
        sm.cancel()
    }

    @Test("Stale 3: Duplicate completion for the same run")
    func staleScenario3DuplicateCompletion() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .dispatch)
        try sm.transition(to: .weave)
        try sm.transition(to: .returnState)
        try sm.transition(to: .witness)
        try sm.transition(to: .resolve)

        try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)

        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)
        }
        sm.cancel()
    }

    @Test("Stale 4: Completion while run is in RECEDE")
    func staleScenario4CompletionDuringRecede() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .recede)

        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)
        }
        sm.cancel()
    }

    @Test("Stale 5: Context envelope from old generation bound to new run")
    func staleScenario5StaleEnvelopeBinding() throws {
        let sm = PulseStateMachine()
        _ = try sm.startRun()
        try sm.transition(to: .lens)

        let staleEnv = PulseContextEnvelope(generationToken: "stale-generation-token")
        #expect(throws: PulseStateMachineError.self) {
            try sm.bindEnvelope(staleEnv)
        }
        sm.cancel()
    }

    @Test("Stale 6: Receipt from wrong run rejected")
    func staleScenario6WrongRunReceipt() throws {
        let sm = PulseStateMachine()
        _ = try sm.startRun()
        try sm.transition(to: .lens)

        let wrongReceipt = WitnessReceipt(
            runID: UUID(), // Wrong run
            objectClass: "CodeObject",
            capabilityID: "test.echo",
            targetMachine: "local",
            evidenceState: .executed,
            durationMilliseconds: 1.0,
            summary: "Wrong run receipt"
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.bindReceipt(wrongReceipt)
        }
        sm.cancel()
    }

    @Test("Stale 7: Result from wrong run rejected")
    func staleScenario7WrongRunResult() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .dispatch)
        try sm.transition(to: .weave)
        try sm.transition(to: .returnState)
        try sm.transition(to: .witness)
        try sm.transition(to: .resolve)

        let wrongResult = PulseResultObject(
            runID: UUID(), // Wrong run
            sourceObjectID: UUID(),
            sourceObjectClass: .code,
            capabilityID: "test.echo",
            executorID: "local",
            outcome: .succeeded,
            summary: "Wrong run result",
            isHeld: false,
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: run.generationToken
        )

        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded, result: wrongResult)
        }
        sm.cancel()
    }

    @Test("Stale 8: Cancellation requested, success races before acknowledgment")
    func staleScenario8CancellationRequestedRacingCallback() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)

        sm.requestCancellation(reason: "race_test")
        #expect(sm.currentRun?.cancellationState == .requested)

        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)
        }
        sm.acknowledgeCancellation()
        #expect(sm.currentState == .quiet)
    }

    @Test("Stale 9: Timeout occurs, then success callback arrives")
    func staleScenario9TimeoutLateCallback() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .dispatch)
        try sm.transition(to: .sever)

        try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .timedOut)
        try sm.transition(to: .recede)
        try sm.transition(to: .quiet)

        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)
        }
    }

    // MARK: - Stage A Identity, Lifecycle & Termination Hardening Tests

    @Test("Unified Result validation: recordCompletion rejects all 4 mismatch types")
    func unifiedResultValidationRecordCompletionRejectsMismatches() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)

        let sourceID = UUID()
        let primaryObj = SelectedTextObject(
            id: sourceID,
            text: "let x = 1",
            provenance: ObjectProvenance(acquisitionMethod: "test")
        )
        let env = PulseContextEnvelope(generationToken: run.generationToken, primaryObject: primaryObj)
        try sm.bindEnvelope(env)

        try sm.transition(to: .veil)
        try sm.transition(to: .attune)
        try sm.transition(to: .strand)
        try sm.transition(to: .dispatch)
        try sm.transition(to: .weave)
        try sm.transition(to: .returnState)
        try sm.transition(to: .witness)
        try sm.transition(to: .resolve)

        // 1. Cross-run (wrong runID)
        let wrongRunResult = PulseResultObject(
            runID: UUID(),
            sourceObjectID: sourceID,
            sourceObjectClass: .selectedText,
            capabilityID: "test.cap",
            executorID: "local",
            outcome: .succeeded,
            summary: "summary",
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: run.generationToken
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded, result: wrongRunResult)
        }

        // 2. Cross-source (wrong sourceObjectID)
        let wrongSourceResult = PulseResultObject(
            runID: run.runID,
            sourceObjectID: UUID(),
            sourceObjectClass: .selectedText,
            capabilityID: "test.cap",
            executorID: "local",
            outcome: .succeeded,
            summary: "summary",
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: run.generationToken
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded, result: wrongSourceResult)
        }

        // 3. Wrong sourceObjectClass
        let wrongClassResult = PulseResultObject(
            runID: run.runID,
            sourceObjectID: sourceID,
            sourceObjectClass: .code,
            capabilityID: "test.cap",
            executorID: "local",
            outcome: .succeeded,
            summary: "summary",
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: run.generationToken
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded, result: wrongClassResult)
        }

        // 4a. Stale token
        let staleTokenResult = PulseResultObject(
            runID: run.runID,
            sourceObjectID: sourceID,
            sourceObjectClass: .selectedText,
            capabilityID: "test.cap",
            executorID: "local",
            outcome: .succeeded,
            summary: "summary",
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: "stale-token-1234"
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded, result: staleTokenResult)
        }

        // 4b. Missing token (nil)
        let missingTokenResult = PulseResultObject(
            runID: run.runID,
            sourceObjectID: sourceID,
            sourceObjectClass: .selectedText,
            capabilityID: "test.cap",
            executorID: "local",
            outcome: .succeeded,
            summary: "summary",
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: nil
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded, result: missingTokenResult)
        }

        sm.cancel()
    }

    @Test("Unified Result validation: holdResult rejects all 4 mismatch types")
    func unifiedResultValidationHoldResultRejectsMismatches() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)

        let sourceID = UUID()
        let primaryObj = SelectedTextObject(
            id: sourceID,
            text: "let x = 1",
            provenance: ObjectProvenance(acquisitionMethod: "test")
        )
        let env = PulseContextEnvelope(generationToken: run.generationToken, primaryObject: primaryObj)
        try sm.bindEnvelope(env)
        try sm.transition(to: .veil)

        // 1. Cross-run
        let wrongRunResult = PulseResultObject(
            runID: UUID(),
            sourceObjectID: sourceID,
            sourceObjectClass: .selectedText,
            capabilityID: "test.cap",
            executorID: "local",
            outcome: .succeeded,
            summary: "summary",
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: run.generationToken
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.holdResult(wrongRunResult)
        }

        // 2. Cross-source
        let wrongSourceResult = PulseResultObject(
            runID: run.runID,
            sourceObjectID: UUID(),
            sourceObjectClass: .selectedText,
            capabilityID: "test.cap",
            executorID: "local",
            outcome: .succeeded,
            summary: "summary",
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: run.generationToken
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.holdResult(wrongSourceResult)
        }

        // 3. Wrong sourceObjectClass
        let wrongClassResult = PulseResultObject(
            runID: run.runID,
            sourceObjectID: sourceID,
            sourceObjectClass: .code,
            capabilityID: "test.cap",
            executorID: "local",
            outcome: .succeeded,
            summary: "summary",
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: run.generationToken
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.holdResult(wrongClassResult)
        }

        // 4a. Stale token
        let staleTokenResult = PulseResultObject(
            runID: run.runID,
            sourceObjectID: sourceID,
            sourceObjectClass: .selectedText,
            capabilityID: "test.cap",
            executorID: "local",
            outcome: .succeeded,
            summary: "summary",
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: "wrong-token"
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.holdResult(staleTokenResult)
        }

        // 4b. Missing token (nil)
        let missingTokenResult = PulseResultObject(
            runID: run.runID,
            sourceObjectID: sourceID,
            sourceObjectClass: .selectedText,
            capabilityID: "test.cap",
            executorID: "local",
            outcome: .succeeded,
            summary: "summary",
            provenance: ObjectProvenance(acquisitionMethod: "test"),
            contextGenerationToken: nil
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.holdResult(missingTokenResult)
        }

        sm.cancel()
    }

    @Test("Envelope binding lifetime: rejects binding after completion, recession, or non-acquisition states")
    func envelopeBindingLifetimeRestrictions() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        let validEnv = PulseContextEnvelope(generationToken: run.generationToken)

        // Binding in PULSE is permitted
        #expect(throws: Never.self) {
            try sm.bindEnvelope(validEnv)
        }

        try sm.transition(to: .lens)
        // Binding in LENS is permitted
        #expect(throws: Never.self) {
            try sm.bindEnvelope(validEnv)
        }

        try sm.transition(to: .veil)
        // Binding in VEIL is rejected (past acquisition phase)
        #expect(throws: PulseStateMachineError.self) {
            try sm.bindEnvelope(validEnv)
        }

        try sm.transition(to: .dispatch)
        // Binding in DISPATCH is rejected
        #expect(throws: PulseStateMachineError.self) {
            try sm.bindEnvelope(validEnv)
        }

        sm.cancel()
        // Binding after cancellation / QUIET is rejected
        #expect(throws: PulseStateMachineError.self) {
            try sm.bindEnvelope(validEnv)
        }
    }

    @Test("Witness metadata binding: validates runID, parentRunID, objectClass, capabilityID, targetID, outcome")
    func witnessMetadataBindingValidation() throws {
        let sm = PulseStateMachine()
        let parentID = UUID()
        let run = try sm.startRun(parentRunID: parentID)
        try sm.transition(to: .lens)

        let sourceID = UUID()
        let primaryObj = SelectedTextObject(
            id: sourceID,
            text: "let a = 0",
            provenance: ObjectProvenance(acquisitionMethod: "test")
        )
        let env = PulseContextEnvelope(generationToken: run.generationToken, primaryObject: primaryObj)
        try sm.bindEnvelope(env)

        try sm.assignCapability(capabilityID: "git.commit", targetID: "macbook")

        // 1. Wrong runID
        let wrongRunReceipt = WitnessReceipt(
            runID: UUID(),
            parentRunID: parentID,
            objectClass: "SelectedTextObject",
            capabilityID: "git.commit",
            targetMachine: "macbook",
            evidenceState: .executed,
            durationMilliseconds: 10.0,
            summary: "ok"
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.bindReceipt(wrongRunReceipt)
        }

        // 2. Wrong parentRunID
        let wrongParentReceipt = WitnessReceipt(
            runID: run.runID,
            parentRunID: UUID(),
            objectClass: "SelectedTextObject",
            capabilityID: "git.commit",
            targetMachine: "macbook",
            evidenceState: .executed,
            durationMilliseconds: 10.0,
            summary: "ok"
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.bindReceipt(wrongParentReceipt)
        }

        // 3. Wrong objectClass
        let wrongClassReceipt = WitnessReceipt(
            runID: run.runID,
            parentRunID: parentID,
            objectClass: "CodeSnippetObject",
            capabilityID: "git.commit",
            targetMachine: "macbook",
            evidenceState: .executed,
            durationMilliseconds: 10.0,
            summary: "ok"
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.bindReceipt(wrongClassReceipt)
        }

        // 4. Wrong capabilityID
        let wrongCapReceipt = WitnessReceipt(
            runID: run.runID,
            parentRunID: parentID,
            objectClass: "SelectedTextObject",
            capabilityID: "ollama.prompt",
            targetMachine: "macbook",
            evidenceState: .executed,
            durationMilliseconds: 10.0,
            summary: "ok"
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.bindReceipt(wrongCapReceipt)
        }

        // 5. Wrong targetID
        let wrongTargetReceipt = WitnessReceipt(
            runID: run.runID,
            parentRunID: parentID,
            objectClass: "SelectedTextObject",
            capabilityID: "git.commit",
            targetMachine: "server-remote",
            evidenceState: .executed,
            durationMilliseconds: 10.0,
            summary: "ok"
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.bindReceipt(wrongTargetReceipt)
        }

        // Complete the run with outcome .succeeded to test outcome validation
        try sm.transition(to: .veil)
        try sm.transition(to: .attune)
        try sm.transition(to: .strand)
        try sm.transition(to: .dispatch)
        try sm.transition(to: .weave)
        try sm.transition(to: .returnState)
        try sm.transition(to: .witness)
        try sm.transition(to: .resolve)
        try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)

        // 6. Wrong outcome (contradicting run's outcome)
        let wrongOutcomeReceipt = WitnessReceipt(
            runID: run.runID,
            parentRunID: parentID,
            objectClass: "SelectedTextObject",
            capabilityID: "git.commit",
            targetMachine: "macbook",
            evidenceState: .executed,
            outcome: .failed,
            durationMilliseconds: 10.0,
            summary: "contradicting outcome"
        )
        #expect(throws: PulseStateMachineError.self) {
            try sm.bindReceipt(wrongOutcomeReceipt)
        }

        // 7. Valid matching receipt
        let validReceipt = WitnessReceipt(
            runID: run.runID,
            parentRunID: parentID,
            objectClass: "SelectedTextObject",
            capabilityID: "git.commit",
            targetMachine: "macbook",
            evidenceState: .executed,
            outcome: .succeeded,
            durationMilliseconds: 10.0,
            summary: "valid receipt"
        )
        #expect(throws: Never.self) {
            try sm.bindReceipt(validReceipt)
        }
        #expect(sm.currentRun?.receiptID == validReceipt.receiptID)

        sm.cancel()
    }

    @Test("Execution-phase cancellation: DISPATCH -> SEVER -> RECEDE -> QUIET with observer synchronization")
    func executionPhaseCancellationThroughSeverFromDispatch() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .attune)
        try sm.transition(to: .strand)
        try sm.transition(to: .dispatch)

        final class TransitionCollector: @unchecked Sendable {
            private let lock = NSLock()
            private var items: [(PulseState, PulseState, PulseState)] = []
            func append(_ item: (PulseState, PulseState, PulseState)) {
                lock.lock()
                items.append(item)
                lock.unlock()
            }
            var all: [(PulseState, PulseState, PulseState)] {
                lock.lock()
                defer { lock.unlock() }
                return items
            }
        }

        let collector = TransitionCollector()
        sm.onStateChange { from, to in
            collector.append((from, to, sm.currentState))
        }

        sm.requestCancellation(reason: "user_cancel_during_dispatch")
        #expect(sm.currentRun?.cancellationState == .requested)
        #expect(sm.currentRun?.cancellationRequestedAt != nil)

        let finalState = sm.acknowledgeCancellation()
        #expect(finalState == .quiet)
        #expect(sm.currentState == .quiet)
        #expect(sm.currentRun?.cancellationState == .acknowledged)
        #expect(sm.currentRun?.cancellationAcknowledgedAt != nil)
        #expect(sm.currentRun?.outcome == .cancelled)

        let observedTransitions = collector.all
        #expect(observedTransitions.count == 3)
        #expect(observedTransitions[0] == (.dispatch, .sever, .sever))
        #expect(observedTransitions[1] == (.sever, .recede, .recede))
        #expect(observedTransitions[2] == (.recede, .quiet, .quiet))

        // Late completion after cancellation is rejected
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)
        }
    }

    @Test("Execution-phase cancellation: WEAVE -> SEVER -> RECEDE -> QUIET with observer synchronization")
    func executionPhaseCancellationThroughSeverFromWeave() throws {
        let sm = PulseStateMachine()
        let run = try sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .attune)
        try sm.transition(to: .strand)
        try sm.transition(to: .dispatch)
        try sm.transition(to: .weave)

        final class TransitionCollector: @unchecked Sendable {
            private let lock = NSLock()
            private var items: [(PulseState, PulseState, PulseState)] = []
            func append(_ item: (PulseState, PulseState, PulseState)) {
                lock.lock()
                items.append(item)
                lock.unlock()
            }
            var all: [(PulseState, PulseState, PulseState)] {
                lock.lock()
                defer { lock.unlock() }
                return items
            }
        }

        let collector = TransitionCollector()
        sm.onStateChange { from, to in
            collector.append((from, to, sm.currentState))
        }

        sm.requestCancellation(reason: "user_cancel_during_weave")
        #expect(sm.currentRun?.cancellationState == .requested)

        let finalState = sm.acknowledgeCancellation()
        #expect(finalState == .quiet)
        #expect(sm.currentState == .quiet)
        #expect(sm.currentRun?.outcome == .cancelled)

        let observedTransitions = collector.all
        #expect(observedTransitions.count == 3)
        #expect(observedTransitions[0] == (.weave, .sever, .sever))
        #expect(observedTransitions[1] == (.sever, .recede, .recede))
        #expect(observedTransitions[2] == (.recede, .quiet, .quiet))

        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(runID: run.runID, generationToken: run.generationToken, outcome: .succeeded)
        }
    }

    // MARK: - Evidence & Configuration Tests

    @Test("Witness structured receipt records proof state and excludes raw sensitive payloads")
    func witnessReceiptExcludesRawSensitivePayloads() {
        let receipt = WitnessReceipt(
            runID: UUID(),
            parentRunID: nil,
            objectClass: ObjectClass.selectedText.rawValue,
            capabilityID: "core.macos.inspect_element",
            targetMachine: "MacBook Air M1",
            evidenceState: .verified,
            durationMilliseconds: 14.5,
            summary: "Inspected UI control with role AXButton"
        )

        #expect(receipt.evidenceState == .verified)
        #expect(receipt.isVerified)
        #expect(!receipt.isExecutedOnly)
        #expect(receipt.targetMachine == "MacBook Air M1")
        #expect(receipt.summary.contains("AXButton"))
    }

    @Test("Terminal outcome classifications are distinct and exhaustive")
    func terminalOutcomeClassifications() {
        let allOutcomes = PulseTerminalOutcome.allCases
        #expect(allOutcomes.count == 8)
        #expect(PulseTerminalOutcome.succeeded.isSuccess)
        #expect(!PulseTerminalOutcome.failed.isSuccess)
        #expect(!PulseTerminalOutcome.timedOut.isSuccess)
        #expect(!PulseTerminalOutcome.cancelled.isSuccess)
        #expect(!PulseTerminalOutcome.blocked.isSuccess)

        #expect(PulseTerminalOutcome.timedOut != PulseTerminalOutcome.failed)
        #expect(PulseTerminalOutcome.blocked != PulseTerminalOutcome.cancelled)
    }

    @Test("Hotkey binding defaults to Shift-Command-Space")
    func hotkeyBindingDefaults() {
        let binding = HotkeyBinding.default
        #expect(binding.keyCode == 49)
        #expect(binding.modifiers.contains(.command))
        #expect(binding.modifiers.contains(.shift))
        #expect(binding.displayString == "⇧⌘Space")
    }

    @Test("PulseConfiguration JSON roundtrip")
    func configurationJSONRoundtrip() throws {
        let config = PulseConfiguration.default
        let data = try config.encode()
        let decoded = PulseConfiguration.decode(from: data)
        #expect(config == decoded)
    }

    // Helper function to step a machine into a target state
    private func transitionToState(_ sm: PulseStateMachine, target: PulseState) {
        switch target {
        case .quiet, .pulse:
            break
        case .lens:
            _ = try? sm.transition(to: .lens)
        case .veil:
            _ = try? sm.transition(to: .lens)
            _ = try? sm.transition(to: .veil)
        case .attune:
            transitionToState(sm, target: .veil)
            _ = try? sm.transition(to: .attune)
        case .strand:
            transitionToState(sm, target: .attune)
            _ = try? sm.transition(to: .strand)
        case .fork:
            transitionToState(sm, target: .strand)
            _ = try? sm.transition(to: .fork)
        case .dispatch:
            transitionToState(sm, target: .strand)
            _ = try? sm.transition(to: .dispatch)
        case .weave:
            transitionToState(sm, target: .dispatch)
            _ = try? sm.transition(to: .weave)
        case .returnState:
            transitionToState(sm, target: .weave)
            _ = try? sm.transition(to: .returnState)
        case .witness:
            transitionToState(sm, target: .returnState)
            _ = try? sm.transition(to: .witness)
        case .resolve:
            transitionToState(sm, target: .witness)
            _ = try? sm.transition(to: .resolve)
        case .recede:
            transitionToState(sm, target: .resolve)
            _ = try? sm.transition(to: .recede)
        case .fray:
            transitionToState(sm, target: .veil)
            _ = try? sm.transition(to: .fray)
        case .sever:
            transitionToState(sm, target: .veil)
            _ = try? sm.transition(to: .sever)
        }
    }
}
