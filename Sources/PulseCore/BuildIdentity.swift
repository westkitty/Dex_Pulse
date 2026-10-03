import Foundation

/// Static build identity and version diagnostics for DEX//PULSE.
public struct BuildIdentity: Sendable {
    public static let productName = "DEX//PULSE"
    public static let bundleIdentifier = "com.westkitty.dexpulse"
    public static let version = "0.1.0"
    public static let buildNumber = "1"
    public static let phase = "Phase 5 Object Layout Freeze Trial"
    public static let targetPlatform = "macOS 14+ (Apple Silicon)"
    public static let runtimeDependencies = "Native Swift/AppKit/CoreAnimation/Metal (0 third-party daemons)"

    /// Returns a human-readable diagnostic banner for CLI and logs.
    public static var banner: String {
        """
        \(productName) v\(version) (\(phase))
        Bundle ID: \(bundleIdentifier)
        Platform: \(targetPlatform)
        Runtime: \(runtimeDependencies)
        """
    }
}
