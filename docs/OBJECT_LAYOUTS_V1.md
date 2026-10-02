# DEX//PULSE V1 Object Layout Registry — Planning Source

## Status

**Provisional until Phase 5 layout-freeze gate.**

Each recognized object class gets a stable directional layout. Pulse must not use a universal eight-verb wheel and must not AI-rank actions into moving positions. The registry may be tuned before freeze using real owner usage; after freeze, directional changes require an explicit migration/ADR.

## Layout principles

- Put the most frequent/urgent object-specific Reflexes one gesture away.
- Same conceptual Reflex may occupy different direction across classes only when the class-specific motor model is clearer; prefer consistency when it does not damage frequency.
- Unavailable capabilities preserve position and explain availability in browse/debug mode; do not collapse neighbors into the vacated slot after freeze.
- More than ~7 immediate choices should move to nested/search disclosure rather than thinner slices.
- Targets are a second ring only when a Reflex actually requires/benefits from one.

## Provisional mappings

These are hypotheses, not locked product behavior.

### Error / log

| Direction | Reflex |
|---|---|
| N | Explain |
| NE | Research evidence |
| E | Diagnose |
| SE | Send to agent |
| S | Keep/Witness |
| SW | Find source |
| W | Repair packet (non-executing in early V1) |
| NW | Regression fixture |

### Repository / project / path

| Direction | Reflex |
|---|---|
| N | Status / Inspect |
| NE | Recent changes |
| E | Validate/read checks |
| SE | Target / send |
| S | Keep/project context |
| SW | Open/reveal |
| W | Search source |
| NW | Checkpoint reserved for later bounded-write policy; read-only alternative during early V1 |

### UI element

| Direction | Reflex |
|---|---|
| N | Inspect element |
| NE | Explain control/context |
| E | Supported AX actions (informational) |
| SE | Add reference to Spool |
| S | Keep reference |
| SW | Parent/context |
| W | Related element/search |
| NW | Bind/suggest Reflex (post-V1 placeholder) |

V1 does not auto-execute `AXPress` merely because the control supports it.

### Text

| Direction | Reflex |
|---|---|
| N | Explain |
| NE | Verify/research |
| E | Transform/refine |
| SE | Send |
| S | Keep/Spool |
| SW | Open/find source when applicable |
| W | Inspect structure |
| NW | Route to best executor |

### Image/file

| Direction | Reflex |
|---|---|
| N | Inspect metadata |
| NE | Enhance/visual capability if Pack exists |
| E | Convert/asset capability if Pack exists |
| SE | Send/target |
| S | Spool/Keep |
| SW | Reveal/open |
| W | Related/project use |
| NW | Variant/generate capability if Pack exists |

## Freeze evidence

Before a class moves from `provisional` to `frozen`, record:

- at least 20 real invocations or a deliberate owner review if frequency is naturally lower;
- misfire/overshoot notes;
- repeated actions not represented;
- direction conflicts with neighboring classes;
- edge-screen usability;
- keyboard equivalent;
- owner approval or explicit no-objection after review.
