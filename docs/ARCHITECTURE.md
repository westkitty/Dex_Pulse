# DEX//PULSE Architecture

## Architectural thesis

Pulse is a native contextual operating layer. The architecture must keep the transient interaction hot path deterministic and fast while allowing richer executors to live behind a typed capability boundary.

The core data flow is:

`Trigger -> ContextEnvelope -> Object resolution -> applicable Reflexes -> optional Target -> Policy -> Executor -> ResultObject -> WitnessReceipt -> Recede`

## Process and module boundaries

Recommended V1 package shape:

```text
DEXPulse.app
├── PulseApp                  application lifecycle / menu bar / settings entry
├── PulseInput                global hotkey, pointer origin, invocation state
├── PulseLens                 Accessibility/context acquisition + object classification
├── PulseObjects              typed object model
├── PulseKit                  capability/Reflex/Target registry + policy metadata
├── PulseVeil                 transient radial interaction + behavioral geometry
├── PulseStrands              Metal ribbon renderer and visual state model
├── PulseExecution            executor orchestration, cancellation, result routing
├── PulseWitness              receipts, proof metadata, retention
├── PulseSpool                transient multi-object carry + explicit pin references
├── PulseHabits               content-free interaction aggregates/suggestions
├── PulsePacks                bounded adapters
└── PulseSupport              settings, logging, performance signposts, shared utilities
```

Prefer Swift Package targets/libraries with one application target rather than one giant app module. Do not create dynamic plugin loading in V1 unless a concrete consumer requires it; compiled Pack adapters can implement the same protocol first.

## Framework allocation

### AppKit
Own:

- transient windows and overlay placement;
- pointer coordinates and display geometry;
- Accessibility acquisition;
- global hotkey plumbing;
- focus-aware interaction;
- menu bar/app lifecycle;
- event routing where low-level control is required.

### Core Animation
Own:

- Pulse Point;
- Pulsefront;
- Veil sectors and transitions;
- text/icon opacity and transforms;
- lightweight state changes;
- non-Strand transient effects.

### Metal
Own only canonical Strand rendering that needs a real ribbon surface:

- sampled ribbon geometry;
- twist/orientation;
- apparent-width changes;
- transverse barcode surface pattern;
- face/underside shading;
- crossing/depth ordering;
- restrained bloom;
- encoded packet motion.

No permanent Metal render loop while QUIET.

### SwiftUI
Appropriate for persistent, lower-frequency surfaces:

- settings;
- Pack management;
- Witness history;
- future Loom editor;
- accessibility/preferences;
- debug tools.

Do not let SwiftUI convenience override hot-path interaction correctness.

## Concurrency and ownership

Use Swift structured concurrency with explicit ownership rather than detached background work. Recommended ownership boundaries:

- `PulseStateStore` / interaction state: `@MainActor`;
- Accessibility acquisition: bounded service/actor that returns immutable snapshots;
- capability registry/policy: actor or Sendable immutable descriptors;
- execution coordinator: actor owning run IDs, cancellation, deadlines, and concurrency classes;
- Witness/storage: actor with transactional writes and schema migration;
- Metal renderer state: render-owned immutable frame snapshots prepared without blocking input handling.

No shell, model, network, Git traversal, database maintenance, or Pack availability probe may block the main actor. AX calls that must run on the main thread are narrowly bounded and measured.

## Trigger subsystem

V1 provides a configurable native global hotkey. Current provisional default: `Shift-Command-Space`.

Requirements:

- no Karabiner/Hammerspoon dependency;
- hotkey change UI must detect obvious conflicts when possible;
- invocation is event-driven;
- no polling loop;
- trigger lifecycle cannot interfere with DexDictate.

Implementation choice (Carbon registration vs another native mechanism) is an implementation decision to prove during Phase 1. Select the mechanism with lowest latency/permission burden on macOS 14+ and keep it behind `GlobalHotKeyProviding`.

## Lens acquisition pipeline

The acquisition stage returns candidates with provenance rather than one unexamined string.

```text
ContextEnvelope
├── invocation origin
├── timestamp
├── pointer location
├── frontmost application identity
├── explicit selection candidates
├── AX element under pointer
├── focused AX element
├── frontmost window/app object
├── clipboard fallback candidate
└── acquisition diagnostics
```

Primary selection follows locked precedence. Lower-priority candidates may remain available as secondary context or be added to Spool, but they cannot silently override the primary object.

Accessibility reads must avoid secure-field leakage.

## Classification pipeline

1. native deterministic object construction from source/provenance;
2. deterministic refiners (UTType, URL parser, file metadata, Git/repo detection, JSON/code/error heuristics);
3. optional local classifier only for ambiguity;
4. never block Veil appearance on model classification.

A classifier may refine `TextSelection` into `ErrorLog`, `CodeSnippet`, `URL`, etc., but must preserve the source object and confidence/provenance.

## PulseKit registry

PulseKit owns typed capability discovery. It must not own provider-specific execution details.

A capability declares:

- stable ID and schema version;
- accepted object types;
- optional Target types;
- sector/directional layout metadata per object class;
- risk class;
- required permissions/resources;
- executor ID;
- expected Result type;
- whether cancellation is supported;
- validation/proof contract;
- latency/compute hints;
- locality constraints.

The registry returns applicable Reflexes synchronously from known metadata. AI must not be required merely to decide which registered capability accepts a file or URL.

## Executors

V1 executor families:

- `NativeExecutor` — local OS/file/app actions that are explicitly safe;
- `ShellExecutor` — bounded allowlisted commands generated/owned by Pulse code, never arbitrary selected shell by default;
- `OllamaExecutor` — local model requests through an explicit endpoint configuration;
- `GitExecutor` / `GitHubPack` — safe read/status/search routes first;
- future `DEXReachPack`, `DexGatePack`, and other DEX adapters after their standalone IPC contracts are proven.

No V1 executor may expose a destructive action.

## Machine Targets

`MacBook` and `Big Mac` are Target Objects. A capability may advertise supported Targets and locality preference.

Safe inference/read work may choose Big Mac automatically only when:

- capability declares remote-safe;
- Big Mac is available;
- there is no user override;
- the operation has no mutation semantics;
- the resulting Witness receipt records the chosen machine.

Mutation never silently changes machine.

## Result Objects

Executors return a typed Result Object plus a structured execution result. Result Objects remain actionable.

A Result must not be confused with proof. Witness decides which claims were actually observed/verified.

## Permission and stale-context boundary

Accessibility/Input Monitoring permission is a product state, not a crash condition. On denied/revoked permission, Lens exposes the highest safe lower-fidelity object and a clear setup/recovery action. Reauthorization never silently replays a previously blocked Reflex. Live AX objects are revalidated immediately before execution.

## Cancellation and recede

Execution state is separate from overlay lifetime. A long-running task may continue only when the user explicitly permits background completion; otherwise dismissal cancels the bounded operation when cancellation is supported.

Fast V1 path: Result and Witness appear, then user dismisses or configured auto-recede occurs. Recede never destroys a pinned Result or still-running explicitly retained task.

## Storage

Use Application Support for durable product data and user configuration. Suggested stores:

- settings/preferences;
- pinned object references/bookmarks;
- 30-day Witness metadata store;
- 180-day content-free habit aggregate store;
- Pack configuration and model/machine identifiers.

Do not persist Spool transient state across app restart/login.

## Logging

Local debug logs must avoid selected text/payload contents by default. Log stable IDs, timings, object types, state transitions, executor outcomes, and explicit redacted diagnostic fields.

## Design rule

Every additional abstraction must have either a V1 consumer or a clear compatibility need forced by an approved Pack boundary. Do not build a speculative plugin platform before the vertical slice works.
