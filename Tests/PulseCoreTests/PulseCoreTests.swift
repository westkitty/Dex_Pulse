import Testing
import Foundation
@testable import PulseCore

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
        let run = sm.startRun()
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
        sm.startRun()
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
        sm.startRun()
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

    @Test("Cancellation from every transient state strictly converges to QUIET (INV-007)")
    func cancellationConvergenceAcrossAllTransientStates() {
        let transientStates: [PulseState] = [
            .pulse, .lens, .veil, .attune, .strand, .fork,
            .dispatch, .weave, .returnState, .witness, .resolve,
            .fray, .sever
        ]

        for state in transientStates {
            let sm = PulseStateMachine()
            _ = sm.startRun()
            transitionToState(sm, target: state)
            #expect(sm.currentState == state)

            let finalState = sm.cancel()
            #expect(finalState == .quiet)
            #expect(sm.currentState == .quiet)
            #expect(sm.currentState.isResting)
            #expect(sm.currentRun?.outcome == .cancelled)
        }
    }

    @Test("Explicit PulseRun tracking and generation token identity")
    func explicitRunModel() {
        let sm = PulseStateMachine()
        let token = "generation-token-alpha"
        let envelope = PulseContextEnvelope(generationToken: token)

        let run = sm.startRun(envelope: envelope)
        #expect(run.generationToken == token)
        #expect(sm.activeGenerationToken == token)
        #expect(run.state == .pulse)
        #expect(run.outcome == nil)
        #expect(sm.currentRun?.runID == run.runID)

        sm.cancel()
        #expect(sm.activeGenerationToken == nil)
        #expect(sm.currentRun?.outcome == .cancelled)
    }

    @Test("Stale completion callbacks are rejected deterministically (INV-008)")
    func staleCompletionRejection() throws {
        let sm = PulseStateMachine()
        let run = sm.startRun()
        let realToken = run.generationToken

        // 1. Mismatched run ID
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(
                runID: UUID(),
                generationToken: realToken,
                outcome: .succeeded
            )
        }

        // 2. Mismatched generation token
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(
                runID: run.runID,
                generationToken: "mismatched-token-fake",
                outcome: .succeeded
            )
        }

        // 3. Callback after cancel()
        sm.cancel()
        #expect(throws: PulseStateMachineError.self) {
            try sm.recordCompletion(
                runID: run.runID,
                generationToken: realToken,
                outcome: .succeeded
            )
        }
    }

    @Test("Result hold pauses recede while inspectable and releases cleanly")
    func resultHoldSemantics() throws {
        let sm = PulseStateMachine()
        let run = sm.startRun()
        try sm.transition(to: .lens)
        try sm.transition(to: .veil)
        try sm.transition(to: .dispatch)
        try sm.transition(to: .witness)
        try sm.transition(to: .resolve)

        let result = PulseResultObject(
            runID: run.runID,
            sourceObjectID: UUID(),
            sourceObjectClass: .code,
            capabilityID: "git.inspect_status",
            executorID: "local.executor",
            outcome: .succeeded,
            summary: "Git status: clean working tree",
            isHeld: true,
            provenance: ObjectProvenance(acquisitionMethod: "unit-test"),
            privacyClass: .ordinary
        )

        try sm.holdResult(result)
        #expect(sm.isResultHeld)
        #expect(sm.heldResult?.summary == "Git status: clean working tree")
        #expect(sm.heldResult?.isHeld == true)

        sm.releaseResultHold()
        #expect(!sm.isResultHeld)
        #expect(sm.heldResult == nil)

        sm.cancel()
        #expect(sm.currentState == .quiet)
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
