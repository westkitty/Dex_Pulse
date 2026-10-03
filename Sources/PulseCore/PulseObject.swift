import Foundation

/// Provenance metadata tracking the origin of an object acquired by Pulse.
public struct ObjectProvenance: Sendable, Codable, Equatable {
    public let timestamp: Date
    public let sourceAppBundle: String?
    public let sourcePID: Int32?
    public let acquisitionMethod: String

    public init(
        timestamp: Date = Date(),
        sourceAppBundle: String? = nil,
        sourcePID: Int32? = nil,
        acquisitionMethod: String
    ) {
        self.timestamp = timestamp
        self.sourceAppBundle = sourceAppBundle
        self.sourcePID = sourcePID
        self.acquisitionMethod = acquisitionMethod
    }
}

/// Enumeration of all recognized V1 object classes.
public enum ObjectClass: String, Sendable, Codable, CaseIterable {
    case selectedText = "SelectedTextObject"
    case file = "FileObject"
    case fileSet = "FileSetObject"
    case path = "PathObject"
    case url = "URLObject"
    case repository = "RepositoryObject"
    case code = "CodeObject"
    case errorLog = "ErrorLogObject"
    case image = "ImageObject"
    case uiElement = "UIElementObject"
    case focusedElement = "FocusedElementObject"
    case window = "WindowObject"
    case application = "ApplicationObject"
    case clipboard = "ClipboardObject"
    case result = "ResultObject"
    case machineTarget = "MachineTarget"
}

/// Base protocol for all typed objects processed by DEX//PULSE.
public protocol PulseObject: Sendable {
    var objectClass: ObjectClass { get }
    var provenance: ObjectProvenance { get }
    var summary: String { get }
}

/// Selected text acquired explicitly from active UI selection.
public struct SelectedTextObject: PulseObject {
    public let objectClass: ObjectClass = .selectedText
    public let provenance: ObjectProvenance
    public let text: String
    public var summary: String { "Selected text (\(text.count) chars)" }

    public init(text: String, provenance: ObjectProvenance) {
        self.text = text
        self.provenance = provenance
    }
}

/// UI element located under pointer or focused via Accessibility.
public struct UIElementObject: PulseObject {
    public let objectClass: ObjectClass = .uiElement
    public let provenance: ObjectProvenance
    public let role: String
    public let title: String?
    public let applicationName: String?
    public var summary: String { "UI Element [\(role)] \(title ?? "")" }

    public init(role: String, title: String?, applicationName: String?, provenance: ObjectProvenance) {
        self.role = role
        self.title = title
        self.applicationName = applicationName
        self.provenance = provenance
    }
}

/// File or path object.
public struct FileObject: PulseObject {
    public let objectClass: ObjectClass = .file
    public let provenance: ObjectProvenance
    public let path: String
    public var summary: String { "File: \(URL(fileURLWithPath: path).lastPathComponent)" }

    public init(path: String, provenance: ObjectProvenance) {
        self.path = path
        self.provenance = provenance
    }
}

/// Fallback read-only snapshot of existing clipboard.
public struct ClipboardObject: PulseObject {
    public let objectClass: ObjectClass = .clipboard
    public let provenance: ObjectProvenance
    public let changeCount: Int
    public let types: [String]
    public var summary: String { "Clipboard (changeCount: \(changeCount))" }

    public init(changeCount: Int, types: [String], provenance: ObjectProvenance) {
        self.changeCount = changeCount
        self.types = types
        self.provenance = provenance
    }
}

/// Context envelope capturing invocation context atomically.
public struct PulseContextEnvelope: Sendable {
    public let invocationTime: Date
    public let screenCoordinates: (x: Double, y: Double)?
    public let primaryObject: (any PulseObject)?
    public let fallbackObject: (any PulseObject)?

    public init(
        invocationTime: Date = Date(),
        screenCoordinates: (x: Double, y: Double)? = nil,
        primaryObject: (any PulseObject)? = nil,
        fallbackObject: (any PulseObject)? = nil
    ) {
        self.invocationTime = invocationTime
        self.screenCoordinates = screenCoordinates
        self.primaryObject = primaryObject
        self.fallbackObject = fallbackObject
    }
}
