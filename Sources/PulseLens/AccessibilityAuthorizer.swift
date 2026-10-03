import Foundation
import ApplicationServices

/// Authorization status for macOS Accessibility (AX) APIs.
public enum AccessibilityAuthorizationStatus: String, Sendable, Codable {
    case authorized = "authorized"
    case denied = "denied"
    case unavailable = "unavailable"
}

/// Non-invasive probe for process Accessibility trust.
///
/// Follows strict non-nagging doctrine: never invokes prompts on the hot path
/// and never blocks the calling thread.
public struct AccessibilityAuthorizer: Sendable {
    public init() {}

    /// Checks current process Accessibility authorization without presenting a system prompt.
    public static func checkStatus() -> AccessibilityAuthorizationStatus {
        let isTrusted = AXIsProcessTrusted()
        return isTrusted ? .authorized : .denied
    }

    /// Explicitly request system trust dialog only when deliberately invoked by user action.
    public static func requestAuthorizationPrompt() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
}
