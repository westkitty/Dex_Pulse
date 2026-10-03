import Foundation
import Carbon
import AppKit
import PulseCore

/// Descriptor for a temporary Carbon hotkey chord used to navigate the Veil
/// without stealing focus from the active foreground application.
public struct VeilChordDescriptor: Sendable, Equatable {
    public let action: VeilKeyAction
    public let keyCode: UInt32
    public let modifiers: HotkeyModifiers
    public let displayString: String

    public init(action: VeilKeyAction, keyCode: UInt32, modifiers: HotkeyModifiers, displayString: String) {
        self.action = action
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.displayString = displayString
    }
}

/// Errors occurring during temporary chord registration.
public enum VeilHotkeyError: Error, Sendable, Equatable {
    case collisionWithGlobalHotkey(keyCode: UInt32, modifiers: HotkeyModifiers)
    case registrationFailed(action: VeilKeyAction, osStatus: OSStatus)
}

/// Bounded native Carbon hotkey adapter active strictly while the Veil is visible.
///
/// Invariants:
/// - Registered ONLY while the Veil is presented; unregistered immediately on dismissal (RECEDE/QUIET).
/// - Delivers keyboard commands without stealing key/main focus from the frontmost application.
/// - Operates through HIToolbox `RegisterEventHotKey` without requiring Input Monitoring or Accessibility.
/// - Checks for collisions against the primary global Pulse invocation hotkey.
public final class VeilKeyboardDeliveryAdapter: @unchecked Sendable {
    private let lock = NSLock()
    private var eventHandlerRef: EventHandlerRef?
    private var registeredHotKeys: [UInt32: (ref: EventHotKeyRef, descriptor: VeilChordDescriptor)] = [:]
    private var onAction: (@Sendable (VeilKeyAction) -> Void)?
    private let hotKeySignature: OSType = 0x5645494C // 'VEIL'

    /// Canonical chord map covering all required interaction actions.
    public static let defaultChords: [VeilChordDescriptor] = [
        // Previous slot: Control+Option+[
        VeilChordDescriptor(action: .stepPrevious, keyCode: 33, modifiers: [.control, .option], displayString: "⌃⌥["),
        // Next slot: Control+Option+]
        VeilChordDescriptor(action: .stepNext, keyCode: 30, modifiers: [.control, .option], displayString: "⌃⌥]"),
        // Nested outward / dive: Control+Option+O
        VeilChordDescriptor(action: .diveNested, keyCode: 31, modifiers: [.control, .option], displayString: "⌃⌥O"),
        // Nested inward / back: Control+Option+I
        VeilChordDescriptor(action: .backOutNested, keyCode: 34, modifiers: [.control, .option], displayString: "⌃⌥I"),
        // Activate: Control+Option+Return
        VeilChordDescriptor(action: .activate, keyCode: 36, modifiers: [.control, .option], displayString: "⌃⌥↩"),
        // Cancel: Control+Option+Escape
        VeilChordDescriptor(action: .cancel, keyCode: 53, modifiers: [.control, .option], displayString: "⌃⌥⎋"),
    ]

    public init() {}

    deinit {
        unregister()
    }

    /// Whether any chords are currently active and registered with the OS.
    public var isRegistered: Bool {
        lock.lock()
        defer { lock.unlock() }
        return !registeredHotKeys.isEmpty
    }

    /// List of currently active registered chord descriptors.
    public var activeChords: [VeilChordDescriptor] {
        lock.lock()
        defer { lock.unlock() }
        return registeredHotKeys.values.map { $0.descriptor }
    }

    /// Registers the temporary Veil navigation chords.
    ///
    /// - Parameters:
    ///   - chords: Custom chords to register, defaulting to `defaultChords`.
    ///   - collisionBinding: Existing global invocation binding to check against for collisions.
    ///   - onAction: Callback invoked on the main thread when a chord is delivered.
    /// - Returns: Success with registered count, or failure with collision/registration error.
    @discardableResult
    public func register(
        chords: [VeilChordDescriptor] = defaultChords,
        collisionBinding: HotkeyBinding? = nil,
        onAction: @escaping @Sendable (VeilKeyAction) -> Void
    ) -> Result<Int, VeilHotkeyError> {
        lock.lock()
        defer { lock.unlock() }

        // Clean up any stale registrations first
        _unregisterInternal()
        self.onAction = onAction

        // Collision check against global invocation hotkey
        if let collision = collisionBinding {
            for chord in chords {
                if chord.keyCode == collision.keyCode && chord.modifiers == collision.modifiers {
                    return .failure(.collisionWithGlobalHotkey(keyCode: chord.keyCode, modifiers: chord.modifiers))
                }
            }
        }

        // Install Carbon Event Handler if not already present
        if eventHandlerRef == nil {
            var eventType = EventTypeSpec(
                eventClass: OSType(kEventClassKeyboard),
                eventKind: UInt32(kEventHotKeyPressed)
            )

            let selfPtr = Unmanaged.passUnretained(self).toOpaque()
            let handlerStatus = InstallEventHandler(
                GetApplicationEventTarget(),
                { (_, theEvent, userData) -> OSStatus in
                    guard let theEvent = theEvent, let userData = userData else { return noErr }
                    let adapter = Unmanaged<VeilKeyboardDeliveryAdapter>.fromOpaque(userData).takeUnretainedValue()
                    _ = adapter.processCarbonEvent(theEvent)
                    return noErr
                },
                1,
                &eventType,
                selfPtr,
                &eventHandlerRef
            )

            if handlerStatus != noErr {
                return .failure(.registrationFailed(action: .unhandled, osStatus: handlerStatus))
            }
        }

        // Register each chord with Carbon
        var registeredCount = 0
        for (index, chord) in chords.enumerated() {
            let hotkeyID = UInt32(index + 1000)
            let carbonID = EventHotKeyID(signature: hotKeySignature, id: hotkeyID)

            var carbonModifiers: UInt32 = 0
            if chord.modifiers.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
            if chord.modifiers.contains(.shift)   { carbonModifiers |= UInt32(shiftKey) }
            if chord.modifiers.contains(.option)  { carbonModifiers |= UInt32(optionKey) }
            if chord.modifiers.contains(.control) { carbonModifiers |= UInt32(controlKey) }

            var ref: EventHotKeyRef?
            let regStatus = RegisterEventHotKey(
                chord.keyCode,
                carbonModifiers,
                carbonID,
                GetApplicationEventTarget(),
                0,
                &ref
            )

            if regStatus == noErr, let validRef = ref {
                registeredHotKeys[hotkeyID] = (ref: validRef, descriptor: chord)
                registeredCount += 1
            } else {
                _unregisterInternal()
                return .failure(.registrationFailed(action: chord.action, osStatus: regStatus))
            }
        }

        return .success(registeredCount)
    }

    /// Completely unregisters all temporary chords and tears down event handlers.
    public func unregister() {
        lock.lock()
        defer { lock.unlock() }
        _unregisterInternal()
    }

    private func _unregisterInternal() {
        for (_, entry) in registeredHotKeys {
            UnregisterEventHotKey(entry.ref)
        }
        registeredHotKeys.removeAll()

        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
            eventHandlerRef = nil
        }
        onAction = nil
    }

    private func handleHotKeyTrigger(id: EventHotKeyID) {
        guard id.signature == hotKeySignature else { return }

        lock.lock()
        guard let entry = registeredHotKeys[id.id] else {
            lock.unlock()
            return
        }
        let action = entry.descriptor.action
        let callback = onAction
        lock.unlock()

        if Thread.isMainThread {
            callback?(action)
        } else {
            DispatchQueue.main.async {
                callback?(action)
            }
        }
    }

    /// Extracts the EventHotKeyID from a Carbon EventRef and triggers the corresponding action.
    @discardableResult
    func processCarbonEvent(_ event: EventRef) -> OSStatus {
        var hkID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hkID
        )
        if status == noErr {
            handleHotKeyTrigger(id: hkID)
            return noErr
        }
        return status
    }

    /// Delivers a synthetic hotkey event directly through Carbon's event processing pipeline for testing.
    @discardableResult
    public func deliverSyntheticEvent(for action: VeilKeyAction) -> Bool {
        lock.lock()
        guard let entry = registeredHotKeys.first(where: { $0.value.descriptor.action == action }) else {
            lock.unlock()
            return false
        }
        let targetID = entry.key
        lock.unlock()

        var carbonEvent: EventRef?
        let createStatus = CreateEvent(
            nil,
            OSType(kEventClassKeyboard),
            UInt32(kEventHotKeyPressed),
            0,
            EventAttributes(kEventAttributeNone),
            &carbonEvent
        )
        guard createStatus == noErr, let ev = carbonEvent else { return false }
        defer { ReleaseEvent(ev) }

        var hkID = EventHotKeyID(signature: hotKeySignature, id: targetID)
        let setStatus = SetEventParameter(
            ev,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            MemoryLayout<EventHotKeyID>.size,
            &hkID
        )
        guard setStatus == noErr else { return false }

        // Process Carbon Event directly through parameter extraction and action dispatch
        let processStatus = processCarbonEvent(ev)
        return processStatus == noErr
    }
}
