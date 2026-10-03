import Foundation
#if canImport(AppKit)
import AppKit
import PulseCore
import PulseLens

/// Non-activating borderless panel hosting the annular Veil interaction view.
///
/// Invariants:
/// - Never steals key or main focus from the target application (INV-FOCUS).
/// - Borderless, transparent, and floating across all Spaces.
/// - Passes clicks through transparent corners and neutral center to underlying windows.
public final class VeilWindow: NSPanel {
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
        self.hasShadow = false
        self.isReleasedWhenClosed = false
        self.acceptsMouseMovedEvents = true
    }
}

/// Controller orchestrating the presentation, interaction, and dismissal
/// lifecycle of the Veil annular interface.
@MainActor
public final class VeilInteractionController: NSObject {
    private var window: VeilWindow?
    private var veilView: VeilView?
    private let stateMachine: PulseStateMachine
    private var pointerTracker: VeilPointerTracker?
    private var keyboardNavigator: VeilKeyboardNavigator?

    private var localKeyMonitor: Any?
    private var globalMouseMonitor: Any?

    public var showDebugGeometry: Bool = false {
        didSet { veilView?.showDebugGeometry = showDebugGeometry }
    }

    public init(stateMachine: PulseStateMachine) {
        self.stateMachine = stateMachine
        super.init()
    }

    public var isVisible: Bool {
        window?.isVisible ?? false
    }

    /// Toggles the Veil on/off from hotkey or trigger.
    public func toggle(at screenPoint: CGPoint? = nil) {
        if isVisible {
            dismiss()
        } else {
            present(at: screenPoint)
        }
    }

    /// Presents the Veil annular wheel at the designated causal origin point.
    public func present(at screenPoint: CGPoint? = nil, envelope providedEnvelope: PulseContextEnvelope? = nil) {
        let mouseLocation = screenPoint ?? NSEvent.mouseLocation
        let cgPoint = LensCoordinates.toCG(appKitPoint: mouseLocation)

        let objClass: ObjectClass

        if stateMachine.currentState == .quiet {
            let run: PulseRun
            do {
                run = try stateMachine.startRun()
            } catch {
                return
            }
            _ = try? stateMachine.transition(to: .lens)
            let env = providedEnvelope ?? LensResolver.acquireContextEnvelope(
                at: (x: Double(cgPoint.x), y: Double(cgPoint.y)),
                generationToken: run.generationToken
            )
            try? stateMachine.bindEnvelope(env)
            objClass = env.primaryObject?.objectClass ?? .clipboard
        } else if stateMachine.currentState == .lens {
            if let env = providedEnvelope {
                try? stateMachine.bindEnvelope(env)
                objClass = env.primaryObject?.objectClass ?? .clipboard
            } else if let boundClass = stateMachine.currentRun?.sourceObjectClass {
                objClass = boundClass
            } else {
                let env = LensResolver.acquireContextEnvelope(
                    at: (x: Double(cgPoint.x), y: Double(cgPoint.y)),
                    generationToken: stateMachine.currentRun?.generationToken ?? UUID().uuidString
                )
                try? stateMachine.bindEnvelope(env)
                objClass = env.primaryObject?.objectClass ?? .clipboard
            }
        } else {
            return
        }

        // 3. Resolve layout from experimental registry
        let layout = VeilLayoutRegistry.shared.layout(for: objClass)

        // 4. Compute minimally-translated placement
        let placement = VeilPlacementPlanner.resolvePlacement(causalOrigin: mouseLocation)

        // 5. Construct window frame centered at placement.veilCenter
        let windowDiameter: CGFloat = 440.0
        let halfD = windowDiameter / 2.0
        let windowRect = NSRect(
            x: placement.veilCenter.x - halfD,
            y: placement.veilCenter.y - halfD,
            width: windowDiameter,
            height: windowDiameter
        )

        let localCenter = CGPoint(x: halfD, y: halfD)

        // 6. Setup tracking & navigation engines
        let tracker = VeilPointerTracker(center: localCenter)
        let navigator = VeilKeyboardNavigator(layout: layout)
        tracker.startTracking(layout: layout, center: localCenter)

        self.pointerTracker = tracker
        self.keyboardNavigator = navigator

        // Wire navigator callbacks
        navigator.onSelectionChanged = { [weak self, weak tracker] dir, choiceID in
            Task { @MainActor [weak self, weak tracker] in
                guard let tracker = tracker else { return }
                if let d = dir {
                    if let c = choiceID {
                        tracker.armNestedChoice(c, parentDirection: d)
                    } else {
                        tracker.armDirection(d)
                    }
                }
                self?.veilView?.needsDisplay = true
            }
        }

        navigator.onActivated = { [weak self] dir, choiceID in
            Task { @MainActor [weak self] in
                self?.handleActivation(direction: dir, choiceID: choiceID)
            }
        }

        navigator.onCancelled = { [weak self] in
            Task { @MainActor [weak self] in
                self?.dismiss()
            }
        }

        tracker.onExitBoundary = { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.dismiss()
            }
        }

        tracker.onStateChange = { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.veilView?.needsDisplay = true
            }
        }

        // 7. Construct or update VeilView & VeilWindow
        let view = VeilView(
            frame: NSRect(origin: .zero, size: windowRect.size),
            layout: layout,
            placement: placement,
            pointerTracker: tracker,
            keyboardNavigator: navigator
        )
        view.showDebugGeometry = showDebugGeometry
        self.veilView = view

        if window == nil {
            let win = VeilWindow(contentRect: windowRect)
            win.contentView = view
            self.window = win
        } else {
            window?.setFrame(windowRect, display: true)
            window?.contentView = view
        }

        guard let win = window else { return }

        // 8. Order front without activating
        win.alphaValue = 0.0
        win.orderFrontRegardless()

        let isReducedMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        if isReducedMotion {
            win.alphaValue = 1.0
        } else {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.08
                win.animator().alphaValue = 1.0
            }
        }

        // 9. Transition LENS -> VEIL
        _ = try? stateMachine.transition(to: .veil)

        // Setup temporary monitors during presentation only
        setupTransientMonitors()
    }

    /// Dismisses the Veil cleanly through RECEDE to QUIET.
    public func dismiss() {
        guard let win = window, win.isVisible else {
            stateMachine.cancel()
            return
        }

        tearDownTransientMonitors()
        pointerTracker?.stopTracking()

        if stateMachine.isResultHeld {
            stateMachine.releaseResultHold()
        }

        do {
            try stateMachine.transition(to: .recede)
        } catch {
            stateMachine.cancel()
            win.orderOut(nil)
            return
        }

        let isReducedMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        if isReducedMotion {
            win.orderOut(nil)
            do {
                try stateMachine.transition(to: .quiet)
            } catch {
                stateMachine.resetToQuiet()
            }
        } else {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.08
                win.animator().alphaValue = 0.0
            }, completionHandler: { [weak self] in
                win.orderOut(nil)
                do {
                    try self?.stateMachine.transition(to: .quiet)
                } catch {
                    self?.stateMachine.resetToQuiet()
                }
            })
        }
    }

    private func handleActivation(direction: CompassDirection, choiceID: String?) {
        guard let layout = veilView?.layout, layout.reflex(at: direction) != nil else {
            dismiss()
            return
        }

        // Attune Reflex on state machine
        _ = try? stateMachine.transition(to: .attune)

        // Dismiss Veil cleanly after activation trigger
        dismiss()
    }

    private func setupTransientMonitors() {
        tearDownTransientMonitors()

        // Local key monitor to intercept keys while presented without keylogging
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, let nav = self.keyboardNavigator else { return event }
            if nav.handleNSEvent(event) {
                return nil // Key consumed by Veil
            }
            return event
        }
    }

    private func tearDownTransientMonitors() {
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
        if let monitor = globalMouseMonitor {
            NSEvent.removeMonitor(monitor)
            globalMouseMonitor = nil
        }
    }
}
#endif
