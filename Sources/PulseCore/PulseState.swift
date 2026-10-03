import Foundation

/// Semantic state vocabulary for DEX//PULSE.
///
/// The canonical causal loop as defined in `docs/INTERACTION_MODEL.md` is:
/// `QUIET -> PULSE -> LENS -> VEIL -> ATTUNE -> STRAND -> optional FORK/Target -> policy -> DISPATCH -> WEAVE -> RETURN -> WITNESS -> RESOLVE -> RECEDE -> QUIET`
///
/// Failures branch through `FRAY` (recoverable degradation/warning) or `SEVER` (hard termination/cancellation/block).
public enum PulseState: String, Sendable, Codable, Equatable, CaseIterable, CustomStringConvertible {
    // Resting state
    case quiet = "QUIET"

    // Primary interaction loop states
    case pulse = "PULSE"
    case lens = "LENS"
    case veil = "VEIL"
    case attune = "ATTUNE"
    case strand = "STRAND"
    case fork = "FORK"
    case dispatch = "DISPATCH"
    case weave = "WEAVE"
    case returnState = "RETURN"
    case witness = "WITNESS"
    case resolve = "RESOLVE"
    case recede = "RECEDE"

    // Failure / branch states
    case fray = "FRAY"
    case sever = "SEVER"

    public var description: String { rawValue }

    /// Indicates whether the app is in the resting background state.
    public var isResting: Bool {
        self == .quiet
    }

    /// Indicates whether this is a transient active state requiring display or interaction.
    public var isTransient: Bool {
        !isResting
    }
}

/// Explicit transition rules between semantic states.
public struct PulseStateTransition: Sendable {
    /// Validates whether a state transition is permitted.
    public static func isValid(from current: PulseState, to next: PulseState) -> Bool {
        switch (current, next) {
        // Startup and summon
        case (.quiet, .pulse):
            return true

        // Invocation context acquisition
        case (.pulse, .lens):
            return true

        // Context envelope acquired -> Presentation
        case (.lens, .veil):
            return true

        // Phase 0/1 backward compatibility shortcut (pulse -> veil)
        case (.pulse, .veil):
            return true

        // Primary interaction forward graph
        case (.veil, .attune):
            return true
        case (.attune, .strand):
            return true
        case (.strand, .fork):
            return true
        case (.strand, .dispatch):
            return true
        case (.fork, .dispatch):
            return true
        case (.dispatch, .weave):
            return true
        case (.weave, .returnState):
            return true
        case (.returnState, .witness):
            return true
        case (.witness, .resolve):
            return true
        case (.resolve, .recede):
            return true

        // Phase 0/1 backward compatibility shortcuts
        case (.veil, .dispatch):
            return true
        case (.dispatch, .witness):
            return true

        // Fray (recoverable issue / degradation) from any active working state
        case (.pulse, .fray),
             (.lens, .fray),
             (.veil, .fray),
             (.attune, .fray),
             (.strand, .fray),
             (.fork, .fray),
             (.dispatch, .fray),
             (.weave, .fray),
             (.returnState, .fray),
             (.witness, .fray):
            return true

        // Transitions out of Fray
        case (.fray, .veil),      // Retry/re-attune
             (.fray, .sever),     // Escalation to hard failure
             (.fray, .recede):    // Dismissal
            return true

        // Sever (hard failure / cancellation / block) from any transient state
        case (.pulse, .sever),
             (.lens, .sever),
             (.veil, .sever),
             (.attune, .sever),
             (.strand, .sever),
             (.fork, .sever),
             (.dispatch, .sever),
             (.weave, .sever),
             (.returnState, .sever),
             (.witness, .sever),
             (.resolve, .sever):
            return true

        case (.sever, .recede):
            return true

        // Direct dismiss / cancellation paths to RECEDE from any active state
        case (.pulse, .recede),
             (.lens, .recede),
             (.veil, .recede),
             (.attune, .recede),
             (.strand, .recede),
             (.fork, .recede),
             (.dispatch, .recede),
             (.weave, .recede),
             (.returnState, .recede),
             (.witness, .recede):
            return true

        // Return to resting quiet state
        case (.recede, .quiet):
            return true

        default:
            return false
        }
    }
}
