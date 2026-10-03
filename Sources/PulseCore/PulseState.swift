import Foundation

/// Semantic state vocabulary for DEX//PULSE.
///
/// The canonical causal loop is:
/// `QUIET -> PULSE -> LENS -> VEIL -> Reflex -> optional Target -> DISPATCH/WEAVE -> Result Object -> WITNESS -> RESOLVE -> RECEDE -> QUIET`
public enum PulseState: String, Sendable, Codable, Equatable, CustomStringConvertible {
    // Phase 0/1 implemented active states
    case quiet = "QUIET"
    case pulse = "PULSE"
    case veil = "VEIL"
    case recede = "RECEDE"

    // Declared future semantic states (vocabulary defined by Master Plan)
    case dispatch = "DISPATCH"
    case witness = "WITNESS"
    case resolve = "RESOLVE"
    case sever = "SEVER"

    public var description: String { rawValue }

    /// Indicates whether the app is in the resting background state.
    public var isResting: Bool {
        self == .quiet
    }

    /// Indicates whether this is a transient active state requiring display/interaction.
    public var isTransient: Bool {
        !isResting
    }
}

/// Explicit transition rules between semantic states.
public struct PulseStateTransition: Sendable {
    /// Validates whether a state transition is permitted.
    public static func isValid(from current: PulseState, to next: PulseState) -> Bool {
        switch (current, next) {
        // Startup and normal invoke
        case (.quiet, .pulse):
            return true

        // Pulse summon reaching presentation
        case (.pulse, .veil):
            return true

        // Early cancellation or dismiss during pulse
        case (.pulse, .recede):
            return true

        // Dismissal / cancellation from veil
        case (.veil, .recede):
            return true

        // Return to resting quiet state
        case (.recede, .quiet):
            return true

        // Future loop paths (vocabulary validation)
        case (.veil, .dispatch):
            return true
        case (.dispatch, .witness):
            return true
        case (.witness, .resolve):
            return true
        case (.resolve, .recede):
            return true

        // Emergency sever/cancel paths from any transient state
        case (.veil, .sever),
             (.dispatch, .sever),
             (.witness, .sever):
            return true
        case (.sever, .recede):
            return true

        default:
            return false
        }
    }
}
