import Foundation
import CoreGraphics
import PulseCore

/// Design tokens for DEX//PULSE visual surfaces.
///
/// Invariant: Obsidian field, restrained cyan/azure accents, controlled geometry.
public struct PulseVisualsTheme: Sendable {
    // Colors represented in normalized RGBA
    public static let obsidianField = (r: 0.04, g: 0.04, b: 0.05, a: 0.92)
    public static let azureAccent   = (r: 0.00, g: 0.66, b: 0.82, a: 1.00)
    public static let borderRestrained = (r: 0.15, g: 0.25, b: 0.35, a: 0.60)
    public static let textPrimary   = (r: 0.95, g: 0.96, b: 0.98, a: 1.00)
    public static let textSecondary = (r: 0.60, g: 0.65, b: 0.70, a: 1.00)

    // Geometry tokens
    public static let defaultOverlaySize = CGSize(width: 380, height: 180)
    public static let cornerRadius: CGFloat = 12.0
    public static let pulsePointDiameter: CGFloat = 16.0
}

/// Status of the visual rendering engine.
public enum VisualRendererState: String, Sendable, CustomStringConvertible {
    case coreAnimationAvailable = "Core Animation debug Pulsefront available"
    case metalStrandsPendingPhase6 = "Metal Strand renderer pending Phase 6 (canonical fixtures loaded)"

    public var description: String { rawValue }
}

/// Interface for future canonical Strand renderer.
public protocol StrandRenderingProtocol: Sendable {
    var rendererState: VisualRendererState { get }
}

/// Visual resource lookup and shader path anchoring.
public struct VisualResourceLocator: Sendable {
    /// Returns the path to the future Shaders directory.
    public static func shadersDirectoryURL() -> URL? {
        // Points to relative Sources/PulseVisuals/Shaders
        return Bundle.main.resourceURL?.appendingPathComponent("Shaders")
    }
}
