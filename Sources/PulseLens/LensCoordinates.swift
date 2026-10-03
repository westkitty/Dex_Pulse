import Foundation
import CoreGraphics
import AppKit

/// Centralized coordinate conversion between AppKit (bottom-left origin, Y-up)
/// and CoreGraphics / Accessibility (top-left origin, Y-down).
public struct LensCoordinates: Sendable {
    
    /// Returns the primary display height in points.
    public static func primaryScreenHeight() -> CGFloat {
        if let primary = NSScreen.screens.first {
            return primary.frame.height
        }
        let bounds = CGDisplayBounds(CGMainDisplayID())
        return bounds.height > 0 ? bounds.height : 1080.0
    }

    /// Converts an AppKit screen point (bottom-left origin) to CoreGraphics/AX point (top-left origin).
    public static func toCG(appKitPoint: CGPoint, primaryHeight: CGFloat? = nil) -> CGPoint {
        let height = primaryHeight ?? primaryScreenHeight()
        return CGPoint(x: appKitPoint.x, y: height - appKitPoint.y)
    }

    /// Converts a CoreGraphics/AX screen point (top-left origin) to AppKit screen point (bottom-left origin).
    public static func toAppKit(cgPoint: CGPoint, primaryHeight: CGFloat? = nil) -> CGPoint {
        let height = primaryHeight ?? primaryScreenHeight()
        return CGPoint(x: cgPoint.x, y: height - cgPoint.y)
    }

    /// Converts an AppKit screen rect to CoreGraphics/AX screen rect.
    public static func toCG(appKitRect: NSRect, primaryHeight: CGFloat? = nil) -> CGRect {
        let height = primaryHeight ?? primaryScreenHeight()
        let cgY = height - (appKitRect.origin.y + appKitRect.height)
        return CGRect(x: appKitRect.origin.x, y: cgY, width: appKitRect.width, height: appKitRect.height)
    }

    /// Converts a CoreGraphics/AX screen rect to AppKit screen rect.
    public static func toAppKit(cgRect: CGRect, primaryHeight: CGFloat? = nil) -> NSRect {
        let height = primaryHeight ?? primaryScreenHeight()
        let appKitY = height - (cgRect.origin.y + cgRect.height)
        return NSRect(x: cgRect.origin.x, y: appKitY, width: cgRect.width, height: cgRect.height)
    }

    /// Obtains current mouse location in CoreGraphics/AX coordinates.
    public static func currentMouseLocationInCG() -> CGPoint {
        let appKitPoint = NSEvent.mouseLocation
        return toCG(appKitPoint: appKitPoint)
    }

    /// Obtains current mouse location in AppKit coordinates.
    public static func currentMouseLocationInAppKit() -> CGPoint {
        return NSEvent.mouseLocation
    }
}
