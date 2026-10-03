import Foundation
import ApplicationServices
import AppKit
import PulseCore

/// Provider for Tier 1: Explicit selected files (e.g. from Finder or file browser).
public struct SelectedFileProvider: LensAcquisitionProvider {
    public let tier: LensPrecedenceTier = .selectedContent

    public init() {}

    public func acquireCandidate(at screenPoint: (x: Double, y: Double)?) -> LensCandidate? {
        guard AccessibilityAuthorizer.checkStatus() == .authorized else {
            return nil
        }

        let frontmost = NSWorkspace.shared.frontmostApplication
        guard let bundleID = frontmost?.bundleIdentifier, bundleID == "com.apple.finder" else {
            return nil
        }

        let frontPID = frontmost?.processIdentifier
        let appName = frontmost?.localizedName ?? "Finder"

        guard let pid = frontPID else { return nil }
        let appElement = AXUIElementCreateApplication(pid)
        AXTimeoutHelper.applyTimeout(to: appElement)

        // Query focused element or window
        var focusedRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appElement, kAXFocusedUIElementAttribute as CFString, &focusedRef) == .success,
              let focused = focusedRef else {
            return nil
        }
        let focusedElement = (focused as! AXUIElement)
        AXTimeoutHelper.applyTimeout(to: focusedElement)

        var selectedPaths: [String] = []

        // 1. Try kAXSelectedChildrenAttribute
        var selectedChildrenRef: CFTypeRef?
        if AXUIElementCopyAttributeValue(focusedElement, "AXSelectedChildren" as CFString, &selectedChildrenRef) == .success,
           let children = selectedChildrenRef as? [AXUIElement] {
            for child in children.prefix(50) {
                AXTimeoutHelper.applyTimeout(to: child)
                var urlRef: CFTypeRef?
                if AXUIElementCopyAttributeValue(child, "AXURL" as CFString, &urlRef) == .success,
                   let ref = urlRef {
                    if let url = ref as? URL, url.isFileURL {
                        selectedPaths.append(url.path)
                    } else if let urlStr = ref as? String,
                              let url = URL(string: urlStr), url.isFileURL {
                        selectedPaths.append(url.path)
                    }
                } else {
                    var filenameRef: CFTypeRef?
                    if AXUIElementCopyAttributeValue(child, "AXFilenames" as CFString, &filenameRef) == .success,
                       let filenames = filenameRef as? [String] {
                        selectedPaths.append(contentsOf: filenames)
                    }
                }
            }
        }

        // 2. Try kAXFilenamesAttribute directly on focused element
        if selectedPaths.isEmpty {
            var filenameRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(focusedElement, "AXFilenames" as CFString, &filenameRef) == .success,
               let filenames = filenameRef as? [String] {
                selectedPaths.append(contentsOf: filenames)
            }
        }

        // 3. Try kAXURLAttribute directly
        if selectedPaths.isEmpty {
            var urlRef: CFTypeRef?
            if AXUIElementCopyAttributeValue(focusedElement, "AXURL" as CFString, &urlRef) == .success,
               let ref = urlRef {
                if let url = ref as? URL, url.isFileURL {
                    selectedPaths.append(url.path)
                } else if let urlStr = ref as? String,
                          let url = URL(string: urlStr), url.isFileURL {
                    selectedPaths.append(url.path)
                }
            }
        }

        guard !selectedPaths.isEmpty else {
            return nil
        }

        let prov = ObjectProvenance(
            sourceAppBundle: bundleID,
            sourcePID: frontPID,
            acquisitionMethod: "accessibility.finder.selected_files"
        )

        let object = SelectedFileObject(
            filePaths: selectedPaths,
            provenance: prov,
            privacyClass: .ordinary,
            confidence: 1.0
        )

        return LensCandidate(
            tier: .selectedContent,
            object: object,
            confidence: 1.0,
            acquisitionReason: "Explicit file selection in \(appName) (\(selectedPaths.count) items)"
        )
    }
}
