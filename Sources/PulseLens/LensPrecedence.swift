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
public enum LensPrecedenceTier: Int, Sendable, Comparable {
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
    public static func resolvePrimary(from candidates: [LensCandidate]) -> LensCandidate? {
        // Sort ascending by tier rawValue (1 beats 2 beats 3...)
        let sorted = candidates.sorted {
            if $0.tier != $1.tier {
                return $0.tier < $1.tier
            }
            return $0.confidence > $1.confidence
        }
        return sorted.first
    }
}
