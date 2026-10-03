import Foundation
import AppKit
import PulseCore
import PulseVisuals

/// Non-activating borderless panel for Phase 0/1 debug Pulse overlay.
///
/// Invariants:
/// - Does not steal key or main focus from the originating app.
/// - Borderless and floating across spaces.
/// - Dismisses predictably on Escape or hotkey re-trigger.
/// - Does not mutate pasteboard contents or changeCount.
public final class DebugPulseOverlayWindow: NSPanel {
    public override var canBecomeKey: Bool { false }
    public override var canBecomeMain: Bool { false }

    public init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        self.hasShadow = true
        self.isReleasedWhenClosed = false
    }
}

/// Controller managing presentation and lifecycle of the Phase 0/1 debug Pulse surface.
@MainActor
public final class DebugPulseOverlayController: NSObject {
    private var window: DebugPulseOverlayWindow?
    private let stateMachine: PulseStateMachine
    private var localKeyMonitor: Any?
    private var autoDismissTimer: Timer?

    public init(stateMachine: PulseStateMachine) {
        self.stateMachine = stateMachine
        super.init()
    }

    public var isVisible: Bool {
        window?.isVisible ?? false
    }

    /// Toggles the overlay on/off from hotkey.
    public func toggle(at screenPoint: CGPoint? = nil) {
        if isVisible {
            dismiss()
        } else {
            present(at: screenPoint)
        }
    }

    /// Presents the debug overlay at the designated point (or near mouse pointer).
    public func present(at screenPoint: CGPoint? = nil) {
        do {
            try stateMachine.transition(to: .pulse)
        } catch {
            // If already active or invalid transition, attempt clean cancel first
            stateMachine.cancel()
            _ = try? stateMachine.transition(to: .pulse)
        }

        let mouseLocation = screenPoint ?? NSEvent.mouseLocation
        let size = PulseVisualsTheme.defaultOverlaySize

        // Center on mouse position, clamping to screen bounds
        let screen = NSScreen.screens.first { NSPointInRect(mouseLocation, $0.frame) } ?? NSScreen.main
        let screenFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)

        var originX = mouseLocation.x - (size.width / 2)
        var originY = mouseLocation.y - (size.height / 2)

        originX = max(screenFrame.minX + 20, min(originX, screenFrame.maxX - size.width - 20))
        originY = max(screenFrame.minY + 20, min(originY, screenFrame.maxY - size.height - 20))

        let windowRect = NSRect(x: originX, y: originY, width: size.width, height: size.height)

        if window == nil {
            let win = DebugPulseOverlayWindow(contentRect: windowRect)
            win.contentView = createContentView(bounds: NSRect(origin: .zero, size: size), originPoint: mouseLocation)
            self.window = win
        } else {
            window?.setFrame(windowRect, display: true)
            window?.contentView = createContentView(bounds: NSRect(origin: .zero, size: size), originPoint: mouseLocation)
        }

        guard let win = window else { return }

        win.alphaValue = 0.0
        win.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.08
            win.animator().alphaValue = 1.0
        }

        _ = try? stateMachine.transition(to: .veil)

        // Setup local Escape key monitoring
        setupKeyMonitor()
    }

    /// Dismisses the overlay and transitions cleanly through RECEDE to QUIET.
    public func dismiss() {
        guard let win = window, win.isVisible else {
            stateMachine.cancel()
            return
        }

        tearDownKeyMonitor()
        autoDismissTimer?.invalidate()
        autoDismissTimer = nil

        _ = try? stateMachine.transition(to: .recede)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.08
            win.animator().alphaValue = 0.0
        }, completionHandler: { [weak self] in
            win.orderOut(nil)
            self?.stateMachine.resetToQuiet()
        })
    }

    private func setupKeyMonitor() {
        tearDownKeyMonitor()
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape
                self?.dismiss()
                return nil
            }
            return event
        }
    }

    private func tearDownKeyMonitor() {
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
    }

    private func createContentView(bounds: NSRect, originPoint: CGPoint) -> NSView {
        let view = NSView(frame: bounds)
        view.wantsLayer = true

        guard let layer = view.layer else { return view }

        let t = PulseVisualsTheme.self
        layer.backgroundColor = CGColor(
            red: t.obsidianField.r,
            green: t.obsidianField.g,
            blue: t.obsidianField.b,
            alpha: t.obsidianField.a
        )
        layer.cornerRadius = t.cornerRadius
        layer.borderColor = CGColor(
            red: t.borderRestrained.r,
            green: t.borderRestrained.g,
            blue: t.borderRestrained.b,
            alpha: t.borderRestrained.a
        )
        layer.borderWidth = 1.5

        // Pulse Point indicator (azure accent dot)
        let dot = CALayer()
        let dotSize = t.pulsePointDiameter
        dot.frame = CGRect(x: 20, y: bounds.height - 36, width: dotSize, height: dotSize)
        dot.cornerRadius = dotSize / 2
        dot.backgroundColor = CGColor(
            red: t.azureAccent.r,
            green: t.azureAccent.g,
            blue: t.azureAccent.b,
            alpha: t.azureAccent.a
        )
        layer.addSublayer(dot)

        // Title label: DEX // PULSE
        let titleLabel = NSTextField(labelWithString: "DEX // PULSE")
        titleLabel.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = NSColor(
            red: t.textPrimary.r,
            green: t.textPrimary.g,
            blue: t.textPrimary.b,
            alpha: t.textPrimary.a
        )
        titleLabel.frame = NSRect(x: 44, y: bounds.height - 40, width: 140, height: 20)
        view.addSubview(titleLabel)

        // State pill: [VEIL]
        let stateLabel = NSTextField(labelWithString: "[VEIL]")
        stateLabel.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .semibold)
        stateLabel.textColor = NSColor(
            red: t.azureAccent.r,
            green: t.azureAccent.g,
            blue: t.azureAccent.b,
            alpha: t.azureAccent.a
        )
        stateLabel.frame = NSRect(x: bounds.width - 90, y: bounds.height - 40, width: 70, height: 20)
        stateLabel.alignment = .right
        view.addSubview(stateLabel)

        // Subtitle / context description
        let contextLabel = NSTextField(labelWithString: "Phase 0/1 Native Reflex Overlay")
        contextLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        contextLabel.textColor = NSColor(
            red: t.textSecondary.r,
            green: t.textSecondary.g,
            blue: t.textSecondary.b,
            alpha: t.textSecondary.a
        )
        contextLabel.frame = NSRect(x: 20, y: bounds.height - 70, width: bounds.width - 40, height: 18)
        view.addSubview(contextLabel)

        // Origin and hotkey metrics
        let originString = String(format: "Origin: (%.0f, %.0f)", originPoint.x, originPoint.y)
        let metricsLabel = NSTextField(labelWithString: "\(originString)  •  Focus: Non-activating")
        metricsLabel.font = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        metricsLabel.textColor = NSColor(
            red: t.textSecondary.r,
            green: t.textSecondary.g,
            blue: t.textSecondary.b,
            alpha: 0.8
        )
        metricsLabel.frame = NSRect(x: 20, y: bounds.height - 94, width: bounds.width - 40, height: 16)
        view.addSubview(metricsLabel)

        // Dismiss instructions
        let hintLabel = NSTextField(labelWithString: "Press ⇧⌘Space or Esc to dismiss (clean recede)")
        hintLabel.font = NSFont.systemFont(ofSize: 10, weight: .regular)
        hintLabel.textColor = NSColor(
            red: t.textSecondary.r,
            green: t.textSecondary.g,
            blue: t.textSecondary.b,
            alpha: 0.6
        )
        hintLabel.frame = NSRect(x: 20, y: 16, width: bounds.width - 40, height: 16)
        view.addSubview(hintLabel)

        return view
    }
}
