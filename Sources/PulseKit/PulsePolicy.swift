import Foundation
import PulseCore

/// Policy violation errors returned by central Pulse policy engine.
public enum PolicyViolation: Error, Equatable, CustomStringConvertible {
    case destructiveCapabilityBlocked(capabilityID: String)
    case unsupportedObjectClass(expected: Set<ObjectClass>, received: ObjectClass)
    case unverifiedTarget(machine: String)

    public var description: String {
        switch self {
        case .destructiveCapabilityBlocked(let id):
            return "Policy violation (INV-002): Capability [\(id)] classified as destructive is rejected in V1"
        case .unsupportedObjectClass(let expected, let received):
            return "Policy violation: Capability does not accept object class [\(received)]. Accepted: \(expected)"
        case .unverifiedTarget(let machine):
            return "Policy violation: Target [\(machine)] is unverified"
        }
    }
}

/// Central policy engine for DEX//PULSE.
///
/// Invariant: A Pack or adapter cannot override this gate.
public struct PulsePolicy: Sendable {
    /// Validates whether a capability is permitted to execute on a given object in V1.
    public static func validateExecution(
        capability: CapabilityDescriptor,
        for object: any PulseObject
    ) -> Result<Void, PolicyViolation> {
        // Core invariant: V1 has NO executable destructive capability
        if capability.riskClass == .destructiveFuture {
            return .failure(.destructiveCapabilityBlocked(capabilityID: capability.capabilityID))
        }

        // Validate accepted object class
        if !capability.acceptedObjectClasses.contains(object.objectClass) {
            return .failure(.unsupportedObjectClass(
                expected: capability.acceptedObjectClasses,
                received: object.objectClass
            ))
        }

        return .success(())
    }
}

/// Capability registry managing declared capabilities.
public final class PulseKitRegistry: @unchecked Sendable {
    private let lock = NSLock()
    private var capabilities: [String: CapabilityDescriptor] = [:]

    public init() {
        registerBootstrapCapabilities()
    }

    /// Registers a capability descriptor.
    public func register(_ descriptor: CapabilityDescriptor) {
        lock.lock()
        defer { lock.unlock() }
        capabilities[descriptor.capabilityID] = descriptor
    }

    /// Look up capability by ID.
    public func capability(for id: String) -> CapabilityDescriptor? {
        lock.lock()
        defer { lock.unlock() }
        return capabilities[id]
    }

    /// All registered capabilities.
    public var allCapabilities: [CapabilityDescriptor] {
        lock.lock()
        defer { lock.unlock() }
        return Array(capabilities.values)
    }

    /// Bootstrap baseline capabilities (Core macOS inspect, Git status read, Ollama explain).
    private func registerBootstrapCapabilities() {
        // Core macOS Inspect (read-only)
        register(CapabilityDescriptor(
            capabilityID: "core.macos.inspect_element",
            displayName: "Inspect UI Element",
            acceptedObjectClasses: [.uiElement, .focusedElement],
            riskClass: .readOnly,
            locality: .localDeterministic,
            targetRequirement: .localOnly,
            supportsCancellation: true,
            mutatesState: false,
            proofContractDescription: "AX element attribute inspection receipt"
        ))

        // Git Status (read-only)
        register(CapabilityDescriptor(
            capabilityID: "git.inspect_status",
            displayName: "Git Status",
            acceptedObjectClasses: [.repository, .path, .file],
            riskClass: .readOnly,
            locality: .localDeterministic,
            targetRequirement: .localOnly,
            supportsCancellation: true,
            mutatesState: false,
            proofContractDescription: "Git working copy status receipt"
        ))

        // Local Model Explain (read-only model inference)
        register(CapabilityDescriptor(
            capabilityID: "ollama.explain_error",
            displayName: "Explain Error Log",
            acceptedObjectClasses: [.errorLog, .selectedText, .code],
            riskClass: .readOnly,
            locality: .localModel,
            targetRequirement: .eligibleBigMac,
            supportsCancellation: true,
            mutatesState: false,
            proofContractDescription: "Model inference execution receipt"
        ))
    }
}
