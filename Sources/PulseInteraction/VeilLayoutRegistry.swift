import Foundation
import PulseCore

/// Lifecycle stability tier of a Veil layout.
///
/// Phase 4: `.experimental`
/// Phase 5: `.candidate` (version `1.0.0-candidate`)
/// Post-Phase 5: `.frozen-v1` (explicit owner approval only)
public enum VeilLayoutLifecycle: String, Sendable, Codable, Equatable, CustomStringConvertible {
    case experimental = "experimental"
    case candidate    = "candidate"
    case frozenV1     = "frozen-v1"

    public var description: String { rawValue }

    public var isCandidate: Bool { self == .candidate }
    public var isFrozen: Bool { self == .frozenV1 }
    public var isExperimental: Bool { self == .experimental }
}

/// Errors occurring during layout freeze operations.
public enum VeilLayoutFreezeError: Error, Sendable, Equatable {
    case notCandidate(currentLifecycle: VeilLayoutLifecycle)
    case invalidApprovalToken
    case automatedHarnessProhibited
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
public struct VeilObjectLayout: Sendable, Equatable {
    public let objectClass: ObjectClass
    public let lifecycle: VeilLayoutLifecycle
    public let slots: [CompassDirection: VeilReflexDescriptor]
    public let version: String

    public init(
        objectClass: ObjectClass,
        lifecycle: VeilLayoutLifecycle = .candidate,
        slots: [CompassDirection: VeilReflexDescriptor],
        version: String = "1.0.0-candidate"
    ) {
        self.objectClass = objectClass
        self.lifecycle = lifecycle
        self.slots = slots
        self.version = version
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
            return "\(dir.rawValue): \(desc.id) [\(desc.label)] (\(desc.state))"
        }
        return "[\(objectClass.rawValue)] (lifecycle: \(lifecycle), version: \(version))\n" + sortedSlots.joined(separator: "\n")
    }
}

/// Typed registry managing directional layouts for all recognized V1 object classes.
///
/// Invariant:
/// - Same object class always maps to the same slot directions (V1-030).
/// - No AI ranking, dynamic reordering, or motor reflow (V1-031).
/// - Unavailable capabilities preserve position (disabled slot); neighbors never slide over.
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
    public func layout(for objectClass: ObjectClass) -> VeilObjectLayout {
        lock.lock()
        defer { lock.unlock() }
        if let existing = layouts[objectClass] {
            return existing
        }
        // Fallback to text family layout if not explicitly registered
        return createTextLayout(for: objectClass)
    }

    /// Returns all registered object classes.
    public var registeredClasses: [ObjectClass] {
        lock.lock()
        defer { lock.unlock() }
        return Array(layouts.keys)
    }

    /// Returns a deterministic snapshot of all layouts for testing.
    public func fullRegistrySnapshot() -> String {
        lock.lock()
        defer { lock.unlock() }
        return ObjectClass.allCases.map { objClass in
            let lay = layouts[objClass] ?? createTextLayout(for: objClass)
            return lay.snapshotDescription
        }.joined(separator: "\n---\n")
    }

    /// Freezes a candidate layout into .frozenV1. Requires explicit owner approval token.
    ///
    /// Invariant: Automated test harnesses and autonomous agents are strictly PROHIBITED
    /// from freezing layouts. Only explicit human owner approval can authorize freezing.
    @discardableResult
    public func freezeLayout(for objectClass: ObjectClass, ownerApprovalToken: String) -> Result<VeilObjectLayout, VeilLayoutFreezeError> {
        lock.lock()
        defer { lock.unlock() }

        guard let existing = layouts[objectClass] else {
            return .failure(.notCandidate(currentLifecycle: .experimental))
        }

        guard existing.lifecycle == .candidate else {
            return .failure(.notCandidate(currentLifecycle: existing.lifecycle))
        }

        // Automated test harness guard
        if ownerApprovalToken == "AUTOMATED_HARNESS" || ownerApprovalToken == "CI" {
            return .failure(.automatedHarnessProhibited)
        }

        // Require valid owner authorization token format (OWNER-FREEZE-...)
        guard ownerApprovalToken.hasPrefix("OWNER-FREEZE-") && ownerApprovalToken.count >= 20 else {
            return .failure(.invalidApprovalToken)
        }

        let frozen = VeilObjectLayout(
            objectClass: objectClass,
            lifecycle: .frozenV1,
            slots: existing.slots,
            version: "frozen-v1"
        )
        layouts[objectClass] = frozen
        return .success(frozen)
    }

    // MARK: - Default Layout Registration (Authority: docs/OBJECT_LAYOUTS_V1.md)

    private func registerDefaultLayouts() {
        // 1. Error / Log Family
        let errorLayout = createErrorLogLayout()
        layouts[.errorLog] = errorLayout

        // 2. Code / Repository / File / Path Family
        let repoFamily = createRepoPathLayout(for: .code)
        layouts[.code] = repoFamily
        layouts[.path] = createRepoPathLayout(for: .path)
        layouts[.file] = createRepoPathLayout(for: .file)
        layouts[.selectedFile] = createRepoPathLayout(for: .selectedFile)

        // 3. UI Element Family
        let uiFamily = createUIElementLayout(for: .uiElement)
        layouts[.uiElement] = uiFamily
        layouts[.focusedElement] = createUIElementLayout(for: .focusedElement)
        layouts[.window] = createUIElementLayout(for: .window)
        layouts[.application] = createUIElementLayout(for: .application)

        // 4. Text Family
        let textFamily = createTextLayout(for: .selectedText)
        layouts[.selectedText] = textFamily
        layouts[.jsonText] = createTextLayout(for: .jsonText)
        layouts[.clipboard] = createTextLayout(for: .clipboard)
        layouts[.url] = createTextLayout(for: .url)

        // 5. Result Family
        layouts[.result] = createResultLayout()
    }

    private func createErrorLogLayout() -> VeilObjectLayout {
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

        return VeilObjectLayout(objectClass: .errorLog, slots: slots)
    }

    private func createRepoPathLayout(for objClass: ObjectClass) -> VeilObjectLayout {
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
            state: .locked(reason: "Automated write checkpoints locked in Phase 4"),
            keyboardHint: "P"
        )

        return VeilObjectLayout(objectClass: objClass, slots: slots)
    }

    private func createUIElementLayout(for objClass: ObjectClass) -> VeilObjectLayout {
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

        return VeilObjectLayout(objectClass: objClass, slots: slots)
    }

    private func createTextLayout(for objClass: ObjectClass) -> VeilObjectLayout {
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
            summary: "Verify and research claims",
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

        return VeilObjectLayout(objectClass: objClass, slots: slots)
    }

    private func createResultLayout() -> VeilObjectLayout {
        var slots: [CompassDirection: VeilReflexDescriptor] = [:]
        slots[.n] = VeilReflexDescriptor(
            id: "result.repulse",
            label: "Re-Pulse",
            summary: "Invoke new Pulse on this result",
            direction: .n,
            keyboardHint: "R"
        )
        slots[.ne] = VeilReflexDescriptor(
            id: "result.evidence",
            label: "Evidence",
            summary: "Inspect execution evidence and timing",
            direction: .ne,
            keyboardHint: "E"
        )
        slots[.e] = VeilReflexDescriptor(
            id: "result.witness",
            label: "Witness Proof",
            summary: "View structured Witness receipt",
            direction: .e,
            keyboardHint: "W"
        )
        slots[.se] = VeilReflexDescriptor(
            id: "result.target",
            label: "Send / Target",
            summary: "Send result to machine or spool",
            direction: .se,
            keyboardHint: "S"
        )
        slots[.s] = VeilReflexDescriptor(
            id: "result.spool",
            label: "Keep / Pin",
            summary: "Pin result to Spool for session persistence",
            direction: .s,
            keyboardHint: "K"
        )
        slots[.sw] = VeilReflexDescriptor(
            id: "result.open",
            label: "Reveal",
            summary: "Reveal result output in editor",
            direction: .sw,
            keyboardHint: "O"
        )
        slots[.w] = VeilReflexDescriptor(
            id: "result.diff",
            label: "Diff",
            summary: "Inspect structural diff against input",
            direction: .w,
            keyboardHint: "D"
        )
        slots[.nw] = VeilReflexDescriptor(
            id: "result.dismiss",
            label: "Dismiss",
            summary: "Dismiss result and recede",
            direction: .nw,
            keyboardHint: "Esc"
        )

        return VeilObjectLayout(objectClass: .result, slots: slots)
    }
}
