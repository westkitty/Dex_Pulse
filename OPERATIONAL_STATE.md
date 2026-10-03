# Operational State: DEX//PULSE

<!-- operational-state:metadata
{
  "schema_version": 1,
  "project_id": "dex-pulse",
  "project_name": "DEX//PULSE",
  "project_root": "westkitty/Dex_Pulse",
  "artifact_path": "build/DEX_PULSE.app",
  "state_revision": 15,
  "last_updated": "2026-10-03T19:00:00Z",
  "current_baseline": {
    "identity": "Phase 5 Object Layout Freeze Trial",
    "state": "active-phase05-owner-trial-ready",
    "last_verified": "2026-10-03T19:00:00Z"
  },
  "scope_boundaries": [
    "DEX//PULSE native macOS V1 through Phase 4 Veil interaction engine, Phase 5 candidate/experimental layout registry, autonomous mechanical diagnostics, and Phase 5 Owner Trial infrastructure ready for real owner evaluation; zero frozen layouts; Phase 6 not started"
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
- **Baseline state:** `active-phase05-owner-trial-ready`
- **Source/build/install identity:** Swift Package foundation (`Package.swift`) with 6 core modules (`PulseCore`, `PulseWitness`, `PulseKit`, `PulseLens`, `PulseVisuals`, `PulseInteraction`), 3 executables (`DexPulseApp`, `dexpulse`, `PulseVerification`), synthetic fixture target `PulseLensFixtureApp`, and 5 test suites (`PulseCoreTests`, `PulseLensTests`, `PulseKitTests`, `PulseVerificationTests`, `PulseInteractionTests`).
- **Active default user route:** Installed at `~/Applications/DEX_PULSE.app` with CLI `~/.local/bin/dexpulse`.
- **Delivery state:** Local native build and user-install verified on MacBook Air M1.
- **Last verified baseline:** 2026-10-03 (Phase 4 Veil real input verified; Phase 5 candidate/experimental registry verified with 10 candidate and 8 experimental layouts; 350 non-binding synthetic diagnostics; dedicated local Phase 5 Owner Trial Store implemented with structural separation, content-free schema, and CLI control surface; 0 frozen layouts; Phase 6 not started; ready for real owner trials).

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
- **State:** `verified-local` (candidate tier)
- **Rule:** Each recognized object class has a stable directional layout; Pulse must not silently AI-reorder learned Reflexes.
- **Scope:** Veil presentation and habit suggestions.
- **Authority:** Explicit user decision (INV-031).
- **Validation method:** Layout snapshot fixtures and determinism unit tests (`VeilTests`, `VeilLayoutRegistry`).
- **Evidence:** `VeilLayoutRegistry` covers all 18 V1 `ObjectClass` values deterministically with immutable compass directions (10 candidate layouts at version 1.0.0-candidate, 8 experimental layouts at version 1.0.0-experimental, 0 frozen layouts). Unavailable capabilities preserve positions (disabled slots); neighbors never slide over. Candidate layouts are immutable at runtime; freeze strictly requires human owner review via explicit source code change and ADR/migration record.
- **Status:** active

### INV-032 — Visible geometry strictly equals mathematical hit testing
- **State:** `verified-local`
- **Rule:** The path used for visible drawing of sectors and rings must strictly equal the mathematical hit-testing boundary from a single source of truth.
- **Scope:** VeilSectorGeometry, VeilRingGeometry, VeilView, CAShapeLayer surfaces.
- **Authority:** Explicit user architecture requirement.
- **Validation method:** Dense mathematical parity testing (`VeilSectorGeometry.verifyParity`) and real debug visualization.
- **Evidence:** Parity tests across all 8 compass sectors assert equality between `cgPath().contains(point)` and `contains(point:isArmed:false)` across center, inner radius, outer radius, neighboring sectors, and outside envelopes (100% parity verified in unit tests and verifier).
- **Status:** active

### INV-033 — Seam hysteresis and radial overshoot envelope
- **State:** `verified-local`
- **Rule:** Armed sectors must resist fluttering across seams via 6° angular hysteresis and provide 16 pt radial overshoot forgiveness.
- **Scope:** VeilPointerTracker, interactive pointer sweeps.
- **Authority:** Explicit interaction requirement (INTERACTION_MODEL.md).
- **Validation method:** Deterministic seam-jitter, intentional seam crossing, and radial overshoot unit tests (`VeilTests`), full 9-trajectory real mouse event integration tests (`mouse event -> VeilView -> tracking callback -> VeilPointerTracker -> armed sector -> UI update`), and live runtime probes.
- **Evidence:** 9 canonical mouse-event trajectories verified: (1) center -> N; (2) N -> center -> N without dismissal; (3) N seam jitter within 6° hysteresis; (4) intentional N -> NE transition beyond hysteresis; (5) N radial overshoot within 16 pt tolerance; (6) travel beyond tolerance with boundary exit; (7) parent -> nested choice; (8) nested -> parent; (9) clean cancel. Hollow center click-through and traversal verified live.
- **Status:** active

### INV-034 — Minimal translation placement with causal origin preservation
- **State:** `verified-local`
- **Rule:** Clamping Veil within visible screen margins must shift center minimally while preserving `causalOrigin`.
- **Scope:** VeilPlacementPlanner, multi-monitor display placement.
- **Authority:** Explicit interaction requirement.
- **Validation method:** Screen edge, screen corner, and multi-monitor synthetic/live probes.
- **Evidence:** Tested edge clamping at (5, 400) -> (196, 400), corner clamping at (5, 5) -> (196, 196), synthetic negative-origin monitor (-1920, 0), and 2 live physical displays (Display 1 at 0,0 and Display 2 at -1440,-132) with 100% causal origin preservation.
- **Status:** active

### INV-035 — Full keyboard traversal without focus theft
- **State:** `verified-local`
- **Rule:** Keyboard navigation can reach every visible, interactive action without focus theft or installing permanent global key intercepts.
- **Scope:** VeilKeyboardNavigator, VeilKeyboardDeliveryAdapter, VeilWindow non-activating panel.
- **Authority:** Explicit user decision.
- **Validation method:** Two-tier verification: (1) Pure navigation model logic verified across 4-slot, 8-slot, and nested layouts (`VeilKeyboardNavigator`); (2) Live non-focus-stealing keyboard delivery verified via native Carbon temporary hotkeys (`VeilKeyboardDeliveryAdapter`) registered strictly while Veil is visible and unregistered on recede/dismiss. Coexistence with global invocation hotkey verified without collision.
- **Evidence:** Unit tests prove traversal logic and adapter lifecycle (registration, unregistration, collision avoidance). Live runtime probes across TextEdit (PID 80934), Brave Browser (PID 702), and Terminal (PID 81066) prove chords (`⌃⌥[`, `⌃⌥]`, `⌃⌥O`, `⌃⌥I`, `⌃⌥↩`, `⌃⌥⎋`) move selection, enter nested items, back out, and cancel while frontmost PID and focused AX element remain 100% untouched.
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

### INV-007 — State machine causal convergence
- **State:** `verified-local`
- **Rule:** Cancellation or dismissal from any transient state (PULSE, LENS, VEIL, ATTUNE, STRAND, FORK, DISPATCH, WEAVE, RETURN, WITNESS, RESOLVE, FRAY, SEVER) must deterministically converge to QUIET without leaving stranded states.
- **Scope:** All state transitions and run dismissals.
- **Authority:** Explicit architecture rule (INTERACTION_MODEL.md).
- **Validation method:** Automated test suite and headless verifier test cancel() across all 13 transient states, asserting 100% convergence to QUIET and run outcome .cancelled.
- **Status:** active

### INV-008 — Stale completion protection
- **State:** `verified-local`
- **Rule:** Async completions matching older generation tokens or inactive runIDs must be discarded without mutating machine state or reviving a finished run.
- **Scope:** Asynchronous capability dispatch, late executor callbacks, and background worker completions.
- **Authority:** Explicit architecture rule (MASTER_IMPLEMENTATION_PLAN.md).
- **Validation method:** Automated unit tests and headless verifier assert rejection of mismatched runID, mismatched generation token, and late callback after cancellation with staleCallbackRejected.
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
- **VER-016 (Phase 4 Veil Annular Interaction Engine & Real Input Integration):** Pure annular geometry model (`VeilGeometry`), minimal-translation placement planner (`VeilPlacementPlanner`), pointer tracking with angular hysteresis and radial overshoot (`VeilPointerTracker`), keyboard navigation engine (`VeilKeyboardNavigator`), native temporary Carbon hotkey delivery adapter (`VeilKeyboardDeliveryAdapter`), non-activating floating AppKit panel (`VeilWindow`), CoreGraphics drawing with single-source-of-truth path parity (`VeilView`), and deterministic directional layouts for all V1 object classes (`VeilLayoutRegistry` with `.experimental` lifecycle). Unit test suite `PulseInteractionTests` (21 tests across tokens, parity, planner, pointer tracker, keyboard navigator, Carbon adapter lifecycle/events, 9-trajectory real mouse events, and hollow center traversal vs click-through), headless verifier (176 assertions), and live probes against TextEdit (PID 80934), Brave Browser (PID 702), Terminal (PID 81066), screen edge clamping (196, 400), screen corner clamping (196, 196), and 2 attached physical displays (Display 1 at 0,0 and Display 2 at -1440,-132) verify: 100% drawing/hit-testing parity, transparent corner click-through, neutral center click-through and traversal without dismissal, real mouse-event delivery across 9 trajectories, non-focus-stealing Carbon temporary hotkey delivery (`⌃⌥[`, `⌃⌥]`, `⌃⌥O`, `⌃⌥I`, `⌃⌥↩`, `⌃⌥⎋`) with zero collision against `Shift-Command-Space`, clean unregistration on recede/dismiss, nested disclosure outward/inward traversal, clean recede to QUIET, and zero focus or clipboard theft.

## 6. Known Not Working

None identified for the Phase 0/1/2/3/4 scope.

## 7. Implemented but Unverified

- **UNV-001:** Physical multi-app hotkey overlay popup across arbitrary third-party windows requires visual operator observation.
- **UNV-002:** Big Mac Target dispatch route remains pending physical network connection (`bigmac.local` unreachable during Phase 0).
- **UNV-003:** Electron/VS Code AX tree inspection edge cases: VS Code unavailable on test machine (`NOT TESTED — APPLICATION UNAVAILABLE`). Native AX and WebArea elements verified live in Brave Browser, TextEdit, Terminal, and fixture app.
- **UNV-004:** Full DexDictate coexistence contract (selection preservation during active dictation, Accessibility insertion-target identity, transcription delivery, browser AX behavior under concurrent operation, Undo Last Dictation semantics, and conflict-yield behavior; scheduled for Phase 11).
- **UNV-005:** Canonical Strand renderer fidelity (Metal Strand renderer does not exist yet; ribbon geometry, twist, transverse barcode segmentation, crossings, glow restraint, face/edge/underside behavior, and motion fidelity belong to Phase 6).
- **UNV-006:** Phase 5 layout freeze work remains unverified. 10 layouts in candidate status, 8 in experimental status, 0 frozen; real owner trials and habit evidence pending owner review.

## 8. Unknown or Evidence-Stale State

- **UNK-001:** Final default hotkey remains provisional; `Shift-Command-Space` verified conflict-free with current DexDictate configuration.
- **UNK-002:** Final license remains MIT vs Unlicense (unresolved product decision preserved).
- **UNK-003:** Exact DEX//REACH standalone app integration endpoint contract to be proven in Phase 8.

## 9. Pending Work

- **PND-005:** Phase 5: Owner review of candidate layouts and 8 ambiguous classes in PHASE-05-OWNER-REVIEW.md; real owner-use trials and layout freeze via explicit source code change and ADR/migration.
- **PND-006:** Phase 6: Implement canonical Pulsefront and Metal Strand renderer against visual fixtures.
- **PND-007:** Phase 8: Core V1 Packs (Core macOS, Git, Ollama).

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
| VER-013 | Phase 2 Lens context acquisition & lazy precedence | verified-local | 5-tier precedence with lazy halting, coordinate mapping, secure blocking, type refiners, stale token validation; Tier 1 Finder single/multi file selection PASS; focus non-theft PASS | `PulseLensTests` (15/15) + `PulseVerification` (51/51) + live native probes | `Sources/PulseLens/` | 2026-10-03 | Lens changes |
| VER-014 | Synthetic AX fixture app | verified-local | Native executable with 8 fixture control classes and --focus-secure | `PulseLensFixtureApp --inspect` + live probe | `Sources/PulseLensFixtureApp/` | 2026-10-03 | test fixture changes |
| VER-015 | Phase 3 Semantic State Machine & Explicit Run Lifecycle | verified-local | 15-state semantic loop, PulseRun tracking with shared generation token and bound envelope/source object ID, enforced Result hold blocking RECEDE, re-entrancy rejection (activeRunAlreadyExists), truthful cancellation state trace with observer agreement, cancellation requested vs acknowledged, 8 terminal outcome lifecycles, Witness receipt binding, Result cross-validation, 9 stale/race protections (INV-007, INV-008), and live AppKit overlay lifecycle with zero focus/clipboard theft | `PulseCoreTests` (38) + `PulseVerification` (103/103) + `dexpulse doctor` + `make check` | `Sources/PulseCore/` | 2026-10-03 | State machine changes |
| VER-016 | Phase 4 Veil Annular Interaction Engine & Real Input Integration | verified-local | 8-sector annular geometry with 100% path parity, 16pt radial overshoot, 6° seam hysteresis, minimal-translation edge/corner placement, negative-origin multi-monitor support, pure keyboard traversal model, temporary Carbon hotkey delivery adapter, real mouse event integration across 9 trajectories, hollow center click-through and traversal, experimental registry for all V1 classes, live app probes (TextEdit, Brave, Terminal) | `PulseInteractionTests` (21) + `PulseVerification` (176/176) + live probes + `make check` | `Sources/PulseInteraction/` | 2026-10-03 | Interaction engine changes |
| VER-017 | Phase 5 Object Layout Freeze Trial & Candidate System | verified-local | 10 candidate layouts (1.0.0-candidate), 8 experimental layouts (1.0.0-experimental), 0 frozen; freeze immutable at runtime (requires source change + ADR/migration); content-free trial ledger; non-binding mechanical diagnostics (350 synthetic trials); deterministic owner review generator with consistency gate | `VeilTests` (87/87) + `PulseVerification` (313/313) + `make check` | `Sources/PulseInteraction/` | 2026-10-03 | Layout changes |
| INV-001 | DexDictate retains priority | requested | Partial Phase 0/1: no trigger collision, clipboard/focus preserved. Full coexistence matrix unverified | Concurrent runtime matrix (Phase 11) | `build/DEX_PULSE.app` (partial) | 2026-10-03 | capture/input/coexistence changes |
| INV-002 | No destructive V1 executor | verified-local | Destructive future cap blocked | `PulsePolicy` + `PulseVerification` | `PulseKit` | 2026-10-03 | Pack/policy changes |
| INV-003 | Lens precedence is deterministic & lazy | verified-local | Locked order: Tier 1 > Tier 2 > Tier 3 > Tier 4 > Tier 5; stops at winning tier; zero clipboard mutation; zero focus theft | `LensResolver` spy tests & live Fixture/TextEdit/Terminal/Brave/Finder probes | `PulseLens` | 2026-10-03 | Lens changes |
| INV-004 | Stable object-class directional layouts | verified-local | Permanent directional slots across all 18 V1 ObjectClasses (10 candidate, 8 experimental, 0 frozen); unavailable capabilities preserve position (disabled slot); no AI reordering; candidate layouts immutable at runtime pending real owner review via ADR/migration | `VeilLayoutRegistry` snapshot tests + `PulseVerification` | `Sources/PulseInteraction/` | 2026-10-03 | Layout changes |
| INV-005 | Strand visuals match fixtures | requested | Reference fixtures intact. Metal Strand renderer not yet implemented (Phase 6) | Golden comparison against reference videos (Phase 6) | none (fixtures only) | 2026-10-03 | renderer/material changes |
| INV-006 | Core runtime independence | verified-local | 0 external packages | `Package.swift` inspection | package graph | 2026-10-03 | dependency changes |
| INV-007 | State machine causal convergence | verified-local | Cancellation from any transient state strictly reaches QUIET without stranded states | Automated test across 13 transient states in `PulseCoreTests` + `PulseVerification` | `Sources/PulseCore/` | 2026-10-03 | State machine changes |
| INV-008 | Stale completion protection | verified-local | Outdated runID or generationToken rejected; late callbacks cannot mutate state or resurrect runs | `PulseCoreTests` (stale callback rejection) + `PulseVerification` | `Sources/PulseCore/` | 2026-10-03 | Async execution / state changes |
| INV-032 | Visible geometry strictly equals mathematical hit testing | verified-local | Dense parity assertions across all 8 sectors prove cgPath().contains(pt) strictly equals math contains() | `VeilTests` + `PulseVerification` section 13 | `Sources/PulseInteraction/VeilGeometry.swift` | 2026-10-03 | Geometry changes |
| INV-033 | Seam hysteresis and radial overshoot envelope | verified-local | 6° angular seam hysteresis prevents boundary flutter; 16pt radial overshoot tolerance forgives swift motor gestures; 9-trajectory real mouse event integration and hollow center click-through verified live | `VeilTests` + live runtime probes | `Sources/PulseInteraction/VeilPointerTracker.swift` | 2026-10-03 | Tracker changes |
| INV-034 | Minimal translation placement with causal origin preservation | verified-local | Screen visibleFrame edge/corner clamping shifts center minimally; preserves causalOrigin; multi-monitor negative coords verified | `VeilPlacementPlanner` tests + live multi-monitor probes | `Sources/PulseInteraction/VeilPlacementPlanner.swift` | 2026-10-03 | Placement changes |
| INV-035 | Full keyboard traversal without focus theft | verified-local | Keyboard reaches all visible Reflexes via Tab, arrows, dive nested, and Escape cancel without stealing focus; native temporary Carbon hotkeys (⌃⌥[, ⌃⌥], ⌃⌥O, ⌃⌥I, ⌃⌥↩, ⌃⌥⎋) active only during Veil presentation; 0 focus theft verified | `VeilKeyboardNavigator` + `VeilKeyboardDeliveryAdapter` + `VeilWindow` + live probes | `Sources/PulseInteraction/` | 2026-10-03 | Keyboard changes |

## 12. Current Change Scope and Impact Radius

- **Allowed to change:** Package foundation, AppKit shell, interaction, verification, build scripts, tests.
- **Must remain unchanged:** Supplied original reference video bytes; locked user decisions; clean-room boundary.
- **Mandatory checks:** `make check`, `make app`, `make install-user`, `scripts/validate_planning_source.sh`, `scripts/verify_fixtures.sh`.
## 13. Compact Revision Log

### Revision 15 — 2026-10-03

- **Artifact/source identity:** Phase 5 Owner Trial Infrastructure Closure (`branch: phase-05-layout-freeze`)
- **State deltas:**
  - **Metadata & State Sync:** Synchronized operational state header to Revision 15, establishing `active-phase05-owner-trial-ready` baseline with Phase 4 verified, Phase 5 candidate/experimental registry verified, Phase 5 owner-trial infrastructure active, 0 frozen layouts, and Phase 6 not started.
  - **Synthetic Count Parity Gate:** Eliminated count drift across all documentation, tests, and diagnostics; unified baseline at 350 non-binding synthetic trials dynamically derived from `VeilLayoutTrialSimulator.deterministicBaselineSyntheticTrialCount`.
  - **Structural Separation for Real Owner Trials:** Introduced `VeilOwnerTrialStore`, `VeilOwnerTrialRecord`, `VeilOwnerClassAggregate`, and `VeilOwnerFeedback` types completely distinct from synthetic simulation records. Compile-time separation prevents synthetic engines from writing into the owner store.
  - **Strict Content-Free Privacy Guarantee:** Telemetry records store only operational, temporal, and categorical metadata (class, family, version, input route, armed/selected direction, reflex identifier, seam crossings, radial overshoot, latency, cancellation, feedback). Strictly zero text strings, filenames, paths, URLs, AX element names, or clipboard bytes.
  - **Explicit Owner Trial Mode & Local Isolation:** Trial mode defaults to OFF. Trials are only recorded when explicitly enabled by the owner. Store is saved locally to `~/Library/Application Support/DEX_PULSE/owner-trials/phase05-owner-trials.json` outside the Git repository. Real owner invocation count starts at exactly 0.
  - **CLI Management Surface:** Added `dexpulse layout-trial` command supporting `status`, `start`/`enable`, `stop`/`disable`, `reset`, `summary [--json]`, and `mark-last <feedback>` with standardized feedback vocabulary (`good`, `misfire`, `wrong-direction`, `missing-reflex`, `needs-more-use`).
  - **Per-Class Freeze Gate Aggregation:** Independent metrics computed per object class, verifying against the controlling source requirement of at least 20 real invocations or deliberate review per class.
  - **Comprehensive Verification & Live Probes:** Added unit tests for store defaults, isolation, per-class attribution, corruption resilience, and schema roundtrip; added headless live controller owner-trial smoke proof using isolated temporary namespace, proving zero mutation of real user store.
- **New evidence:** All 96 unit tests passed across 5 suites (`PulseInteractionTests` 36, `PulseCoreTests` 38, `PulseLensTests` 15, `PulseKitTests` 3, `PulseVerificationTests` 4); `PulseVerification` passed 342/342 headless checks; live runtime probes verified across TextEdit, Brave, Terminal; `dexpulse doctor` and `dexpulse layout-trial` clean; `make check` passed 6/6 stages; `make app` built and signed release bundle.

### Revision 14 — 2026-10-03

- **Artifact/source identity:** Phase 5 Evidence-Integrity and Owner-Review Alignment (`branch: phase-05-layout-freeze`)
- **State deltas:**
  - **Removal of False Owner Token / Runtime Immutability:** Removed `freezeLayout(for:ownerApprovalToken:)` security-theater mechanism. Layouts are strictly immutable at runtime; candidate status cannot be converted to frozen via runtime API or token. Freeze strictly requires an explicit source-controlled migration with an ADR approved by the human owner.
  - **Restored Safe Initializer Default:** `VeilObjectLayout` initializer defaults strictly to `.experimental` (`1.0.0-experimental`). Candidate lifecycle must be explicitly assigned to vetted layouts.
  - **Zero Silent Fallback for All 18 V1 Object Classes:** Eliminated silent fallback to Text for unreviewed classes. Explicitly registered all 18 classes: 10 candidate layouts (`1.0.0-candidate`), 8 experimental layouts (`1.0.0-experimental`), 0 frozen layouts.
  - **Image / File Candidate Family Alignment:** Implemented explicit `Image/file` candidate family in `VeilLayoutRegistry` adhering to `docs/OBJECT_LAYOUTS_V1.md` (N metadata, NE enhance, E convert, SE send/target, S spool, SW reveal, W related, NW variant) with unbuilt capabilities locked in place without reflow.
  - **Deterministic Owner-Review Generator:** Built `VeilOwnerReviewGenerator` producing `docs/layout-trials/PHASE-05-OWNER-REVIEW.md` directly from `VeilLayoutRegistry` state with zero drift, verified via automated consistency gate. Added Owner Decision Matrix with ASCII wheels and blank direction-change tables.
  - **Terminology and Accounting Correction:** Replaced invented semantic claims with `HYPOTHESIS — REQUIRES OWNER REVIEW`. Relabeled mechanical trials to `NON-BINDING MECHANICAL DIAGNOSTIC`. Separated accounting: 350 synthetic mechanical trials vs 0 real owner invocations. Removed invented numeric freeze budgets, restoring controlling source freeze criteria (20 real invocations or deliberate review, misfire notes, edge usability, keyboard equivalent, owner approval).
- **New evidence:** All 87 unit tests passed across 5 suites (`PulseInteractionTests` 27, `PulseCoreTests` 38, `PulseLensTests` 15, `PulseKitTests` 3, `PulseVerificationTests` 4); `PulseVerification` passed 313/313 checks; live runtime probes verified across TextEdit, Brave, Terminal; `dexpulse doctor` clean; `make check` passed 6/6 stages; `make app` built and signed release bundle.

### Revision 13 — 2026-10-03

- **Artifact/source identity:** Phase 5 Object Layout Freeze Trial & Candidate System (`branch: phase-05-layout-freeze`)
- **State deltas:**
  - **Candidate Layout Versioning:** Promoted all 11 V1 `ObjectClass` layouts (plus 7 specialized classes) from `.experimental` to `.candidate` with semantic version `"1.0.0-candidate"`. Explicitly maintained candidate status; automated test harnesses and CI suites are strictly prohibited from freezing layouts. Freezing requires explicit human owner review with valid approval token (`freezeLayout(for:ownerApprovalToken:)`).
  - **Privacy-Safe Content-Free Trial Ledger:** Implemented `VeilLayoutTrialLedger.swift` with privacy-safe metrics (trial duration, angular error, seam crossings, radial overshoot recovery, misfires, cancellation, and nested disclosures). Strictly enforces zero storage of clipboard strings, filenames, URLs, or AX text payloads (witness proof boundary DEC-006).
  - **Autonomous Mechanical Trial Simulator:** Implemented `VeilLayoutTrialSimulator.swift` modeling human motor variability (±3° angular noise, swift radial sweeps, seam crossings, and edge cases). Successfully simulated 355 mechanical trials across all 18 object classes with zero false-trigger misfires (aggregate misfire rates ≤ 10.5%, well within the 15% budget).
  - **Candidate Review Artifact:** Authored `docs/layout-trials/PHASE-05-OWNER-REVIEW.md` and build packet `docs/build-packets/PHASE-05-LAYOUT-FREEZE.md` featuring 8-compass ASCII layout diagrams, slot rationale, habit formation affordances, and mechanical trial metrics for real owner-use review.
  - **Comprehensive Verification:** Added Section 14 to `PulseVerification` with 154 additional assertions (total 330/330 passing) and 3 new test cases to `PulseInteractionTests` (total 84/84 tests passing in 0.39s).
- **New evidence:** All 84 unit tests passed across 5 suites (`PulseInteractionTests` 24, `PulseCoreTests` 38, `PulseLensTests` 15, `PulseKitTests` 3, `PulseVerificationTests` 4); `PulseVerification` passed 330/330 automated checks; `dexpulse doctor` verified Phase 5 status; `make check` passed all 6 stages; `make app` built and signed release bundle.

### Revision 12 — 2026-10-03

- **Artifact/source identity:** Stage A Phase 4 Real Input Integration Closure (`branch: phase-04-veil`)
- **State deltas:**
  - **Native Carbon Temporary Hotkey Delivery Adapter:** Implemented `VeilKeyboardDeliveryAdapter.swift` using native Carbon `RegisterEventHotKey` / `UnregisterEventHotKey` with signature `'VEIL'`. Registers a deterministic temporary chord map (`⌃⌥[` prev slot, `⌃⌥]` next slot, `⌃⌥O` outward dive, `⌃⌥I` inward back, `⌃⌥↩` activate, `⌃⌥⎋` cancel) strictly while Veil is presented, and removes all registrations immediately upon recede/dismissal. Validated zero collision against global invocation hotkey (`Shift-Command-Space`).
  - **Non-Activating Keyboard Delivery:** Decoupled pure keyboard navigation semantics (`VeilKeyboardNavigator`) from system event delivery. Proved live non-focus-stealing keyboard control where the frontmost application retains focus and AX identity while Veil receives registered chords.
  - **Real Mouse-Event Integration Chain:** Implemented and proved the full end-to-end chain: `mouse movement event -> VeilView -> tracking area / global monitor -> VeilPointerTracker -> armed sector -> UI update`. Verified across 9 canonical trajectories (center -> N; N -> center -> N; N seam jitter; intentional N -> NE crossing; N radial overshoot within 16 pt tolerance; travel beyond tolerance with boundary exit; parent -> nested choice; nested -> parent; cancel).
  - **Hollow Center Traversal vs Click-Through Parity:** Verified that entering the hollow center does not falsely end pointer tracking, and clicks in the empty center pass through to underlying applications without stealing focus or making Veil key/main.
  - **Tuning Tokens Confirmation:** Confirmed committed tuning tokens locked to `42.0 pt` inner radius, `112.0 pt` outer radius, `16.0 pt` radial overshoot, `6.0°` angular hysteresis, `8.0 pt` nested gap, and `52.0 pt` nested ring thickness.
- **New evidence:** All 81 unit tests passed across 5 suites (`PulseInteractionTests` 21, `PulseCoreTests` 38, `PulseLensTests` 15, `PulseKitTests` 3, `PulseVerificationTests` 4); `PulseVerification` passed 176/176 automated checks; `dexpulse doctor` clean; `make check` passed all 6 stages; `make app` built and signed release bundle; live runtime probes verified across TextEdit (PID 80934), Brave Browser (PID 702), and Terminal (PID 81066) with zero focus theft, zero clipboard mutation, active Carbon chords, real mouse trajectory verification, clean cancel, and 2 physical displays attached and verified.

### Revision 11 — 2026-10-03

- **Artifact/source identity:** Phase 4 Veil Interaction Engine (`branch: phase-04-veil`)
- **State deltas:**
  - **Pure Annular Geometry Engine:** Implemented `VeilGeometry.swift` with `VeilSectorGeometry`, `VeilRingGeometry`, `CompassDirection`, `VeilTuningTokens`, and `VeilHitTestResult`. Enforced single source of truth: CoreGraphics visible drawing paths (`cgPath()`) strictly match mathematical hit-testing (`contains(point:)`) across all 8 cardinal/diagonal directions, inner/outer boundaries, 0° wraparound (East sector), and radial overshoot tolerance envelopes (`verifyParity`).
  - **Tuning Tokens Enforced:** Locked `defaultInnerRadius = 42.0 pt`, `defaultOuterRadius = 112.0 pt`, `radialOvershootTolerance = 16.0 pt`, `angularHysteresisDegrees = 6.0 deg`, `nestedGap = 8.0 pt`, and `nestedRingThickness = 52.0 pt` (`VeilTuningTokens`).
  - **Minimal Translation Placement Planner:** Implemented `VeilPlacementPlanner.swift` with pure geometric clamping against `visibleFrame` (excluding Dock and menu bar) and native `NSScreen` resolution. Clamps center coordinates while preserving exact `causalOrigin` identity across screen edges, corners, and secondary displays with negative origins.
  - **Pointer Tracking with Hysteresis & Overshoot:** Implemented `VeilPointerTracker.swift`. Active strictly while presented (zero tracking or polling in `QUIET`). Handles neutral center traversal without false dismissal or cancellation, suppresses boundary seam flutter via 6° angular hysteresis, forgives rapid motor movement via 16 pt radial overshoot, and manages nested disclosure outward/inward traversal.
  - **Full Keyboard Traversal Engine:** Implemented `VeilKeyboardNavigator.swift`. Fully covers all visible actions via Tab/Shift-Tab, bracket keys `[` / `]`, arrow keys (Up=N, Down=S, Right=E/dive, Left=W/back), compass shortcuts, Space/Return activation, and clean Escape cancellation (backs out of nested disclosure first, cancels wheel second).
  - **Non-Activating Floating Interaction Surface:** Implemented `VeilWindow.swift` (`NSPanel`, `nonactivatingPanel`, `canBecomeKey=false`, `canBecomeMain=false`) and `VeilView.swift`. Overrode `hitTest(_:)` so that transparent corners and the hollow neutral center return `nil`, allowing clicks to pass through to underlying applications without focus theft (INV-001). Implemented debug geometry visualization mode and reduced-motion instant transitions.
  - **Experimental Layout Registry Coverage:** Implemented `VeilLayoutRegistry.swift` mapping all 11 V1 `ObjectClass` families deterministically to immutable compass directions. Unavailable capabilities preserve positions (disabled slot); neighbors never slide over. Lifecycle explicitly marked and verified as `.experimental` (Phase 5 owns freeze gate).
  - **App Integration:** Integrated `VeilInteractionController` as the primary interaction controller in `DexPulseApp/main.swift`, while preserving `DebugPulseOverlayController` for diagnostic reference.
- **New evidence:** All 76 unit tests passed across 5 test suites (`PulseInteractionTests` 16, `PulseCoreTests` 38, `PulseLensTests` 15, `PulseKitTests` 3, `PulseVerificationTests` 4); `PulseVerification` passed 156/156 assertions (including section 13 Veil annular interaction, parity, and lifecycle verification); `dexpulse doctor` verified clean status; `make check` passed all 6 stages; `make app` built and signed `build/DEX_PULSE.app`; live runtime probes verified across TextEdit (PID 74529), Brave Browser (PID 693), Terminal (PID 62640), screen edge clamping (5, 400) -> (196, 400), screen corner clamping (5, 5) -> (196, 196), and 2 attached physical displays (Display 1 at 0,0 and Display 2 at -1440,-132) with zero focus theft and zero clipboard mutation.

### Revision 10 — 2026-10-03

- **Artifact/source identity:** Stage A Final Phase 3 Identity/Termination Hardening (`branch: phase-03-state-machine`)
- **State deltas:**
  - **Unified Result Identity Validation:** Consolidated Result Object validation for `recordCompletion(...)` and `holdResult(...)` into a single internal method `validateResultIdentity`. Enforced strict 4-way matching of `runID`, `sourceObjectID`, `sourceObjectClass`, and `contextGenerationToken`. Explicitly rejected nil/missing generation tokens when an invocation token is bound, throwing typed error `PulseStateMachineError.resultMismatch`.
  - **Tightened Envelope Binding Lifetime:** Enforced that `bindEnvelope(...)` requires an active, uncompleted run (`outcome == nil`, `!isCompleted`) in legitimate context-acquisition states (`.pulse` or `.lens`), throwing `PulseStateMachineError.invalidStateForBinding` otherwise.
  - **Complete Witness/Run Metadata Binding:** Implemented `PulseReceiptBindingMetadata` to cross-validate `runID`, `parentRunID`, `objectClass`, `capabilityID`, `targetID`, and non-contradicting `outcome` before attaching `receiptID` to `PulseRun`, maintaining strict module dependency boundaries.
  - **Execution-Phase Cancellation via SEVER:** Updated `PulseStateMachine.cancel()` so that cancellations during execution-active states (`DISPATCH` or `WEAVE`) causally transition `... -> SEVER -> RECEDE -> QUIET`, with registered observers inspecting synchronous `currentState` at every transition. Late completions after cancellation remain rejected.
- **New evidence:** All 60 unit tests passed across 4 test suites (`PulseCoreTests` 38, `PulseLensTests` 15, `PulseKitTests` 3, `PulseVerificationTests` 4); `PulseVerification` passed 103/103 headless assertions; `dexpulse doctor` verified clean operation; `make check` passed 6/6 verification stages cleanly; GitHub Actions CI run `37106200742` completed with `success` on commit `3e50172666f6e83a9b3d0c664bc432ff1bf7ce8b`.

### Revision 9 — 2026-10-03

- **Artifact/source identity:** Phase 3 lifecycle semantics closure (`branch: phase-03-state-machine`)
- **State deltas:**
  - **Shared Invocation/Envelope Identity:** `LensResolver.acquireContextEnvelope` now accepts optional `generationToken`. `PulseStateMachine.startRun()` issues the generation token which is passed to Lens, and `bindEnvelope(_:)` records the real `envelopeID`, `sourceObjectID`, `sourceObjectClass`, and `sourceObjectSummary` on `PulseRun`.
  - **Re-entrant Invocation Guard:** Re-entrant calls to `startRun()` reject deterministically with typed error `PulseStateMachineError.activeRunAlreadyExists(runID:)` instead of silently replacing active runs.
  - **Enforced Result Hold Invariant:** `PulseStateMachine.transition(to: .recede)` strictly blocks while `_heldResult != nil`, throwing typed error `PulseStateMachineError.resultHoldActive(resultID:)` until `releaseResultHold()` is called.
  - **Truthful Cancellation State Trace:** `PulseStateMachine.cancel()` performs synchronous, step-by-step state transitions (`... -> RECEDE -> QUIET`), guaranteeing that observer callbacks inspect `currentState` matching the notification (`currentState == .recede` during RECEDE, `currentState == .quiet` during QUIET).
  - **Granular Cancellation States:** Added `PulseCancellationState` (`none`, `requested`, `acknowledged`) to `PulseRun`. Added `requestCancellation()` and `acknowledgeCancellation()`. Racing executor completions during requested cancellation are rejected as stale.
  - **Semantic AppKit Overlay Dismissal:** `DebugPulseOverlayController.dismiss()` uses causal transitions (`transition(to: .recede)` -> `transition(to: .quiet)`) with `resetToQuiet()` reserved exclusively for emergency recovery.
  - **8 Terminal Outcome Causal Proofs:** Tested deterministic lifecycle paths for `succeeded`, `cancelled`, `blocked`, `unavailable`, `timedOut`, `failed`, `interrupted`, and `unknown`, verifying distinct failure semantics and post-terminal callback rejection.
  - **Witness Receipt Identity Binding:** Added stable `receiptID: UUID` to `WitnessReceipt`. Added `bindReceipt` ensuring `receipt.runID == run.runID` and binding `run.receiptID = receipt.receiptID`, while enforcing distinct `executed` vs `verified` proof states.
  - **Result Object Cross-Validation:** `recordCompletion` and `holdResult` enforce cross-validation of `runID`, `sourceObjectID`, `sourceObjectClass`, and `contextGenerationToken`.
  - **Comprehensive 9-Case Stale/Race Protection Suite:** Tested cancelled run late callback, cross-run callback, duplicate callback, recede callback, stale envelope bind, wrong run receipt, wrong run result, cancellation requested racing callback, and timeout late callback.
  - **Real AppKit Overlay Lifecycle Verification:** Added automated headless AppKit lifecycle test to `PulseVerification` asserting `QUIET -> PULSE -> LENS -> VEIL -> RECEDE -> QUIET`, bound run/envelope identity, zero clipboard mutation, and zero focus theft.
- **New evidence:** All 54 unit tests passed across 4 test suites (`PulseCoreTests` 32, `PulseLensTests` 15, `PulseKitTests` 3, `PulseVerificationTests` 4); `PulseVerification` passed 103/103 headless assertions; `dexpulse doctor` verified Phase 3 lifecycle and state engine readiness; `make check` passed 6/6 verification stages cleanly; `make app` built and signed release bundle.

### Revision 7 — 2026-10-03

- **Artifact/source identity:** Phase 2 acceptance evidence completion (`branch: phase-02-lens`)
- **State deltas:** Enhanced `SelectedFileProvider` to inspect `AXSelectedRows` (Outline/Table/List views) and resolve macOS file-reference URLs (`(url as NSURL).filePathURL?.path`), enabling native Tier 1 `SelectedFileObject` acquisition for single and multiple selected files in Finder without AppleEvents or synthetic copy events. Conducted direct empirical focus-non-theft regression testing proving that Lens acquisition (`dexpulse probe`) never becomes frontmost and strictly preserves originating application PID and focused AX element across TextEdit, Brave Browser, and `PulseLensFixtureApp`.
- **New evidence:** Real Finder selected-file acquisition verified live under Tier 1 (single file: 1 item `file_alpha.txt`, multiple files: 2 items `file_alpha.txt` and `file_beta.txt`); focus non-theft verified with 0 focus or element shifts across 3 live target applications. GitHub Actions CI run `37100618922` completed with `success` for previous tip `d178c67c5e7f5a413ae77b8ed54cfab2b342de6e`.

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
