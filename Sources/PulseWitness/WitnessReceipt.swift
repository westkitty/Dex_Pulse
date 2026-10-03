import Foundation
import PulseCore

/// Structured evidence classification for DEX//PULSE actions and claims.
///
/// Invariant: Distinguishes what is directly observed or verified from what is
/// merely claimed or unknown.
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
/// Invariant: Raw sensitive user payloads (text, diffs, credentials) are omitted by default.
public struct WitnessReceipt: Sendable, Codable, Equatable {
    public let runID: UUID
    public let parentRunID: UUID?
    public let timestamp: Date
    public let objectClass: String
    public let capabilityID: String
    public let targetMachine: String
    public let evidenceState: EvidenceState
    public let durationMilliseconds: Double
    public let summary: String

    public init(
        runID: UUID = UUID(),
        parentRunID: UUID? = nil,
        timestamp: Date = Date(),
        objectClass: String,
        capabilityID: String,
        targetMachine: String,
        evidenceState: EvidenceState,
        durationMilliseconds: Double,
        summary: String
    ) {
        self.runID = runID
        self.parentRunID = parentRunID
        self.timestamp = timestamp
        self.objectClass = objectClass
        self.capabilityID = capabilityID
        self.targetMachine = targetMachine
        self.evidenceState = evidenceState
        self.durationMilliseconds = durationMilliseconds
        self.summary = summary
    }
}

/// Lightweight interface for Witness recording.
public protocol WitnessRecording: Sendable {
    func recordReceipt(_ receipt: WitnessReceipt)
    func latestReceipts(limit: Int) -> [WitnessReceipt]
}

/// In-memory transient receipt store for Phase 0/1 bootstrap.
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
