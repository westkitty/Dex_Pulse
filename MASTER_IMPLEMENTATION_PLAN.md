# DEX//PULSE Master Implementation Plan

**Repository:** `westkitty/Dex_Pulse`
**Scope:** empty repository -> native macOS V1 vertical slice
**Primary user:** Andrew
**Canonical development machine:** Big Mac
**Primary operator/runtime target:** MacBook Air M1
**Status:** implementation plan; no app behavior is verified until evidence is recorded in `OPERATIONAL_STATE.md`

## 1. Objective

Build DEX//PULSE as a native, local-first macOS reflex layer that turns explicit context into fast, object-specific actions without stealing focus, corrupting clipboard state, or hiding consequential behavior behind AI. The V1 proof is the complete causal loop:

`QUIET -> PULSE -> LENS -> VEIL -> Reflex -> optional Target -> DISPATCH/WEAVE -> Result Object -> WITNESS -> RESOLVE -> RECEDE -> QUIET`

The first release-quality vertical slice must work with selected content, files/paths, UI elements under the pointer, focused Accessibility elements, frontmost apps/windows, and read-only clipboard fallback. It must execute at least one deterministic capability and one local-model capability, preserve DexDictate priority, render canonical Starsilk-derived Strands from the owner-supplied visual fixtures, and leave inspectable proof.

## 2. Locked constraints

The authoritative product locks live in `PROJECT_BIBLE.md`. Implementation must preserve these in particular:

- Apple Silicon macOS 14+ V1 target.
- Native Swift/AppKit/Core Animation/Metal; SwiftUI may own persistent management surfaces.
- No runtime requirement on Karabiner, Hammerspoon, Docker, browser extensions, Python, Node, or another helper application.
- MacBook is the everyday operator/CLI machine; Big Mac is the canonical development/heavy-compute machine.
- Lens precedence is exact: explicit selected text/file -> UI element under pointer -> focused AX element -> frontmost window/app -> existing clipboard fallback.
- Merely opening Pulse never writes to or temporarily replaces clipboard contents.
- Object grammar is `Object -> Reflex -> optional Target -> Result Object`.
- Each recognized object class owns a stable directional layout. No universal verb wheel; no AI reordering of learned positions.
- UI elements/buttons are V1 objects.
- V1 exposes no executable destructive capability.
- DexDictate wins any conflict involving focus, selection, clipboard, trigger handling, AX insertion targets, or undo assumptions.
- PulseKit is the capability registry; integrations are Packs/adapters.
- Spool and ordinary Result Objects are memory-only unless explicitly pinned.
- Witness defaults to 30-day structured retention; habit aggregates are content-free and may retain 180 days.
- Ghost Mode is architecturally possible but execution-disabled in V1.
- Owner-supplied MP4 fixtures are highest visual authority for Strand rendering.

## 3. Development architecture

Use a command-line-reproducible Swift Package foundation plus a native `.app` assembly path. Do not make a generated IDE project the source of truth.

Planned package/target boundaries:

```text
Dex_Pulse/
├── Package.swift
├── Sources/
│   ├── PulseCore/             # object model, state machine, result/proof types
│   ├── PulseKit/              # capability registry, packs, policy, targets
│   ├── PulseLens/             # Accessibility/context acquisition + classifiers
│   ├── PulseInteraction/      # Veil geometry, hit testing, pointer intent
│   ├── PulseVisuals/          # Core Animation surfaces + Strand renderer façade
│   │   └── Shaders/           # Metal source
│   ├── PulseWitness/          # receipts, retention, habit ledger
│   ├── PulsePacks/            # V1 compiled packs/adapters
│   ├── DexPulseApp/           # AppKit application shell/menu bar/settings entry
│   ├── DexPulseCLI/           # `dexpulse` diagnostics/operator CLI
│   └── PulseVerification/     # deterministic verification/fixture runner
├── Tests/
├── fixtures/
├── scripts/
└── Supporting/                # Info.plist, entitlements, app metadata
```

The exact module split may be simplified if real dependency pressure proves it excessive. The architectural invariant is separation between context acquisition, object/capability semantics, transient interaction, rendering, execution, and proof.

### Build doctrine

- `swift build` / `swift test` must exercise the non-app package graph.
- Native app assembly may use `xcrun`, `swift build`, `metal`/`metallib`, `codesign`, and standard macOS tooling.
- `scripts/build_app.sh` is the canonical local app-bundle build path.
- `make check` becomes the single deterministic pre-commit quality gate. The initial planning-only source gate is `scripts/validate_planning_source.sh`; implementation later folds it into `make check`.
- Big Mac owns heavyweight development/build profiling; MacBook receives installable builds and runs runtime/performance acceptance.
- The MacBook operator should not need a full development stack to use installed `DEX//PULSE.app` or the shipped `dexpulse` CLI.

## 4. V1 object classes

V1 must support these object families as explicit typed objects, not merely strings:

1. `SelectedTextObject`
2. `FileObject` / `FileSetObject`
3. `PathObject`
4. `URLObject`
5. `RepositoryObject`
6. `CodeObject`
7. `ErrorLogObject`
8. `ImageObject`
9. `UIElementObject`
10. `FocusedElementObject`
11. `WindowObject`
12. `ApplicationObject`
13. `ClipboardObject`
14. `ResultObject`
15. `MachineTarget` (`MacBook`, `Big Mac`)

Some classes may refine another class after deterministic recognition. Example: selected text may become `URLObject`, `PathObject`, `ErrorLogObject`, or `CodeObject` while preserving provenance back to the selection.

Initial layouts remain provisional until the layout-freeze gate in Phase 5. See `docs/OBJECT_LAYOUTS_V1.md`.

## 5. Golden V1 journeys

The vertical slice is not accepted from one happy-path demo. Three primary journeys are mandatory:

### Journey A — deterministic/local

`Repository/path -> Pulse -> Lens: RepositoryObject -> Veil -> Inspect Git -> local Git Pack -> Result Object -> Witness exit/status proof -> Recede`

Purpose: prove fast context resolution, object-specific Veil, deterministic executor, Result/Witness, and no model/network dependency.

### Journey B — local model

`Terminal selected error/log -> Pulse -> Lens: ErrorLogObject -> Veil -> Diagnose -> Ollama Pack -> local/Big-Mac eligible target -> Result Object -> Witness model/executor receipt -> Recede`

Purpose: prove local-model routing without putting inference on the hot path.

### Journey C — UI element

`Pointer over real button/control -> Pulse with no explicit selection -> Lens: UIElementObject -> Veil -> Inspect Element -> native AX capability -> Result Object -> Witness AX provenance -> Recede`

Purpose: prove UI-element-under-pointer precedence, Accessibility semantics, stable pointer geometry, and non-mutating interaction.

### Additional V1 target proof

When Big Mac and DEX//REACH are available, run a safe read-only Reflex explicitly or automatically routed to Big Mac and prove that target identity is visible in Witness. Big Mac unavailability must degrade cleanly; it must not prevent Journeys A-C.

## 6. Phased build

| Phase | Goal | Key outputs | Exit criteria |
|---|---|---|---|
| 0 | Freeze foundation | repo constitution, visual fixtures, state, plan, environment fingerprint | source-of-truth package complete; Big Mac/MacBook environment facts recorded without invented assumptions |
| 1 | Reproducible native skeleton | Swift package, app shell, CLI, verification target, build/install scripts, CI skeleton | app launches locally; CLI runs; tests/build reproducible; no hot-path feature claims yet |
| 2 | Context envelope + Lens | AX authorizer, pointer hit test, explicit selection capture, frontmost app/window, existing clipboard fallback, deterministic recognizers | precedence tests pass; no invocation clipboard mutation; Brave/Terminal/native selection probes captured in fixture harness |
| 3 | Pulse state machine | semantic states, cancellation, result lifecycle, Recede behavior | state transitions deterministic/tested; no hidden mutation; cancellation always reaches QUIET |
| 4 | Veil interaction engine | overlay window, annular hit geometry, contextual layout registry, keyboard path, pointer hysteresis | visible geometry == hit geometry; edge/multi-monitor placement stable; object layouts render from registry |
| 5 | Layout freeze gate | real-use trials for major V1 object classes, provisional mapping revisions | mappings for V1 classes explicitly frozen; no automatic ranking/reordering remains |
| 6 | Canonical visuals | Pulsefront, Pulse Point, Metal Strand ribbon renderer, fixture scenes, reduced-motion equivalents | renderer passes visual-reference gate; no wire/lightning failure; on-demand renderer sleeps in QUIET |
| 7 | PulseKit + policy | registry, descriptors, Targets, availability, no-destructive policy, cancellation/proof contract | incompatible/blocked/unavailable capabilities explain why; destructive descriptors cannot execute |
| 8 | Core V1 Packs | Core macOS, Git, Ollama; GitHub/DEX//REACH read routes as available; DexGate boundary | Journey A and Journey B execute with structured Result/Witness evidence |
| 9 | UI-element vertical slice | UIElement object Reflexes + AX inspection | Journey C passes in native app + Brave/Electron sample where AX permits; no focus steal |
| 10 | Spool + Result/Witness | memory-only Spool, pin/reference rules, 30-day Witness store, 180-day content-free habit ledger | restart clears unpinned Spool/results; retention tests pass; raw content absent from habit data |
| 11 | DexDictate coexistence | priority guard, trigger conflict inspection, focus/clipboard/selection regression suite | DexDictate active and inactive journeys pass; Pulse invocation changes none of DexDictate's protected state |
| 12 | Performance/accessibility hardening | signposts, benchmarks, Reduce Motion, keyboard/VoiceOver labels, multi-monitor/120Hz checks | performance budgets meet release gates on MacBook; reduced-motion semantics complete |
| 13 | Integrated V1 acceptance | run full matrix from installed app, collect proof | all mandatory rows in `docs/V1_ACCEPTANCE_MATRIX.md` pass; unknowns reported; V1 vertical slice may be declared complete |

## 7. Phase details

### Phase 0 — Foundation and environment fingerprint

Before code, validate that the repository source package is self-consistent and can be resumed without this chat. The planning fixture originals are immutable source inputs; generated derivatives never replace them.

Tasks:

- Commit this planning/source-of-truth package and exact visual fixture bytes.
- Keep repository public for now; treat public/private as operational, not architectural.
- Do not select MIT vs Unlicense silently. Record as provisional until owner locks it.
- Fingerprint Big Mac: macOS version, CPU/architecture, Xcode/CLI tools, Swift, Metal toolchain, signing identities available, repo location, free disk.
- Fingerprint MacBook runtime: macOS, architecture, display refresh configurations, Accessibility permission state, DexDictate installation/bundle identity, Ollama/DEX endpoints actually available.
- Pin tool versions only after measured environment evidence exists.
- Create `.gitignore`, `.gitattributes`, repository validation script, and `Makefile` during scaffold phase.

Exit criteria: no environmental fact is guessed; visual references hash-match manifest; source authority is navigable from README.

### Phase 1 — Native skeleton

Build the smallest real app:

- menu-bar/background-capable macOS app with no dock requirement unless deliberately enabled for debugging;
- configurable global hotkey, provisional default `Shift-Command-Space`;
- launch/quit/settings surface;
- `dexpulse doctor` CLI showing installation, permissions, packs, renderer, and machine-target health without exposing secrets;
- `PulseVerification` executable for deterministic headless checks;
- package tests and local app-bundle build script;
- CI on macOS for build/test/package integrity.

Do not implement Strand art before overlay/context scaffolding can exercise it.

### Phase 2 — Lens/context acquisition

Construct `PulseContextEnvelope` atomically at invocation time. Capture only what is needed to route the current explicit interaction.

Precedence implementation:

1. explicit selected text/file via Accessibility/native selection APIs;
2. `AXUIElementCopyElementAtPosition`-class hit testing at pointer;
3. focused AX element;
4. frontmost application/window;
5. existing clipboard read-only snapshot.

Requirements:

- provenance for every candidate;
- confidence and reason for primary-object selection;
- secure/password field guard;
- no automatic synthetic copy event;
- no clipboard writes during Lens resolution;
- no full-screen/screen-record capture;
- OCR only through explicit future/optional user capture, not ambient Lens behavior;
- preserve original object while refining type.

Brave/Chromium: explicitly validate accessibility-tree availability and use the least invasive native mechanism; do not add a browser extension merely to make Pulse work.

Terminal: validate selected text and focused element behavior against the actual Terminal app configuration used by the owner.

### Phase 3 — Semantic state machine

Implement the state model from `docs/INTERACTION_MODEL.md` as code, not incidental UI booleans.

Mandatory terminal paths:

- success: `... -> WITNESS -> RESOLVE -> RECEDE -> QUIET`;
- cancelled: any transient state -> `SEVER/CANCELLED -> RECEDE -> QUIET` as appropriate;
- blocked/unavailable: explanatory result -> `SEVER -> RECEDE`;
- persistent result hold: Result Object may pause automatic Recede while user is inspecting it.

No executor may keep Veil stuck indefinitely after cancellation.

### Phase 4 — Veil interaction engine

Use a borderless, non-activating/transient AppKit overlay that preserves the originating app's context whenever possible.

Implement:

- true annular-sector hit testing;
- pointer trajectory/hysteresis and overshoot tolerance;
- edge-aware placement without moving the causal origin;
- nested Reflex/Target disclosure from the current anchor;
- keyboard equivalent for every visible action;
- Escape/cancel and persistent browse mode;
- stable object-class layout registry;
- debug geometry overlay showing visible path vs actual hit region.

The overlay must never capture focus simply by appearing.

### Phase 5 — Object layout freeze

Before building habit-based shortcuts, use Pulse manually across representative objects. Record misfires, reach distance, accidental sector changes, and repeated desired Reflexes.

Freeze V1 layouts only when:

- each required class has a clear primary Reflex set;
- directions are semantically/motorically coherent;
- frequent actions are not buried behind extra rings;
- mappings work at screen edges;
- keyboard equivalents remain understandable.

After freeze, layout changes require an explicit ADR/migration. Habit learning may suggest pinning or a future Thread; it never silently remaps sectors.

### Phase 6 — Visual system and canonical Strand renderer

Implement Pulse Point and Pulsefront with Core Animation. Implement canonical Strand surfaces with an on-demand Metal path.

Required fixture scenes:

1. broad single ribbon;
2. edge-on twist / extreme apparent-width change;
3. long S curve;
4. two/three over-under crossings;
5. explicit semantic junction distinct from crossing;
6. dispatch barcode packet;
7. Fray;
8. Sever;
9. Return/Witness;
10. Recede.

Visual QA compares render captures against the original videos, not merely contact sheets. See `docs/VISUAL_LANGUAGE.md` and `docs/VISUAL_FIXTURE_QA.md`.

### Phase 7 — PulseKit capability registry and policy

Build descriptors and registry before adding many integrations.

Every Reflex must state:

- accepted object types;
- optional/required Target types;
- locality and network needs;
- availability checks;
- risk class;
- cancellation support;
- Result type;
- proof contract;
- whether the action can mutate anything.

V1 policy rejects the `destructiveFuture` class before executor code is reached. A Pack cannot override core policy.

### Phase 8 — Core Packs and executors

Implement only Packs needed to prove architecture first.

**CoreMacOSPack** — AX inspect, reveal/open, safe metadata inspection.
**GitPack** — status, diff summary, repo identity, recent metadata; keep V1 routes read-only unless a later explicit V1 decision authorizes a bounded reversible write.
**OllamaPack** — local OpenAI/Ollama-compatible inference for Diagnose/Explain.
**GitHubPack** — read-only repo/issue/commit context where configured/networked.
**DEXReachPack** — safe read/inference dispatch and machine Target identity.
**DexGatePack** — inspection boundary for unknown scripts; no post-gate execution in V1.

DexSpeak/DexDiffusion/DexSprite/DexEnhance/DexCast Pack contracts should be scaffoldable without changes to PulseKit, but need not be V1-complete unless they directly improve a golden journey without destabilizing it.

### Phase 9 — UI-element object proof

Required attributes include:

- role/subrole;
- title/label/value where safe;
- application PID/bundle identity;
- enabled/focused state;
- bounds;
- supported AX actions;
- source element reference valid only within safe lifetime;
- privacy classification.

V1 default Reflex for UI controls is read-only `Inspect Element`. Any future `Press` capability is a separate explicit capability and must not appear merely because `AXPress` exists.

### Phase 10 — Spool, Result Objects, Witness, habit ledger

Use local application storage under a DEX//PULSE support directory, never the Git repository.

Spool:

- memory-only by default;
- app restart/login clears unpinned entries;
- pin stores durable reference plus minimal metadata;
- pinning content copies requires explicit user action and explanation when no durable reference exists.

Witness:

- structured receipts keyed by run ID and parent run ID;
- executor/target identity, timing, object class, capability, result/proof state;
- `observed/executed/verified/claimed/unknown` evidence vocabulary;
- raw sensitive payload omitted by default;
- default rolling retention 30 days unless pinned/project-owned.

Habit ledger:

- derived only from Pulse's own approved interactions;
- content-free aggregates;
- default 180-day retention;
- suggestions only; never auto-create Threads or remap Veils.

### Phase 11 — DexDictate coexistence

`docs/DEXDICTATE_COEXISTENCE.md` is mandatory test authority.

At minimum validate:

- both applications idle;
- DexDictate recording while Pulse hotkey is attempted;
- DexDictate transcribing/output delivery while Pulse is invoked;
- selected-text replacement target preserved;
- browser AX tree behavior preserved;
- clipboard value unchanged by Pulse invocation;
- Pulse does not trigger DexDictate and vice versa;
- focus returns/persists correctly;
- DexDictate Undo Last Dictation remains valid after an unrelated Pulse invocation.

If a conflict exists, Pulse yields.

### Phase 12 — Performance, accessibility, resilience

Instrument before optimizing. Use os_signpost/MetricKit or appropriate native measurements plus deterministic test scenes.

Test:

- cold/warm summon;
- 60 Hz and 120 Hz where hardware permits;
- multi-monitor and edge/corner invocation;
- low memory pressure on the 8 GB MacBook;
- Big Mac available/unavailable;
- Ollama available/unavailable/slow;
- revoked Accessibility permission;
- Pack unavailable or malformed, timed out, concurrent/re-entered beyond its declared class;
- denied/revoked Accessibility/Input Monitoring permission and reauthorization without replay;
- stale AX element/window references between Lens resolution and execution;
- crash/relaunch with an in-flight run and storage migration from an older schema;
- result cancellation/retry;
- Reduce Motion;
- keyboard-only navigation;
- VoiceOver labels/announcements for persistent result/Witness surfaces.

### Phase 13 — Integrated V1 gate

Install the candidate build on the MacBook and execute the full acceptance matrix from the installed identity. Source presence or Big Mac simulator proof is not sufficient.

Completion requires:

- all mandatory acceptance rows Pass;
- no destructive route exists;
- visual fixture gate Pass;
- performance budget Pass or explicit owner-approved budget revision;
- DexDictate coexistence Pass;
- Journey A/B/C Pass end to end;
- Operational State promoted only from direct evidence;
- candidate commit/hash and installed bundle identity recorded.

## 8. Performance budgets

Detailed budgets live in `docs/PERFORMANCE_BUDGETS.md`. Initial release targets on MacBook Air M1:

- input -> first visible Pulse feedback: p95 <= 50 ms;
- input -> Veil interactable from deterministic state: p95 <= 120 ms, release ceiling <= 150 ms absent OS scheduling anomalies;
- no LLM/network dependency before Veil interactivity;
- idle CPU average <= 0.5% over a 60 s quiet sample after settling;
- no active display/render loop in QUIET;
- preferred idle RSS <= 120 MB, release ceiling <= 160 MB unless profiling justifies revision;
- ordinary 60 Hz interaction: <1% missed frames in controlled benchmark;
- Strand renderer GPU time target <= 4 ms/frame on representative V1 scenes at MacBook native UI scale;
- 120 Hz path should remain responsive where display/hardware makes it testable, but lack of 120 Hz hardware does not become fake proof.

Budgets are hypotheses until measured. Revise by evidence/ADR, not convenience.

## 9. Security/privacy model

See `docs/SECURITY_PRIVACY.md`.

V1 principles:

- explicit context only;
- no ambient surveillance;
- no telemetry;
- no automatic payload logging;
- secrets stay in Keychain or executor-owned secure storage, never config/history/Git;
- remote execution is visible as a Target;
- capability availability never implies authority;
- destructive executor path is absent;
- unknown script inspection and execution are separate concepts;
- public repository must contain no real personal history, machine credentials, private endpoints, or user payloads.

## 10. Testing strategy

See `docs/TEST_STRATEGY.md`.

Layers:

1. pure unit tests: geometry, state machine, recognition, policy, retention;
2. deterministic integration tests: registry/Packs/results/Witness;
3. AX harness apps: selected text, buttons, fields, focus, secure fields;
4. renderer fixture scenes/golden captures;
5. installed-app journey tests on MacBook;
6. DexDictate coexistence manual + automated checks where possible;
7. performance benchmarks;
8. final cold-start acceptance.

No test may simulate away the behavior it claims to prove.

## 11. Clean-room / licensing boundary

QDuo is architectural/behavioral prior art, not a code donor. See `docs/CLEAN_ROOM_BOUNDARY.md`.

Until the owner locks a license, do not import GPL-covered QDuo source or derivatives. Reimplement behavior from independently stated requirements, platform APIs, public documentation, tests we author, and observed behavior.

## 12. Repository documentation contract

These files are part of the implementation system, not optional prose:

- `PROJECT_BIBLE.md` — durable product truth and decisions;
- `OPERATIONAL_STATE.md` — evidence state;
- `MASTER_IMPLEMENTATION_PLAN.md` — staged execution plan;
- `PROJECT_SYSTEM_INSTRUCTION.md` — compact ChatGPT Project instruction;
- `docs/ARCHITECTURE.md` — component boundaries;
- `docs/INTERACTION_MODEL.md` — state and behavior grammar;
- `docs/OBJECT_MODEL.md` — object/context/provenance contract;
- `docs/OBJECT_LAYOUTS_V1.md` — provisional/frozen directional layouts;
- `docs/PULSEKIT_CAPABILITY_CONTRACT.md` — capability/Packs contract;
- `docs/VISUAL_LANGUAGE.md` + visual fixtures — renderer authority;
- `docs/V1_ACCEPTANCE_MATRIX.md` — definition of done;
- `docs/PERFORMANCE_BUDGETS.md` — measurable performance doctrine;
- `docs/DEXDICTATE_COEXISTENCE.md` — priority contract;
- `docs/SECURITY_PRIVACY.md` — data and execution boundary;
- `docs/TEST_STRATEGY.md` — proof architecture;
- `docs/LOCAL_STORAGE.md` — persistence/migration/interruption contract;
- `docs/ERROR_MODEL.md` — terminal/proof/recovery state vocabulary;
- `docs/ENVIRONMENT_FINGERPRINT.md` — measured build/runtime environment authority;
- `docs/DEVELOPMENT_WORKFLOW.md` — branch/build/validation workflow;
- `docs/REFERENCE_PROJECTS.md` — mechanism prior art, with copying boundaries;
- `docs/ADVERSARIAL_REVIEW.md` — critique that shaped the optimized plan;
- `docs/REQUIREMENT_TRACEABILITY.md` — request-to-artifact coverage.

A future agent that changes a locked decision must update the controlling source(s), not merely code around them.

## 13. Stop conditions

Stop the active implementation phase rather than piling on fixes when any of these occur:

- Pulse invocation changes clipboard contents without an explicit post-open action.
- Pulse steals focus/target identity in a way that can invalidate DexDictate behavior.
- Lens precedence becomes nondeterministic or model-dependent.
- a destructive capability becomes reachable in V1.
- a Strand renderer materially diverges from the canonical MP4 fixtures.
- Veil layout begins auto-reordering learned positions.
- the hot path blocks on network/model work.
- tests claim behavior that has not been exercised through the real path.
- Big Mac-specific assumptions make the MacBook runtime unusable.
- an integration requires adding a prohibited runtime dependency to Pulse core.

Repair the violated invariant before proceeding to feature expansion.

## 14. Post-V1 boundary

Do not pull these into V1 unless the owner explicitly reslices scope:

- Teach DEX demonstration recording/compiler;
- user-facing Loom editor;
- Ghost Mode execution;
- DEX//PAD tablet surface;
- broad Pack marketplace/dynamic arbitrary code loading;
- destructive capability framework activation;
- autonomous background execution.

Post-V1 priority is Teach DEX + Loom because the long-term product thesis is not merely quick action invocation; it is progressive compression of repeated owner-approved workflows into inspectable Reflexes/Threads.

## 15. First implementation packet

The next coding pass after this planning commit is `docs/build-packets/PHASE-00-01-BOOTSTRAP.md`.

Do not begin by drawing the final Strand renderer. Begin by creating the reproducible native skeleton, evidence harness, environment fingerprint, global hotkey, and empty Pulse state machine. The visual system becomes valuable only after the app can invoke, resolve context, and close correctly.
