import Foundation
import PulseCore
import PulseWitness

/// Risk classification for capabilities.
///
/// Invariant (INV-002): V1 exposes no executable destructive capability.
public enum RiskClass: String, Sendable, Codable, Equatable {
    case readOnly = "READ_ONLY"
    case idempotentWrite = "IDEMPOTENT_WRITE"
    case reversibleWrite = "REVERSIBLE_WRITE"
    case destructiveFuture = "DESTRUCTIVE_FUTURE" // Blocked from execution in V1
}

/// Execution locality and network requirements.
public enum LocalityRequirement: String, Sendable, Codable, Equatable {
    case localDeterministic = "LOCAL_DETERMINISTIC"
    case localModel = "LOCAL_MODEL"
    case remoteModel = "REMOTE_MODEL"
    case remoteTarget = "REMOTE_TARGET"
}

/// Availability state of a capability.
public enum CapabilityAvailability: Sendable, Equatable {
    case available
    case unavailable(reason: String)
    case notConfigured
    case unsupported(reason: String)
    case unknown
}

/// Target machine selection requirements.
public enum TargetRequirement: String, Sendable, Codable, Equatable {
    case localOnly = "LOCAL_ONLY"
    case eligibleBigMac = "ELIGIBLE_BIG_MAC"
    case requiresBigMac = "REQUIRES_BIG_MAC"
}

/// Formal declaration of a capability registered with PulseKit.
public struct CapabilityDescriptor: Sendable, Equatable {
    public let capabilityID: String
    public let displayName: String
    public let acceptedObjectClasses: Set<ObjectClass>
    public let riskClass: RiskClass
    public let locality: LocalityRequirement
    public let targetRequirement: TargetRequirement
    public let supportsCancellation: Bool
    public let mutatesState: Bool
    public let proofContractDescription: String

    public init(
        capabilityID: String,
        displayName: String,
        acceptedObjectClasses: Set<ObjectClass>,
        riskClass: RiskClass,
        locality: LocalityRequirement = .localDeterministic,
        targetRequirement: TargetRequirement = .localOnly,
        supportsCancellation: Bool = true,
        mutatesState: Bool = false,
        proofContractDescription: String = "Structured execution receipt recorded in Witness"
    ) {
        self.capabilityID = capabilityID
        self.displayName = displayName
        self.acceptedObjectClasses = acceptedObjectClasses
        self.riskClass = riskClass
        self.locality = locality
        self.targetRequirement = targetRequirement
        self.supportsCancellation = supportsCancellation
        self.mutatesState = mutatesState
        self.proofContractDescription = proofContractDescription
    }
}
