import Foundation
import CoreGraphics
#if canImport(AppKit)
import AppKit
#endif

/// Result of placing the Veil annular wheel on a target display.
///
/// Invariant: Causal origin is preserved even when the Veil center is shifted
/// to fit within screen margins (INV-034).
public struct VeilPlacementResult: Sendable, Equatable {
    /// The computed center point of the Veil wheel in screen coordinates.
    public let veilCenter: CGPoint

    /// The original causal origin (e.g. pointer click or AX center) before clamping.
    public let causalOrigin: CGPoint

    /// Vector offset from causalOrigin to veilCenter.
    public var translationOffset: CGVector {
        CGVector(dx: veilCenter.x - causalOrigin.x, dy: veilCenter.y - causalOrigin.y)
    }

    /// Whether the Veil had to be shifted away from screen edges or corners.
    public var isShifted: Bool {
        abs(translationOffset.dx) > 0.001 || abs(translationOffset.dy) > 0.001
    }

    /// Visible bounds of the screen enclosing the Veil (excluding Dock and Menu Bar).
    public let visibleFrame: CGRect

    /// Full bounds of the target screen.
    public let screenFrame: CGRect

    public init(
        veilCenter: CGPoint,
        causalOrigin: CGPoint,
        visibleFrame: CGRect,
        screenFrame: CGRect
    ) {
        self.veilCenter = veilCenter
        self.causalOrigin = causalOrigin
        self.visibleFrame = visibleFrame
        self.screenFrame = screenFrame
    }
}

/// Computes minimal-translation placement of the Veil annular wheel.
///
/// Respects:
/// - Screen visibleFrame bounds (avoiding Dock and Menu Bar).
/// - Multi-monitor coordinate spaces, including secondary displays with negative origins.
/// - Preservation of causalOrigin identity for connector lines or strand origins.
public struct VeilPlacementPlanner: Sendable {

    /// Pure geometric placement computation given an arbitrary visibleFrame and screenFrame.
    ///
    /// - Parameters:
    ///   - causalOrigin: Global coordinate point of trigger.
    ///   - visibleFrame: Usable screen rect (Dock/menu bar excluded).
    ///   - screenFrame: Full physical screen rect.
    ///   - radius: Interactive outer radius of the Veil wheel.
    ///   - margin: Safety margin from screen edges in points.
    /// - Returns: Fully resolved `VeilPlacementResult`.
    public static func computePlacement(
        causalOrigin: CGPoint,
        visibleFrame: CGRect,
        screenFrame: CGRect,
        radius: CGFloat = VeilTuningTokens.maxActiveRadius,
        margin: CGFloat = 8.0
    ) -> VeilPlacementResult {
        let requiredClearance = radius + margin

        var targetX = causalOrigin.x
        var targetY = causalOrigin.y

        // Horizontal clamping
        let minX = visibleFrame.minX + requiredClearance
        let maxX = visibleFrame.maxX - requiredClearance
        if maxX < minX {
            // Screen narrower than 2 * requiredClearance; center horizontally
            targetX = visibleFrame.midX
        } else if targetX < minX {
            targetX = minX
        } else if targetX > maxX {
            targetX = maxX
        }

        // Vertical clamping
        let minY = visibleFrame.minY + requiredClearance
        let maxY = visibleFrame.maxY - requiredClearance
        if maxY < minY {
            // Screen shorter than 2 * requiredClearance; center vertically
            targetY = visibleFrame.midY
        } else if targetY < minY {
            targetY = minY
        } else if targetY > maxY {
            targetY = maxY
        }

        return VeilPlacementResult(
            veilCenter: CGPoint(x: targetX, y: targetY),
            causalOrigin: causalOrigin,
            visibleFrame: visibleFrame,
            screenFrame: screenFrame
        )
    }

    #if canImport(AppKit)
    /// Resolves placement against actual or synthetic `NSScreen` objects.
    public static func resolvePlacement(
        causalOrigin: CGPoint,
        screens: [NSScreen] = NSScreen.screens,
        radius: CGFloat = VeilTuningTokens.maxActiveRadius,
        margin: CGFloat = 8.0
    ) -> VeilPlacementResult {
        // Find screen containing causalOrigin
        let targetScreen = screens.first(where: { $0.frame.contains(causalOrigin) })
            ?? screens.first(where: { $0.visibleFrame.contains(causalOrigin) })
            ?? NSScreen.main
            ?? screens.first

        let screenFrame = targetScreen?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
        let visibleFrame = targetScreen?.visibleFrame ?? screenFrame

        return computePlacement(
            causalOrigin: causalOrigin,
            visibleFrame: visibleFrame,
            screenFrame: screenFrame,
            radius: radius,
            margin: margin
        )
    }
    #endif
}
