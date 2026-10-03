import Foundation

/// Modifiers supported for global hotkey invocation.
public struct HotkeyModifiers: OptionSet, Sendable, Codable, Equatable, Hashable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let command = HotkeyModifiers(rawValue: 1 << 0)
    public static let shift   = HotkeyModifiers(rawValue: 1 << 1)
    public static let option  = HotkeyModifiers(rawValue: 1 << 2)
    public static let control = HotkeyModifiers(rawValue: 1 << 3)

    public var displayString: String {
        var parts: [String] = []
        if contains(.control) { parts.append("⌃") }
        if contains(.option) { parts.append("⌥") }
        if contains(.shift) { parts.append("⇧") }
        if contains(.command) { parts.append("⌘") }
        return parts.joined()
    }
}

/// Key code abstraction for hotkey configuration.
public struct HotkeyBinding: Sendable, Codable, Equatable {
    /// Virtual key code (default 49 = space)
    public var keyCode: UInt32
    public var modifiers: HotkeyModifiers
    public var displayKeyName: String

    public init(keyCode: UInt32 = 49, modifiers: HotkeyModifiers = [.command, .shift], displayKeyName: String = "Space") {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.displayKeyName = displayKeyName
    }

    public var displayString: String {
        return "\(modifiers.displayString)\(displayKeyName)"
    }

    /// The provisional V1 default: Shift-Command-Space
    public static let `default` = HotkeyBinding(
        keyCode: 49, // kVK_Space
        modifiers: [.command, .shift],
        displayKeyName: "Space"
    )
}

/// User configuration for DEX//PULSE.
public struct PulseConfiguration: Sendable, Codable, Equatable {
    public var schemaVersion: Int
    public var hotkey: HotkeyBinding
    public var showMenuBarIcon: Bool
    public var reduceMotion: Bool
    public var autoRecedeSeconds: Double

    public init(
        schemaVersion: Int = 1,
        hotkey: HotkeyBinding = .default,
        showMenuBarIcon: Bool = true,
        reduceMotion: Bool = false,
        autoRecedeSeconds: Double = 10.0
    ) {
        self.schemaVersion = schemaVersion
        self.hotkey = hotkey
        self.showMenuBarIcon = showMenuBarIcon
        self.reduceMotion = reduceMotion
        self.autoRecedeSeconds = autoRecedeSeconds
    }

    public static let `default` = PulseConfiguration()

    /// Encode configuration to JSON data.
    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    /// Decode configuration from JSON data, falling back gracefully to defaults on error.
    public static func decode(from data: Data) -> PulseConfiguration {
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(PulseConfiguration.self, from: data)
        } catch {
            return .default
        }
    }
}
