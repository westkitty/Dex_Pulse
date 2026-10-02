# Operational State: DEX//PULSE

<!-- operational-state:metadata
{
  "schema_version": 1,
  "project_id": "dex-pulse",
  "project_name": "DEX//PULSE",
  "project_root": "westkitty/Dex_Pulse",
  "artifact_path": "",
  "state_revision": 1,
  "last_updated": "2026-10-02T11:30:00Z",
  "current_baseline": {
    "identity": "planning/source-of-truth foundation",
    "state": "current-baseline",
    "last_verified": null
  },
  "scope_boundaries": [
    "DEX//PULSE native macOS V1 through the first integrated vertical slice"
  ],
  "linked_parent_state": null
}
-->

## 1. Project Identity and Scope

- **Project ID:** `dex-pulse`
- **Purpose:** Native contextual reflex layer for fast, local-first action across selected content, UI elements, applications, projects, machines, and DEX capabilities.
- **Project type:** Native macOS utility / contextual interaction and execution platform.
- **Primary root or artifact:** `westkitty/Dex_Pulse`
- **Target environment:** Apple Silicon macOS 14+; Big Mac canonical development, MacBook primary operator/runtime target.
- **Canonical authority:** `PROJECT_BIBLE.md`, this file, `MASTER_IMPLEMENTATION_PLAN.md`, accepted ADRs, canonical visual fixtures.
- **Governed scope:** Empty-repository foundation through native V1 vertical slice.
- **Explicitly not governed:** Post-V1 Teach DEX, DEX//PAD, mature Loom editor, public plugin marketplace, destructive capabilities.

## 2. Current Baseline

- **Primary artifact:** planning/source-of-truth foundation
- **Baseline state:** `current-baseline`
- **Source/build/install identity:** No application code exists yet.
- **Active default user route:** Not implemented.
- **Delivery state:** Not implemented.
- **Last verified baseline:** Planning package only; no runtime behavior verified.

## 3. Artifact Contract

The project must produce a native Apple Silicon macOS application whose V1 vertical slice implements: native configurable global hotkey; Pulsefront/Veil; locked Lens precedence; selected text/file and UI-element context; stable per-object directional layouts; PulseKit capability registry; at least one real safe executor path; optional machine Target; Result Object; Witness proof; Spool; privacy-safe retention; and clean RECEDE. The app core must not depend on Karabiner, Hammerspoon, Docker, browser extensions, Python, Node, or continuous cloud access.

## 4. Active Invariants

### INV-001 — DexDictate priority
- **State:** `requested`
- **Rule:** Pulse must not steal focus, selection, clipboard state, trigger state, or insertion/undo assumptions from DexDictate; opening Pulse must not mutate the clipboard.
- **Scope:** All capture, invocation, fallback, write-back, and automation paths.
- **Authority:** Explicit user decision.
- **Validation method:** Concurrent runtime matrix with DexDictate recording/transcribing/insertion paths.
- **Status:** active

### INV-002 — No destructive V1 executor
- **State:** `requested`
- **Rule:** V1 exposes no executable destructive capability.
- **Scope:** PulseKit registry and every V1 Pack.
- **Authority:** Explicit user decision.
- **Validation method:** Static registry inspection plus executable capability enumeration tests.
- **Status:** active

### INV-003 — Context precedence
- **State:** `requested`
- **Rule:** Lens primary object precedence is selected text/file -> UI element under pointer -> focused Accessibility element -> frontmost window/app -> clipboard fallback.
- **Scope:** All Lens acquisition.
- **Authority:** Explicit user decision.
- **Validation method:** Deterministic context fixtures and real app journey tests.
- **Status:** active

### INV-004 — Stable object-class directional layouts
- **State:** `requested`
- **Rule:** Each recognized object class has a stable directional layout; Pulse must not silently AI-reorder learned Reflexes.
- **Scope:** Veil presentation and habit suggestions.
- **Authority:** Explicit user decision.
- **Validation method:** Layout snapshot fixtures and migration/version checks.
- **Status:** active

### INV-005 — Canonical Strand fixture fidelity
- **State:** `requested`
- **Rule:** Strand rendering must match the repository video fixtures for ribbon geometry, twist, transverse barcode segmentation, readable faces/edges, crossings, and restrained glow.
- **Scope:** PulseStrandRenderer and all visual variants derived from it.
- **Authority:** Explicit user direction plus supplied reference media.
- **Validation method:** Golden visual comparison plus human reference review against original videos.
- **Status:** active

### INV-006 — Core runtime independence
- **State:** `requested`
- **Rule:** Pulse core must not require Karabiner, Hammerspoon, Docker, a browser extension, Python, Node, or another application runtime.
- **Scope:** Installation and V1 core path.
- **Authority:** Explicit user decision.
- **Validation method:** Clean-machine dependency audit and packaged-app smoke test.
- **Status:** active

## 5. Verified Working Behavior

None. No runtime implementation has been built or verified yet.

## 6. Known Not Working

None recorded as defects because no runtime implementation exists yet.

## 7. Implemented but Unverified

- **UNV-001:** Repository planning/source-of-truth package exists once committed. This does not prove application behavior.

## 8. Unknown or Evidence-Stale State

- **UNK-001:** Final default hotkey remains provisional; current candidate is `Shift-Command-Space`.
- **UNK-002:** Final license remains MIT vs Unlicense.
- **UNK-003:** Repository may remain public or later become private; architecture must not depend on visibility.
- **UNK-004:** Exact DEX//REACH standalone app integration endpoint/contract must be proven before its Pack can be called production-ready.
- **UNK-005:** Exact DexGate automation/IPC handoff must be proven before Pulse can claim automatic gate integration.

## 9. Pending Work

- **PND-001:** Implement repository foundation and native Swift build target.
- **PND-002:** Implement Lens acquisition and context precedence.
- **PND-003:** Implement typed Object/Reflex/Target/Result model and PulseKit registry.
- **PND-004:** Implement Veil interaction and object-class directional layouts.
- **PND-005:** Implement canonical Pulsefront and Metal Strand renderer against visual fixtures.
- **PND-006:** Implement safe executor, Result Objects, Witness, and policy gates.
- **PND-007:** Implement Spool/pins, retention, and content-free habit ledger.
- **PND-008:** Integrate and validate the V1 vertical slice end-to-end.

## 10. Active Decisions, Defaults, and Prohibitions

- **DEC-001:** Big Mac is canonical development/heavy-compute machine; MacBook is primary operator/CLI/runtime target.
- **DEC-002:** V1 app is native Swift; transient hot path uses AppKit/Core Animation and canonical Strand rendering uses Metal.
- **DEC-003:** PulseKit capability registry exists from day one; DEX integrations arrive as Packs/adapters.
- **DEC-004:** Ghost Mode remains disabled until visible Veil reliability is proven.
- **DEC-005:** Spool and transient Results are memory-only by default; persistence requires explicit pin/KEEP.
- **DEC-006:** Witness structured records default to 30-day retention; content-free habit aggregates default to 180 days.
- **DEC-007:** Sensory feedback defaults on during development; sound remains subtle.
- **DEC-008:** DEX//PULSE is a DEX product using an explicitly exported Starsilk visual/causal grammar, not a Starsilk application.
- **DEC-009:** Approved exported terms: Strand, Thread, Loom, Witness, Veil, Lens, Spool.
- **DEC-010:** V1 begins deterministic/native, then local model judgment; remote model use requires an explicitly enabled capability.

## 11. Validation and Evidence Matrix

| ID | Claim or behavior | State | Evidence | Validation method | Artifact/revision | Last checked | Recheck trigger |
|---|---|---|---|---|---|---|---|
| INV-001 | DexDictate retains priority | requested | User decision | Concurrent runtime matrix | none | 2026-10-02 | capture/input changes |
| INV-002 | No destructive V1 executor | requested | User decision | Registry enumeration + integration tests | none | 2026-10-02 | Pack/capability changes |
| INV-003 | Lens precedence is deterministic | requested | User decision | Acquisition fixture suite | none | 2026-10-02 | Lens changes |
| INV-005 | Strand visuals match fixtures | requested | Four supplied videos | Golden capture + human review | fixture hashes in manifest | 2026-10-02 | renderer/material changes |
| UNV-001 | Planning package exists | implemented-unverified | Repo commit after publication | Read back required files | pending | 2026-10-02 | source-of-truth changes |

## 12. Current Change Scope and Impact Radius

- **Allowed to change:** Repository planning/source-of-truth files and fixture assets.
- **Must remain unchanged:** Supplied original reference video bytes; locked user decisions.
- **Potentially affected behavior:** None; no runtime exists yet.
- **Mandatory checks:** Read-back of committed docs; SHA-256 verification of visual fixtures; Project instruction length check.
- **Checks deliberately reused:** None.
- **Repair class:** Planning/source foundation.

## 13. Compact Revision Log

### Revision 1 — 2026-10-02

- **Artifact/source identity:** planning/source-of-truth foundation
- **State deltas:** Initialized DEX//PULSE operational state from locked project decisions.
- **New evidence:** Four user-supplied visual reference videos and derived contact sheets; repository was empty before foundation work.
- **Validation not performed:** No native runtime/build/interaction behavior exists yet.
