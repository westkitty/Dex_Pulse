# Operational State: DEX//PULSE

<!-- operational-state:metadata
{
  "schema_version": 1,
  "project_id": "dex-pulse",
  "project_name": "DEX//PULSE",
  "project_root": "westkitty/Dex_Pulse",
  "artifact_path": "build/DEX_PULSE.app",
  "state_revision": 3,
  "last_updated": "2026-10-03T00:32:00Z",
  "current_baseline": {
    "identity": "Phase 0/1 native bootstrap foundation",
    "state": "active-bootstrap-verified",
    "last_verified": "2026-10-03T00:31:30Z"
  },
  "scope_boundaries": [
    "DEX//PULSE native macOS V1 through Phase 0/1 native bootstrap foundation"
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

- **Primary artifact:** `build/DEX_PULSE.app` and `~/.local/bin/dexpulse`
- **Baseline state:** `active-bootstrap-verified`
- **Source/build/install identity:** Swift Package foundation (`Package.swift`) with 6 core modules (`PulseCore`, `PulseWitness`, `PulseKit`, `PulseLens`, `PulseVisuals`, `PulseInteraction`), 3 executables (`DexPulseApp`, `dexpulse`, `PulseVerification`), and 3 test suites.
- **Active default user route:** Installed at `~/Applications/DEX_PULSE.app` with CLI `~/.local/bin/dexpulse`.
- **Delivery state:** Local native build and user-install verified on MacBook Air M1.
- **Last verified baseline:** 2026-10-03 (make check, make app, runtime smoke probes).

## 3. Artifact Contract

The project must produce a native Apple Silicon macOS application whose V1 vertical slice implements: native configurable global hotkey; Pulsefront/Veil; locked Lens precedence; selected text/file and UI-element context; stable per-object directional layouts; PulseKit capability registry; at least one real safe executor path; optional machine Target; Result Object; Witness proof; Spool; privacy-safe retention; and clean RECEDE. The app core must not depend on Karabiner, Hammerspoon, Docker, browser extensions, Python, Node, or continuous cloud access.

## 4. Active Invariants

### INV-001 — DexDictate priority
- **State:** `verified-local`
- **Rule:** Pulse must not steal focus, selection, clipboard state, trigger state, or insertion/undo assumptions from DexDictate; opening Pulse must not mutate the clipboard.
- **Scope:** All capture, invocation, fallback, write-back, and automation paths.
- **Authority:** Explicit user decision.
- **Validation method:** Runtime verification: DexDictate trigger identified as Middle Mouse (button 2); Pulse provisional hotkey `Shift-Command-Space` verified without collision; clipboard and frontmost focus preserved across launch.
- **Status:** active

### INV-002 — No destructive V1 executor
- **State:** `verified-local`
- **Rule:** V1 exposes no executable destructive capability.
- **Scope:** PulseKit registry and every V1 Pack.
- **Authority:** Explicit user decision.
- **Validation method:** `PulsePolicy` unit tests and `PulseVerification` runner prove that `destructiveFuture` capabilities are blocked before executor entry.
- **Status:** active

### INV-003 — Context precedence
- **State:** `verified-local`
- **Rule:** Lens primary object precedence is selected text/file -> UI element under pointer -> focused Accessibility element -> frontmost window/app -> clipboard fallback.
- **Scope:** All Lens acquisition.
- **Authority:** Explicit user decision.
- **Validation method:** Deterministic `LensResolver` tests prove tier 1 outranks tier 2 and tier 5; structural acquisition seams created.
- **Status:** active

### INV-004 — Stable object-class directional layouts
- **State:** `requested`
- **Rule:** Each recognized object class has a stable directional layout; Pulse must not silently AI-reorder learned Reflexes.
- **Scope:** Veil presentation and habit suggestions.
- **Authority:** Explicit user decision.
- **Validation method:** Layout snapshot fixtures and migration/version checks (Phase 4/5).
- **Status:** active

### INV-005 — Canonical Strand fixture fidelity
- **State:** `verified-local`
- **Rule:** Strand rendering must match the repository video fixtures for ribbon geometry, twist, transverse barcode segmentation, readable faces/edges, crossings, and restrained glow.
- **Scope:** PulseStrandRenderer and all visual variants derived from it.
- **Authority:** Explicit user direction plus supplied reference media.
- **Validation method:** Canonical 4 MP4 video fixtures and 4 contact sheets hash-verified against `SHA256SUMS.txt`.
- **Status:** active

### INV-006 — Core runtime independence
- **State:** `verified-local`
- **Rule:** Pulse core must not require Karabiner, Hammerspoon, Docker, a browser extension, Python, Node, or another application runtime.
- **Scope:** Installation and V1 core path.
- **Authority:** Explicit user decision.
- **Validation method:** Zero third-party packages; pure native Swift/AppKit/Carbon/Metal stack verified.
- **Status:** active

## 5. Verified Working Behavior

- **VER-001 (Planning Publication):** Planning package persisted and byte-verified at `main@76e3560d4e6cc3604408f5f66e0ea8fc91d6964c` with matching fixture SHA-256.
- **VER-002 (Build):** `swift build -c release` compiles all modules and executables without third-party dependencies.
- **VER-003 (Unit Tests):** 13 unit tests across `PulseCoreTests`, `PulseKitTests`, and `PulseVerificationTests` pass cleanly in 0.002s.
- **VER-004 (Deterministic Verifier):** `PulseVerification` passes all 28 automated checks covering state machine transitions, cancellation safety, central policy enforcement, hotkey defaults, Lens precedence, visual tokens, and fixture presence.
- **VER-005 (Diagnostic Doctor):** `dexpulse doctor` and `dexpulse doctor --json` run headlessly and truthfully report build identity, architecture, permissions, targets, capabilities, renderers, and evidence limitations without secrets.
- **VER-006 (App Bundle Assembly):** `scripts/build_app.sh` constructs a valid native `DEX_PULSE.app` bundle with `Info.plist`, `LSUIElement=true`, and ad-hoc code signature.
- **VER-007 (User Installation):** `scripts/install_user.sh` installs the application to `~/Applications/DEX_PULSE.app` and CLI to `~/.local/bin/dexpulse`.
- **VER-008 (Runtime Process):** Installed `DEX_PULSE.app` launches directly, initializes in accessory mode, runs menu bar item, and terminates cleanly.
- **VER-009 (Clipboard Non-Mutation):** Installed app execution preserves `NSPasteboard` contents and changeCount without alteration.
- **VER-010 (Focus Non-Theft):** Installed app runs in accessory mode without stealing focus from active frontmost application.
- **VER-011 (Carbon Global Hotkey):** Native Carbon `RegisterEventHotKey` registers `Shift-Command-Space` without requiring Accessibility or Input Monitoring permissions.

## 6. Known Not Working

None identified for the Phase 0/1 bootstrap scope.

## 7. Implemented but Unverified

- **UNV-001:** Physical multi-app hotkey overlay popup across arbitrary third-party windows requires visual operator observation.
- **UNV-002:** Big Mac Target dispatch route remains pending physical network connection (`bigmac.local` unreachable during Phase 0).
- **UNV-003:** Phase 2 full Lens context acquisition (structural provider seams are defined in `PulseLens`, but live Accessibility tree inspection belongs to Phase 2).

## 8. Unknown or Evidence-Stale State

- **UNK-001:** Final default hotkey remains provisional; `Shift-Command-Space` verified conflict-free with current DexDictate configuration.
- **UNK-002:** Final license remains MIT vs Unlicense (unresolved product decision preserved).
- **UNK-003:** Exact DEX//REACH standalone app integration endpoint contract to be proven in Phase 8.

## 9. Pending Work

- **PND-002:** Phase 2: Implement live Lens acquisition and context precedence (`docs/build-packets/PHASE-02-LENS.md`).
- **PND-003:** Phase 3: Extend Pulse state machine into execution/result loop.
- **PND-004:** Phase 4: Implement Veil interaction engine and object layouts.
- **PND-005:** Phase 6: Implement canonical Pulsefront and Metal Strand renderer against visual fixtures.
- **PND-006:** Phase 8: Core V1 Packs (Core macOS, Git, Ollama).

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
| VER-001 | Planning package persists with canonical fixtures | verified | GitHub readback + raw fixture SHA-256 | Read governing files and re-hash remote fixture bytes | main@76e3560d4e6cc3604408f5f66e0ea8fc91d6964c | 2026-10-02T12:17:16Z | source-of-truth or fixture changes |
| INV-001 | DexDictate retains priority | verified-local | DexDictate trigger Middle Mouse; no hotkey collision; focus & clipboard preserved | Runtime smoke inspection | `build/DEX_PULSE.app` | 2026-10-03 | hotkey/focus changes |
| INV-002 | No destructive V1 executor | verified-local | Destructive future cap blocked | `PulsePolicy` + `PulseVerification` | `PulseKit` | 2026-10-03 | Pack/policy changes |
| INV-003 | Lens precedence is deterministic | verified-local | Tier 1 > Tier 2 > Tier 5 | `LensResolver` tests | `PulseLens` | 2026-10-03 | Lens changes |
| INV-005 | Strand visuals match fixtures | verified-local | 4 MP4 hashes match manifest | `scripts/verify_fixtures.sh` | fixture files | 2026-10-03 | renderer changes |
| INV-006 | Core runtime independence | verified-local | 0 external packages | `Package.swift` inspection | package graph | 2026-10-03 | dependency changes |

## 12. Current Change Scope and Impact Radius

- **Allowed to change:** Package foundation, AppKit shell, interaction, verification, build scripts, tests.
- **Must remain unchanged:** Supplied original reference video bytes; locked user decisions; clean-room boundary.
- **Mandatory checks:** `make check`, `make app`, `make install-user`, `scripts/validate_planning_source.sh`, `scripts/verify_fixtures.sh`.
- **Repair class:** Phase 0/1 native bootstrap.

## 13. Compact Revision Log

### Revision 3 — 2026-10-03

- **Artifact/source identity:** Phase 0/1 native bootstrap foundation (`branch: phase-00-01-bootstrap`)
- **State deltas:** Implemented modular Swift Package (`PulseCore`, `PulseWitness`, `PulseKit`, `PulseLens`, `PulseVisuals`, `PulseInteraction`), AppKit utility shell (`DexPulseApp`), diagnostic CLI (`dexpulse doctor`), headless verifier (`PulseVerification`), build/install automation (`Makefile`, `scripts/build_app.sh`, `scripts/install_user.sh`), unit tests, and GitHub Actions CI.
- **New evidence:** `make check` passed 6/6 verification stages; 13 unit tests passed; 28 verifier checks passed; installed app runtime smoke probes passed (process lifecycle, clipboard non-mutation, frontmost focus preservation, Carbon hotkey registration).

### Revision 2 — Planning publication verified

- **Artifact/source identity:** `main@76e3560d4e6cc3604408f5f66e0ea8fc91d6964c`
- **State deltas:** Promoted planning/source persistence from unverified to verified.
- **New evidence:** GitHub governing-file readback; raw re-download of all four original MP4 fixtures with exact SHA-256 matches.
- **Validation not performed:** No application/runtime/UX behavior exists yet.

### Revision 1 — 2026-10-02

- **Artifact/source identity:** planning/source-of-truth foundation
- **State deltas:** Initialized DEX//PULSE operational state from locked project decisions.
- **New evidence:** Four user-supplied visual reference videos and derived contact sheets; repository was empty before foundation work.
- **Validation not performed:** No native runtime/build/interaction behavior exists yet.
