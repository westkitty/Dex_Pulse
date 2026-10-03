import Foundation

public enum PulseStateMachineError: Error, Equatable, CustomStringConvertible {
    case invalidTransition(from: PulseState, to: PulseState)
    case strandedState(PulseState)
    case staleCallbackRejected(String)
    case noActiveRun
    case invalidStateForHold(PulseState)

    public var description: String {
        switch self {
        case .invalidTransition(let from, let to):
            return "Invalid Pulse state transition from [\(from)] to [\(to)]"
        case .strandedState(let state):
            return "App stranded in non-quiet state [\(state)]"
        case .staleCallbackRejected(let reason):
            return "Stale completion rejected: \(reason)"
        case .noActiveRun:
            return "No active Pulse execution run"
        case .invalidStateForHold(let state):
            return "Cannot hold result in non-resolved state [\(state)]"
        }
    }
}

/// Thread-safe semantic state machine for DEX//PULSE.
///
/// Ensures explicit, verifiable transitions across all 15 semantic states,
/// manages explicit `PulseRun` lifecycles, enforces stale async completion rejection,
/// supports memory-only Result holds that pause auto-recede, and guarantees that
/// cancellation from any transient state strictly converges to QUIET.
public final class PulseStateMachine: @unchecked Sendable {
    private let lock = NSLock()
    private var _currentState: PulseState
    private var _currentRun: PulseRun?
    private var _activeGenerationToken: String?
    private var _heldResult: PulseResultObject?
    private var stateChangeHandlers: [(PulseState, PulseState) -> Void] = []
    private var runCompletionHandlers: [(PulseRun) -> Void] = []

    public init(initialState: PulseState = .quiet) {
        self._currentState = initialState
        if initialState != .quiet {
            let token = UUID().uuidString
            self._activeGenerationToken = token
            self._currentRun = PulseRun(
                runID: UUID(),
                startTime: Date(),
                generationToken: token,
                state: initialState
            )
        }
    }

    public var currentState: PulseState {
        lock.lock()
        defer { lock.unlock() }
        return _currentState
    }

    public var currentRun: PulseRun? {
        lock.lock()
        defer { lock.unlock() }
        return _currentRun
    }

    public var activeGenerationToken: String? {
        lock.lock()
        defer { lock.unlock() }
        return _activeGenerationToken
    }

    public var isResultHeld: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _heldResult != nil
    }

    public var heldResult: PulseResultObject? {
        lock.lock()
        defer { lock.unlock() }
        return _heldResult
    }

    /// Subscribes to state changes.
    public func onStateChange(_ handler: @escaping @Sendable (PulseState, PulseState) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        stateChangeHandlers.append(handler)
    }

    /// Subscribes to run completion events.
    public func onRunCompletion(_ handler: @escaping @Sendable (PulseRun) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        runCompletionHandlers.append(handler)
    }

    /// Initiates a new explicit execution run from QUIET into PULSE.
    @discardableResult
    public func startRun(
        envelope: PulseContextEnvelope? = nil,
        parentRunID: UUID? = nil
    ) -> PulseRun {
        lock.lock()
        // If an interaction was already active, cancel it cleanly first
        if _currentState != .quiet {
            _cancelInternalLocked()
        }

        let token = envelope?.generationToken ?? UUID().uuidString
        let run = PulseRun(
            runID: UUID(),
            parentRunID: parentRunID,
            startTime: Date(),
            envelopeID: envelope?.id,
            generationToken: token,
            sourceObjectSummary: envelope?.primaryObject?.summary,
            sourceObjectClass: envelope?.primaryObject?.objectClass,
            state: .pulse
        )

        let oldState = _currentState
        _currentState = .pulse
        _currentRun = run
        _activeGenerationToken = token
        _heldResult = nil

        let handlers = stateChangeHandlers
        lock.unlock()

        for handler in handlers {
            handler(oldState, .pulse)
        }

        return run
    }

    /// Explicitly transitions to a new state if permitted by the transition graph.
    @discardableResult
    public func transition(to newState: PulseState) throws -> PulseState {
        lock.lock()
        let oldState = _currentState

        guard PulseStateTransition.isValid(from: oldState, to: newState) else {
            lock.unlock()
            throw PulseStateMachineError.invalidTransition(from: oldState, to: newState)
        }

        _currentState = newState
        _currentRun?.state = newState

        if newState == .quiet {
            _currentRun?.endTime = Date()
            _activeGenerationToken = nil
        }

        let handlers = stateChangeHandlers
        lock.unlock()

        for handler in handlers {
            handler(oldState, newState)
        }
        return newState
    }

    /// Validates whether an incoming async callback belongs to the currently active run and token.
    public func isValidCallback(runID: UUID, generationToken: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard let current = _currentRun,
              current.runID == runID,
              current.generationToken == generationToken,
              _activeGenerationToken == generationToken,
              _currentState != .quiet,
              _currentState != .recede,
              current.outcome == nil else {
            return false
        }
        return true
    }

    /// Records asynchronous completion from an executor, enforcing stale-callback rejection.
    @discardableResult
    public func recordCompletion(
        runID: UUID,
        generationToken: String,
        outcome: PulseTerminalOutcome,
        result: PulseResultObject? = nil
    ) throws -> PulseRun {
        lock.lock()
        guard let current = _currentRun else {
            lock.unlock()
            throw PulseStateMachineError.noActiveRun
        }

        guard current.runID == runID else {
            lock.unlock()
            throw PulseStateMachineError.staleCallbackRejected(
                "Run ID mismatch: expected \(current.runID), received \(runID)"
            )
        }

        guard current.generationToken == generationToken, _activeGenerationToken == generationToken else {
            lock.unlock()
            throw PulseStateMachineError.staleCallbackRejected(
                "Generation token mismatch: expected \(current.generationToken), received \(generationToken)"
            )
        }

        guard _currentState != .quiet && _currentState != .recede && current.outcome == nil else {
            lock.unlock()
            throw PulseStateMachineError.staleCallbackRejected(
                "Run already completed or in terminating state [\(_currentState)]"
            )
        }

        _currentRun?.outcome = outcome
        _currentRun?.endTime = Date()

        if let res = result {
            _currentRun?.resultID = res.id
            if res.isHeld {
                _heldResult = res
            }
        }

        let finalRun = _currentRun!
        let runHandlers = runCompletionHandlers
        lock.unlock()

        for handler in runHandlers {
            handler(finalRun)
        }

        return finalRun
    }

    /// Holds the active Result Object to pause automatic recede during user inspection.
    public func holdResult(_ result: PulseResultObject) throws {
        lock.lock()
        guard _currentState == .resolve || _currentState == .veil || _currentState == .witness else {
            lock.unlock()
            throw PulseStateMachineError.invalidStateForHold(_currentState)
        }
        var held = result
        held.isHeld = true
        _heldResult = held
        _currentRun?.resultID = held.id
        lock.unlock()
    }

    /// Releases the active Result hold, enabling auto-recede to proceed.
    public func releaseResultHold() {
        lock.lock()
        _heldResult = nil
        lock.unlock()
    }

    /// Cancels any transient interaction and guarantees clean convergence through RECEDE to QUIET.
    @discardableResult
    public func cancel(reason: String? = nil) -> PulseState {
        lock.lock()
        let oldState = _currentState
        if oldState == .quiet {
            lock.unlock()
            return .quiet
        }

        _cancelInternalLocked()
        let handlers = stateChangeHandlers
        lock.unlock()

        // Notify transition to RECEDE
        for handler in handlers {
            handler(oldState, .recede)
        }

        // Notify transition to QUIET
        for handler in handlers {
            handler(.recede, .quiet)
        }

        return .quiet
    }

    /// Internal locked implementation of cancellation convergence.
    private func _cancelInternalLocked() {
        if _currentRun != nil && _currentRun?.outcome == nil {
            _currentRun?.outcome = .cancelled
            _currentRun?.endTime = Date()
        }
        _currentRun?.state = .quiet
        _activeGenerationToken = nil
        _heldResult = nil
        _currentState = .quiet
    }

    /// Resets the state machine unconditionally to QUIET (used during startup/shutdown).
    public func resetToQuiet() {
        lock.lock()
        let oldState = _currentState
        _cancelInternalLocked()
        let handlers = stateChangeHandlers
        lock.unlock()

        if oldState != .quiet {
            for handler in handlers {
                handler(oldState, .quiet)
            }
        }
    }
}
