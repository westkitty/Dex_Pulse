import Foundation
import ApplicationServices
import AppKit
import PulseCore

/// Provider for Tier 1: Explicit selected text acquired via Accessibility.
///
/// Strictly obeys:
/// - No synthetic `Cmd-C` or keyboard event injection.
/// - No clipboard mutation.
/// - Whitespace-only rejection (empty/whitespace drops to lower tiers).
/// - Secure field guard: password/secure fields block payload extraction and tag `.secureBlocked`.
public struct SelectedTextProvider: LensAcquisitionProvider {
    public let tier: LensPrecedenceTier = .selectedContent

    public init() {}

    public func acquireCandidate(at screenPoint: (x: Double, y: Double)?) -> LensCandidate? {
        guard AccessibilityAuthorizer.checkStatus() == .authorized else {
            return nil
        }

        let frontmost = NSWorkspace.shared.frontmostApplication
        let frontPID = frontmost?.processIdentifier
        let bundleID = frontmost?.bundleIdentifier
        let appName = frontmost?.localizedName ?? "Application"

        // 1. Check focused element of frontmost application
        var targetElement: AXUIElement?
        if let pid = frontPID {
            let appElement = AXUIElementCreateApplication(pid)
            var focusedRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedRef) == .success,
               let focused = focusedRef {
                targetElement = (focused as! AXUIElement)
            }
        }

        // Fallback to system-wide focused element if application probe was empty
        if targetElement == nil {
            let systemWide = AXUIElementCreateSystemWide()
            var focusedRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(systemWide, kAXFocusedUIElementAttribute as CFString, &focusedRef) == .success,
               let focused = focusedRef {
                targetElement = (focused as! AXUIElement)
            }
        }

        guard let element = targetElement else {
            return nil
        }

        // 2. Check role and subrole for secure / password fields
        var roleRef: CFTypeRef?
        var subroleRef: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleRef)
        _ = AXUIElementCopyAttributeValue(element, kAXSubroleAttribute as CFString, &subroleRef)

        let role = (roleRef as? String) ?? ""
        let subrole = (subroleRef as? String) ?? ""

        let isSecureField = role == "AXSecureTextField" ||
                            subrole == "AXSecureTextField" ||
                            subrole == "NSSecureTextField"

        if isSecureField {
            // NEVER extract or log secret text from secure fields (SEC-001)
            let prov = ObjectProvenance(
                sourceAppBundle: bundleID,
                sourcePID: frontPID,
                acquisitionMethod: "accessibility.secure_field_blocked",
                axRole: role.isEmpty ? "AXSecureTextField" : role
            )
            let blockedObject = SelectedTextObject(
                text: "",
                provenance: prov,
                privacyClass: .secureBlocked,
                confidence: 1.0
            )
            return LensCandidate(
                tier: .selectedContent,
                object: blockedObject,
                confidence: 1.0,
                acquisitionReason: "Secure password field detected in \(appName); payload reading blocked by policy"
            )
        }

        // 3. Query selected text
        var selectedTextRef: CFTypeRef?
        let axError = AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &selectedTextRef)
        guard axError == .success, let rawSelected = selectedTextRef as? String else {
            return nil
        }

        // 4. Reject empty or whitespace-only selections
        if rawSelected.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return nil
        }

        let prov = ObjectProvenance(
            sourceAppBundle: bundleID,
            sourcePID: frontPID,
            acquisitionMethod: "accessibility.kAXSelectedTextAttribute",
            axRole: role
        )

        let object = SelectedTextObject(
            text: rawSelected,
            provenance: prov,
            privacyClass: .ordinary,
            confidence: 1.0
        )

        return LensCandidate(
            tier: .selectedContent,
            object: object,
            confidence: 1.0,
            acquisitionReason: "Explicit text selection in \(appName) (\(rawSelected.count) chars)"
        )
    }
}
