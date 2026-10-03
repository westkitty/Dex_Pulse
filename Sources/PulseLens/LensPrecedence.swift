import Foundation
import PulseCore

/// Locked context acquisition precedence hierarchy (INV-003).
///
/// Order:
/// 1. explicit selected text or selected file
/// 2. UI element under pointer
/// 3. focused Accessibility element
/// 4. frontmost window/application
/// 5. clipboard fallback (read-only, never mutated)
public enum LensPrecedenceTier: Int, Sendable, Comparable, CaseIterable {
    case selectedContent = 1
    case pointerUIElement = 2
    case focusedAXElement = 3
    case frontmostAppOrWindow = 4
    case clipboardFallback = 5

    public static func < (lhs: LensPrecedenceTier, rhs: LensPrecedenceTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// Candidate object discovered during Lens acquisition pass.
public struct LensCandidate: Sendable {
    public let tier: LensPrecedenceTier
    public let object: any PulseObject
    public let confidence: Double
    public let acquisitionReason: String

    public init(
        tier: LensPrecedenceTier,
        object: any PulseObject,
        confidence: Double = 1.0,
        acquisitionReason: String
    ) {
        self.tier = tier
        self.object = object
        self.confidence = confidence
        self.acquisitionReason = acquisitionReason
    }
}

/// Protocol for structural Lens context acquisition providers.
public protocol LensAcquisitionProvider: Sendable {
    var tier: LensPrecedenceTier { get }
    func acquireCandidate(at screenPoint: (x: Double, y: Double)?) -> LensCandidate?
}

/// Deterministic Lens resolver strictly adhering to locked precedence.
public struct LensResolver: Sendable {

    /// Selects the winning primary candidate from an array of candidates based on locked tier precedence.
    public static func resolvePrimary(from candidates: [LensCandidate]) -> LensCandidate? {
        // Sort ascending by tier rawValue (1 beats 2 beats 3...); tie-break by confidence descending
        let sorted = candidates.sorted {
            if $0.tier != $1.tier {
                return $0.tier < $1.tier
            }
            return $0.confidence > $1.confidence
        }
        return sorted.first
    }

    /// Acquires a full, bounded PulseContextEnvelope for an invocation at the given screen coordinates.
    public static func acquireContextEnvelope(
        at screenPoint: (x: Double, y: Double)? = nil,
        providers: [any LensAcquisitionProvider]? = nil
    ) -> PulseContextEnvelope {
        let activeProviders = providers ?? [
            SelectedTextProvider(),
            SelectedFileProvider(),
            PointerElementProvider(),
            FocusedElementProvider(),
            FrontmostAppProvider(),
            ClipboardFallbackProvider()
        ]

        let generationToken = UUID().uuidString
        var discoveredCandidates: [LensCandidate] = []

        for provider in activeProviders {
            if let candidate = provider.acquireCandidate(at: screenPoint) {
                // If candidate is a text selection, deterministically refine it
                let refinedObject = TypeRefiners.refine(object: candidate.object)
                let refinedCandidate = LensCandidate(
                    tier: candidate.tier,
                    object: refinedObject,
                    confidence: candidate.confidence,
                    acquisitionReason: candidate.acquisitionReason
                )
                discoveredCandidates.append(refinedCandidate)
            }
        }

        let sorted = discoveredCandidates.sorted {
            if $0.tier != $1.tier {
                return $0.tier < $1.tier
            }
            return $0.confidence > $1.confidence
        }

        let primary = sorted.first
        let fallback = sorted.first(where: { $0.tier == .clipboardFallback && $0.tier != primary?.tier })

        let candidateSnapshots = sorted.map { cand in
            ContextCandidateSnapshot(
                tierRawValue: cand.tier.rawValue,
                objectClass: cand.object.objectClass,
                objectSummary: cand.object.summary,
                confidence: cand.confidence,
                acquisitionReason: cand.acquisitionReason
            )
        }

        return PulseContextEnvelope(
            invocationTime: Date(),
            generationToken: generationToken,
            screenCoordinates: screenPoint,
            primaryObject: primary?.object,
            primaryReason: primary?.acquisitionReason,
            primaryTier: primary?.tier.rawValue,
            fallbackObject: fallback?.object,
            evaluatedCandidates: candidateSnapshots
        )
    }
}
