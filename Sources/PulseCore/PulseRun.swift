import Foundation

/// Terminal outcome classifications for a DEX//PULSE execution run.
///
/// Invariant: Distinguishes failure types unambiguously:
/// `timedOut` != `failed` != `cancelled` != `blocked` != `unavailable`.
public enum PulseTerminalOutcome: String, Sendable, Codable, Equatable, CaseIterable, CustomStringConvertible {
    case succeeded   = "succeeded"
    case cancelled   = "cancelled"
    case blocked     = "blocked"
    case unavailable = "unavailable"
    case timedOut    = "timedOut"
    case failed      = "failed"
    case interrupted = "interrupted"
    case unknown     = "unknown"

    public var description: String { rawValue }

    /// Indicates whether the outcome represents a successful completion.
    public var isSuccess: Bool {
        self == .succeeded
    }

    /// Indicates whether the outcome represents any form of termination/failure.
    public var isTerminal: Bool {
        true
    }
}

/// Cancellation lifecycle states distinguishing requested from acknowledged.
public enum PulseCancellationState: String, Sendable, Codable, Equatable, CaseIterable, CustomStringConvertible {
    case none = "none"
    case requested = "requested"
    case acknowledged = "acknowledged"

    public var description: String { rawValue }
}

/// Lightweight receipt binding metadata for dependency-safe run cross-validation.
public struct PulseReceiptBindingMetadata: Sendable, Codable, Equatable {
    public let receiptID: UUID
    public let runID: UUID
    public let parentRunID: UUID?
    public let objectClass: String?
    public let capabilityID: String?
    public let targetID: String?
    public let outcome: PulseTerminalOutcome?

    public init(
        receiptID: UUID,
        runID: UUID,
        parentRunID: UUID? = nil,
        objectClass: String? = nil,
        capabilityID: String? = nil,
        targetID: String? = nil,
        outcome: PulseTerminalOutcome? = nil
    ) {
        self.receiptID = receiptID
        self.runID = runID
        self.parentRunID = parentRunID
        self.objectClass = objectClass
        self.capabilityID = capabilityID
        self.targetID = targetID
        self.outcome = outcome
    }
}

/// Explicit execution run representation tracking full lifecycle and provenance.
public struct PulseRun: Sendable, Codable, Equatable, Identifiable {
    public let runID: UUID
    public let parentRunID: UUID?
    public let startTime: Date
    public var endTime: Date?
    public var envelopeID: UUID?
    public let generationToken: String
    public var sourceObjectID: UUID?
    public var sourceObjectSummary: String?
    public var sourceObjectClass: ObjectClass?
    public var state: PulseState
    public var outcome: PulseTerminalOutcome?
    public var cancellationState: PulseCancellationState
    public var cancellationRequestedAt: Date?
    public var cancellationAcknowledgedAt: Date?
    public var capabilityID: String?
    public var targetID: String?
    public var resultID: UUID?
    public var receiptID: UUID?

    public var id: UUID { runID }

    public init(
        runID: UUID = UUID(),
        parentRunID: UUID? = nil,
        startTime: Date = Date(),
        endTime: Date? = nil,
        envelopeID: UUID? = nil,
        generationToken: String = UUID().uuidString,
        sourceObjectID: UUID? = nil,
        sourceObjectSummary: String? = nil,
        sourceObjectClass: ObjectClass? = nil,
        state: PulseState = .pulse,
        outcome: PulseTerminalOutcome? = nil,
        cancellationState: PulseCancellationState = .none,
        cancellationRequestedAt: Date? = nil,
        cancellationAcknowledgedAt: Date? = nil,
        capabilityID: String? = nil,
        targetID: String? = nil,
        resultID: UUID? = nil,
        receiptID: UUID? = nil
    ) {
        self.runID = runID
        self.parentRunID = parentRunID
        self.startTime = startTime
        self.endTime = endTime
        self.envelopeID = envelopeID
        self.generationToken = generationToken
        self.sourceObjectID = sourceObjectID
        self.sourceObjectSummary = sourceObjectSummary
        self.sourceObjectClass = sourceObjectClass
        self.state = state
        self.outcome = outcome
        self.cancellationState = cancellationState
        self.cancellationRequestedAt = cancellationRequestedAt
        self.cancellationAcknowledgedAt = cancellationAcknowledgedAt
        self.capabilityID = capabilityID
        self.targetID = targetID
        self.resultID = resultID
        self.receiptID = receiptID
    }

    /// Whether this run has reached a terminal outcome.
    public var isCompleted: Bool {
        outcome != nil || state == .quiet || state == .recede || cancellationState == .acknowledged
    }

    /// Execution duration in seconds if finished, or elapsed time if still running.
    public var duration: TimeInterval {
        (endTime ?? Date()).timeIntervalSince(startTime)
    }
}
