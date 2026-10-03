import Foundation
import ApplicationServices
import AppKit
import PulseCore

/// Provider for Tier 4: Frontmost application or window.
public struct FrontmostAppProvider: LensAcquisitionProvider {
    public let tier: LensPrecedenceTier = .frontmostAppOrWindow

    public init() {}

    public func acquireCandidate(at screenPoint: (x: Double, y: Double)?) -> LensCandidate? {
        guard let frontmost = NSWorkspace.shared.frontmostApplication else {
            return nil
        }

        let pid = frontmost.processIdentifier
        let appName = frontmost.localizedName ?? "Application"
        let bundleID = frontmost.bundleIdentifier

        var windowTitle: String?

        if AccessibilityAuthorizer.checkStatus() == .authorized {
            let appElement = AXUIElementCreateApplication(pid)
            var windowRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &windowRef) == .success,
               let windowElem = windowRef {
                var titleRef: CFTypeRef?
                if AXUIElementCopyAttributeValue((windowElem as! AXUIElement), kAXTitleAttribute as CFString, &titleRef) == .success {
                    windowTitle = titleRef as? String
                }
            }
        }

        let prov = ObjectProvenance(
            sourceAppBundle: bundleID,
            sourcePID: pid,
            acquisitionMethod: windowTitle != nil ? "workspace.frontmostWindow" : "workspace.frontmostApplication",
            windowTitle: windowTitle
        )

        let object: any PulseObject
        let reason: String

        if let title = windowTitle, !title.isEmpty {
            object = WindowObject(
                windowTitle: title,
                applicationName: appName,
                pid: pid,
                provenance: prov,
                privacyClass: .ordinary,
                confidence: 1.0
            )
            reason = "Frontmost window: '\(title)' (\(appName))"
        } else {
            object = ApplicationObject(
                applicationName: appName,
                bundleIdentifier: bundleID,
                pid: pid,
                provenance: prov,
                privacyClass: .ordinary,
                confidence: 1.0
            )
            reason = "Frontmost application: \(appName) [PID: \(pid)]"
        }

        return LensCandidate(
            tier: .frontmostAppOrWindow,
            object: object,
            confidence: 1.0,
            acquisitionReason: reason
        )
    }
}
