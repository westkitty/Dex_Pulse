import Foundation
import PulseCore

/// Structured evidence classification for DEX//PULSE actions and claims.
///
/// Invariant: Distinguishes what is directly observed or verified from what is
/// merely claimed or unknown.
/// Crucial distinction: EXECUTED != VERIFIED. An execution that returns an exit code
/// is EXECUTED; only corroborating empirical proof makes it VERIFIED.
public enum EvidenceState: String, Sendable, Codable, Equatable, CustomStringConvertible {
    case observed = "OBSERVED"
    case executed = "EXECUTED"
    case verified = "VERIFIED"
    case claimed  = "CLAIMED"
    case unknown  = "UNKNOWN"

    public var description: String { rawValue }
}

/// Structured receipt for an executed capability or interaction proof.
///
/// Invariants:
/// - Raw sensitive user payloads (text, diffs, credentials) are strictly omitted.
/// - Contains only execution metadata, durations, proof status, and non-sensitive summaries.
public struct WitnessReceipt: Sendable, Codable, Equatable, Identifiable {
    public let receiptID: UUID
    public let runID: UUID
    public let parentRunID: UUID?
    public let timestamp: Date
    public let objectClass: String
    public let capabilityID: String
    public let targetMachine: String
    public let evidenceState: EvidenceState
    public let outcome: PulseTerminalOutcome?
    public let durationMilliseconds: Double
    public let summary: String

    public var id: UUID { receiptID }

    /// Distinct proof classification: EXECUTED != VERIFIED
    public var isVerified: Bool {
        evidenceState == .verified
    }

    /// Whether this receipt merely records execution without independent verification.
    public var isExecutedOnly: Bool {
        evidenceState == .executed
    }

    public init(
        receiptID: UUID = UUID(),
        runID: UUID = UUID(),
        parentRunID: UUID? = nil,
        timestamp: Date = Date(),
        objectClass: String,
        capabilityID: String,
        targetMachine: String,
        evidenceState: EvidenceState,
        outcome: PulseTerminalOutcome? = nil,
        durationMilliseconds: Double,
        summary: String
    ) {
        self.receiptID = receiptID
        self.runID = runID
        self.parentRunID = parentRunID
        self.timestamp = timestamp
        self.objectClass = objectClass
        self.capabilityID = capabilityID
        self.targetMachine = targetMachine
        self.evidenceState = evidenceState
        self.outcome = outcome
        self.durationMilliseconds = durationMilliseconds
        self.summary = summary
    }
}

/// Lightweight interface for Witness recording.
public protocol WitnessRecording: Sendable {
    func recordReceipt(_ receipt: WitnessReceipt)
    func latestReceipts(limit: Int) -> [WitnessReceipt]
}

/// In-memory transient receipt store for DEX//PULSE.
public final class MemoryWitnessStore: WitnessRecording, @unchecked Sendable {
    private let lock = NSLock()
    private var receipts: [WitnessReceipt] = []

    public init() {}

    public func recordReceipt(_ receipt: WitnessReceipt) {
        lock.lock()
        defer { lock.unlock() }
        receipts.append(receipt)
        if receipts.count > 100 {
            receipts.removeFirst(receipts.count - 100)
        }
    }

    public func latestReceipts(limit: Int = 10) -> [WitnessReceipt] {
        lock.lock()
        defer { lock.unlock() }
        return Array(receipts.suffix(limit))
    }
}

extension PulseStateMachine {
    /// Binds an executed or verified WitnessReceipt to the active run, validating runID and establishing identity.
    public func bindReceipt(_ receipt: WitnessReceipt) throws {
        try bindReceipt(receiptID: receipt.receiptID, runID: receipt.runID)
    }
}
