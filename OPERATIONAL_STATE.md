# Operational State: DEX//PULSE

<!-- operational-state:metadata
{
  "schema_version": 1,
  "project_id": "dex-pulse",
  "project_name": "DEX//PULSE",
  "project_root": "westkitty/Dex_Pulse",
  "artifact_path": "build/DEX_PULSE.app",
  "state_revision": 6,
  "last_updated": "2026-10-03T01:40:00Z",
  "current_baseline": {
    "identity": "Phase 2 Lens context acquisition",
    "state": "active-lens-verified",
    "last_verified": "2026-10-03T01:40:00Z"
  },
  "scope_boundaries": [
    "DEX//PULSE native macOS V1 through Phase 2 context acquisition and deterministic lazy precedence"
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
- **Baseline state:** `active-lens-verified`
- **Source/build/install identity:** Swift Package foundation (`Package.swift`) with 6 core modules (`PulseCore`, `PulseWitness`, `PulseKit`, `PulseLens`, `PulseVisuals`, `PulseInteraction`), 3 executables (`DexPulseApp`, `dexpulse`, `PulseVerification`), synthetic fixture target `PulseLensFixtureApp`, and 4 test suites.
- **Active default user route:** Installed at `~/Applications/DEX_PULSE.app` with CLI `~/.local/bin/dexpulse`.
- **Delivery state:** Local native build and user-install verified on MacBook Air M1.
- **Last verified baseline:** 2026-10-03 (`make check`, `make app`, 28 unit tests, 51 verifier checks, live native probes on macOS).

## 3. Artifact Contract

The project must produce a native Apple Silicon macOS application whose V1 vertical slice implements: native configurable global hotkey; Pulsefront/Veil; locked Lens precedence; selected text/file and UI-element context; stable per-object directional layouts; PulseKit capability registry; at least one real safe executor path; optional machine Target; Result Object; Witness proof; Spool; privacy-safe retention; and clean RECEDE. The app core must not depend on Karabiner, Hammerspoon, Docker, browser extensions, Python, Node, or continuous cloud access.

## 4. Active Invariants

### INV-001 — DexDictate priority
- **State:** `requested`
- **Rule:** Pulse must not steal focus, selection, clipboard state, trigger state, or insertion/undo assumptions from DexDictate; opening Pulse must not mutate the clipboard.
- **Scope:** All capture, invocation, fallback, write-back, and automation paths.
- **Authority:** Explicit user decision.
- **Validation method:** Full concurrent runtime matrix with DexDictate recording/transcribing/insertion paths (Phase 11).
- **Evidence (partial Phase 0/1):** Runtime smoke probes verified DexDictate installed and active (`com.westkitty.dexdictate.macos`), trigger identified as Middle Mouse (button 2) with no collision against provisional hotkey `Shift-Command-Space`, and basic Pulse launch preserved `NSPasteboard` changeCount/content and frontmost application focus.
- **Unverified:** Full DexDictate coexistence contract (selection preservation during real DexDictate use, Accessibility insertion-target identity, transcription/delivery interactions, browser AX behavior while both apps operate, Undo Last Dictation semantics after Pulse interaction, and all conflict/yield behavior defined by the coexistence matrix).
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
- **State:** `requested`
- **Rule:** Strand rendering must match the repository video fixtures for ribbon geometry, twist, transverse barcode segmentation, readable faces/edges, crossings, and restrained glow.
- **Scope:** PulseStrandRenderer and all visual variants derived from it.
- **Authority:** Explicit user direction plus supplied reference media.
- **Validation method:** Golden visual comparison plus human reference review against original videos (Phase 6).
- **Evidence (fixtures only):** Canonical 4 MP4 video fixtures and 4 contact sheets exist in repository and hash-verify cleanly against `SHA256SUMS.txt` via `scripts/verify_fixtures.sh`.
- **Unverified:** Strand renderer visual fidelity. The canonical Metal Strand renderer does not exist yet (belongs to Phase 6); ribbon geometry, twist, transverse barcode segmentation, readable crossings, restrained glow, face/edge/underside behavior, and motion fidelity remain unverified.
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
- **VER-003 (Unit Tests):** 13 unit tests across `PulseCoreTests`, `PulseKitTests`, and `PulseVerificationTests` pass cleanly in 0.015s.
- **VER-004 (Deterministic Verifier):** `PulseVerification` passes all 28 automated checks covering state machine transitions, cancellation safety, central policy enforcement, hotkey defaults, Lens precedence, visual tokens, and fixture presence.
- **VER-005 (Diagnostic Doctor):** `dexpulse doctor` and `dexpulse doctor --json` run headlessly and truthfully report build identity, architecture, permissions, targets, capabilities, renderers, and evidence limitations without secrets.
- **VER-006 (App Bundle Assembly):** `scripts/build_app.sh` constructs a valid native `DEX_PULSE.app` bundle with `Info.plist`, `LSUIElement=true`, and ad-hoc code signature.
- **VER-007 (User Installation):** `scripts/install_user.sh` installs the application to `~/Applications/DEX_PULSE.app` and CLI to `~/.local/bin/dexpulse`.
- **VER-008 (Runtime Process):** Installed `DEX_PULSE.app` launches directly, initializes in accessory mode, runs menu bar item, and terminates cleanly.
- **VER-009 (Clipboard Non-Mutation Smoke):** Installed app execution preserves `NSPasteboard` contents and changeCount without alteration across launch and dismissal.
- **VER-010 (Focus Non-Theft Smoke):** Installed app runs in accessory mode without stealing focus from active frontmost application.
- **VER-011 (Carbon Global Hotkey):** Native Carbon `RegisterEventHotKey` registers `Shift-Command-Space` without requiring Accessibility or Input Monitoring permissions.
- **VER-012 (Visual Reference Fixtures Integrity):** All 4 canonical MP4 videos and 4 contact sheets match `SHA256SUMS.txt` on disk and remote. (Validates asset fixture integrity only; does not validate renderer visual fidelity).
- **VER-013 (Phase 2 Lens Context Acquisition & Lazy Precedence):** Full 5-tier context precedence hierarchy (Tier 1 Selected Content > Tier 2 Pointer Element > Tier 3 Focused Element > Tier 4 Frontmost App/Window > Tier 5 Clipboard Fallback) implemented and verified with true lazy tier-by-tier halting. When Tiers 1–4 succeed, acquisition halts immediately; lower tiers (including Tier 5 clipboard fallback) are never invoked, no clipboard content is read, and no clipboard snapshot is retained in the envelope. Bounded cross-process Accessibility calls enforced natively via `AXUIElementSetMessagingTimeout(0.5)`. Explicit Accessibility denial and degradation reporting implemented in `PulseContextEnvelope` with zero-TCC test injection. Unit tests (28 tests across 4 suites), headless verifier (51 assertions), and live probes on macOS verify: deterministic lazy resolution, coordinate mapping (AppKit bottom-left <-> CG top-left), whitespace rejection, secure field blocking (`privacyClass = .secureBlocked` with zero secret leak), type refinement preserving parent provenance (URL, Path, JSON, ErrorLog, CodeSnippet), stale context generation token and live PID validation, and zero clipboard mutation.
- **VER-014 (Synthetic AX Fixture App):** `PulseLensFixtureApp` target builds and provides inspectable controls (selectable text, secure field with `--focus-secure`, interactive buttons, duplicate labels, disabled button, checkbox, popup menu, multiline editor). Headless and interactive testing verify zero secret leakage from password fields.

## 6. Known Not Working

None identified for the Phase 0/1/2 scope.

## 7. Implemented but Unverified

- **UNV-001:** Physical multi-app hotkey overlay popup across arbitrary third-party windows requires visual operator observation.
- **UNV-002:** Big Mac Target dispatch route remains pending physical network connection (`bigmac.local` unreachable during Phase 0).
- **UNV-003:** Electron/VS Code AX tree inspection edge cases: VS Code unavailable on test machine (`NOT TESTED — APPLICATION UNAVAILABLE`). Native AX and WebArea elements verified live in Brave Browser, TextEdit, Terminal, and fixture app.
- **UNV-004:** Full DexDictate coexistence contract (selection preservation during active dictation, Accessibility insertion-target identity, transcription delivery, browser AX behavior under concurrent operation, Undo Last Dictation semantics, and conflict-yield behavior; scheduled for Phase 11).
- **UNV-005:** Canonical Strand renderer fidelity (Metal Strand renderer does not exist yet; ribbon geometry, twist, transverse barcode segmentation, crossings, glow restraint, face/edge/underside behavior, and motion fidelity belong to Phase 6).

## 8. Unknown or Evidence-Stale State

- **UNK-001:** Final default hotkey remains provisional; `Shift-Command-Space` verified conflict-free with current DexDictate configuration.
- **UNK-002:** Final license remains MIT vs Unlicense (unresolved product decision preserved).
- **UNK-003:** Exact DEX//REACH standalone app integration endpoint contract to be proven in Phase 8.

## 9. Pending Work

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
| VER-012 | Visual fixture integrity | verified-local | All 4 original MP4s and 4 contact sheets match SHA256SUMS.txt | `scripts/verify_fixtures.sh` | `fixtures/visual-references/` | 2026-10-03 | fixture changes |
| VER-013 | Phase 2 Lens context acquisition & lazy precedence | verified-local | 5-tier precedence with lazy halting, coordinate mapping, secure blocking, type refiners, stale token validation | `PulseLensTests` (15/15) + `PulseVerification` (51/51) + live native probes | `Sources/PulseLens/` | 2026-10-03 | Lens changes |
| VER-014 | Synthetic AX fixture app | verified-local | Native executable with 8 fixture control classes and --focus-secure | `PulseLensFixtureApp --inspect` + live probe | `Sources/PulseLensFixtureApp/` | 2026-10-03 | test fixture changes |
| INV-001 | DexDictate retains priority | requested | Partial Phase 0/1: no trigger collision, clipboard/focus preserved. Full coexistence matrix unverified | Concurrent runtime matrix (Phase 11) | `build/DEX_PULSE.app` (partial) | 2026-10-03 | capture/input/coexistence changes |
| INV-002 | No destructive V1 executor | verified-local | Destructive future cap blocked | `PulsePolicy` + `PulseVerification` | `PulseKit` | 2026-10-03 | Pack/policy changes |
| INV-003 | Lens precedence is deterministic & lazy | verified-local | Locked order: Tier 1 > Tier 2 > Tier 3 > Tier 4 > Tier 5; stops at winning tier; zero clipboard mutation | `LensResolver` spy tests & live Fixture/TextEdit/Terminal/Brave/Finder probes | `PulseLens` | 2026-10-03 | Lens changes |
| INV-005 | Strand visuals match fixtures | requested | Reference fixtures intact. Metal Strand renderer not yet implemented (Phase 6) | Golden comparison against reference videos (Phase 6) | none (fixtures only) | 2026-10-03 | renderer/material changes |
| INV-006 | Core runtime independence | verified-local | 0 external packages | `Package.swift` inspection | package graph | 2026-10-03 | dependency changes |

## 12. Current Change Scope and Impact Radius

- **Allowed to change:** Package foundation, AppKit shell, interaction, verification, build scripts, tests.
- **Must remain unchanged:** Supplied original reference video bytes; locked user decisions; clean-room boundary.
- **Mandatory checks:** `make check`, `make app`, `make install-user`, `scripts/validate_planning_source.sh`, `scripts/verify_fixtures.sh`.
- **Repair class:** Phase 2 Lens context acquisition.

## 13. Compact Revision Log

### Revision 6 — 2026-10-03

- **Artifact/source identity:** Phase 2 Lens closure & repair (`branch: phase-02-lens`)
- **State deltas:** Repaired critical lazy precedence defect: `LensResolver.acquireContextEnvelope` now evaluates strictly tier-by-tier and stops immediately upon candidate discovery, guaranteeing that `ClipboardFallbackProvider` is never invoked, read, or snapshotted when Tiers 1–4 succeed. Bounded all cross-process Accessibility calls with native `AXUIElementSetMessagingTimeout(0.5)` via `AXTimeoutHelper`. Added explicit Accessibility authorization status and `ContextDegradationReason` reporting to `PulseContextEnvelope`, with zero-TCC injectable override (`AccessibilityAuthorizer.overrideStatus`). Added `--focus-secure` argument to `PulseLensFixtureApp`. Implemented comprehensive spy provider unit tests verifying zero lower-tier calls when higher tiers win.
- **New evidence:** All 28 unit tests across 4 test suites passed (`PulseLensTests` 15, `PulseCoreTests` 4, `PulseKitTests` 3, `PulseVerificationTests` 6); `PulseVerification` passed 51/51 automated assertions; `make check` passed 6/6 stages; live application matrix completed: `PulseLensFixtureApp` (Tier 1 secure field blocked, `privacyClass = secureBlocked`, zero secret payload leak), `TextEdit` (Tier 1 selection refined to `URLObject`, 1 candidate snapshot, zero clipboard invocation), `Terminal` (Tier 1 selection, zero clipboard mutation), `Brave Browser` (Tier 2 UI element under pointer `[AXButton] 'Reload'`, 1 candidate snapshot), `Finder` (Tier 2 UI element, bounded non-hanging probe), and `VS Code` accurately recorded as `NOT TESTED — APPLICATION UNAVAILABLE`.

### Revision 5 — 2026-10-03

- **Artifact/source identity:** Phase 2 Context Envelope + Lens (`branch: phase-02-lens`)
- **State deltas:** Implemented native Lens context acquisition system in `Sources/PulseLens`: `AccessibilityAuthorizer`, `LensCoordinates`, `SelectedTextProvider`, `SelectedFileProvider`, `PointerElementProvider`, `FocusedElementProvider`, `FrontmostAppProvider`, `ClipboardFallbackProvider`, `TypeRefiners`, `StaleContextValidator`, and `LensResolver`. Created synthetic AX fixture target `PulseLensFixtureApp`. Implemented `Tests/PulseLensTests` (precedence, secure field guard, whitespace rejection, type refinement, stale context validation, coordinate mapping, clipboard immutability). Enhanced `PulseVerification` (45 assertions) and `dexpulse doctor` / `dexpulse probe`.
- **New evidence:** All 21 unit tests in 4 suites passed; `PulseVerification` passed 45/45 checks; `make check` passed 6/6 stages cleanly; live probes against TextEdit (Tier 1 selection refined to `URLObject`), Brave Browser (`AXTextArea`/`AXWebArea` under pointer), and system menu bar verified live on macOS with zero pasteboard mutation.

### Revision 4 — 2026-10-03

- **Artifact/source identity:** Phase 0/1 evidence correction (`branch: phase-00-01-bootstrap`)
- **State deltas:** Corrected overclaims for INV-001 and INV-005. Reclassified INV-001 (DexDictate priority) as `requested` with explicit partial Phase 0/1 evidence (focus/clipboard preservation and no hotkey collision) while marking full coexistence unverified (UNV-004). Reclassified INV-005 (Strand fidelity) as `requested` with fixture integrity explicitly separated as VER-012, while noting Metal Strand renderer implementation and visual fidelity remain unverified (UNV-005, Phase 6).
- **New evidence:** Preserved Phase 0/1 verification evidence from Revision 3 without substantive code changes.

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
