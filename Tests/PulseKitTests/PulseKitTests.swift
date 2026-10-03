import Testing
@testable import PulseCore
@testable import PulseKit
@testable import PulseWitness

@Suite("PulseKit & Central Policy Tests")
struct PulseKitTests {
    @Test("Central policy blocks destructive future capability before execution (INV-002)")
    func centralPolicyBlocksDestructiveFutureCapability() {
        let destructiveCap = CapabilityDescriptor(
            capabilityID: "dangerous.rm_rf",
            displayName: "Delete Recursive",
            acceptedObjectClasses: [.file, .path],
            riskClass: .destructiveFuture
        )

        let file = FileObject(
            path: "/tmp/test",
            provenance: ObjectProvenance(acquisitionMethod: "unit-test")
        )

        let result = PulsePolicy.validateExecution(capability: destructiveCap, for: file)
        switch result {
        case .failure(.destructiveCapabilityBlocked(let id)):
            #expect(id == "dangerous.rm_rf")
        default:
            Issue.record("Policy must block destructive capability before execution")
        }
    }

    @Test("Central policy permits safe read-only capability for matching object")
    func centralPolicyPermitsSafeCapabilityForMatchingObject() {
        let safeCap = CapabilityDescriptor(
            capabilityID: "core.macos.inspect_element",
            displayName: "Inspect Element",
            acceptedObjectClasses: [.uiElement],
            riskClass: .readOnly
        )

        let uiElement = UIElementObject(
            role: "AXButton",
            title: "OK",
            applicationName: "Finder",
            provenance: ObjectProvenance(acquisitionMethod: "unit-test")
        )

        let result = PulsePolicy.validateExecution(capability: safeCap, for: uiElement)
        switch result {
        case .success:
            #expect(Bool(true))
        case .failure(let error):
            Issue.record("Expected success for safe matching capability, got: \(error)")
        }
    }

    @Test("Central policy rejects mismatched object class")
    func centralPolicyRejectsMismatchedObjectClass() {
        let gitCap = CapabilityDescriptor(
            capabilityID: "git.status",
            displayName: "Git Status",
            acceptedObjectClasses: [.repository],
            riskClass: .readOnly
        )

        let selectedText = SelectedTextObject(
            text: "git status",
            provenance: ObjectProvenance(acquisitionMethod: "unit-test")
        )

        let result = PulsePolicy.validateExecution(capability: gitCap, for: selectedText)
        switch result {
        case .failure(.unsupportedObjectClass(let expected, let received)):
            #expect(expected.contains(.repository))
            #expect(received == .selectedText)
        default:
            Issue.record("Expected unsupportedObjectClass policy error")
        }
    }

    @Test("Registry contains bootstrap capabilities")
    func registryContainsBootstrapCapabilities() {
        let registry = PulseKitRegistry()
        let caps = registry.allCapabilities
        #expect(caps.count >= 3)

        let inspectCap = registry.capability(for: "core.macos.inspect_element")
        #expect(inspectCap != nil)
        #expect(inspectCap?.riskClass == .readOnly)

        let gitCap = registry.capability(for: "git.inspect_status")
        #expect(gitCap != nil)
        #expect(gitCap?.riskClass == .readOnly)
    }
}
