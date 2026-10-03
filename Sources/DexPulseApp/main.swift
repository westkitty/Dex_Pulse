import Foundation
import AppKit
import PulseCore
import PulseInteraction
import PulseKit
import PulseWitness

@MainActor
final class DexPulseAppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let stateMachine = PulseStateMachine()
    private var overlayController: DebugPulseOverlayController?
    private let hotkeyManager = GlobalHotkeyManager.shared
    private let kitRegistry = PulseKitRegistry()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Enforce accessory / utility mode (no dock icon, menu bar only)
        NSApp.setActivationPolicy(.accessory)

        // Initialize overlay controller
        overlayController = DebugPulseOverlayController(stateMachine: stateMachine)

        // Setup menu bar item
        setupStatusItem()

        // Register default global hotkey (Shift-Command-Space)
        let regResult = hotkeyManager.register(binding: .default)
        hotkeyManager.setTriggerHandler { [weak self] in
            Task { @MainActor [weak self] in
                self?.overlayController?.toggle()
            }
        }

        // State machine observer updates status item tooltip/title if desired
        stateMachine.onStateChange { [weak self] oldState, newState in
            Task { @MainActor [weak self] in
                self?.updateStatusMenu()
            }
        }

        // Print startup banner to stderr for diagnostics
        FileHandle.standardError.write(
            Data("[DEX//PULSE] Started. \(regResult.statusDescription). State: [QUIET]\n".utf8)
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean shutdown: unregister hotkey, dismiss overlay, reset to quiet
        hotkeyManager.unregister()
        overlayController?.dismiss()
        stateMachine.resetToQuiet()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }

        button.title = "DEX//PULSE"
        button.toolTip = "DEX//PULSE Reflex Layer"

        let menu = NSMenu()
        statusItem?.menu = menu
        updateStatusMenu()
    }

    private func updateStatusMenu() {
        guard let menu = statusItem?.menu else { return }
        menu.removeAllItems()

        // Version & Build Header
        let titleItem = NSMenuItem(
            title: "\(BuildIdentity.productName) v\(BuildIdentity.version)",
            action: nil,
            keyEquivalent: ""
        )
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        // State indicator
        let stateItem = NSMenuItem(
            title: "State: [\(stateMachine.currentState.rawValue)]",
            action: nil,
            keyEquivalent: ""
        )
        stateItem.isEnabled = false
        menu.addItem(stateItem)

        menu.addItem(NSMenuItem.separator())

        // Toggle Pulse Action
        let toggleItem = NSMenuItem(
            title: "Toggle Pulse (\(HotkeyBinding.default.displayString))",
            action: #selector(togglePulseAction),
            keyEquivalent: ""
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        // Doctor diagnostics entry
        let doctorItem = NSMenuItem(
            title: "Diagnostics (dexpulse doctor)...",
            action: #selector(showDoctorAction),
            keyEquivalent: "d"
        )
        doctorItem.target = self
        menu.addItem(doctorItem)

        // About / Settings placeholder entry
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(showSettingsAction),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // Quit entry
        let quitItem = NSMenuItem(
            title: "Quit \(BuildIdentity.productName)",
            action: #selector(quitAction),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
    }

    @objc private func togglePulseAction() {
        overlayController?.toggle()
    }

    @objc private func showDoctorAction() {
        let alert = NSAlert()
        alert.messageText = "DEX//PULSE Diagnostics"
        let status = hotkeyManager.lastResult.statusDescription
        alert.informativeText = """
        Version: \(BuildIdentity.version) (\(BuildIdentity.phase))
        State: [\(stateMachine.currentState)]
        Hotkey: \(status)
        Capabilities: \(kitRegistry.allCapabilities.count) registered
        Run `dexpulse doctor` in Terminal for full system report.
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func showSettingsAction() {
        let alert = NSAlert()
        alert.messageText = "DEX//PULSE Settings"
        alert.informativeText = """
        Provisional Hotkey: \(HotkeyBinding.default.displayString)
        Settings schema: v\(PulseConfiguration.default.schemaVersion)
        Auto-recede: \(PulseConfiguration.default.autoRecedeSeconds)s
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    @objc private func quitAction() {
        NSApp.terminate(nil)
    }
}

@main
struct DexPulseAppMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = DexPulseAppDelegate()
        app.delegate = delegate
        app.run()
    }
}
