import Foundation
import ApplicationServices
import AppKit
import PulseCore

/// Provider for Tier 3: Focused Accessibility element.
public struct FocusedElementProvider: LensAcquisitionProvider {
    public let tier: LensPrecedenceTier = .focusedAXElement

    public init() {}

    public func acquireCandidate(at screenPoint: (x: Double, y: Double)?) -> LensCandidate? {
        guard AccessibilityAuthorizer.checkStatus() == .authorized else {
            return nil
        }

        let frontmost = NSWorkspace.shared.frontmostApplication
        let frontPID = frontmost?.processIdentifier
        let appName = frontmost?.localizedName ?? "Application"
        let bundleID = frontmost?.bundleIdentifier

        var focusedElementRef: AXUIElement?

        if let pid = frontPID {
            let appElement = AXUIElementCreateApplication(pid)
            var focusedRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedRef) == .success,
               let focused = focusedRef {
                focusedElementRef = (focused as! AXUIElement)
            }
        }

        if focusedElementRef == nil {
            let systemWide = AXUIElementCreateSystemWide()
            var focusedRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedRef) == .success,
               let focused = focusedRef {
                focusedElementRef = (focused as! AXUIElement)
            }
        }

        guard let focusedElement = focusedElementRef else {
            return nil
        }

        var roleRef: CFTypeRef?
        var subroleRef: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(focusedElement, kAXRoleAttribute as CFString, &roleRef)
        _ = AXUIElementCopyAttributeValue(focusedElement, kAXSubroleAttribute as CFString, &subroleRef)

        let role = (roleRef as? String) ?? "AXUnknown"
        let subrole = subroleRef as? String

        // Ignore root elements
        if role == "AXSystemWide" || role == "AXApplication" || role == "AXDesktop" {
            return nil
        }

        var titleRef: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(focusedElement, kAXTitleAttribute as CFString, &titleRef)
        if titleRef == nil {
            _ = AXUIElementCopyAttributeValue(focusedElement, kAXDescriptionAttribute as CFString, &titleRef)
        }
        let title = titleRef as? String

        let isSecure = role == "AXSecureTextField" ||
                       subrole == "AXSecureTextField" ||
                       subrole == "NSSecureTextField"

        let prov = ObjectProvenance(
            sourceAppBundle: bundleID,
            sourcePID: frontPID,
            acquisitionMethod: "accessibility.kAXFocusedUIElementAttribute",
            axRole: role
        )

        let object = FocusedElementObject(
            role: role,
            subrole: subrole,
            title: title,
            applicationName: appName,
            pid: frontPID,
            isSecure: isSecure,
            provenance: prov,
            privacyClass: isSecure ? .secureBlocked : .ordinary,
            confidence: 1.0
        )

        return LensCandidate(
            tier: .focusedAXElement,
            object: object,
            confidence: 1.0,
            acquisitionReason: "Focused element: [\(role)] \(title.map { "'\($0)'" } ?? "") in \(appName)"
        )
    }
}
