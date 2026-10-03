import Foundation

public enum PulseStateMachineError: Error, Equatable, CustomStringConvertible {
    case invalidTransition(from: PulseState, to: PulseState)
    case strandedState(PulseState)
    case staleCallbackRejected(String)
    case noActiveRun
    case invalidStateForHold(PulseState)
    case activeRunAlreadyExists(runID: UUID)
    case resultHoldActive(resultID: UUID)

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
        case .activeRunAlreadyExists(let runID):
            return "Active run already exists [\(runID)]"
        case .resultHoldActive(let resultID):
            return "Cannot transition to RECEDE while result hold is active [\(resultID)]"
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
    ///
    /// Re-entrant invocation is rejected with `PulseStateMachineError.activeRunAlreadyExists`.
    @discardableResult
    public func startRun(
        envelope: PulseContextEnvelope? = nil,
        parentRunID: UUID? = nil
    ) throws -> PulseRun {
        lock.lock()
        // Enforce: Re-entrant invocation in startRun() rejects with typed error activeRunAlreadyExists
        if _currentState != .quiet || (_currentRun != nil && !_currentRun!.isCompleted) {
            let activeID = _currentRun?.runID ?? UUID()
            lock.unlock()
            throw PulseStateMachineError.activeRunAlreadyExists(runID: activeID)
        }

        let token = envelope?.generationToken ?? UUID().uuidString
        let run = PulseRun(
            runID: UUID(),
            parentRunID: parentRunID,
            startTime: Date(),
            envelopeID: envelope?.id,
            generationToken: token,
            sourceObjectID: envelope?.primaryObject?.id,
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

    /// Binds a context envelope to the active run, verifying generation token and recording source object identity.
    public func bindEnvelope(_ envelope: PulseContextEnvelope) throws {
        lock.lock()
        guard let current = _currentRun else {
            lock.unlock()
            throw PulseStateMachineError.noActiveRun
        }
        guard envelope.generationToken == current.generationToken,
              envelope.generationToken == _activeGenerationToken else {
            lock.unlock()
            throw PulseStateMachineError.staleCallbackRejected(
                "Envelope generation token mismatch: expected \(current.generationToken), got \(envelope.generationToken)"
            )
        }
        _currentRun?.envelopeID = envelope.id
        if let primary = envelope.primaryObject {
            _currentRun?.sourceObjectID = primary.id
            _currentRun?.sourceObjectClass = primary.objectClass
            _currentRun?.sourceObjectSummary = primary.summary
        }
        lock.unlock()
    }

    /// Binds an executed or verified receipt ID to the active run, validating runID and establishing identity.
    public func bindReceipt(receiptID: UUID, runID: UUID) throws {
        lock.lock()
        guard let current = _currentRun else {
            lock.unlock()
            throw PulseStateMachineError.noActiveRun
        }
        guard runID == current.runID else {
            lock.unlock()
            throw PulseStateMachineError.staleCallbackRejected(
                "Receipt runID mismatch: expected \(current.runID), got \(runID)"
            )
        }
        _currentRun?.receiptID = receiptID
        lock.unlock()
    }

    /// Explicitly transitions to a new state if permitted by the transition graph.
    @discardableResult
    public func transition(to newState: PulseState) throws -> PulseState {
        lock.lock()
        let oldState = _currentState

        // Enforce Result Hold Invariant: cannot transition to RECEDE if Result is held
        if newState == .recede && _heldResult != nil {
            let heldID = _heldResult!.id
            lock.unlock()
            throw PulseStateMachineError.resultHoldActive(resultID: heldID)
        }

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
              current.cancellationState == .none,
              current.outcome == nil else {
            return false
        }
        return true
    }

    /// Records asynchronous completion from an executor, enforcing stale-callback rejection and cross-validation.
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

        // Stale/racing check: if cancellation was requested or acknowledged, reject completion
        guard current.cancellationState == .none else {
            lock.unlock()
            throw PulseStateMachineError.staleCallbackRejected(
                "Cancellation already requested/acknowledged for run [\(current.runID)]"
            )
        }

        guard _currentState != .quiet && _currentState != .recede && current.outcome == nil else {
            lock.unlock()
            throw PulseStateMachineError.staleCallbackRejected(
                "Run already completed or in terminating state [\(_currentState)]"
            )
        }

        // Validate Result Object identity if supplied
        if let res = result {
            guard res.runID == current.runID else {
                lock.unlock()
                throw PulseStateMachineError.staleCallbackRejected(
                    "Result runID mismatch: expected \(current.runID), received \(res.runID)"
                )
            }
            if let srcID = current.sourceObjectID {
                guard res.sourceObjectID == srcID else {
                    lock.unlock()
                    throw PulseStateMachineError.staleCallbackRejected(
                        "Result sourceObjectID mismatch: expected \(srcID), received \(res.sourceObjectID)"
                    )
                }
            }
            if let srcClass = current.sourceObjectClass {
                guard res.sourceObjectClass == srcClass else {
                    lock.unlock()
                    throw PulseStateMachineError.staleCallbackRejected(
                        "Result sourceObjectClass mismatch: expected \(srcClass), received \(res.sourceObjectClass)"
                    )
                }
            }
            if let token = res.contextGenerationToken {
                guard token == current.generationToken else {
                    lock.unlock()
                    throw PulseStateMachineError.staleCallbackRejected(
                        "Result contextGenerationToken mismatch: expected \(current.generationToken), received \(token)"
                    )
                }
            }
            _currentRun?.resultID = res.id
            if res.isHeld {
                _heldResult = res
            }
        }

        _currentRun?.outcome = outcome
        _currentRun?.endTime = Date()

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
        guard let current = _currentRun else {
            lock.unlock()
            throw PulseStateMachineError.noActiveRun
        }
        guard result.runID == current.runID else {
            lock.unlock()
            throw PulseStateMachineError.staleCallbackRejected(
                "Result runID mismatch: expected \(current.runID), received \(result.runID)"
            )
        }
        if let srcID = current.sourceObjectID {
            guard result.sourceObjectID == srcID else {
                lock.unlock()
                throw PulseStateMachineError.staleCallbackRejected(
                    "Result sourceObjectID mismatch: expected \(srcID), received \(result.sourceObjectID)"
                )
            }
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

    /// Requests cancellation for the active run (distinguishing requested from acknowledged).
    public func requestCancellation(reason: String? = nil) {
        lock.lock()
        if _currentRun != nil && _currentRun?.cancellationState == PulseCancellationState.none {
            _currentRun?.cancellationState = .requested
            _currentRun?.cancellationRequestedAt = Date()
        }
        lock.unlock()
    }

    /// Acknowledges cancellation and converges cleanly through RECEDE to QUIET.
    @discardableResult
    public func acknowledgeCancellation() -> PulseState {
        lock.lock()
        if _currentRun != nil {
            _currentRun?.cancellationState = .acknowledged
            _currentRun?.cancellationAcknowledgedAt = Date()
        }
        lock.unlock()
        return cancel(reason: "cancellation_acknowledged")
    }

    /// Cancels any transient interaction and guarantees clean convergence through RECEDE to QUIET.
    ///
    /// Truthful state transitions:
    /// Step 1: Transitions to RECEDE and notifies observers while in RECEDE.
    /// Step 2: Transitions to QUIET and notifies observers while in QUIET.
    @discardableResult
    public func cancel(reason: String? = nil) -> PulseState {
        lock.lock()
        let oldState = _currentState
        if oldState == .quiet {
            lock.unlock()
            return .quiet
        }

        if _currentRun != nil {
            if _currentRun?.outcome == nil {
                _currentRun?.outcome = .cancelled
            }
            if _currentRun?.cancellationState != .acknowledged {
                _currentRun?.cancellationState = .acknowledged
                if _currentRun?.cancellationRequestedAt == nil {
                    _currentRun?.cancellationRequestedAt = Date()
                }
                _currentRun?.cancellationAcknowledgedAt = Date()
            }
        }
        _heldResult = nil

        // If not already in RECEDE, step to RECEDE first
        if oldState != .recede {
            _currentState = .recede
            _currentRun?.state = .recede
            let handlers = stateChangeHandlers
            lock.unlock()
            for handler in handlers {
                handler(oldState, .recede)
            }
            lock.lock()
        }

        // Final step to QUIET
        _currentState = .quiet
        _currentRun?.state = .quiet
        _currentRun?.endTime = Date()
        _activeGenerationToken = nil
        let handlers = stateChangeHandlers
        lock.unlock()

        for handler in handlers {
            handler(.recede, .quiet)
        }

        return .quiet
    }

    /// Resets the state machine unconditionally to QUIET (used during startup/shutdown and emergency recovery).
    public func resetToQuiet() {
        lock.lock()
        let oldState = _currentState
        if _currentRun != nil && _currentRun?.outcome == nil {
            _currentRun?.outcome = .cancelled
            _currentRun?.endTime = Date()
        }
        _currentRun?.state = .quiet
        _activeGenerationToken = nil
        _heldResult = nil
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
