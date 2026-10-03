import Foundation
import AppKit
import PulseCore
import PulseLens

/// Native Accessibility test fixture application for DEX//PULSE.
///
/// Contains controls specified in docs/TEST_STRATEGY.md:
/// - Selectable text field
/// - Multiline text editor
/// - Secure text field (for password/privacy blocking verification)
/// - Normal interactive button
/// - Duplicate-labeled buttons (for label ambiguity verification)
/// - Disabled button
/// - Checkbox control
/// - Pop-up menu control
final class FixtureWindowController: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentRect = NSRect(x: 100, y: 100, width: 480, height: 420)
        window = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "DEX//PULSE AX Fixture Window"

        let contentView = NSView(frame: contentRect)

        // 1. Selectable Text Field
        let selectableLabel = NSTextField(labelWithString: "1. Selectable Text:")
        selectableLabel.frame = NSRect(x: 20, y: 360, width: 200, height: 20)
        contentView.addSubview(selectableLabel)

        let selectableField = NSTextField(frame: NSRect(x: 20, y: 330, width: 440, height: 24))
        selectableField.stringValue = "DEX//PULSE Native Test Selection"
        selectableField.isSelectable = true
        selectableField.isEditable = false
        selectableField.setAccessibilityLabel("Selectable Test Content")
        contentView.addSubview(selectableField)

        // 2. Secure Text Field
        let secureLabel = NSTextField(labelWithString: "2. Secure / Password Field:")
        secureLabel.frame = NSRect(x: 20, y: 295, width: 200, height: 20)
        contentView.addSubview(secureLabel)

        let secureField = NSSecureTextField(frame: NSRect(x: 20, y: 265, width: 440, height: 24))
        secureField.stringValue = "SuperSecretPayload123"
        secureField.setAccessibilityLabel("Password Secure Field")
        contentView.addSubview(secureField)

        // 3. Normal Button
        let submitBtn = NSButton(frame: NSRect(x: 20, y: 220, width: 140, height: 30))
        submitBtn.title = "Submit Action"
        submitBtn.bezelStyle = .rounded
        submitBtn.setAccessibilityLabel("Submit Action Button")
        contentView.addSubview(submitBtn)

        // 4. Duplicate Labeled Buttons
        let dupBtn1 = NSButton(frame: NSRect(x: 170, y: 220, width: 140, height: 30))
        dupBtn1.title = "Duplicate Action"
        dupBtn1.bezelStyle = .rounded
        dupBtn1.setAccessibilityLabel("Duplicate Action")
        contentView.addSubview(dupBtn1)

        let dupBtn2 = NSButton(frame: NSRect(x: 320, y: 220, width: 140, height: 30))
        dupBtn2.title = "Duplicate Action"
        dupBtn2.bezelStyle = .rounded
        dupBtn2.setAccessibilityLabel("Duplicate Action")
        contentView.addSubview(dupBtn2)

        // 5. Disabled Control
        let disabledBtn = NSButton(frame: NSRect(x: 20, y: 175, width: 140, height: 30))
        disabledBtn.title = "Disabled Control"
        disabledBtn.bezelStyle = .rounded
        disabledBtn.isEnabled = false
        disabledBtn.setAccessibilityLabel("Disabled Control Button")
        contentView.addSubview(disabledBtn)

        // 6. Checkbox Control
        let checkbox = NSButton(checkboxWithTitle: "Enable Diagnostic Logging", target: nil, action: nil)
        checkbox.frame = NSRect(x: 170, y: 180, width: 220, height: 20)
        checkbox.state = .on
        checkbox.setAccessibilityLabel("Enable Diagnostic Logging Checkbox")
        contentView.addSubview(checkbox)

        // 7. Pop-up Menu
        let popup = NSPopUpButton(frame: NSRect(x: 20, y: 130, width: 180, height: 26))
        popup.addItems(withTitles: ["Standard Profile", "High Precision", "Minimal"])
        popup.setAccessibilityLabel("Profile Selector PopUp")
        contentView.addSubview(popup)

        // 8. Multiline Editor
        let editorScroll = NSScrollView(frame: NSRect(x: 20, y: 20, width: 440, height: 95))
        let textView = NSTextView(frame: editorScroll.bounds)
        textView.string = "Multiline editor content for Pulse testing.\nSecond line with code: func testPulse() -> Bool { return true }"
        textView.isSelectable = true
        textView.isEditable = true
        textView.setAccessibilityLabel("Multiline Editor")
        editorScroll.documentView = textView
        contentView.addSubview(editorScroll)

        window.contentView = contentView
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        let args = CommandLine.arguments
        if args.contains("--focus-secure") {
            window.makeFirstResponder(secureField)
        }

        // Check command-line argument for auto-termination (used in automated testing)
        if let idx = args.firstIndex(of: "--run-seconds"), idx + 1 < args.count,
           let seconds = Double(args[idx + 1]) {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                NSApp.terminate(nil)
            }
        }
    }
}

let args = CommandLine.arguments
if args.contains("--inspect") {
    print("DEX//PULSE AX Fixture Target: OK")
    print("Controls: SelectableText, SecureField, SubmitBtn, DuplicateBtns(2), DisabledBtn, Checkbox, PopUp, MultilineEditor")
    exit(0)
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let delegate = FixtureWindowController()
app.delegate = delegate
app.run()
