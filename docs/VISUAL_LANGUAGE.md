# DEX//PULSE Visual and Motion Language

## Authority

Highest visual authority, in order:

1. original MP4 fixtures under `fixtures/visual-references/original/`;
2. this document;
3. accepted motion/interaction ADRs;
4. contact sheets under `fixtures/visual-references/contact-sheets/`;
5. external inspiration.

The contact sheets are convenience views only. They cannot substitute for temporal review of the videos.

## Starsilk boundary

DEX//PULSE is not an in-universe Starsilk application. It exports a bounded causal/visual grammar from Starsilk into a DEX product. Do not imply that the real-world application is literally using the cosmological substance.

Approved product vocabulary: `Strand`, `Thread`, `Loom`, `Witness`, `Veil`, `Lens`, `Spool`.

Do not use canon-loaded terms such as Starbinding, Blood Ring, Siege Wall, or Drakken strain as decorative UI names.

## Strand truth

A Strand is a live visual representation of a real causal relationship in Pulse. A Strand must never be decorative filler.

### Required geometry

- A Strand is a ribbon, not a stroked wire.
- The ribbon follows a tensioned spline.
- Twist changes apparent width and exposes face/edge/underside.
- The ribbon surface carries transverse barcode-like segmentation.
- Segments vary in width and spacing; do not use a perfectly uniform ladder pattern.
- Azure/cyan face is brightest; underside/edge reads darker blue.
- Glow is restrained and subordinate to the surface.
- Over/under crossings remain legible.
- A crossing never means semantic joining.
- Semantic joining requires an explicit junction/topology node.
- Motion is controlled and deliberate, not chaotic or organic.

### Forbidden treatments

Do not render a Strand as:

- lightning;
- smoke;
- liquid neon;
- a living tentacle or vine;
- a particle fountain;
- a fuzzy volumetric beam;
- generic sci-fi fiber optics;
- a wavy line with a glow filter;
- background decoration with no product meaning.

## Canonical renderer approach

Use a dedicated `PulseStrandRenderer` backed by Metal/CAMetalLayer for V1 canonical Strands.

Pipeline concept:

`center spline -> sampled ribbon mesh -> local frame/orientation -> twist -> variable apparent width -> barcode material -> azure face/dark underside -> bounded bloom -> composited overlay`

The main app remains native AppKit/Core Animation. Metal is isolated to the Strand surface and exists only while needed; QUIET must not retain a permanent render loop.

## Pulsefront

The Pulsefront is the signature invocation wave. It belongs to the same product language but is not literally a Strand bent into a circle.

Target initial spec:

- origin radius: 12 pt;
- final radius: approximately 260 pt, clipped naturally by screen edges;
- duration: approximately 420 ms;
- primary opacity: 0.18 -> 0;
- stroke: 1.4 pt -> 0.55 pt;
- edge softness increases as radius expands;
- easing: fast propagation, soft dissipation (`0.16, 1.0, 0.30, 1.0` class curve);
- one secondary echo may begin roughly 72 ms later at much lower opacity;
- never more than two wavefronts.

The leading edge may include extremely subtle segmented structure, but it must read first as a faint transparent radio-like propagation wave.

## Motion state vocabulary

- `QUIET` — no transient Pulse UI active.
- `PULSE` — invocation acknowledged and Pulsefront propagates.
- `VEIL` — contextual directional interface becomes available.
- `ATTUNE` — pointer/focus commits toward a candidate Reflex.
- `STRAND` — causal connection becomes visible.
- `FORK` — path exposes multiple valid descendants or Targets.
- `HOLD` — explicit user input/approval is required.
- `DISPATCH` — work leaves the Veil toward an executor.
- `WEAVE` — active work is progressing.
- `RETURN` — result comes back into user context.
- `WITNESS` — execution proof/receipt is available.
- `RESOLVE` — successful terminal state is stable.
- `FRAY` — partial/degraded outcome requires recovery or qualification.
- `SEVER` — failed, cancelled, blocked, or definitively unavailable path.
- `RECEDE` — transient UI leaves the workspace and returns to QUIET.

`DISSOLVE` is a rendering technique, not the semantic closing state.

## Strand state semantics

### Sequential
`A -> B -> C`

### Parallel
A visible junction forks into independently readable children. Children never appear from unrelated coordinates.

### Conditional
Use an explicit branch/junction and label conditions; do not encode meaning by color alone.

### Dispatch
A short rectangular barcode packet may travel along a Strand. Do not use glowing orbs.

### Weave
Long work moves encoded packets through a stable Strand; the entire Strand should not constantly slither.

### Witness
A small proof marker attaches to a completed causal path and opens the corresponding structured receipt.

### Fray
A satellite portion separates slightly or segment timing loses strict alignment while the core remains readable. Never randomize into noise.

### Sever
Cut the Strand at the failure point using a crisp squared termination. The failure point remains actionable.

### Recede
The Veil leaves first; remaining causal structure collapses/retracts toward the resolved Result/Witness relationship; Pulse Point extinguishes last. Do not merely play the entrance animation backward.

## Veil geometry principles

- Interaction origin must stay causally connected to the invocation point.
- Hit geometry must match visible annular/sector geometry.
- No rectangular hitboxes behind visibly curved sectors.
- Small pointer overshoot should not instantly dismiss the interface.
- Contextual object classes may have different directional mappings, but each class's frozen layout must remain stable.
- Nested disclosure must preserve spatial origin and backtracking.

## Reduced Motion parity

Reduce Motion does not remove state meaning.

- Pulsefront: static halo rather than traveling wave.
- Strand: appears immediately rather than drawing/traveling.
- Dispatch/Return: target/source contrast and status changes replace moving packets.
- Weave: static progress/barcode state.
- Sever: immediate squared cut.
- Witness/Result: explicit icon/text state.

## Sensory cues

During development, supported motion/haptics/subtle audio default on. Audio is intentionally minimal:

- invocation: optional short low-volume transient;
- resolve: optional tiny high harmonic;
- sever: optional dry clipped tick.

No ambient hum, soundtrack, or sci-fi chatter.

## Visual acceptance gate

The renderer is not accepted from code review alone. Acceptance requires:

1. deterministic capture scenes showing single ribbon, twist edge-on, high-curvature path, crossing, semantic junction, dispatch packet, sever, and recede;
2. comparison against all original video fixtures at native scale and enlarged review scale;
3. no wire-like collapse at ordinary UI widths;
4. barcode segmentation remains legible without moire or shimmering at 60/120 Hz;
5. crossing order remains readable;
6. glow does not erase geometry;
7. reduced-motion state remains semantically complete.
