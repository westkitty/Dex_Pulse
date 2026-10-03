import Foundation

public enum PulseStateMachineError: Error, Equatable, CustomStringConvertible {
    case invalidTransition(from: PulseState, to: PulseState)
    case strandedState(PulseState)

    public var description: String {
        switch self {
        case .invalidTransition(let from, let to):
            return "Invalid Pulse state transition from [\(from)] to [\(to)]"
        case .strandedState(let state):
            return "App stranded in non-quiet state [\(state)]"
        }
    }
}

/// Thread-safe semantic state machine for DEX//PULSE.
///
/// Ensures explicit, verifiable transitions and guarantees that cancellation
/// always returns the system to QUIET without leaving stranded transient states.
public final class PulseStateMachine: @unchecked Sendable {
    private let lock = NSLock()
    private var _currentState: PulseState
    private var stateChangeHandlers: [(PulseState, PulseState) -> Void] = []

    public init(initialState: PulseState = .quiet) {
        self._currentState = initialState
    }

    public var currentState: PulseState {
        lock.lock()
        defer { lock.unlock() }
        return _currentState
    }

    /// Subscribes to state changes.
    public func onStateChange(_ handler: @escaping @Sendable (PulseState, PulseState) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        stateChangeHandlers.append(handler)
    }

    /// Explicitly transitions to a new state if valid.
    @discardableResult
    public func transition(to newState: PulseState) throws -> PulseState {
        lock.lock()
        let oldState = _currentState

        guard PulseStateTransition.isValid(from: oldState, to: newState) else {
            lock.unlock()
            throw PulseStateMachineError.invalidTransition(from: oldState, to: newState)
        }

        _currentState = newState
        let handlers = stateChangeHandlers
        lock.unlock()

        for handler in handlers {
            handler(oldState, newState)
        }
        return newState
    }

    /// Cancels any transient interaction and returns cleanly through RECEDE to QUIET.
    @discardableResult
    public func cancel() -> PulseState {
        lock.lock()
        let oldState = _currentState
        if oldState == .quiet {
            lock.unlock()
            return .quiet
        }

        // If not already in recede, transition through recede
        _currentState = .recede
        let handlers = stateChangeHandlers
        lock.unlock()

        for handler in handlers {
            handler(oldState, .recede)
        }

        lock.lock()
        _currentState = .quiet
        let quietHandlers = stateChangeHandlers
        lock.unlock()

        for handler in quietHandlers {
            handler(.recede, .quiet)
        }

        return .quiet
    }

    /// Resets the state machine to QUIET (used during startup/shutdown).
    public func resetToQuiet() {
        lock.lock()
        let oldState = _currentState
        _currentState = .quiet
        let handlers = stateChangeHandlers
        lock.unlock()

        if oldState != .quiet {
            for handler in handlers {
                handler(oldState, .quiet)
            }
        }
    }
}
