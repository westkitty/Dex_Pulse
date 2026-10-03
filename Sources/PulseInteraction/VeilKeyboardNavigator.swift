import Foundation
#if canImport(AppKit)
import AppKit
#endif

/// Abstract representation of key actions recognized by the Veil keyboard engine.
public enum VeilKeyAction: Sendable, Equatable {
    case stepNext
    case stepPrevious
    case diveNested
    case backOutNested
    case directDirection(CompassDirection)
    case activate
    case cancel
    case unhandled
}

/// Manages keyboard selection state and traversal across annular slots and nested disclosure.
///
/// Invariant: Keyboard navigation can reach every visible, interactive action
/// without stealing focus or installing permanent global key intercepts (INV-035).
public final class VeilKeyboardNavigator: @unchecked Sendable {
    private let lock = NSLock()

    public private(set) var layout: VeilObjectLayout
    public private(set) var selectedDirection: CompassDirection?
    public private(set) var selectedNestedChoiceIndex: Int?
    public private(set) var isNestedActive: Bool = false

    /// Callbacks
    public var onSelectionChanged: (@Sendable (CompassDirection?, String?) -> Void)?
    public var onActivated: (@Sendable (CompassDirection, String?) -> Void)?
    public var onCancelled: (@Sendable () -> Void)?

    public init(layout: VeilObjectLayout) {
        self.layout = layout
    }

    /// Updates the active layout and resets selection if needed.
    public func updateLayout(_ newLayout: VeilObjectLayout) {
        lock.lock()
        defer { lock.unlock() }
        self.layout = newLayout
        if let sel = selectedDirection, newLayout.reflex(at: sel) == nil {
            selectedDirection = nil
            selectedNestedChoiceIndex = nil
            isNestedActive = false
        }
    }

    /// Sorted list of interactive directions in the current layout.
    public var interactiveDirections: [CompassDirection] {
        CompassDirection.allCases.filter { dir in
            guard let desc = layout.reflex(at: dir) else { return false }
            return desc.state.isInteractive
        }
    }

    /// Steps selection clockwise / next.
    public func stepNext() {
        lock.lock()
        defer { lock.unlock() }

        if isNestedActive, let dir = selectedDirection, let choices = layout.reflex(at: dir)?.nestedChoices, !choices.isEmpty {
            let nextIdx = ((selectedNestedChoiceIndex ?? 0) + 1) % choices.count
            selectedNestedChoiceIndex = nextIdx
            let choiceID = choices[nextIdx].id
            notifySelection(dir: dir, choiceID: choiceID)
            return
        }

        let interactive = interactiveDirections
        guard !interactive.isEmpty else { return }

        if let current = selectedDirection, let idx = interactive.firstIndex(of: current) {
            let nextDir = interactive[(idx + 1) % interactive.count]
            selectedDirection = nextDir
            selectedNestedChoiceIndex = nil
            isNestedActive = false
            notifySelection(dir: nextDir, choiceID: nil)
        } else {
            let first = interactive.first!
            selectedDirection = first
            selectedNestedChoiceIndex = nil
            isNestedActive = false
            notifySelection(dir: first, choiceID: nil)
        }
    }

    /// Steps selection counter-clockwise / previous.
    public func stepPrevious() {
        lock.lock()
        defer { lock.unlock() }

        if isNestedActive, let dir = selectedDirection, let choices = layout.reflex(at: dir)?.nestedChoices, !choices.isEmpty {
            let prevIdx = ((selectedNestedChoiceIndex ?? 0) - 1 + choices.count) % choices.count
            selectedNestedChoiceIndex = prevIdx
            let choiceID = choices[prevIdx].id
            notifySelection(dir: dir, choiceID: choiceID)
            return
        }

        let interactive = interactiveDirections
        guard !interactive.isEmpty else { return }

        if let current = selectedDirection, let idx = interactive.firstIndex(of: current) {
            let prevDir = interactive[(idx - 1 + interactive.count) % interactive.count]
            selectedDirection = prevDir
            selectedNestedChoiceIndex = nil
            isNestedActive = false
            notifySelection(dir: prevDir, choiceID: nil)
        } else {
            let last = interactive.last!
            selectedDirection = last
            selectedNestedChoiceIndex = nil
            isNestedActive = false
            notifySelection(dir: last, choiceID: nil)
        }
    }

    /// Dives into nested disclosure if available for current direction.
    public func diveNested() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard let dir = selectedDirection,
              let choices = layout.reflex(at: dir)?.nestedChoices,
              !choices.isEmpty else {
            return false
        }

        isNestedActive = true
        selectedNestedChoiceIndex = 0
        let choiceID = choices[0].id
        notifySelection(dir: dir, choiceID: choiceID)
        return true
    }

    /// Backs out of nested disclosure to parent direction.
    public func backOutNested() -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard isNestedActive else { return false }
        isNestedActive = false
        selectedNestedChoiceIndex = nil
        notifySelection(dir: selectedDirection, choiceID: nil)
        return true
    }

    /// Selects a specific compass direction directly.
    public func selectDirection(_ dir: CompassDirection) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        guard let desc = layout.reflex(at: dir), desc.state.isInteractive else {
            return false
        }

        selectedDirection = dir
        selectedNestedChoiceIndex = nil
        isNestedActive = false
        notifySelection(dir: dir, choiceID: nil)
        return true
    }

    /// Activates the currently selected Reflex (or nested choice).
    public func activate() -> (direction: CompassDirection, choiceID: String?)? {
        lock.lock()
        guard let dir = selectedDirection,
              let desc = layout.reflex(at: dir),
              desc.state.isInteractive else {
            lock.unlock()
            return nil
        }

        var choiceID: String? = nil
        if isNestedActive, let idx = selectedNestedChoiceIndex, let choices = desc.nestedChoices, idx < choices.count {
            choiceID = choices[idx].id
        }

        let activateCallback = onActivated
        lock.unlock()

        activateCallback?(dir, choiceID)
        return (dir, choiceID)
    }

    /// Handles cancellation (backs out of nested, or triggers full cancel).
    public func cancel() {
        lock.lock()
        if isNestedActive {
            isNestedActive = false
            selectedNestedChoiceIndex = nil
            let dir = selectedDirection
            notifySelection(dir: dir, choiceID: nil)
            lock.unlock()
            return
        }
        let cancelCallback = onCancelled
        lock.unlock()
        cancelCallback?()
    }

    // MARK: - Key Event Translation

    /// Pure key string interpreter for testing and keyboard event feeds.
    public func interpretKey(
        characters: String,
        isShift: Bool = false,
        keyCode: UInt16 = 0
    ) -> VeilKeyAction {
        // Tab / Shift-Tab
        if characters == "\t" || keyCode == 48 {
            return isShift ? .stepPrevious : .stepNext
        }

        // Bracket keys
        if characters == "]" {
            return .stepNext
        }
        if characters == "[" {
            return .stepPrevious
        }

        // Arrow keys (standard macOS keycodes: 126=Up, 125=Down, 123=Left, 124=Right)
        if keyCode == 126 { // Up / North
            return .directDirection(.n)
        }
        if keyCode == 125 { // Down / South
            return .directDirection(.s)
        }
        if keyCode == 124 { // Right / East or Dive Nested
            if isNestedActive {
                return .stepNext
            } else if let dir = selectedDirection, let choices = layout.reflex(at: dir)?.nestedChoices, !choices.isEmpty {
                return .diveNested
            }
            return .directDirection(.e)
        }
        if keyCode == 123 { // Left / West or Back Out Nested
            if isNestedActive {
                return .backOutNested
            }
            return .directDirection(.w)
        }

        // Return / Space -> Activate (or dive nested if on parent with disclosure)
        if characters == "\r" || characters == " " || keyCode == 36 || keyCode == 49 {
            if !isNestedActive, let dir = selectedDirection, let choices = layout.reflex(at: dir)?.nestedChoices, !choices.isEmpty {
                return .diveNested
            }
            return .activate
        }

        // Escape -> Cancel or Back Out
        if characters == "\u{1b}" || keyCode == 53 {
            return isNestedActive ? .backOutNested : .cancel
        }

        // Match keyboardHint
        let upper = characters.uppercased()
        for dir in CompassDirection.allCases {
            if let desc = layout.reflex(at: dir), desc.state.isInteractive, desc.keyboardHint?.uppercased() == upper {
                return .directDirection(dir)
            }
        }

        return .unhandled
    }

    #if canImport(AppKit)
    /// Dispatches an `NSEvent` key down. Returns true if handled.
    public func handleNSEvent(_ event: NSEvent) -> Bool {
        guard event.type == .keyDown else { return false }
        let chars = event.charactersIgnoringModifiers ?? ""
        let isShift = event.modifierFlags.contains(.shift)
        let action = interpretKey(characters: chars, isShift: isShift, keyCode: event.keyCode)

        switch action {
        case .stepNext:
            stepNext()
            return true
        case .stepPrevious:
            stepPrevious()
            return true
        case .diveNested:
            return diveNested()
        case .backOutNested:
            return backOutNested()
        case .directDirection(let dir):
            return selectDirection(dir)
        case .activate:
            _ = activate()
            return true
        case .cancel:
            cancel()
            return true
        case .unhandled:
            return false
        }
    }
    #endif

    private func notifySelection(dir: CompassDirection?, choiceID: String?) {
        onSelectionChanged?(dir, choiceID)
    }
}
