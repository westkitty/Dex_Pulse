import Foundation
import CoreGraphics

/// Stable cardinal and diagonal compass directions for DEX//PULSE Veil layouts.
///
/// Invariant: Directions are permanent motor slots. They must never be AI-reordered
/// or dynamically shifted across execution runs (INV-031).
public enum CompassDirection: String, Sendable, Codable, CaseIterable, CustomStringConvertible {
    case n  = "N"
    case ne = "NE"
    case e  = "E"
    case se = "SE"
    case s  = "S"
    case sw = "SW"
    case w  = "W"
    case nw = "NW"

    public var description: String { rawValue }

    /// Nominal center angle in standard mathematical degrees where 0° = East, 90° = North.
    public var nominalAngleDegrees: Double {
        switch self {
        case .e:  return 0.0
        case .ne: return 45.0
        case .n:  return 90.0
        case .nw: return 135.0
        case .w:  return 180.0
        case .sw: return 225.0
        case .s:  return 270.0
        case .se: return 315.0
        }
    }

    /// Nominal start angle in degrees [0, 360).
    public var startAngleDegrees: Double {
        let start = nominalAngleDegrees - 22.5
        return start < 0.0 ? start + 360.0 : start
    }

    /// Nominal end angle in degrees [0, 360).
    public var endAngleDegrees: Double {
        let end = nominalAngleDegrees + 22.5
        return end >= 360.0 ? end - 360.0 : end
    }

    /// Next clockwise direction.
    public var clockwise: CompassDirection {
        switch self {
        case .n:  return .ne
        case .ne: return .e
        case .e:  return .se
        case .se: return .s
        case .s:  return .sw
        case .sw: return .w
        case .w:  return .nw
        case .nw: return .n
        }
    }

    /// Previous counter-clockwise direction.
    public var counterClockwise: CompassDirection {
        switch self {
        case .n:  return .nw
        case .nw: return .w
        case .w:  return .sw
        case .sw: return .s
        case .s:  return .se
        case .se: return .e
        case .e:  return .ne
        case .ne: return .n
        }
    }

    /// Opposite direction across the origin.
    public var opposite: CompassDirection {
        switch self {
        case .n:  return .s
        case .ne: return .sw
        case .e:  return .w
        case .se: return .nw
        case .s:  return .n
        case .sw: return .ne
        case .w:  return .e
        case .nw: return .se
        }
    }
}

/// Centralized tuning tokens for Veil interaction geometry.
public struct VeilTuningTokens: Sendable {
    /// Inner radius bounding the hollow neutral origin.
    public static let defaultInnerRadius: CGFloat = 42.0

    /// Outer radius of the main primary Reflex ring.
    public static let defaultOuterRadius: CGFloat = 112.0

    /// Radial overshoot forgiveness envelope (planning target: 12–20 pt).
    public static let radialOvershootTolerance: CGFloat = 16.0

    /// Angular seam hysteresis applied to armed sector (planning target: 5–8 degrees).
    public static let angularHysteresisDegrees: Double = 6.0

    /// Radial gap between the primary ring and the outer nested disclosure ring.
    public static let nestedGap: CGFloat = 8.0

    /// Radial thickness of the outer nested disclosure ring.
    public static let nestedRingThickness: CGFloat = 52.0

    /// Maximum total active radius including nested disclosure and overshoot.
    public static var maxActiveRadius: CGFloat {
        defaultOuterRadius + nestedGap + nestedRingThickness + radialOvershootTolerance
    }
}

/// Pure geometric model of an annular sector.
///
/// Single source of truth for drawing path, hit testing, debug overlay, and accessibility boundaries.
public struct VeilSectorGeometry: Sendable, Equatable {
    public let direction: CompassDirection
    public let center: CGPoint
    public let innerRadius: CGFloat
    public let outerRadius: CGFloat
    public let nominalCenterAngleDegrees: Double
    public let startAngleDegrees: Double
    public let endAngleDegrees: Double
    public let overshootTolerance: CGFloat

    public init(
        direction: CompassDirection,
        center: CGPoint = .zero,
        innerRadius: CGFloat = VeilTuningTokens.defaultInnerRadius,
        outerRadius: CGFloat = VeilTuningTokens.defaultOuterRadius,
        overshootTolerance: CGFloat = VeilTuningTokens.radialOvershootTolerance
    ) {
        self.direction = direction
        self.center = center
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
        self.nominalCenterAngleDegrees = direction.nominalAngleDegrees
        self.startAngleDegrees = direction.startAngleDegrees
        self.endAngleDegrees = direction.endAngleDegrees
        self.overshootTolerance = overshootTolerance
    }

    /// Custom sector constructor with arbitrary angle bounds (used for nested disclosures).
    public init(
        direction: CompassDirection,
        center: CGPoint,
        innerRadius: CGFloat,
        outerRadius: CGFloat,
        startAngleDegrees: Double,
        endAngleDegrees: Double,
        overshootTolerance: CGFloat = VeilTuningTokens.radialOvershootTolerance
    ) {
        self.direction = direction
        self.center = center
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
        self.nominalCenterAngleDegrees = (startAngleDegrees + endAngleDegrees) / 2.0
        self.startAngleDegrees = startAngleDegrees
        self.endAngleDegrees = endAngleDegrees
        self.overshootTolerance = overshootTolerance
    }

    /// Constructs the exact CGPath used for visible drawing and rendering.
    public func cgPath() -> CGPath {
        let path = CGMutablePath()

        let startRad = startAngleDegrees * .pi / 180.0
        let endRad = endAngleDegrees * .pi / 180.0

        // Handle normal vs zero-crossing arc
        if startAngleDegrees > endAngleDegrees {
            // Sector wraps across 0° / 360° (e.g. 337.5° to 22.5°)
            // Arc 1: Outer arc counter-clockwise from startRad to endRad
            path.addArc(center: center, radius: outerRadius, startAngle: startRad, endAngle: endRad, clockwise: false)
            // Arc 2: Inner arc clockwise from endRad to startRad
            path.addArc(center: center, radius: innerRadius, startAngle: endRad, endAngle: startRad, clockwise: true)
            path.closeSubpath()
        } else {
            // Standard arc counter-clockwise from start to end
            path.addArc(center: center, radius: outerRadius, startAngle: startRad, endAngle: endRad, clockwise: false)
            path.addArc(center: center, radius: innerRadius, startAngle: endRad, endAngle: startRad, clockwise: true)
            path.closeSubpath()
        }

        return path
    }

    /// Constructs the outer radial overshoot forgiveness path (for debug overlay only).
    public func overshootPath() -> CGPath {
        let path = CGMutablePath()
        let startRad = startAngleDegrees * .pi / 180.0
        let endRad = endAngleDegrees * .pi / 180.0
        let effectiveOuter = outerRadius + overshootTolerance

        if startAngleDegrees > endAngleDegrees {
            path.addArc(center: center, radius: effectiveOuter, startAngle: startRad, endAngle: endRad, clockwise: false)
            path.addArc(center: center, radius: outerRadius, startAngle: endRad, endAngle: startRad, clockwise: true)
            path.closeSubpath()
        } else {
            path.addArc(center: center, radius: effectiveOuter, startAngle: startRad, endAngle: endRad, clockwise: false)
            path.addArc(center: center, radius: outerRadius, startAngle: endRad, endAngle: startRad, clockwise: true)
            path.closeSubpath()
        }
        return path
    }

    /// Evaluates mathematical hit testing against a point, sharing exact boundary definitions with `cgPath()`.
    ///
    /// - Parameters:
    ///   - point: Query point in the coordinate system of `center`.
    ///   - isArmed: When true, radial overshoot tolerance and angular hysteresis are applied.
    ///   - hysteresisDegrees: Additional angular tolerance applied when armed.
    public func contains(point: CGPoint, isArmed: Bool = false, hysteresisDegrees: Double = 0.0) -> Bool {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = hypot(dx, dy)

        let effectiveOuter = isArmed ? (outerRadius + overshootTolerance) : outerRadius
        guard distance >= innerRadius && distance <= effectiveOuter else {
            return false
        }

        // Angle in radians in [-pi, pi], converted to [0, 360)
        var angle = atan2(dy, dx) * 180.0 / .pi
        if angle < 0.0 {
            angle += 360.0
        }

        return containsAngle(angle, hysteresisDegrees: isArmed ? hysteresisDegrees : 0.0)
    }

    /// Evaluates whether an angle (in degrees [0, 360)) falls within this sector's angular bounds.
    public func containsAngle(_ angle: Double, hysteresisDegrees: Double = 0.0) -> Bool {
        var start = startAngleDegrees - hysteresisDegrees
        var end = endAngleDegrees + hysteresisDegrees

        // Normalize
        if start < 0.0 { start += 360.0 }
        if end >= 360.0 { end -= 360.0 }

        if start > end {
            // Wraparound across 0° (e.g. East sector: start ~337.5°, end ~22.5°)
            return angle >= start || angle <= end
        } else {
            return angle >= start && angle <= end
        }
    }

    /// Verifies that mathematical hit testing exactly matches CoreGraphics path hit testing.
    public func verifyParity(point: CGPoint) -> (pathContains: Bool, mathContains: Bool, parityMatches: Bool) {
        let path = cgPath()
        let pathContains = path.contains(point)
        let mathContains = contains(point: point, isArmed: false)
        return (pathContains, mathContains, pathContains == mathContains)
    }
}

/// Hit test evaluation result for Veil interaction surface.
public enum VeilHitTestResult: Sendable, Equatable {
    /// Pointer is within the hollow neutral origin; interaction remains alive without triggering action.
    case neutralCenter

    /// Pointer is within a primary annular sector.
    case sector(CompassDirection, isArmed: Bool)

    /// Pointer is within a nested disclosure sector.
    case nestedSector(parentDirection: CompassDirection, choiceID: String)

    /// Pointer is outside all active interactive radii and tolerance envelopes.
    case outside
}

/// Geometry engine managing full annular Veil ring and optional nested outer disclosure ring.
public struct VeilRingGeometry: Sendable, Equatable {
    public let center: CGPoint
    public let innerRadius: CGFloat
    public let outerRadius: CGFloat
    public let sectors: [CompassDirection: VeilSectorGeometry]
    public var nestedSectors: [String: VeilSectorGeometry]

    public init(
        center: CGPoint = .zero,
        innerRadius: CGFloat = VeilTuningTokens.defaultInnerRadius,
        outerRadius: CGFloat = VeilTuningTokens.defaultOuterRadius,
        nestedSectors: [String: VeilSectorGeometry] = [:]
    ) {
        self.center = center
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
        self.nestedSectors = nestedSectors

        var map: [CompassDirection: VeilSectorGeometry] = [:]
        for dir in CompassDirection.allCases {
            map[dir] = VeilSectorGeometry(
                direction: dir,
                center: center,
                innerRadius: innerRadius,
                outerRadius: outerRadius
            )
        }
        self.sectors = map
    }

    /// Whether a point lies in the neutral hollow center origin.
    public func isInsideNeutralCenter(_ point: CGPoint) -> Bool {
        let dist = hypot(point.x - center.x, point.y - center.y)
        return dist < innerRadius
    }

    /// Full hit test evaluation against the annular Veil ring.
    ///
    /// Respects:
    /// 1. Neutral center traversal (no accidental dismissal).
    /// 2. Active nested disclosure ring if visible.
    /// 3. Angular seam hysteresis and radial overshoot on currently armed direction.
    /// 4. Primary annular sectors.
    /// 5. Outside boundary.
    public func hitTest(
        point: CGPoint,
        armedDirection: CompassDirection? = nil,
        activeNestedParent: CompassDirection? = nil
    ) -> VeilHitTestResult {
        // 1. Neutral center
        if isInsideNeutralCenter(point) {
            return .neutralCenter
        }

        // 2. Check nested disclosure ring if present
        if let parent = activeNestedParent {
            for (choiceID, nestedSec) in nestedSectors {
                if nestedSec.contains(point: point, isArmed: true) {
                    return .nestedSector(parentDirection: parent, choiceID: choiceID)
                }
            }
        }

        // 3. Armed sector with hysteresis and overshoot takes priority near boundary
        if let armed = armedDirection, let armedSec = sectors[armed] {
            if armedSec.contains(
                point: point,
                isArmed: true,
                hysteresisDegrees: VeilTuningTokens.angularHysteresisDegrees
            ) {
                return .sector(armed, isArmed: true)
            }
        }

        // 4. Primary annular sectors
        for (dir, sec) in sectors {
            if sec.contains(point: point, isArmed: false) {
                return .sector(dir, isArmed: false)
            }
        }

        // 5. Outside
        return .outside
    }

    /// Configures the outer nested disclosure ring geometry for a specific parent direction and choices.
    public mutating func configureNestedSectors(for direction: CompassDirection, choices: [VeilTargetChoice]) {
        guard let parentSec = sectors[direction], !choices.isEmpty else {
            nestedSectors.removeAll()
            return
        }

        var newNested: [String: VeilSectorGeometry] = [:]
        let inner = outerRadius + VeilTuningTokens.nestedGap
        let outer = inner + VeilTuningTokens.nestedRingThickness

        var span = parentSec.endAngleDegrees - parentSec.startAngleDegrees
        if span < 0 {
            span += 360.0
        }
        let step = span / Double(choices.count)

        for (i, choice) in choices.enumerated() {
            var subStart = parentSec.startAngleDegrees + Double(i) * step
            var subEnd = subStart + step
            if subStart >= 360.0 { subStart -= 360.0 }
            if subEnd >= 360.0 { subEnd -= 360.0 }

            newNested[choice.id] = VeilSectorGeometry(
                direction: direction,
                center: center,
                innerRadius: inner,
                outerRadius: outer,
                startAngleDegrees: subStart,
                endAngleDegrees: subEnd,
                overshootTolerance: VeilTuningTokens.radialOvershootTolerance
            )
        }
        self.nestedSectors = newNested
    }

    /// Clears any active nested disclosure geometry.
    public mutating func clearNestedSectors() {
        nestedSectors.removeAll()
    }
}
