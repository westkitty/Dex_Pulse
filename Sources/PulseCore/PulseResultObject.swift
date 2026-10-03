import Foundation

/// Concrete Result Object representing the output of a DEX//PULSE execution run.
///
/// Invariant: Memory-only in Phase 3. Holds may pause auto-recede while the user
/// is inspecting the result.
public struct PulseResultObject: PulseObject, Sendable, Codable, Equatable, Identifiable {
    public let id: UUID // resultID
    public let runID: UUID
    public let sourceObjectID: UUID
    public let sourceObjectClass: ObjectClass
    public let capabilityID: String
    public let executorID: String
    public let targetID: String?
    public let outcome: PulseTerminalOutcome
    public let summary: String
    public var isHeld: Bool
    public let createdAt: Date
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let payloadDescriptor: String
    public let contextGenerationToken: String?

    public var objectClass: ObjectClass { .result }
    public var source: ObjectSource { .result }
    public var confidence: Double { 1.0 }

    public init(
        id: UUID = UUID(),
        runID: UUID,
        sourceObjectID: UUID,
        sourceObjectClass: ObjectClass,
        capabilityID: String,
        executorID: String,
        targetID: String? = nil,
        outcome: PulseTerminalOutcome,
        summary: String,
        isHeld: Bool = false,
        createdAt: Date = Date(),
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        payloadDescriptor: String = "",
        contextGenerationToken: String? = nil
    ) {
        self.id = id
        self.runID = runID
        self.sourceObjectID = sourceObjectID
        self.sourceObjectClass = sourceObjectClass
        self.capabilityID = capabilityID
        self.executorID = executorID
        self.targetID = targetID
        self.outcome = outcome
        self.summary = summary
        self.isHeld = isHeld
        self.createdAt = createdAt
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.payloadDescriptor = payloadDescriptor.isEmpty ? summary : payloadDescriptor
        self.contextGenerationToken = contextGenerationToken
    }
}
