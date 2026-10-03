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
    private var keyboardAdapter: VeilKeyboardDeliveryAdapter?

    public var showDebugGeometry: Bool = false {
        didSet { veilView?.showDebugGeometry = showDebugGeometry }
    }

    public var isKeyboardAdapterActive: Bool {
        keyboardAdapter?.isRegistered ?? false
    }

    public var activeKeyboardChords: [VeilChordDescriptor] {
        keyboardAdapter?.activeChords ?? []
    }

    /// Owner trial development store for Phase 5 real-use trials.
    public var trialStore: VeilOwnerTrialStore = .shared
    private var presentationTimestamp: Date?
    private var initialArmedDirection: CompassDirection?
    private var lastInputRoute: VeilInputRoute = .pointer
    private var wasActivated: Bool = false

    public var currentPointerState: VeilPointerState {
        pointerTracker?.currentState ?? .idle
    }

    public var currentArmedDirection: CompassDirection? {
        pointerTracker?.armedDirection
    }

    public var currentActiveNestedChoiceID: String? {
        pointerTracker?.activeNestedChoiceID
    }

    public var currentSelectedDirection: CompassDirection? {
        keyboardNavigator?.selectedDirection
    }

    public var currentLayout: VeilObjectLayout? {
        veilView?.layout
    }

    public var interactionView: VeilView? {
        veilView
    }

    public var panelWindow: VeilWindow? {
        window
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
        trialStore.reloadFromDisk()
        self.presentationTimestamp = Date()
        self.initialArmedDirection = nil
        self.lastInputRoute = .pointer
        self.wasActivated = false

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
                self?.lastInputRoute = .keyboard
                if self?.initialArmedDirection == nil {
                    self?.initialArmedDirection = dir
                }
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
                self?.lastInputRoute = .keyboard
                self?.handleActivation(direction: dir, choiceID: choiceID)
            }
        }

        navigator.onCancelled = { [weak self] in
            Task { @MainActor [weak self] in
                self?.lastInputRoute = .keyboard
                self?.dismiss()
            }
        }

        tracker.onExitBoundary = { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.dismiss()
            }
        }

        tracker.onStateChange = { [weak self, weak tracker] _ in
            Task { @MainActor [weak self, weak tracker] in
                if self?.initialArmedDirection == nil, let armed = tracker?.armedDirection {
                    self?.initialArmedDirection = armed
                }
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

        let isReducedMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion || !NSApplication.shared.isRunning
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
        if !wasActivated, let pTime = presentationTimestamp, trialStore.isTrialModeEnabled, let layout = veilView?.layout {
            let elapsed = Date().timeIntervalSince(pTime) * 1000.0
            let record = VeilOwnerTrialRecord(
                objectClass: layout.objectClass,
                layoutFamily: layout.family,
                layoutVersion: layout.version,
                inputRoute: lastInputRoute,
                initialArmedDirection: initialArmedDirection,
                finalSelectedDirection: nil,
                selectedReflexID: nil,
                selectedNestedChoiceID: nil,
                seamCrossingCount: pointerTracker?.seamCrossings ?? 0,
                maxRadialOvershootPt: pointerTracker?.maxRadialOvershoot ?? 0.0,
                elapsedSelectionMs: (elapsed * 10).rounded() / 10,
                wasCancelled: true,
                didEnterNested: pointerTracker?.activeNestedChoiceID != nil,
                feedback: .unreviewed
            )
            trialStore.recordTrial(record)
        }
        presentationTimestamp = nil
        initialArmedDirection = nil
        wasActivated = false

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

        let isReducedMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion || !NSApplication.shared.isRunning
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

    /// Simulates activation of a directional reflex for test runners and verification harnesses.
    public func simulateActivation(direction: CompassDirection, choiceID: String? = nil) {
        handleActivation(direction: direction, choiceID: choiceID)
    }

    internal func handleActivation(direction: CompassDirection, choiceID: String?) {
        guard let layout = veilView?.layout, layout.reflex(at: direction) != nil else {
            dismiss()
            return
        }

        self.wasActivated = true

        if trialStore.isTrialModeEnabled {
            let elapsed = presentationTimestamp.map { Date().timeIntervalSince($0) * 1000.0 } ?? 0.0
            let parentReflexID = layout.reflex(at: direction)?.id
            let record = VeilOwnerTrialRecord(
                objectClass: layout.objectClass,
                layoutFamily: layout.family,
                layoutVersion: layout.version,
                inputRoute: lastInputRoute,
                initialArmedDirection: initialArmedDirection,
                finalSelectedDirection: direction,
                selectedReflexID: parentReflexID,
                selectedNestedChoiceID: choiceID,
                seamCrossingCount: pointerTracker?.seamCrossings ?? 0,
                maxRadialOvershootPt: pointerTracker?.maxRadialOvershoot ?? 0.0,
                elapsedSelectionMs: (elapsed * 10).rounded() / 10,
                wasCancelled: false,
                didEnterNested: choiceID != nil || (pointerTracker?.activeNestedChoiceID != nil),
                feedback: .unreviewed
            )
            trialStore.recordTrial(record)
        }

        // Attune Reflex on state machine
        _ = try? stateMachine.transition(to: .attune)

        // Dismiss Veil cleanly after activation trigger
        dismiss()
    }

    private func setupTransientMonitors() {
        tearDownTransientMonitors()

        // 1. Register temporary Carbon hotkey chords valid strictly while Veil is presented
        let adapter = VeilKeyboardDeliveryAdapter()
        let globalBinding = HotkeyBinding.default
        _ = adapter.register(collisionBinding: globalBinding) { [weak self] action in
            Task { @MainActor [weak self] in
                guard let self = self, let nav = self.keyboardNavigator else { return }
                switch action {
                case .stepNext:
                    nav.stepNext()
                case .stepPrevious:
                    nav.stepPrevious()
                case .diveNested:
                    _ = nav.diveNested()
                case .backOutNested:
                    _ = nav.backOutNested()
                case .activate:
                    _ = nav.activate()
                case .cancel:
                    nav.cancel()
                case .directDirection(let dir):
                    _ = nav.selectDirection(dir)
                case .unhandled:
                    break
                }
            }
        }
        self.keyboardAdapter = adapter

        // 2. Global mouse monitor to track pointer moves over non-activating Veil surface
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown]) { [weak self] event in
            guard let self = self, let win = self.window, win.isVisible, let view = self.veilView else { return }
            let screenPoint = NSEvent.mouseLocation
            if win.frame.contains(screenPoint) {
                let windowPoint = win.convertPoint(fromScreen: screenPoint)
                if let movedEvent = NSEvent.mouseEvent(
                    with: event.type == .leftMouseDown ? .leftMouseDown : .mouseMoved,
                    location: windowPoint,
                    modifierFlags: event.modifierFlags,
                    timestamp: event.timestamp,
                    windowNumber: win.windowNumber,
                    context: nil,
                    eventNumber: event.eventNumber,
                    clickCount: event.clickCount,
                    pressure: event.pressure
                ) {
                    if event.type == .leftMouseDown {
                        let viewPoint = view.convert(windowPoint, from: nil)
                        let hit = view.pointerTracker.geometry.hitTest(
                            point: viewPoint,
                            armedDirection: view.pointerTracker.armedDirection,
                            activeNestedParent: view.pointerTracker.activeNestedParent
                        )
                        switch hit {
                        case .sector, .nestedSector:
                            view.mouseDown(with: movedEvent)
                        case .neutralCenter, .outside:
                            break
                        }
                    } else {
                        view.mouseMoved(with: movedEvent)
                    }
                }
            }
        }

        // 3. Local key monitor if application event loop receives key down
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self, let nav = self.keyboardNavigator else { return event }
            if nav.handleNSEvent(event) {
                return nil // Key consumed by Veil
            }
            return event
        }
    }

    private func tearDownTransientMonitors() {
        if let adapter = keyboardAdapter {
            adapter.unregister()
            keyboardAdapter = nil
        }
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
        if let monitor = globalMouseMonitor {
            NSEvent.removeMonitor(monitor)
            globalMouseMonitor = nil
        }
    }

    /// Delivers a synthetic hotkey chord for testing the Carbon event delivery path.
    @discardableResult
    public func deliverSyntheticHotkey(action: VeilKeyAction) -> Bool {
        guard let adapter = keyboardAdapter else { return false }
        return adapter.deliverSyntheticEvent(for: action)
    }
}
#endif
