import Foundation

/// Provenance metadata tracking the origin of an object acquired by Pulse.
public struct ObjectProvenance: Sendable, Codable, Equatable {
    public let timestamp: Date
    public let sourceAppBundle: String?
    public let sourcePID: Int32?
    public let acquisitionMethod: String
    public let windowTitle: String?
    public let axRole: String?
    public let parentObjectID: String?

    public init(
        timestamp: Date = Date(),
        sourceAppBundle: String? = nil,
        sourcePID: Int32? = nil,
        acquisitionMethod: String,
        windowTitle: String? = nil,
        axRole: String? = nil,
        parentObjectID: String? = nil
    ) {
        self.timestamp = timestamp
        self.sourceAppBundle = sourceAppBundle
        self.sourcePID = sourcePID
        self.acquisitionMethod = acquisitionMethod
        self.windowTitle = windowTitle
        self.axRole = axRole
        self.parentObjectID = parentObjectID
    }
}

/// Provenance source categories for context objects.
public enum ObjectSource: String, Sendable, Codable {
    case selection = "selection"
    case pointerAX = "pointerAX"
    case focusedAX = "focusedAX"
    case frontmost = "frontmost"
    case clipboard = "clipboard"
    case result = "result"
    case spool = "spool"
    case pin = "pin"
}

/// Enforced privacy classification levels (SEC-001 / OBJECT_MODEL).
public enum PrivacyClass: String, Sendable, Codable, Comparable {
    case `public` = "public"
    case ordinary = "ordinary"
    case sensitive = "sensitive"
    case secureBlocked = "secure-blocked"

    public static func < (lhs: PrivacyClass, rhs: PrivacyClass) -> Bool {
        let order: [PrivacyClass] = [.public, .ordinary, .sensitive, .secureBlocked]
        let lIndex = order.firstIndex(of: lhs) ?? 0
        let rIndex = order.firstIndex(of: rhs) ?? 0
        return lIndex < rIndex
    }
}

/// Enumeration of all recognized V1 object classes.
public enum ObjectClass: String, Sendable, Codable, CaseIterable {
    case selectedText = "SelectedTextObject"
    case selectedFile = "SelectedFileObject"
    case file = "FileObject"
    case fileSet = "FileSetObject"
    case path = "PathObject"
    case url = "URLObject"
    case repository = "RepositoryObject"
    case code = "CodeObject"
    case errorLog = "ErrorLogObject"
    case jsonText = "JSONTextObject"
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
    var id: UUID { get }
    var objectClass: ObjectClass { get }
    var source: ObjectSource { get }
    var createdAt: Date { get }
    var confidence: Double { get }
    var provenance: ObjectProvenance { get }
    var privacyClass: PrivacyClass { get }
    var payloadDescriptor: String { get }
    var summary: String { get }
    var contextGenerationToken: String? { get }
}

public extension PulseObject {
    var id: UUID { UUID() }
    var createdAt: Date { provenance.timestamp }
    var confidence: Double { 1.0 }
    var privacyClass: PrivacyClass { .ordinary }
    var payloadDescriptor: String { summary }
    var contextGenerationToken: String? { nil }
}

/// Selected text acquired explicitly from active UI selection.
public struct SelectedTextObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .selectedText
    public let source: ObjectSource = .selection
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let text: String
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "Selected text (\(text.count) chars)" }
    public var summary: String { "Selected text (\(text.count) chars)" }

    public init(
        id: UUID = UUID(),
        text: String,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 1.0,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// UI element located under pointer or focused via Accessibility.
public struct UIElementObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .uiElement
    public let source: ObjectSource
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let role: String
    public let subrole: String?
    public let title: String?
    public let valueDescription: String?
    public let applicationName: String?
    public let bundleIdentifier: String?
    public let pid: Int32?
    public let isEnabled: Bool
    public let isSecure: Bool
    public let availableActions: [String]
    public let screenFrame: (x: Double, y: Double, width: Double, height: Double)?
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "UI Element [\(role)] \(title ?? "")" }
    public var summary: String { "UI Element [\(role)] \(title ?? "")" }

    public init(
        id: UUID = UUID(),
        source: ObjectSource = .pointerAX,
        role: String,
        subrole: String? = nil,
        title: String?,
        valueDescription: String? = nil,
        applicationName: String?,
        bundleIdentifier: String? = nil,
        pid: Int32? = nil,
        isEnabled: Bool = true,
        isSecure: Bool = false,
        availableActions: [String] = [],
        screenFrame: (x: Double, y: Double, width: Double, height: Double)? = nil,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 1.0,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.source = source
        self.role = role
        self.subrole = subrole
        self.title = title
        self.valueDescription = valueDescription
        self.applicationName = applicationName
        self.bundleIdentifier = bundleIdentifier
        self.pid = pid
        self.isEnabled = isEnabled
        self.isSecure = isSecure
        self.availableActions = availableActions
        self.screenFrame = screenFrame
        self.provenance = provenance
        self.privacyClass = isSecure ? .secureBlocked : privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// Element specifically identified as having Accessibility focus.
public struct FocusedElementObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .focusedElement
    public let source: ObjectSource = .focusedAX
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let role: String
    public let subrole: String?
    public let title: String?
    public let applicationName: String?
    public let pid: Int32?
    public let isSecure: Bool
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "Focused Element [\(role)] \(title ?? "")" }
    public var summary: String { "Focused Element [\(role)] \(title ?? "")" }

    public init(
        id: UUID = UUID(),
        role: String,
        subrole: String? = nil,
        title: String?,
        applicationName: String?,
        pid: Int32? = nil,
        isSecure: Bool = false,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 1.0,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.role = role
        self.subrole = subrole
        self.title = title
        self.applicationName = applicationName
        self.pid = pid
        self.isSecure = isSecure
        self.provenance = provenance
        self.privacyClass = isSecure ? .secureBlocked : privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// File or path object.
public struct FileObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .file
    public let source: ObjectSource
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let path: String
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "File: \(URL(fileURLWithPath: path).lastPathComponent)" }
    public var summary: String { "File: \(URL(fileURLWithPath: path).lastPathComponent)" }

    public init(
        id: UUID = UUID(),
        source: ObjectSource = .selection,
        path: String,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 1.0,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.source = source
        self.path = path
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// Explicitly selected files (e.g. from Finder or Open dialog).
public struct SelectedFileObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .selectedFile
    public let source: ObjectSource = .selection
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let filePaths: [String]
    public let contextGenerationToken: String?

    public var primaryPath: String? { filePaths.first }
    public var payloadDescriptor: String {
        if filePaths.count == 1, let first = filePaths.first {
            return "Selected file: \(URL(fileURLWithPath: first).lastPathComponent)"
        }
        return "Selected files: (\(filePaths.count) items)"
    }
    public var summary: String { payloadDescriptor }

    public init(
        id: UUID = UUID(),
        filePaths: [String],
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 1.0,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.filePaths = filePaths
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// Window object representing frontmost or referenced application window.
public struct WindowObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .window
    public let source: ObjectSource
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let windowTitle: String?
    public let applicationName: String?
    public let pid: Int32?
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "Window: \(windowTitle ?? "Untitled") (\(applicationName ?? "Unknown"))" }
    public var summary: String { payloadDescriptor }

    public init(
        id: UUID = UUID(),
        source: ObjectSource = .frontmost,
        windowTitle: String?,
        applicationName: String?,
        pid: Int32? = nil,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 1.0,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.source = source
        self.windowTitle = windowTitle
        self.applicationName = applicationName
        self.pid = pid
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// Application object representing the frontmost active process.
public struct ApplicationObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .application
    public let source: ObjectSource
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let applicationName: String
    public let bundleIdentifier: String?
    public let pid: Int32
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "Application: \(applicationName) [PID: \(pid)]" }
    public var summary: String { payloadDescriptor }

    public init(
        id: UUID = UUID(),
        source: ObjectSource = .frontmost,
        applicationName: String,
        bundleIdentifier: String? = nil,
        pid: Int32,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 1.0,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.source = source
        self.applicationName = applicationName
        self.bundleIdentifier = bundleIdentifier
        self.pid = pid
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// URL refined from text selection or link target.
public struct URLObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .url
    public let source: ObjectSource
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let url: URL
    public let rawText: String
    public let parentObjectID: String?
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "URL: \(url.absoluteString)" }
    public var summary: String { payloadDescriptor }

    public init(
        id: UUID = UUID(),
        source: ObjectSource = .selection,
        url: URL,
        rawText: String,
        parentObjectID: String? = nil,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 1.0,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.source = source
        self.url = url
        self.rawText = rawText
        self.parentObjectID = parentObjectID
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// Filesystem path refined from text selection.
public struct PathObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .path
    public let source: ObjectSource
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let path: String
    public let existsOnDisk: Bool
    public let parentObjectID: String?
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "Path: \(path)" }
    public var summary: String { payloadDescriptor }

    public init(
        id: UUID = UUID(),
        source: ObjectSource = .selection,
        path: String,
        existsOnDisk: Bool = false,
        parentObjectID: String? = nil,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 1.0,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.source = source
        self.path = path
        self.existsOnDisk = existsOnDisk
        self.parentObjectID = parentObjectID
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// Code snippet refined from text selection.
public struct CodeSnippetObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .code
    public let source: ObjectSource
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let code: String
    public let languageHint: String?
    public let parentObjectID: String?
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "Code Snippet (\(languageHint ?? "unknown")): \(code.prefix(40))..." }
    public var summary: String { payloadDescriptor }

    public init(
        id: UUID = UUID(),
        source: ObjectSource = .selection,
        code: String,
        languageHint: String? = nil,
        parentObjectID: String? = nil,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 0.9,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.source = source
        self.code = code
        self.languageHint = languageHint
        self.parentObjectID = parentObjectID
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// Error log or stack trace refined from text selection.
public struct ErrorLogObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .errorLog
    public let source: ObjectSource
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let logText: String
    public let detectedKeywords: [String]
    public let parentObjectID: String?
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "Error Log (\(detectedKeywords.joined(separator: ", "))): \(logText.prefix(40))..." }
    public var summary: String { payloadDescriptor }

    public init(
        id: UUID = UUID(),
        source: ObjectSource = .selection,
        logText: String,
        detectedKeywords: [String] = [],
        parentObjectID: String? = nil,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 0.9,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.source = source
        self.logText = logText
        self.detectedKeywords = detectedKeywords
        self.parentObjectID = parentObjectID
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// JSON payload refined from text selection.
public struct JSONTextObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .jsonText
    public let source: ObjectSource
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let jsonString: String
    public let isArray: Bool
    public let parentObjectID: String?
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "JSON (\(isArray ? "Array" : "Object")): \(jsonString.prefix(40))..." }
    public var summary: String { payloadDescriptor }

    public init(
        id: UUID = UUID(),
        source: ObjectSource = .selection,
        jsonString: String,
        isArray: Bool = false,
        parentObjectID: String? = nil,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 1.0,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.source = source
        self.jsonString = jsonString
        self.isArray = isArray
        self.parentObjectID = parentObjectID
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// Fallback read-only snapshot of existing clipboard.
public struct ClipboardObject: PulseObject {
    public let id: UUID
    public let objectClass: ObjectClass = .clipboard
    public let source: ObjectSource = .clipboard
    public let createdAt: Date
    public let confidence: Double
    public let provenance: ObjectProvenance
    public let privacyClass: PrivacyClass
    public let changeCount: Int
    public let types: [String]
    public let textPreview: String?
    public let contextGenerationToken: String?

    public var payloadDescriptor: String { "Clipboard (changeCount: \(changeCount), types: \(types.count))" }
    public var summary: String { "Clipboard (changeCount: \(changeCount))" }

    public init(
        id: UUID = UUID(),
        changeCount: Int,
        types: [String],
        textPreview: String? = nil,
        provenance: ObjectProvenance,
        privacyClass: PrivacyClass = .ordinary,
        confidence: Double = 1.0,
        contextGenerationToken: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.changeCount = changeCount
        self.types = types
        self.textPreview = textPreview
        self.provenance = provenance
        self.privacyClass = privacyClass
        self.confidence = confidence
        self.contextGenerationToken = contextGenerationToken
        self.createdAt = createdAt
    }
}

/// Record of an evaluated candidate during context resolution.
public struct ContextCandidateSnapshot: Sendable {
    public let tierRawValue: Int
    public let objectClass: ObjectClass
    public let objectSummary: String
    public let confidence: Double
    public let acquisitionReason: String

    public init(
        tierRawValue: Int,
        objectClass: ObjectClass,
        objectSummary: String,
        confidence: Double,
        acquisitionReason: String
    ) {
        self.tierRawValue = tierRawValue
        self.objectClass = objectClass
        self.objectSummary = objectSummary
        self.confidence = confidence
        self.acquisitionReason = acquisitionReason
    }
}

/// Context degradation reasons capturing non-fatal provider issues or permission limitations.
public enum ContextDegradationReason: String, Sendable, Codable, Equatable {
    case accessibilityPermissionDenied = "accessibility.permissionDenied"
    case accessibilityUnavailable = "accessibility.unavailable"
    case accessibilityTimedOut = "accessibility.timedOut"
    case secureFieldBlocked = "privacy.secureFieldBlocked"
    case staleContextDetected = "staleContext.invalidated"
    case providerUnsupported = "provider.unsupported"
}

/// Context envelope capturing invocation context atomically.
public struct PulseContextEnvelope: Sendable {
    public let id: UUID
    public let invocationTime: Date
    public let generationToken: String
    public let screenCoordinates: (x: Double, y: Double)?
    public let primaryObject: (any PulseObject)?
    public let primaryReason: String?
    public let primaryTier: Int?
    public let fallbackObject: (any PulseObject)?
    public let evaluatedCandidates: [ContextCandidateSnapshot]
    public let accessibilityStatus: String
    public let degradationReasons: [ContextDegradationReason]

    public init(
        id: UUID = UUID(),
        invocationTime: Date = Date(),
        generationToken: String = UUID().uuidString,
        screenCoordinates: (x: Double, y: Double)? = nil,
        primaryObject: (any PulseObject)? = nil,
        primaryReason: String? = nil,
        primaryTier: Int? = nil,
        fallbackObject: (any PulseObject)? = nil,
        evaluatedCandidates: [ContextCandidateSnapshot] = [],
        accessibilityStatus: String = "authorized",
        degradationReasons: [ContextDegradationReason] = []
    ) {
        self.id = id
        self.invocationTime = invocationTime
        self.generationToken = generationToken
        self.screenCoordinates = screenCoordinates
        self.primaryObject = primaryObject
        self.primaryReason = primaryReason
        self.primaryTier = primaryTier
        self.fallbackObject = fallbackObject
        self.evaluatedCandidates = evaluatedCandidates
        self.accessibilityStatus = accessibilityStatus
        self.degradationReasons = degradationReasons
    }
}
