import Foundation
import ApplicationServices
import AppKit
import PulseCore

/// Provider for Tier 2: UI element under pointer via AX hit testing.
///
/// Pure inspection only: never triggers actions or mutates the element.
public struct PointerElementProvider: LensAcquisitionProvider {
    public let tier: LensPrecedenceTier = .pointerUIElement

    public init() {}

    public func acquireCandidate(at screenPoint: (x: Double, y: Double)?) -> LensCandidate? {
        guard AccessibilityAuthorizer.checkStatus() == .authorized else {
            return nil
        }

        let targetPoint: CGPoint
        if let pt = screenPoint {
            targetPoint = CGPoint(x: pt.x, y: pt.y)
        } else {
            targetPoint = LensCoordinates.currentMouseLocationInCG()
        }

        let systemWide = AXUIElementCreateSystemWide()
        AXTimeoutHelper.applyTimeout(to: systemWide)
        var hitElementRef: AXUIElement?

        let axError = AXUIElementCopyElementAtPosition(
            systemWide,
            Float(targetPoint.x),
            Float(targetPoint.y),
            &hitElementRef
        )

        guard axError == .success, let hitElement = hitElementRef else {
            return nil
        }
        AXTimeoutHelper.applyTimeout(to: hitElement)

        // 1. Extract Role & Subrole
        var roleRef: CFTypeRef?
        var subroleRef: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(hitElement, kAXRoleAttribute as CFString, &roleRef)
        _ = AXUIElementCopyAttributeValue(hitElement, kAXSubroleAttribute as CFString, &subroleRef)
        let role = (roleRef as? String) ?? "AXUnknown"
        let subrole = subroleRef as? String

        // Ignore root desktop / system wide elements if nothing specific was hit
        if role == "AXSystemWide" || role == "AXDesktop" {
            return nil
        }

        // 2. Extract Title / Description / Label
        var titleRef: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(hitElement, kAXTitleAttribute as CFString, &titleRef)
        if titleRef == nil {
            _ = AXUIElementCopyAttributeValue(hitElement, kAXDescriptionAttribute as CFString, &titleRef)
        }
        let title = titleRef as? String

        // 3. Extract Owning Application
        var pid: pid_t = 0
        _ = AXUIElementGetPid(hitElement, &pid)
        let runningApp = pid > 0 ? NSRunningApplication(processIdentifier: pid) : nil
        let appName = runningApp?.localizedName ?? "Unknown"
        let bundleID = runningApp?.bundleIdentifier

        // 4. Secure check
        let isSecure = role == "AXSecureTextField" ||
                       subrole == "AXSecureTextField" ||
                       subrole == "NSSecureTextField"

        // 5. Value (only read if non-secure)
        var valueDescription: String?
        if !isSecure {
            var valRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(hitElement, kAXValueAttribute as CFString, &valRef) == .success {
                if let strVal = valRef as? String {
                    valueDescription = String(strVal.prefix(60))
                }
            }
        }

        // 6. Enabled state
        var enabledRef: CFTypeRef?
        let isEnabled: Bool
        if AXUIElementCopyAttributeValue(hitElement, kAXEnabledAttribute as CFString, &enabledRef) == .success,
           let en = enabledRef as? Bool {
            isEnabled = en
        } else {
            isEnabled = true
        }

        // 7. Screen Frame
        var frameTuple: (x: Double, y: Double, width: Double, height: Double)?
        var posRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        var elemPos = CGPoint.zero
        var elemSize = CGSize.zero

        if AXUIElementCopyAttributeValue(hitElement, kAXPositionAttribute as CFString, &posRef) == .success,
           let posVal = posRef, CFGetTypeID(posVal) == AXValueGetTypeID() {
            AXValueGetValue(posVal as! AXValue, .cgPoint, &elemPos)
        }
        if AXUIElementCopyAttributeValue(hitElement, kAXSizeAttribute as CFString, &sizeRef) == .success,
           let sizeVal = sizeRef, CFGetTypeID(sizeVal) == AXValueGetTypeID() {
            AXValueGetValue(sizeVal as! AXValue, .cgSize, &elemSize)
        }
        if elemSize.width > 0 && elemSize.height > 0 {
            frameTuple = (Double(elemPos.x), Double(elemPos.y), Double(elemSize.width), Double(elemSize.height))
        }

        // 8. Available Actions
        var actions: [String] = []
        var actionsRef: CFArray?
        if AXUIElementCopyActionNames(hitElement, &actionsRef) == .success,
           let acts = actionsRef as? [String] {
            actions = acts
        }

        let prov = ObjectProvenance(
            sourceAppBundle: bundleID,
            sourcePID: pid > 0 ? pid : nil,
            acquisitionMethod: "accessibility.AXUIElementCopyElementAtPosition",
            axRole: role
        )

        let object = UIElementObject(
            source: .pointerAX,
            role: role,
            subrole: subrole,
            title: title,
            valueDescription: valueDescription,
            applicationName: appName,
            bundleIdentifier: bundleID,
            pid: pid > 0 ? pid : nil,
            isEnabled: isEnabled,
            isSecure: isSecure,
            availableActions: actions,
            screenFrame: frameTuple,
            provenance: prov,
            privacyClass: isSecure ? .secureBlocked : .ordinary,
            confidence: 1.0
        )

        let reason = "UI element under pointer: [\(role)] \(title.map { "'\($0)'" } ?? "") in \(appName)"

        return LensCandidate(
            tier: .pointerUIElement,
            object: object,
            confidence: 1.0,
            acquisitionReason: reason
        )
    }
}
