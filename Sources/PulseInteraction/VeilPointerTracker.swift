import Foundation
import CoreGraphics

/// Tracking states for pointer navigation within the Veil wheel.
public enum VeilPointerState: Sendable, Equatable {
    case idle
    case inCenter
    case sectorHover(CompassDirection)
    case sectorArmed(CompassDirection)
    case nestedArmed(parent: CompassDirection, choiceID: String)
    case outside(point: CGPoint, distance: CGFloat)
}

/// Manages interactive pointer updates, angular hysteresis, radial overshoot,
/// and nested disclosure transitions.
///
/// Invariant: Tracking is strictly active only while the Veil is presented.
/// When in QUIET state, tracking is stopped and consumes zero CPU (INV-PERF).
public final class VeilPointerTracker: @unchecked Sendable {
    private let lock = NSLock()

    private var _isTracking: Bool = false
    private var _geometry: VeilRingGeometry
    private var _layout: VeilObjectLayout?
    private var _currentState: VeilPointerState = .idle

    public private(set) var armedDirection: CompassDirection?
    public private(set) var activeNestedParent: CompassDirection?
    public private(set) var activeNestedChoiceID: String?

    /// Callbacks for state changes
    public var onStateChange: (@Sendable (VeilPointerState) -> Void)?
    public var onExitBoundary: (@Sendable (CGPoint) -> Void)?

    public init(center: CGPoint = .zero) {
        self._geometry = VeilRingGeometry(center: center)
    }

    /// Whether tracking is currently active.
    public var isTracking: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isTracking
    }

    /// Current pointer state.
    public var currentState: VeilPointerState {
        lock.lock()
        defer { lock.unlock() }
        return _currentState
    }

    /// Current ring geometry.
    public var geometry: VeilRingGeometry {
        lock.lock()
        defer { lock.unlock() }
        return _geometry
    }

    /// Begins tracking for a given layout and center position.
    public func startTracking(layout: VeilObjectLayout, center: CGPoint) {
        lock.lock()
        defer { lock.unlock() }
        _geometry = VeilRingGeometry(center: center)
        _layout = layout
        _isTracking = true
        _currentState = .inCenter
        armedDirection = nil
        activeNestedParent = nil
        activeNestedChoiceID = nil
    }

    /// Stops tracking and resets state.
    public func stopTracking() {
        lock.lock()
        defer { lock.unlock() }
        _isTracking = false
        _currentState = .idle
        armedDirection = nil
        activeNestedParent = nil
        activeNestedChoiceID = nil
        _geometry.clearNestedSectors()
    }

    /// Evaluates pointer movement against the active annular wheel geometry.
    ///
    /// Respects:
    /// - Center neutral zone traversal (does NOT dismiss wheel).
    /// - Angular seam hysteresis on armed direction (prevents flutter).
    /// - Radial overshoot tolerance on armed direction (forgiveness).
    /// - Nested disclosure activation and inward/outward traversal.
    /// - Outside boundary exit.
    @discardableResult
    public func updatePointer(at point: CGPoint) -> VeilHitTestResult {
        lock.lock()
        guard _isTracking else {
            lock.unlock()
            return .outside
        }

        let result = _geometry.hitTest(
            point: point,
            armedDirection: armedDirection,
            activeNestedParent: activeNestedParent
        )

        var newState: VeilPointerState = _currentState
        var notifyExit: CGPoint? = nil

        switch result {
        case .neutralCenter:
            // Returning to center does NOT dismiss or cancel; interaction remains alive.
            armedDirection = nil
            activeNestedChoiceID = nil
            // Clear nested sectors when returning to origin
            _geometry.clearNestedSectors()
            activeNestedParent = nil
            newState = .inCenter

        case .sector(let dir, _):
            // Check if this slot is interactive
            let descriptor = _layout?.reflex(at: dir)
            let isInteractive = descriptor?.state.isInteractive ?? true

            if isInteractive {
                armedDirection = dir
                activeNestedChoiceID = nil
                newState = .sectorArmed(dir)

                // If descriptor has nested choices, open disclosure outer ring
                if let nestedChoices = descriptor?.nestedChoices, !nestedChoices.isEmpty {
                    _geometry.configureNestedSectors(for: dir, choices: nestedChoices)
                    activeNestedParent = dir
                } else if activeNestedParent != dir {
                    _geometry.clearNestedSectors()
                    activeNestedParent = nil
                }
            } else {
                // Disabled or locked slot
                armedDirection = nil
                newState = .sectorHover(dir)
                _geometry.clearNestedSectors()
                activeNestedParent = nil
            }

        case .nestedSector(let parentDirection, let choiceID):
            armedDirection = parentDirection
            activeNestedParent = parentDirection
            activeNestedChoiceID = choiceID
            newState = .nestedArmed(parent: parentDirection, choiceID: choiceID)

        case .outside:
            let dist = hypot(point.x - _geometry.center.x, point.y - _geometry.center.y)
            newState = .outside(point: point, distance: dist)
            // Exit boundary callback when pointer leaves active tolerance
            let maxTol = VeilTuningTokens.maxActiveRadius + 24.0
            if dist > maxTol {
                notifyExit = point
            }
        }

        let stateChanged = (_currentState != newState)
        _currentState = newState
        let callback = onStateChange
        let exitCallback = onExitBoundary
        lock.unlock()

        if stateChanged {
            callback?(newState)
        }
        if let exitPt = notifyExit {
            exitCallback?(exitPt)
        }

        return result
    }

    /// Explicitly arms a direction (e.g. from keyboard navigation).
    public func armDirection(_ direction: CompassDirection) {
        lock.lock()
        guard _isTracking else {
            lock.unlock()
            return
        }
        armedDirection = direction
        activeNestedChoiceID = nil

        let descriptor = _layout?.reflex(at: direction)
        if let nestedChoices = descriptor?.nestedChoices, !nestedChoices.isEmpty {
            _geometry.configureNestedSectors(for: direction, choices: nestedChoices)
            activeNestedParent = direction
        } else {
            _geometry.clearNestedSectors()
            activeNestedParent = nil
        }

        _currentState = .sectorArmed(direction)
        let callback = onStateChange
        lock.unlock()

        callback?(.sectorArmed(direction))
    }

    /// Explicitly arms a nested choice.
    public func armNestedChoice(_ choiceID: String, parentDirection: CompassDirection) {
        lock.lock()
        guard _isTracking else {
            lock.unlock()
            return
        }
        armedDirection = parentDirection
        activeNestedParent = parentDirection
        activeNestedChoiceID = choiceID
        _currentState = .nestedArmed(parent: parentDirection, choiceID: choiceID)
        let callback = onStateChange
        lock.unlock()

        callback?(.nestedArmed(parent: parentDirection, choiceID: choiceID))
    }
}
