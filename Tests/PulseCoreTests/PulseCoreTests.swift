import Testing
@testable import PulseCore

@Suite("PulseCore Tests")
struct PulseCoreTests {
    @Test("Initial state is QUIET and resting")
    func stateMachineInitialStateIsQuiet() {
        let sm = PulseStateMachine()
        #expect(sm.currentState == .quiet)
        #expect(sm.currentState.isResting)
        #expect(!sm.currentState.isTransient)
    }

    @Test("Valid state transitions sequence")
    func validTransitions() throws {
        let sm = PulseStateMachine()
        try sm.transition(to: .pulse)
        #expect(sm.currentState == .pulse)
        #expect(sm.currentState.isTransient)

        try sm.transition(to: .veil)
        #expect(sm.currentState == .veil)

        try sm.transition(to: .recede)
        #expect(sm.currentState == .recede)

        try sm.transition(to: .quiet)
        #expect(sm.currentState == .quiet)
    }

    @Test("Invalid transition throws error")
    func invalidTransitionThrowsError() {
        let sm = PulseStateMachine()
        #expect(throws: PulseStateMachineError.self) {
            try sm.transition(to: .veil)
        }
    }

    @Test("Cancellation from any state returns to QUIET")
    func cancellationReturnsToQuiet() throws {
        let sm = PulseStateMachine()
        try sm.transition(to: .pulse)
        let finalState = sm.cancel()
        #expect(finalState == .quiet)
        #expect(sm.currentState == .quiet)

        try sm.transition(to: .pulse)
        try sm.transition(to: .veil)
        let finalStateFromVeil = sm.cancel()
        #expect(finalStateFromVeil == .quiet)
        #expect(sm.currentState == .quiet)
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
}
