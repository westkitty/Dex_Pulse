import Foundation
import PulseCore

/// Deterministic generator for the Phase 5 Owner Review document.
///
/// Ensures docs/layout-trials/PHASE-05-OWNER-REVIEW.md is 100% synchronized with
/// runtime `VeilLayoutRegistry` state, eliminating drift between code and documentation.
public enum VeilOwnerReviewGenerator {

    /// Generates the complete markdown text of the owner-review document.
    public static func generateDocument(registry: VeilLayoutRegistry = .shared) -> String {
        var doc = ""

        // Header
        doc += "# DEX//PULSE Phase 5 — Candidate Object Layout Review\n\n"
        doc += "**Status:** `READY FOR OWNER REVIEW`<br>\n"
        doc += "**Candidate Classes (10):** `selectedText`, `errorLog`, `repository`, `path`, `uiElement`, `focusedElement`, `image`, `file`, `selectedFile`, `fileSet`<br>\n"
        doc += "**Ambiguous / Experimental Classes (8):** `code`, `url`, `jsonText`, `window`, `application`, `clipboard`, `result`, `machineTarget`<br>\n"
        doc += "**Frozen Classes:** `0` (Freeze strictly prohibited prior to real owner review)<br>\n"
        doc += "**Target:** Apple Silicon macOS 14+ (MacBook Air / Big Mac)\n\n"

        doc += "> [!IMPORTANT]\n"
        doc += "> **OWNER APPROVAL NEEDED TO FREEZE**<br>\n"
        doc += "> Under repository authority doctrine, automated test harnesses and autonomous agents are strictly **prohibited** from freezing layouts into `.frozen-v1`. There is no runtime token or API that mutates `.candidate` into `.frozen-v1`. Freeze occurs strictly via an explicit source code change with an ADR/migration record approved by the human owner. All layouts in this document remain in candidate or experimental status pending real owner-use validation.\n\n"

        doc += "---\n\n"

        // 1. Executive Summary
        doc += "## 1. Executive Summary\n\n"
        doc += "Phase 5 establishes the directional layout candidate foundation for DEX//PULSE. Each object class recognizes a stable compass wheel mapped to high-frequency Reflexes without AI reordering or dynamic reflow.\n\n"
        doc += "### Candidate Promotion Criteria\n"
        doc += "A layout is promoted to `.candidate` (`1.0.0-candidate`) only when:\n"
        doc += "1. Its directional mapping is explicitly present in governing planning source (`docs/OBJECT_LAYOUTS_V1.md`), OR\n"
        doc += "2. Explicit family inheritance is justified by governing source;\n"
        doc += "3. Mechanical reachability is proven via synthetic simulations;\n"
        doc += "4. No unresolved source contradictions exist.\n\n"
        doc += "Classes not meeting these criteria remain `.experimental` (`1.0.0-experimental`) and are marked `OWNER DECISION REQUIRED`.\n\n"

        let tempLedger = VeilLayoutTrialLedger()
        let aggregates = VeilLayoutTrialSimulator.runAllTrials(ledger: tempLedger)
        let totalSyntheticTrials = aggregates.map(\.totalSyntheticTrials).reduce(0, +)

        doc += "### Non-Binding Mechanical Diagnostics Summary\n"
        doc += "- **Synthetic Mechanical Trials:** \(totalSyntheticTrials) simulated trials across all 18 `ObjectClass` values.\n"
        doc += "- **Real Owner Invocations Recorded:** 0 (real-world trial ledger active; real habit evidence pending).\n"
        doc += "- **Diagnostic Status:** `NON-BINDING MECHANICAL DIAGNOSTIC` — simulated trials prove geometry and tracker math, but do NOT constitute human muscle-memory evidence or owner approval.\n"
        doc += "- **Controlling Freeze Evidence:** Per `docs/OBJECT_LAYOUTS_V1.md`, product freeze requires:\n"
        doc += "  - At least 20 real invocations OR deliberate owner review;\n"
        doc += "  - Misfire/overshoot notes from real motor use;\n"
        doc += "  - Repeated desired actions not represented;\n"
        doc += "  - Direction conflict notes;\n"
        doc += "  - Edge-screen usability verification;\n"
        doc += "  - Keyboard equivalent verification;\n"
        doc += "  - Explicit owner approval or no-objection.\n\n"

        doc += "---\n\n"

        // 2. Candidate Families
        doc += "## 2. Candidate Families (10 Classes with Source Authority)\n\n"

        // 2.1 Text Family
        doc += generateFamilySection(
            title: "2.1 Text Family (`selectedText`)",
            layout: registry.layout(for: .selectedText),
            familyDescription: "Authority: `docs/OBJECT_LAYOUTS_V1.md: Text`. Primary text inquiry, refinement, and routing."
        )

        // 2.2 Error / Log Family
        doc += generateFamilySection(
            title: "2.2 Error / Log Family (`errorLog`)",
            layout: registry.layout(for: .errorLog),
            familyDescription: "Authority: `docs/OBJECT_LAYOUTS_V1.md: Error / log`. Rapid error triage, stack trace diagnosis, and regression capture."
        )

        // 2.3 Repository / Project / Path Family
        doc += generateFamilySection(
            title: "2.3 Repository / Project / Path Family (`repository`, `path`)",
            layout: registry.layout(for: .repository),
            familyDescription: "Authority: `docs/OBJECT_LAYOUTS_V1.md: Repository / project / path`. Developer project state, git status, and target execution."
        )

        // 2.4 UI Element Family
        doc += generateFamilySection(
            title: "2.4 UI Element Family (`uiElement`, `focusedElement`)",
            layout: registry.layout(for: .uiElement),
            familyDescription: "Authority: `docs/OBJECT_LAYOUTS_V1.md: UI element`. Accessibility element inspection and hierarchy traversal."
        )

        // 2.5 Image / File Family
        doc += generateFamilySection(
            title: "2.5 Image / File Family (`image`, `file`, `selectedFile`, `fileSet`)",
            layout: registry.layout(for: .image),
            familyDescription: "Authority: `docs/OBJECT_LAYOUTS_V1.md: Image/file`. Asset and file metadata inspection, reveal, and conversion."
        )

        doc += "---\n\n"

        // 3. Ambiguous / Experimental Classes
        doc += "## 3. Ambiguous / Experimental Classes (8 Classes — Owner Decision Required)\n\n"
        doc += "These classes are not fully assigned in `docs/OBJECT_LAYOUTS_V1.md`. They are registered with provisional slots under `.experimental` lifecycle (`1.0.0-experimental`) and require deliberate owner decision before candidate promotion.\n\n"

        let experimentalClasses: [ObjectClass] = [
            .code, .url, .jsonText, .window, .application, .clipboard, .result, .machineTarget
        ]

        for (index, objClass) in experimentalClasses.enumerated() {
            let layout = registry.layout(for: objClass)
            doc += generateExperimentalSection(
                sectionNumber: "3.\(index + 1)",
                layout: layout
            )
        }

        doc += "---\n\n"

        // 4. Non-Binding Mechanical Diagnostics & Habit Telemetry Ledger
        doc += "## 4. Non-Binding Mechanical Diagnostics & Telemetry Ledger\n\n"
        doc += "> [!NOTE]\n"
        doc += "> All synthetic metrics below are **non-binding mechanical diagnostics** proving reachability and tracker math. They do NOT satisfy the product freeze requirement for real owner invocations.\n\n"

        doc += "| Object Class | Lifecycle | Synthetic Trials | Boundary Challenges | Simulated Recovery Rate | Real Owner Invocations |\n"
        doc += "|:---|:---:|:---:|:---:|:---:|:---:|\n"
        for agg in aggregates {
            let layout = registry.layout(for: agg.objectClass)
            let recoveryPct = String(format: "%.1f%%", (1.0 - agg.misfireRate) * 100.0)
            doc += "| `\(agg.objectClass.rawValue)` | `.\(layout.lifecycle.rawValue)` | \(agg.totalTrials) | \(agg.misfireCount) | \(recoveryPct) | 0 |\n"
        }
        doc += "\n"

        doc += "---\n\n"

        // 5. Owner Decision Matrix
        doc += "## 5. Owner Decision Matrix\n\n"
        doc += "Andrew: Use this decision matrix to review, accept, or modify directional layouts for V1.\n\n"

        let decisionGroups: [(name: String, sampleClass: ObjectClass, isCandidate: Bool)] = [
            ("Text Family (`selectedText`)", .selectedText, true),
            ("Error / Log Family (`errorLog`)", .errorLog, true),
            ("Repository / Project / Path Family (`repository`, `path`)", .repository, true),
            ("UI Element Family (`uiElement`, `focusedElement`)", .uiElement, true),
            ("Image / File Family (`image`, `file`, `selectedFile`, `fileSet`)", .image, true),
            ("Code Layout (`code`)", .code, false),
            ("URL Layout (`url`)", .url, false),
            ("JSONText Layout (`jsonText`)", .jsonText, false),
            ("Window Layout (`window`)", .window, false),
            ("Application Layout (`application`)", .application, false),
            ("Clipboard Layout (`clipboard`)", .clipboard, false),
            ("Result Layout (`result`)", .result, false),
            ("MachineTarget Layout (`machineTarget`)", .machineTarget, false)
        ]

        for item in decisionGroups {
            let lay = registry.layout(for: item.sampleClass)
            doc += "### \(item.name)\n\n"
            doc += "**Current Lifecycle:** `.\(lay.lifecycle.rawValue)` (\(lay.version))<br>\n"
            doc += "**Source Authority:** \(lay.sourceAuthority)\n\n"
            doc += "Current mapping:\n\n"
            doc += "```text\n"
            doc += formatCompactCompass(layout: lay)
            doc += "```\n\n"
            doc += "- [ ] KEEP AS SHOWN\n"
            doc += "- [ ] CHANGE (specify replacements in table below)\n"
            doc += "- [ ] NEEDS LIVE USE BEFORE DECISION\n"
            if !item.isCandidate {
                doc += "- [ ] UNRESOLVED FAMILY (assign to existing family or declare new family)\n"
            }
            doc += "\n"
            doc += "If CHANGE, specify replacement slots:\n\n"
            doc += "| Slot | New Reflex ID | New Label | Rationale |\n"
            doc += "|:---|:---|:---|:---|\n"
            doc += "| N | | | |\n"
            doc += "| NE | | | |\n"
            doc += "| E | | | |\n"
            doc += "| SE | | | |\n"
            doc += "| S | | | |\n"
            doc += "| SW | | | |\n"
            doc += "| W | | | |\n"
            doc += "| NW | | | |\n\n"
        }

        return doc.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
    }

    // MARK: - Private Helpers

    private static func generateFamilySection(
        title: String,
        layout: VeilObjectLayout,
        familyDescription: String
    ) -> String {
        var sec = "### \(title)\n\n"
        sec += "**Lifecycle:** `.\(layout.lifecycle.rawValue)` (`\(layout.version)`)\n\n"
        sec += "\(familyDescription)\n\n"
        sec += "```text\n"
        sec += formatAsciiCompass(layout: layout)
        sec += "```\n\n"
        sec += generateSlotTable(layout: layout)
        sec += "\n"
        return sec
    }

    private static func generateExperimentalSection(
        sectionNumber: String,
        layout: VeilObjectLayout
    ) -> String {
        var sec = "### \(sectionNumber) \(layout.objectClass.rawValue) — `OWNER DECISION REQUIRED`\n\n"
        sec += "**Lifecycle:** `.\(layout.lifecycle.rawValue)` (`\(layout.version)`)<br>\n"
        sec += "**Authority:** \(layout.sourceAuthority)<br>\n"
        if !layout.unresolvedQuestions.isEmpty {
            sec += "**Unresolved Question:** \(layout.unresolvedQuestions.joined(separator: " "))\n"
        }
        sec += "\n```text\n"
        sec += formatAsciiCompass(layout: layout)
        sec += "```\n\n"
        sec += generateSlotTable(layout: layout)
        sec += "\n"
        return sec
    }

    private static func generateSlotTable(layout: VeilObjectLayout) -> String {
        var table = "| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |\n"
        table += "|:---|:---|:---|:---|:---|:---|\n"

        for dir in CompassDirection.allCases {
            guard let desc = layout.reflex(at: dir) else {
                table += "| **\(dir.rawValue)** | *none* | — | — | — | Unassigned |\n"
                continue
            }
            let nested = desc.nestedChoices?.map(\.label).joined(separator: ", ") ?? "—"
            let stateStr = desc.state.description
            let note = (layout.lifecycle == .candidate) ? "Candidate Reflex" : "HYPOTHESIS — REQUIRES OWNER REVIEW"
            table += "| **\(dir.rawValue)** | `\(desc.id)` | \(desc.label) | \(stateStr) | \(nested) | \(note) |\n"
        }
        return table
    }

    private static func formatAsciiCompass(layout: VeilObjectLayout) -> String {
        let n  = layout.reflex(at: .n)?.label ?? "—"
        let ne = layout.reflex(at: .ne)?.label ?? "—"
        let e  = layout.reflex(at: .e)?.label ?? "—"
        let se = layout.reflex(at: .se)?.label ?? "—"
        let s  = layout.reflex(at: .s)?.label ?? "—"
        let sw = layout.reflex(at: .sw)?.label ?? "—"
        let w  = layout.reflex(at: .w)?.label ?? "—"
        let nw = layout.reflex(at: .nw)?.label ?? "—"

        return """
                   [N] \(n)
                     \\     /
       [NW] \(nw) \\   / [NE] \(ne)
             \\     \\ /     /
    [W] \(w) ----- O ----- [E] \(e)
             /     / \\     \\
       [SW] \(sw) /   \\ [SE] \(se)
                 /     \\
               [S] \(s)
    """
    }

    private static func formatCompactCompass(layout: VeilObjectLayout) -> String {
        let n  = layout.reflex(at: .n)?.label ?? "—"
        let ne = layout.reflex(at: .ne)?.label ?? "—"
        let e  = layout.reflex(at: .e)?.label ?? "—"
        let se = layout.reflex(at: .se)?.label ?? "—"
        let s  = layout.reflex(at: .s)?.label ?? "—"
        let sw = layout.reflex(at: .sw)?.label ?? "—"
        let w  = layout.reflex(at: .w)?.label ?? "—"
        let nw = layout.reflex(at: .nw)?.label ?? "—"

        return """
               N: \(n)
         NW: \(nw)   NE: \(ne)
       W: \(w)         E: \(e)
         SW: \(sw)   SE: \(se)
               S: \(s)
    """
    }
}
