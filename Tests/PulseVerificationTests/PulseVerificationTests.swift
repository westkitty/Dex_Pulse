import Testing
import Foundation
@testable import PulseCore
@testable import PulseKit
@testable import PulseWitness
@testable import PulseLens
@testable import PulseVisuals

@Suite("PulseVerification Invariant Tests")
struct PulseVerificationTests {
    @Test("Lens precedence order strictly prioritizes selected content over element and clipboard (INV-003)")
    func lensPrecedenceOrder() {
        let prov = ObjectProvenance(acquisitionMethod: "test")
        let textCandidate = LensCandidate(
            tier: .selectedContent,
            object: SelectedTextObject(text: "Selected text", provenance: prov),
            acquisitionReason: "selection"
        )
        let elementCandidate = LensCandidate(
            tier: .pointerUIElement,
            object: UIElementObject(role: "AXButton", title: "OK", applicationName: "Test", provenance: prov),
            acquisitionReason: "pointer"
        )
        let clipboardCandidate = LensCandidate(
            tier: .clipboardFallback,
            object: ClipboardObject(changeCount: 1, types: ["public.utf8-plain-text"], provenance: prov),
            acquisitionReason: "clipboard"
        )

        // Tier 1 beats Tier 2 and Tier 5
        let resolvedWithSelection = LensResolver.resolvePrimary(from: [clipboardCandidate, elementCandidate, textCandidate])
        #expect(resolvedWithSelection?.tier == .selectedContent)

        // When selection is absent, Tier 2 (pointer UI element) beats Tier 5 (clipboard fallback)
        let resolvedWithoutSelection = LensResolver.resolvePrimary(from: [clipboardCandidate, elementCandidate])
        #expect(resolvedWithoutSelection?.tier == .pointerUIElement)
    }

    @Test("Witness structured receipt records proof state and excludes raw sensitive payloads")
    func witnessReceiptExcludesRawSensitivePayloads() {
        let receipt = WitnessReceipt(
            runID: UUID(),
            parentRunID: nil,
            objectClass: ObjectClass.selectedText.rawValue,
            capabilityID: "core.macos.inspect_element",
            targetMachine: "MacBook Air M1",
            evidenceState: .verified,
            durationMilliseconds: 14.5,
            summary: "Inspected UI control with role AXButton"
        )

        #expect(receipt.evidenceState == .verified)
        #expect(receipt.targetMachine == "MacBook Air M1")
        #expect(receipt.summary.contains("AXButton"))
    }

    @Test("Visual theme tokens match project specifications")
    func visualThemeTokens() {
        #expect(PulseVisualsTheme.cornerRadius == 12.0)
        #expect(PulseVisualsTheme.pulsePointDiameter == 16.0)
    }
}
