import Foundation
import PulseCore

/// Lifecycle stability tier of a Veil layout.
///
/// Phase 4: `.experimental`
/// Phase 5: `.candidate` (version `1.0.0-candidate`)
/// Post-Phase 5: `.frozenV1` (explicit owner approval via source migration/ADR only)
public enum VeilLayoutLifecycle: String, Sendable, Codable, Equatable, CustomStringConvertible {
    case experimental = "experimental"
    case candidate    = "candidate"
    case frozenV1     = "frozen-v1"

    public var description: String { rawValue }

    public var isCandidate: Bool { self == .candidate }
    public var isFrozen: Bool { self == .frozenV1 }
    public var isExperimental: Bool { self == .experimental }
}

/// Recognized layout family grouping.
public enum VeilLayoutFamily: String, Sendable, Codable, Equatable, CustomStringConvertible {
    case text        = "Text"
    case errorLog    = "Error / log"
    case repoPath    = "Repository / project / path"
    case uiElement   = "UI element"
    case imageFile   = "Image / file"
    case unresolved  = "Unresolved / Ambiguous"

    public var description: String { rawValue }
}

/// Visual and interactive presentation state of a Reflex slot.
public enum VeilPresentationState: Sendable, Codable, Equatable {
    case enabled
    case unavailable(reason: String)
    case locked(reason: String)

    public var isInteractive: Bool {
        if case .enabled = self { return true }
        return false
    }

    public var description: String {
        switch self {
        case .enabled:
            return "enabled"
        case .unavailable(let reason):
            return "unavailable: \(reason)"
        case .locked(let reason):
            return "locked: \(reason)"
        }
    }
}

/// A target or secondary choice presented via nested disclosure.
public struct VeilTargetChoice: Sendable, Codable, Equatable, Identifiable {
    public let id: String
    public let label: String
    public let summary: String
    public let isDefault: Bool

    public init(id: String, label: String, summary: String = "", isDefault: Bool = false) {
        self.id = id
        self.label = label
        self.summary = summary
        self.isDefault = isDefault
    }
}

/// Descriptor representing an action slot in the Veil annular wheel.
public struct VeilReflexDescriptor: Sendable, Codable, Equatable, Identifiable {
    public let id: String
    public let label: String
    public let summary: String
    public let direction: CompassDirection
    public let state: VeilPresentationState
    public let keyboardHint: String?
    public let nestedChoices: [VeilTargetChoice]?

    public init(
        id: String,
        label: String,
        summary: String = "",
        direction: CompassDirection,
        state: VeilPresentationState = .enabled,
        keyboardHint: String? = nil,
        nestedChoices: [VeilTargetChoice]? = nil
    ) {
        self.id = id
        self.label = label
        self.summary = summary
        self.direction = direction
        self.state = state
        self.keyboardHint = keyboardHint
        self.nestedChoices = nestedChoices
    }

    /// Whether this Reflex has secondary nested targets/disclosure available.
    public var hasNestedDisclosure: Bool {
        guard let choices = nestedChoices else { return false }
        return !choices.isEmpty
    }
}

/// Typed layout schema mapping directions to Reflexes for an `ObjectClass`.
///
/// SAFE LIFECYCLE DEFAULT:
/// Newly constructed layouts default strictly to `.experimental` and `"1.0.0-experimental"`.
/// Candidate status must be declared explicitly for source-justified candidate families.
public struct VeilObjectLayout: Sendable, Equatable {
    public let objectClass: ObjectClass
    public let family: VeilLayoutFamily
    public let lifecycle: VeilLayoutLifecycle
    public let slots: [CompassDirection: VeilReflexDescriptor]
    public let version: String
    public let sourceAuthority: String
    public let unresolvedQuestions: [String]

    public init(
        objectClass: ObjectClass,
        family: VeilLayoutFamily = .unresolved,
        lifecycle: VeilLayoutLifecycle = .experimental,
        slots: [CompassDirection: VeilReflexDescriptor],
        version: String = "1.0.0-experimental",
        sourceAuthority: String = "docs/OBJECT_LAYOUTS_V1.md",
        unresolvedQuestions: [String] = []
    ) {
        self.objectClass = objectClass
        self.family = family
        self.lifecycle = lifecycle
        self.slots = slots
        self.version = version
        self.sourceAuthority = sourceAuthority
        self.unresolvedQuestions = unresolvedQuestions
    }

    public var isCandidate: Bool { lifecycle.isCandidate }
    public var isFrozen: Bool { lifecycle.isFrozen }
    public var isExperimental: Bool { lifecycle.isExperimental }

    /// Retrieves the reflex at a given compass direction if assigned.
    public func reflex(at direction: CompassDirection) -> VeilReflexDescriptor? {
        slots[direction]
    }

    /// Returns all occupied directions sorted deterministically.
    public var occupiedDirections: [CompassDirection] {
        CompassDirection.allCases.filter { slots[$0] != nil }
    }

    /// Deterministic textual snapshot for verification and testing.
    public var snapshotDescription: String {
        let sortedSlots = CompassDirection.allCases.compactMap { dir -> String? in
            guard let desc = slots[dir] else { return nil }
            return "\(dir.rawValue): \(desc.id) [\(desc.label)] (\(desc.state.description))"
        }
        return "[\(objectClass.rawValue)] (family: \(family), lifecycle: \(lifecycle), version: \(version), authority: \(sourceAuthority))\n" + sortedSlots.joined(separator: "\n")
    }
}

/// Typed registry managing directional layouts for all recognized V1 object classes.
///
/// Invariants:
/// - Same object class always maps to the same slot directions (V1-030).
/// - No AI ranking, dynamic reordering, or motor reflow (V1-031).
/// - Unavailable capabilities preserve position (disabled slot); neighbors never slide over.
/// - NO RUNTIME FREEZE MUTATION: Candidate layouts are immutable at runtime.
///   Freeze occurs strictly via explicit repository source change with an ADR/migration record.
/// - NO SILENT FALLBACK: Every `ObjectClass` has an explicit registered layout or family declaration.
public final class VeilLayoutRegistry: @unchecked Sendable {
    public static let shared = VeilLayoutRegistry()

    private let lock = NSLock()
    private var layouts: [ObjectClass: VeilObjectLayout] = [:]

    public init() {
        registerDefaultLayouts()
    }

    /// Registers a layout for an object class.
    public func registerLayout(_ layout: VeilObjectLayout) {
        lock.lock()
        defer { lock.unlock() }
        layouts[layout.objectClass] = layout
    }

    /// Resolves the layout for a given object class deterministically.
    /// Never silently falls back to Text family for missing classes.
    public func layout(for objectClass: ObjectClass) -> VeilObjectLayout {
        lock.lock()
        defer { lock.unlock() }
        if let existing = layouts[objectClass] {
            return existing
        }
        // Failsafe unresolved layout if an un-registered class is requested.
        return createUnresolvedExperimentalLayout(for: objectClass)
    }

    /// Returns all registered object classes.
    public var registeredClasses: [ObjectClass] {
        lock.lock()
        defer { lock.unlock() }
        return Array(layouts.keys)
    }

    /// Returns all candidate layouts (status .candidate).
    public var candidateLayouts: [VeilObjectLayout] {
        lock.lock()
        defer { lock.unlock() }
        return layouts.values.filter { $0.isCandidate }.sorted { $0.objectClass.rawValue < $1.objectClass.rawValue }
    }

    /// Returns all experimental layouts (status .experimental).
    public var experimentalLayouts: [VeilObjectLayout] {
        lock.lock()
        defer { lock.unlock() }
        return layouts.values.filter { $0.isExperimental }.sorted { $0.objectClass.rawValue < $1.objectClass.rawValue }
    }

    /// Returns a deterministic snapshot of all layouts for testing.
    public func fullRegistrySnapshot() -> String {
        lock.lock()
        defer { lock.unlock() }
        return ObjectClass.allCases.map { objClass in
            let lay = layouts[objClass] ?? createUnresolvedExperimentalLayout(for: objClass)
            return lay.snapshotDescription
        }.joined(separator: "\n---\n")
    }

    // MARK: - Default Layout Registration (Authority: docs/OBJECT_LAYOUTS_V1.md)

    private func registerDefaultLayouts() {
        // =========================================================================
        // 1. CANDIDATE FAMILIES (10 classes with explicit source authority)
        // =========================================================================

        // 1.1 Text Family (Authority: docs/OBJECT_LAYOUTS_V1.md: Text)
        layouts[.selectedText] = createTextLayout(for: .selectedText, lifecycle: .candidate, version: "1.0.0-candidate")

        // 1.2 Error / Log Family (Authority: docs/OBJECT_LAYOUTS_V1.md: Error / log)
        layouts[.errorLog] = createErrorLogLayout(lifecycle: .candidate, version: "1.0.0-candidate")

        // 1.3 Repository / Project / Path Family (Authority: docs/OBJECT_LAYOUTS_V1.md: Repository / project / path)
        layouts[.repository] = createRepoPathLayout(for: .repository, lifecycle: .candidate, version: "1.0.0-candidate")
        layouts[.path] = createRepoPathLayout(for: .path, lifecycle: .candidate, version: "1.0.0-candidate")

        // 1.4 UI Element Family (Authority: docs/OBJECT_LAYOUTS_V1.md: UI element)
        layouts[.uiElement] = createUIElementLayout(for: .uiElement, lifecycle: .candidate, version: "1.0.0-candidate")
        layouts[.focusedElement] = createUIElementLayout(
            for: .focusedElement,
            lifecycle: .candidate,
            version: "1.0.0-candidate",
            authority: "docs/OBJECT_LAYOUTS_V1.md: UI element (declared inheritance for focused AX elements)"
        )

        // 1.5 Image / File Family (Authority: docs/OBJECT_LAYOUTS_V1.md: Image/file)
        layouts[.image] = createImageFileLayout(for: .image, lifecycle: .candidate, version: "1.0.0-candidate")
        layouts[.file] = createImageFileLayout(for: .file, lifecycle: .candidate, version: "1.0.0-candidate")
        layouts[.selectedFile] = createImageFileLayout(for: .selectedFile, lifecycle: .candidate, version: "1.0.0-candidate")
        layouts[.fileSet] = createImageFileLayout(
            for: .fileSet,
            lifecycle: .candidate,
            version: "1.0.0-candidate",
            authority: "docs/OBJECT_LAYOUTS_V1.md: Image/file (declared inheritance for batch multi-file sets)"
        )

        // =========================================================================
        // 2. AMBIGUOUS / EXPERIMENTAL CLASSES (8 classes requiring owner decision)
        // =========================================================================

        // 2.1 Code: unresolved whether dedicated Code family, Repository, or Text
        layouts[.code] = createExperimentalAmbiguousLayout(
            for: .code,
            family: .unresolved,
            authority: "None (docs/OBJECT_LAYOUTS_V1.md does not define Code family)",
            unresolvedQuestions: [
                "Unresolved family: evaluate whether Code belongs to Repository, Text, or dedicated Code layout."
            ],
            slots: createProvisionalCodeSlots()
        )

        // 2.2 URL: unresolved whether Text with link actions or standalone Browser/Web family
        layouts[.url] = createExperimentalAmbiguousLayout(
            for: .url,
            family: .unresolved,
            authority: "None (docs/OBJECT_LAYOUTS_V1.md does not define URL family)",
            unresolvedQuestions: [
                "Unresolved family: evaluate whether URL inherits Text with link actions or standalone Web/Browser family."
            ],
            slots: createProvisionalURLSlots()
        )

        // 2.3 JSONText: unresolved whether Text with formatting or standalone Structured Data family
        layouts[.jsonText] = createExperimentalAmbiguousLayout(
            for: .jsonText,
            family: .unresolved,
            authority: "None (docs/OBJECT_LAYOUTS_V1.md does not define JSONText family)",
            unresolvedQuestions: [
                "Unresolved family: evaluate whether JSONText inherits Text with formatting or standalone Structured Data family."
            ],
            slots: createProvisionalJSONSlots()
        )

        // 2.4 Window: unresolved whether UI element or dedicated OS Window Management family
        layouts[.window] = createExperimentalAmbiguousLayout(
            for: .window,
            family: .unresolved,
            authority: "None (docs/OBJECT_LAYOUTS_V1.md does not define Window family)",
            unresolvedQuestions: [
                "Unresolved family: evaluate whether Window inherits UI element or dedicated OS Window Management family."
            ],
            slots: createProvisionalWindowSlots()
        )

        // 2.5 Application: unresolved whether UI element or dedicated OS Application Process family
        layouts[.application] = createExperimentalAmbiguousLayout(
            for: .application,
            family: .unresolved,
            authority: "None (docs/OBJECT_LAYOUTS_V1.md does not define Application family)",
            unresolvedQuestions: [
                "Unresolved family: evaluate whether Application inherits UI element or dedicated OS Process/App family."
            ],
            slots: createProvisionalApplicationSlots()
        )

        // 2.6 Clipboard: unresolved whether Text inheritance or dynamic multi-type wrapper
        layouts[.clipboard] = createExperimentalAmbiguousLayout(
            for: .clipboard,
            family: .unresolved,
            authority: "None (docs/OBJECT_LAYOUTS_V1.md does not define Clipboard family)",
            unresolvedQuestions: [
                "Unresolved family: evaluate whether Clipboard inherits Text or dynamic multi-type container."
            ],
            slots: createProvisionalClipboardSlots()
        )

        // 2.7 Result: transient Result hold behavior defined in INTERACTION_MODEL.md, but layout unreviewed
        layouts[.result] = createExperimentalAmbiguousLayout(
            for: .result,
            family: .unresolved,
            authority: "docs/INTERACTION_MODEL.md: Result Object (hold and inspection lifecycle)",
            unresolvedQuestions: [
                "Unresolved family: Result hold layout mentioned in docs/INTERACTION_MODEL.md requires deliberate owner validation before candidate promotion."
            ],
            slots: createProvisionalResultSlots()
        )

        // 2.8 MachineTarget: execution target selection layout unreviewed
        layouts[.machineTarget] = createExperimentalAmbiguousLayout(
            for: .machineTarget,
            family: .unresolved,
            authority: "None (docs/OBJECT_LAYOUTS_V1.md does not define MachineTarget family)",
            unresolvedQuestions: [
                "Unresolved family: Machine execution target selection layout is not defined in docs/OBJECT_LAYOUTS_V1.md and requires deliberate owner validation."
            ],
            slots: createProvisionalMachineTargetSlots()
        )
    }

    // MARK: - Family Factory Methods

    private func createTextLayout(
        for objClass: ObjectClass,
        lifecycle: VeilLayoutLifecycle,
        version: String,
        authority: String = "docs/OBJECT_LAYOUTS_V1.md: Text"
    ) -> VeilObjectLayout {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(
            id: "text.explain",
            label: "Explain",
            summary: "Explain selected text meaning",
            direction: .n,
            keyboardHint: "E"
        )
        slots[.ne] = VeilReflexDescriptor(
            id: "text.verify",
            label: "Verify",
            summary: "Verify claims and research evidence",
            direction: .ne,
            keyboardHint: "V"
        )
        slots[.e] = VeilReflexDescriptor(
            id: "text.transform",
            label: "Transform",
            summary: "Format or refine selected text",
            direction: .e,
            keyboardHint: "T"
        )
        slots[.se] = VeilReflexDescriptor(
            id: "text.send",
            label: "Send",
            summary: "Send text to capability or target",
            direction: .se,
            keyboardHint: "S",
            nestedChoices: [
                VeilTargetChoice(id: "text.ollama", label: "Ollama Summarizer", isDefault: true),
                VeilTargetChoice(id: "text.copy", label: "Copy Structured")
            ]
        )
        slots[.s] = VeilReflexDescriptor(
            id: "text.spool",
            label: "Keep / Spool",
            summary: "Keep text reference in Spool",
            direction: .s,
            keyboardHint: "K"
        )
        slots[.sw] = VeilReflexDescriptor(
            id: "text.source",
            label: "Find Source",
            summary: "Find source document or origin",
            direction: .sw,
            keyboardHint: "F"
        )
        slots[.w] = VeilReflexDescriptor(
            id: "text.structure",
            label: "Structure",
            summary: "Inspect structured parsing / syntax",
            direction: .w,
            keyboardHint: "X"
        )
        slots[.nw] = VeilReflexDescriptor(
            id: "text.route",
            label: "Route",
            summary: "Route to best executor",
            direction: .nw,
            keyboardHint: "R"
        )

        return VeilObjectLayout(
            objectClass: objClass,
            family: .text,
            lifecycle: lifecycle,
            slots: slots,
            version: version,
            sourceAuthority: authority
        )
    }

    private func createErrorLogLayout(
        lifecycle: VeilLayoutLifecycle,
        version: String,
        authority: String = "docs/OBJECT_LAYOUTS_V1.md: Error / log"
    ) -> VeilObjectLayout {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(
            id: "error.explain",
            label: "Explain",
            summary: "Explain error and call stack",
            direction: .n,
            keyboardHint: "E"
        )
        slots[.ne] = VeilReflexDescriptor(
            id: "error.research",
            label: "Research",
            summary: "Research evidence and known fixes",
            direction: .ne,
            keyboardHint: "R"
        )
        slots[.e] = VeilReflexDescriptor(
            id: "error.diagnose",
            label: "Diagnose",
            summary: "Diagnose root cause",
            direction: .e,
            keyboardHint: "D"
        )
        slots[.se] = VeilReflexDescriptor(
            id: "error.send_agent",
            label: "Send",
            summary: "Send error context to subagent",
            direction: .se,
            keyboardHint: "S",
            nestedChoices: [
                VeilTargetChoice(id: "agent.local", label: "Local Ollama", isDefault: true),
                VeilTargetChoice(id: "agent.bigmac", label: "Big Mac Worker"),
                VeilTargetChoice(id: "agent.spool", label: "Queue to Spool")
            ]
        )
        slots[.s] = VeilReflexDescriptor(
            id: "error.witness",
            label: "Keep / Witness",
            summary: "Keep log context in Witness store",
            direction: .s,
            keyboardHint: "K"
        )
        slots[.sw] = VeilReflexDescriptor(
            id: "error.find_source",
            label: "Find Source",
            summary: "Locate source file in workspace",
            direction: .sw,
            keyboardHint: "F"
        )
        slots[.w] = VeilReflexDescriptor(
            id: "error.repair_packet",
            label: "Repair",
            summary: "Generate repair packet (non-executing in V1)",
            direction: .w,
            state: .locked(reason: "Repair execution locked until Phase 8"),
            keyboardHint: "P"
        )
        slots[.nw] = VeilReflexDescriptor(
            id: "error.regression_fixture",
            label: "Fixture",
            summary: "Capture as regression fixture",
            direction: .nw,
            keyboardHint: "X"
        )

        return VeilObjectLayout(
            objectClass: .errorLog,
            family: .errorLog,
            lifecycle: lifecycle,
            slots: slots,
            version: version,
            sourceAuthority: authority
        )
    }

    private func createRepoPathLayout(
        for objClass: ObjectClass,
        lifecycle: VeilLayoutLifecycle,
        version: String,
        authority: String = "docs/OBJECT_LAYOUTS_V1.md: Repository / project / path"
    ) -> VeilObjectLayout {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(
            id: "repo.status",
            label: "Status",
            summary: "Inspect Git / project status",
            direction: .n,
            keyboardHint: "S"
        )
        slots[.ne] = VeilReflexDescriptor(
            id: "repo.changes",
            label: "Changes",
            summary: "Inspect recent diff and working tree",
            direction: .ne,
            keyboardHint: "C"
        )
        slots[.e] = VeilReflexDescriptor(
            id: "repo.validate",
            label: "Validate",
            summary: "Run project read checks and verification",
            direction: .e,
            keyboardHint: "V"
        )
        slots[.se] = VeilReflexDescriptor(
            id: "repo.target",
            label: "Target",
            summary: "Target / send to machine",
            direction: .se,
            keyboardHint: "T",
            nestedChoices: [
                VeilTargetChoice(id: "target.local", label: "MacBook Air M1", isDefault: true),
                VeilTargetChoice(id: "target.bigmac", label: "Big Mac Canonical")
            ]
        )
        slots[.s] = VeilReflexDescriptor(
            id: "repo.keep",
            label: "Keep",
            summary: "Keep project context in Witness spool",
            direction: .s,
            keyboardHint: "K"
        )
        slots[.sw] = VeilReflexDescriptor(
            id: "repo.open",
            label: "Open / Reveal",
            summary: "Reveal path in Finder or Terminal",
            direction: .sw,
            keyboardHint: "O"
        )
        slots[.w] = VeilReflexDescriptor(
            id: "repo.search",
            label: "Search",
            summary: "Search source tree",
            direction: .w,
            keyboardHint: "F"
        )
        slots[.nw] = VeilReflexDescriptor(
            id: "repo.checkpoint",
            label: "Checkpoint",
            summary: "Repository checkpoint (read-only in early V1)",
            direction: .nw,
            state: .locked(reason: "Automated write checkpoints locked in early V1"),
            keyboardHint: "P"
        )

        return VeilObjectLayout(
            objectClass: objClass,
            family: .repoPath,
            lifecycle: lifecycle,
            slots: slots,
            version: version,
            sourceAuthority: authority
        )
    }

    private func createUIElementLayout(
        for objClass: ObjectClass,
        lifecycle: VeilLayoutLifecycle,
        version: String,
        authority: String = "docs/OBJECT_LAYOUTS_V1.md: UI element"
    ) -> VeilObjectLayout {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(
            id: "ui.inspect",
            label: "Inspect",
            summary: "Inspect Accessibility element attributes",
            direction: .n,
            keyboardHint: "I"
        )
        slots[.ne] = VeilReflexDescriptor(
            id: "ui.explain",
            label: "Explain",
            summary: "Explain control role and hierarchy",
            direction: .ne,
            keyboardHint: "E"
        )
        slots[.e] = VeilReflexDescriptor(
            id: "ui.actions",
            label: "AX Actions",
            summary: "Supported AX actions (read-only review in V1)",
            direction: .e,
            keyboardHint: "A"
        )
        slots[.se] = VeilReflexDescriptor(
            id: "ui.spool",
            label: "Add to Spool",
            summary: "Add element reference to Spool",
            direction: .se,
            keyboardHint: "S"
        )
        slots[.s] = VeilReflexDescriptor(
            id: "ui.keep",
            label: "Keep",
            summary: "Keep UI reference in active session",
            direction: .s,
            keyboardHint: "K"
        )
        slots[.sw] = VeilReflexDescriptor(
            id: "ui.parent",
            label: "Parent",
            summary: "Inspect parent window/application",
            direction: .sw,
            keyboardHint: "P"
        )
        slots[.w] = VeilReflexDescriptor(
            id: "ui.related",
            label: "Related",
            summary: "Search related elements in app",
            direction: .w,
            keyboardHint: "R"
        )
        slots[.nw] = VeilReflexDescriptor(
            id: "ui.bind",
            label: "Bind Reflex",
            summary: "Bind custom Reflex (post-V1 placeholder)",
            direction: .nw,
            state: .unavailable(reason: "Custom binding unavailable in V1"),
            keyboardHint: "B"
        )

        return VeilObjectLayout(
            objectClass: objClass,
            family: .uiElement,
            lifecycle: lifecycle,
            slots: slots,
            version: version,
            sourceAuthority: authority
        )
    }

    /// Image/file family consistent with docs/OBJECT_LAYOUTS_V1.md.
    private func createImageFileLayout(
        for objClass: ObjectClass,
        lifecycle: VeilLayoutLifecycle,
        version: String,
        authority: String = "docs/OBJECT_LAYOUTS_V1.md: Image/file"
    ) -> VeilObjectLayout {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(
            id: "file.metadata",
            label: "Inspect Metadata",
            summary: "Inspect file dimensions, type, and metadata",
            direction: .n,
            keyboardHint: "I"
        )
        slots[.ne] = VeilReflexDescriptor(
            id: "file.enhance",
            label: "Enhance",
            summary: "Visual enhancement capability (requires Pack)",
            direction: .ne,
            state: .unavailable(reason: "Visual enhance pack unavailable in V1 baseline"),
            keyboardHint: "E"
        )
        slots[.e] = VeilReflexDescriptor(
            id: "file.convert",
            label: "Convert",
            summary: "Asset conversion capability (requires Pack)",
            direction: .e,
            state: .unavailable(reason: "Asset conversion pack unavailable in V1 baseline"),
            keyboardHint: "C"
        )
        slots[.se] = VeilReflexDescriptor(
            id: "file.send",
            label: "Send / Target",
            summary: "Send file reference to target machine or tool",
            direction: .se,
            keyboardHint: "S",
            nestedChoices: [
                VeilTargetChoice(id: "target.local", label: "MacBook Air M1", isDefault: true),
                VeilTargetChoice(id: "target.bigmac", label: "Big Mac Canonical")
            ]
        )
        slots[.s] = VeilReflexDescriptor(
            id: "file.spool",
            label: "Spool / Keep",
            summary: "Keep file reference in Spool",
            direction: .s,
            keyboardHint: "K"
        )
        slots[.sw] = VeilReflexDescriptor(
            id: "file.reveal",
            label: "Reveal / Open",
            summary: "Reveal in Finder or open with default app",
            direction: .sw,
            keyboardHint: "R"
        )
        slots[.w] = VeilReflexDescriptor(
            id: "file.related",
            label: "Related",
            summary: "Find related project assets",
            direction: .w,
            state: .unavailable(reason: "Asset discovery pack unavailable in V1 baseline"),
            keyboardHint: "F"
        )
        slots[.nw] = VeilReflexDescriptor(
            id: "file.variant",
            label: "Variant",
            summary: "Generate variant capability (requires Pack)",
            direction: .nw,
            state: .unavailable(reason: "Variant generation pack unavailable in V1 baseline"),
            keyboardHint: "V"
        )

        return VeilObjectLayout(
            objectClass: objClass,
            family: .imageFile,
            lifecycle: lifecycle,
            slots: slots,
            version: version,
            sourceAuthority: authority
        )
    }

    private func createExperimentalAmbiguousLayout(
        for objClass: ObjectClass,
        family: VeilLayoutFamily,
        authority: String,
        unresolvedQuestions: [String],
        slots: [CompassDirection: VeilReflexDescriptor]
    ) -> VeilObjectLayout {
        VeilObjectLayout(
            objectClass: objClass,
            family: family,
            lifecycle: .experimental,
            slots: slots,
            version: "1.0.0-experimental",
            sourceAuthority: authority,
            unresolvedQuestions: unresolvedQuestions
        )
    }

    private func createUnresolvedExperimentalLayout(for objClass: ObjectClass) -> VeilObjectLayout {
        createExperimentalAmbiguousLayout(
            for: objClass,
            family: .unresolved,
            authority: "None (unregistered class)",
            unresolvedQuestions: ["Unregistered object class requires explicit layout definition."],
            slots: [:]
        )
    }

    // MARK: - Provisional Slots for Ambiguous Classes (Lifecycle: .experimental)

    private func createProvisionalCodeSlots() -> [CompassDirection: VeilReflexDescriptor] {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(id: "code.explain", label: "Explain", summary: "Explain code block", direction: .n)
        slots[.ne] = VeilReflexDescriptor(id: "code.refactor", label: "Refactor", summary: "Refactor code snippet", direction: .ne)
        slots[.e] = VeilReflexDescriptor(id: "code.copy", label: "Copy Block", summary: "Copy code block clean", direction: .e)
        slots[.se] = VeilReflexDescriptor(id: "code.test", label: "Tests", summary: "Generate unit tests", direction: .se)
        slots[.s] = VeilReflexDescriptor(id: "code.run", label: "Run Scratchpad", summary: "Execute in scratch environment", direction: .s)
        slots[.sw] = VeilReflexDescriptor(id: "code.lint", label: "Lint", summary: "Typecheck and lint snippet", direction: .sw)
        slots[.w] = VeilReflexDescriptor(id: "code.doc", label: "Document", summary: "Add docstrings", direction: .w)
        slots[.nw] = VeilReflexDescriptor(id: "code.format", label: "Format", summary: "Format code indentation", direction: .nw)
        return slots
    }

    private func createProvisionalURLSlots() -> [CompassDirection: VeilReflexDescriptor] {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(id: "url.open", label: "Open Browser", summary: "Open URL in default browser", direction: .n)
        slots[.ne] = VeilReflexDescriptor(id: "url.copy", label: "Copy Link", summary: "Copy cleaned link", direction: .ne)
        slots[.e] = VeilReflexDescriptor(id: "url.fetch", label: "Fetch Meta", summary: "Fetch OpenGraph metadata", direction: .e)
        slots[.se] = VeilReflexDescriptor(id: "url.archive", label: "Archive", summary: "Archive page snapshot", direction: .se)
        slots[.s] = VeilReflexDescriptor(id: "url.scan", label: "Scan Security", summary: "Scan URL safety", direction: .s)
        slots[.sw] = VeilReflexDescriptor(id: "url.headers", label: "Headers", summary: "Inspect HTTP headers", direction: .sw)
        slots[.w] = VeilReflexDescriptor(id: "url.share", label: "Share", summary: "Share URL to destination", direction: .w)
        slots[.nw] = VeilReflexDescriptor(id: "url.search", label: "Domain Search", summary: "Search domain web presence", direction: .nw)
        return slots
    }

    private func createProvisionalJSONSlots() -> [CompassDirection: VeilReflexDescriptor] {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(id: "json.validate", label: "Validate", summary: "Validate JSON syntax", direction: .n)
        slots[.ne] = VeilReflexDescriptor(id: "json.format", label: "Prettify", summary: "Prettify JSON formatting", direction: .ne)
        slots[.e] = VeilReflexDescriptor(id: "json.compact", label: "Minify", summary: "Minify JSON string", direction: .e)
        slots[.se] = VeilReflexDescriptor(id: "json.schema", label: "Gen Schema", summary: "Derive JSON schema", direction: .se)
        slots[.s] = VeilReflexDescriptor(id: "json.path", label: "Extract Path", summary: "Query JSON path", direction: .s)
        slots[.sw] = VeilReflexDescriptor(id: "json.yaml", label: "To YAML", summary: "Convert to YAML", direction: .sw)
        slots[.w] = VeilReflexDescriptor(id: "json.inspect", label: "Inspect", summary: "Inspect key hierarchy", direction: .w)
        slots[.nw] = VeilReflexDescriptor(id: "json.types", label: "Codable Swift", summary: "Generate Swift Codable types", direction: .nw)
        return slots
    }

    private func createProvisionalWindowSlots() -> [CompassDirection: VeilReflexDescriptor] {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(id: "window.inspect", label: "Inspect Window", summary: "Inspect window attributes", direction: .n)
        slots[.ne] = VeilReflexDescriptor(id: "window.focus", label: "Focus", summary: "Bring window to front", direction: .ne)
        slots[.e] = VeilReflexDescriptor(id: "window.bounds", label: "Bounds", summary: "Inspect window frame bounds", direction: .e)
        slots[.se] = VeilReflexDescriptor(id: "window.spool", label: "Add to Spool", summary: "Spool window reference", direction: .se)
        slots[.s] = VeilReflexDescriptor(id: "window.keep", label: "Keep", summary: "Keep window reference in session", direction: .s)
        slots[.sw] = VeilReflexDescriptor(id: "window.parent", label: "Parent App", summary: "Inspect owner application", direction: .sw)
        slots[.w] = VeilReflexDescriptor(id: "window.elements", label: "Child Elements", summary: "List top-level window elements", direction: .w)
        slots[.nw] = VeilReflexDescriptor(id: "window.tile", label: "Tile", summary: "Tile window in display space", direction: .nw)
        return slots
    }

    private func createProvisionalApplicationSlots() -> [CompassDirection: VeilReflexDescriptor] {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(id: "app.inspect", label: "Inspect App", summary: "Inspect application PID and bundle", direction: .n)
        slots[.ne] = VeilReflexDescriptor(id: "app.info", label: "Bundle Info", summary: "View bundle identifier and version", direction: .ne)
        slots[.e] = VeilReflexDescriptor(id: "app.windows", label: "Windows", summary: "List open windows", direction: .e)
        slots[.se] = VeilReflexDescriptor(id: "app.spool", label: "Add to Spool", summary: "Spool application reference", direction: .se)
        slots[.s] = VeilReflexDescriptor(id: "app.keep", label: "Keep", summary: "Keep application reference in session", direction: .s)
        slots[.sw] = VeilReflexDescriptor(id: "app.running", label: "Process State", summary: "Inspect CPU/memory state", direction: .sw)
        slots[.w] = VeilReflexDescriptor(id: "app.related", label: "Related Apps", summary: "Find related helper processes", direction: .w)
        slots[.nw] = VeilReflexDescriptor(id: "app.hide", label: "Hide App", summary: "Hide application windows", direction: .nw)
        return slots
    }

    private func createProvisionalClipboardSlots() -> [CompassDirection: VeilReflexDescriptor] {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(id: "clip.inspect", label: "Inspect Types", summary: "Inspect available pasteboard flavors", direction: .n)
        slots[.ne] = VeilReflexDescriptor(id: "clip.paste_plain", label: "Paste Plain", summary: "Extract plain text", direction: .ne)
        slots[.e] = VeilReflexDescriptor(id: "clip.transform", label: "Transform", summary: "Transform clipboard content", direction: .e)
        slots[.se] = VeilReflexDescriptor(id: "clip.send", label: "Send", summary: "Send clipboard payload", direction: .se)
        slots[.s] = VeilReflexDescriptor(id: "clip.spool", label: "Spool / Keep", summary: "Save clipboard entry to Spool", direction: .s)
        slots[.sw] = VeilReflexDescriptor(id: "clip.source", label: "Trace Source", summary: "Trace source application", direction: .sw)
        slots[.w] = VeilReflexDescriptor(id: "clip.clear", label: "Clear History", summary: "Clear transient clipboard reference", direction: .w)
        slots[.nw] = VeilReflexDescriptor(id: "clip.rich", label: "Paste Rich", summary: "Extract formatted rich text/RTF", direction: .nw)
        return slots
    }

    private func createProvisionalResultSlots() -> [CompassDirection: VeilReflexDescriptor] {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(id: "result.repulse", label: "Re-Pulse", summary: "Invoke new Pulse on this result", direction: .n, keyboardHint: "R")
        slots[.ne] = VeilReflexDescriptor(id: "result.evidence", label: "Evidence", summary: "Inspect execution evidence and timing", direction: .ne, keyboardHint: "E")
        slots[.e] = VeilReflexDescriptor(id: "result.witness", label: "Witness Proof", summary: "View structured Witness receipt", direction: .e, keyboardHint: "W")
        slots[.se] = VeilReflexDescriptor(id: "result.target", label: "Send / Target", summary: "Send result to machine or spool", direction: .se, keyboardHint: "S")
        slots[.s] = VeilReflexDescriptor(id: "result.spool", label: "Keep / Pin", summary: "Pin result to Spool for session persistence", direction: .s, keyboardHint: "K")
        slots[.sw] = VeilReflexDescriptor(id: "result.open", label: "Reveal", summary: "Reveal result output in editor", direction: .sw, keyboardHint: "O")
        slots[.w] = VeilReflexDescriptor(id: "result.diff", label: "Diff", summary: "Inspect structural diff against input", direction: .w, keyboardHint: "D")
        slots[.nw] = VeilReflexDescriptor(id: "result.dismiss", label: "Dismiss", summary: "Dismiss result and recede", direction: .nw, keyboardHint: "Esc")
        return slots
    }

    private func createProvisionalMachineTargetSlots() -> [CompassDirection: VeilReflexDescriptor] {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(id: "target.ping", label: "Ping Target", summary: "Test host connectivity", direction: .n)
        slots[.ne] = VeilReflexDescriptor(id: "target.stats", label: "System Stats", summary: "Inspect host CPU and RAM", direction: .ne)
        slots[.e] = VeilReflexDescriptor(id: "target.run", label: "Run Remote", summary: "Dispatch remote execution task", direction: .e)
        slots[.se] = VeilReflexDescriptor(id: "target.context", label: "Target Context", summary: "Bind machine execution context", direction: .se)
        slots[.s] = VeilReflexDescriptor(id: "target.keep", label: "Keep Target", summary: "Keep host reference in Spool", direction: .s)
        slots[.sw] = VeilReflexDescriptor(id: "target.shell", label: "Open Shell", summary: "Open SSH terminal session", direction: .sw)
        slots[.w] = VeilReflexDescriptor(id: "target.caps", label: "Capabilities", summary: "List installed machine capabilities", direction: .w)
        slots[.nw] = VeilReflexDescriptor(id: "target.disconnect", label: "Disconnect", summary: "Disconnect active machine session", direction: .nw)
        return slots
    }
}
