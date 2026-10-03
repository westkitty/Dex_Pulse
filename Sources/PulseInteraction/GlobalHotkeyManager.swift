import Foundation
import Carbon
import AppKit
import PulseCore

public enum HotkeyRegistrationResult: Sendable, Equatable {
    case success(binding: HotkeyBinding)
    case failed(binding: HotkeyBinding, osStatus: OSStatus)
    case unregistered

    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    public var statusDescription: String {
        switch self {
        case .success(let b):
            return "Active (\(b.displayString))"
        case .failed(let b, let status):
            return "Failed to register \(b.displayString) (OSStatus: \(status))"
        case .unregistered:
            return "Unregistered"
        }
    }
}

/// Native Carbon-backed global hotkey service.
///
/// Uses macOS HIToolbox `RegisterEventHotKey`. Requires no Accessibility
/// or Input Monitoring permissions to register. Never steals focus or mutates clipboard.
public final class GlobalHotkeyManager: @unchecked Sendable {
    public static let shared = GlobalHotkeyManager()

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var hotkeyID = EventHotKeyID(signature: 0x4450554C /* 'DPUL' */, id: 1)
    private var onTrigger: (@Sendable () -> Void)?
    private let lock = NSLock()

    private var _lastResult: HotkeyRegistrationResult = .unregistered
    public var lastResult: HotkeyRegistrationResult {
        lock.lock()
        defer { lock.unlock() }
        return _lastResult
    }

    public init() {}

    deinit {
        unregister()
    }

    /// Sets the action handler invoked when the hotkey is triggered.
    public func setTriggerHandler(_ handler: @escaping @Sendable () -> Void) {
        lock.lock()
        defer { lock.unlock() }
        self.onTrigger = handler
    }

    /// Registers the global hotkey using the provided binding.
    @discardableResult
    public func register(binding: HotkeyBinding = .default) -> HotkeyRegistrationResult {
        lock.lock()
        defer { lock.unlock() }

        // Unregister existing first to guarantee determinism
        _unregisterInternal()

        // Install event handler if not already installed
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
                    var hkID = EventHotKeyID()
                    let status = GetEventParameter(
                        theEvent,
                        EventParamName(kEventParamDirectObject),
                        EventParamType(typeEventHotKeyID),
                        nil,
                        MemoryLayout<EventHotKeyID>.size,
                        nil,
                        &hkID
                    )
                    if status == noErr {
                        let manager = Unmanaged<GlobalHotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                        manager.handleHotKeyTrigger(id: hkID)
                    }
                    return noErr
                },
                1,
                &eventType,
                selfPtr,
                &eventHandlerRef
            )

            if handlerStatus != noErr {
                let res = HotkeyRegistrationResult.failed(binding: binding, osStatus: handlerStatus)
                _lastResult = res
                return res
            }
        }

        // Map modifier flags to Carbon modifiers
        var carbonModifiers: UInt32 = 0
        if binding.modifiers.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
        if binding.modifiers.contains(.shift)   { carbonModifiers |= UInt32(shiftKey) }
        if binding.modifiers.contains(.option)  { carbonModifiers |= UInt32(optionKey) }
        if binding.modifiers.contains(.control) { carbonModifiers |= UInt32(controlKey) }

        var ref: EventHotKeyRef?
        let regStatus = RegisterEventHotKey(
            binding.keyCode,
            carbonModifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &ref
        )

        if regStatus == noErr, let validRef = ref {
            self.hotKeyRef = validRef
            let res = HotkeyRegistrationResult.success(binding: binding)
            _lastResult = res
            return res
        } else {
            let res = HotkeyRegistrationResult.failed(binding: binding, osStatus: regStatus)
            _lastResult = res
            return res
        }
    }

    /// Unregisters the current global hotkey.
    public func unregister() {
        lock.lock()
        defer { lock.unlock() }
        _unregisterInternal()
        _lastResult = .unregistered
    }

    private func _unregisterInternal() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
    }

    private func handleHotKeyTrigger(id: EventHotKeyID) {
        guard id.signature == hotkeyID.signature && id.id == hotkeyID.id else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lock.lock()
            let handler = self.onTrigger
            self.lock.unlock()
            handler?()
        }
    }
}
