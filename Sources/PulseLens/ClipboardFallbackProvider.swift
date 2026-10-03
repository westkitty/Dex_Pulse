import Foundation
import AppKit
import PulseCore

/// Provider for Tier 5: Fallback read-only snapshot of existing clipboard.
///
/// Hard Invariant (INV-001):
/// Strictly READ-ONLY. Never writes, clears, swaps, or synthesizes pasteboard events.
/// Pasteboard changeCount MUST remain identical throughout acquisition.
public struct ClipboardFallbackProvider: LensAcquisitionProvider {
    public let tier: LensPrecedenceTier = .clipboardFallback

    public init() {}

    public func acquireCandidate(at screenPoint: (x: Double, y: Double)?) -> LensCandidate? {
        let pasteboard = NSPasteboard.general
        let initialChangeCount = pasteboard.changeCount

        let types = pasteboard.types?.map(\.rawValue) ?? []
        guard !types.isEmpty else {
            return nil
        }

        // Read string preview safely if available without mutating pasteboard
        let stringContent = pasteboard.string(forType: .string)
        let preview = stringContent.map { String($0.prefix(60)) }

        let finalChangeCount = pasteboard.changeCount
        // Ensure read-only immutability invariant
        guard initialChangeCount == finalChangeCount else {
            assertionFailure("FATAL: Clipboard was mutated during read-only fallback acquisition!")
            return nil
        }

        let prov = ObjectProvenance(
            acquisitionMethod: "pasteboard.readOnlySnapshot"
        )

        let object = ClipboardObject(
            changeCount: initialChangeCount,
            types: types,
            textPreview: preview,
            provenance: prov,
            privacyClass: .ordinary,
            confidence: 0.8
        )

        return LensCandidate(
            tier: .clipboardFallback,
            object: object,
            confidence: 0.8,
            acquisitionReason: "Existing clipboard fallback (changeCount: \(initialChangeCount), \(types.count) types)"
        )
    }
}
