import Foundation
import ApplicationServices

/// Helper utility ensuring all cross-process Accessibility queries are bounded
/// by native messaging timeouts so an unresponsive application cannot freeze Lens.
public struct AXTimeoutHelper: Sendable {
    public static let defaultTimeoutSeconds: Float = 0.5

    /// Applies native messaging timeout to an AXUIElement reference.
    @discardableResult
    public static func applyTimeout(to element: AXUIElement, seconds: Float = defaultTimeoutSeconds) -> AXError {
        AXUIElementSetMessagingTimeout(element, seconds)
    }
}
