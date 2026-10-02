# DEX//PULSE Project Bible

## Product thesis

DEX//PULSE is a native macOS reflex layer that reduces the distance between recognizing intent and carrying it out. It is not an AI launcher, not a QDuo fork, and not a Starsilk application. It observes explicit local context, resolves the object being acted on, presents a stable object-class-specific directional Veil, executes a Reflex through the appropriate deterministic or model-backed capability, returns a Result Object, records structured proof through Witness, and then recedes cleanly.

The product should become more useful over time by learning only from its own approved interactions. It must not become a general surveillance system.

## V1 user and equipment

- Primary user: Andrew.
- Primary everyday/operator machine: MacBook Air M1, including command-line invocation and day-to-day Pulse use.
- Canonical development/heavy-compute machine: Big Mac.
- Big Mac and MacBook are first-class Target Objects whenever a capability can run on either.
- Safe read/inference work may automatically choose Big Mac when the capability explicitly permits it. Mutations must not silently change machine.

## Platform doctrine

- Native macOS application.
- Apple Silicon.
- macOS 14+ target unless a later explicit decision changes it.
- Swift/AppKit for event, window, pointer, Accessibility, and transient interaction control.
- Core Animation for Pulsefront, Veil geometry, labels, simple transitions.
- Metal-backed Strand renderer for the Starsilk-derived ribbon geometry.
- SwiftUI is appropriate for persistent surfaces such as settings, Loom, Witness, and management views, but is not required to own the transient hot path.
- Pulse itself must not require Karabiner, Hammerspoon, Docker, a browser extension, Python, Node, or another application runtime.

## Locked interaction model

### Context precedence

Lens resolves primary context in this order:

1. explicit selected text or selected file;
2. UI element under the pointer;
3. focused Accessibility element;
4. frontmost window/application;
5. clipboard fallback.

A normal Pulse invocation over a UI control automatically treats that control as the primary object when no explicit selected text/file overrides it.

### Object grammar

`Object -> Reflex -> optional Target -> Result Object`

Result Objects are actionable objects and can become the origin of another Pulse operation.

### Directional layouts

Each recognized object class owns a stable directional layout. There is no universal eight-verb wheel and no AI-reordered wheel. The initial mappings may be tuned during the pre-freeze usability gate, but once a V1 object-class layout is frozen, Pulse must not silently move learned Reflexes.

### Ghost Mode

Ghost Mode is architecturally supported but disabled in V1 until the visible Veil interaction has been proven reliable enough to preserve motor memory without accidental execution.

### Spool

The normal Spool is memory-only and disappears on application restart/login. A user may explicitly pin an object. Pinned objects persist durable references rather than unnecessary copies. If content itself is the only durable representation, persistence is allowed only because the user explicitly pinned it.

### Results

Result Objects are transient by default. KEEP/pin/project attachment can make them durable. Witness records structured execution proof and metadata, not automatically every result payload.

### Closing behavior

The V1 magic loop ends by closing cleanly: after Result Object and Witness proof are established, the transient interaction RECEDEs back to QUIET. RECEDE is the semantic state; DISSOLVE may be used as a rendering primitive.

## DEX ecosystem doctrine

PulseKit is a capability registry from day one. DEX//REACH, Ollama, Git/GitHub, DexGate, DexSpeak, DexDiffusion, DexSprite, DexEnhance, DexCast, and other DEX tools integrate as Packs/adapters rather than becoming hard-coded core logic.

A Pack declares capabilities and constraints. Pulse core decides applicability and policy; the Pack performs its bounded work.

V1 does not need every DEX Pack complete before the vertical slice. The architecture must allow them without redesigning core.

## Execution doctrine

1. deterministic/native logic first;
2. local model inference when judgment is needed;
3. remote/frontier execution only when an explicitly enabled capability requires it.

Users invoke tasks, not model brands. Model/provider selection is an executor detail unless the user explicitly chooses a Target.

## Permissions and destructive behavior

V1 has no executable destructive capability at all.

The risk type may exist in the schema for future compatibility, but V1 adapters must not expose recursive deletion, force reset/push, irreversible overwrite, privilege-changing system mutation, or an equivalent destructive action.

Unknown downloaded shell scripts must route through DexGate before Pulse ever gains an execution route for them. This does not imply V1 executes them afterward.

## DexDictate priority

DexDictate takes priority whenever Pulse and DexDictate could interfere.

Pulse must not steal focus, selection, clipboard state, or trigger behavior from DexDictate. Opening Pulse must not mutate the clipboard. Pulse must coexist with DexDictate's Accessibility insertion, focused-element identity verification, browser Accessibility behavior, clipboard preservation, and undo semantics.

Future integration is allowed; V1 assumes separate applications with explicit coexistence guards.

## Privacy and retention

- No telemetry by default.
- No continuous screen recording.
- OCR capture is explicit.
- Habit learning records Pulse interactions, not raw ambient activity.
- Habit aggregates are content-free: capability IDs, object classes, project IDs where appropriate, targets, timing, success/failure, and sequence frequency.
- Habit aggregate retention default: 180 days unless later changed.
- Witness structured execution records default to rolling 30-day retention unless pinned/project-required.
- Raw sensitive payloads, selected text, command output, and diffs are omitted or short-lived unless the user explicitly preserves them.

## Starsilk boundary

DEX//PULSE is a DEX product, not an in-universe Starsilk application.

Starsilk contributes the causal visual grammar: azure barcode-ribbon Strands, obsidian field, structural motion, threading, branching, crossings, and deliberate execution topology. The exported vocabulary approved for Pulse is:

- Strand
- Thread
- Loom
- Witness
- Veil
- Lens
- Spool

Do not casually import canon-loaded terms such as Starbinding, Blood Ring, Siege Wall, Drakken strain, or other lore labels as UI flavor.

A Strand is not alive, not sentient, not smoke, not lightning, and not generic glowing magic. It visually represents a real causal relationship in the product.

## Visual authority

The four original uploaded MP4 files under `fixtures/visual-references/original/` are the highest visual authority for Strand material and motion. Contact sheets are convenience derivatives, not replacements for the videos.

Visual must-haves:

- ribbon, not wire;
- variable apparent width caused by 3D twist;
- transverse barcode segmentation across the ribbon surface;
- clear face/edge/underside behavior;
- restrained cyan/azure bloom;
- black/obsidian field;
- crossings remain visually separable;
- crossing does not imply semantic joining;
- semantic junctions are explicit;
- motion is controlled and tensioned, never writhing or chaotic.

## Sensory policy

During development, supported visual motion, subtle sound cues, and restrained haptics default on. Reduced Motion must preserve the same semantic information without relying on travel animation.

Sound must remain extremely subtle and optional. There is no ambient soundtrack or sci-fi chatter.

## V1 holy-shit milestone

A real V1 vertical slice exists when the user can:

1. create explicit context anywhere in a supported app;
2. invoke Pulse with the native global hotkey;
3. see the Pulsefront and Veil appear at the correct interaction origin without waiting for AI;
4. have Lens resolve the correct object using the locked precedence;
5. see the object's stable directional Reflex layout;
6. select a real Reflex;
7. optionally choose a relevant Target such as MacBook or Big Mac;
8. execute through a real executor;
9. receive a Result Object;
10. inspect Witness proof;
11. let the interaction RECEDE cleanly back to QUIET;
12. repeat the entire path without focus, clipboard, DexDictate, or performance regressions.

## V1 non-goals

- Teach DEX demonstration compilation;
- user-authored Loom editor;
- DEX//PAD tablet UI;
- Ghost Mode execution;
- broad third-party plugin marketplace;
- destructive actions;
- continuous screen/activity capture;
- autonomous background agents acting without explicit Pulse policy;
- perfect integration with every DEX app before core interaction correctness exists.

## Post-V1 product truth

Teach DEX is a first major post-V1 feature and is important enough that the product is not considered strategically complete without it. It is intentionally deferred so V1 can prove the deterministic interaction/execution foundation first.
