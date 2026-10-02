# DEX//PULSE Interaction Model

## Primary loop

`QUIET -> PULSE -> LENS -> VEIL -> ATTUNE -> STRAND -> optional FORK/Target -> policy -> DISPATCH -> WEAVE -> RETURN -> WITNESS -> RESOLVE -> RECEDE -> QUIET`

Failures branch through `FRAY` or `SEVER` and remain actionable long enough to inspect/retry/dismiss.

## Invocation origin

The origin is the user's real interaction point whenever meaningful:

- pointer position for contextual invocation;
- selected object's bounds/center when robust geometry exists;
- fallback to pointer position when selection geometry is unknown.

The Veil must not teleport to an unrelated screen location merely to fit perfectly. Clip/shift only as required to keep essential controls operable, preserving obvious causal origin.

## Lens precedence

Locked:

1. explicit selected text/file;
2. UI element under pointer;
3. focused AX element;
4. frontmost window/app;
5. clipboard fallback.

Opening Pulse does not issue Cmd-C or mutate the clipboard.

## Object-specific Veil

There is no universal set of eight verbs.

Each object class has a stable layout schema. Applicability filters can disable/hide irrelevant Reflexes, but learned slots cannot be silently reordered.

### Layout lifecycle

- `experimental`: direction mapping may change during Phase 4 testing;
- `candidate`: mapping used in daily testing but not frozen;
- `frozen-v1`: layout cannot move without explicit decision/migration.

Habit learning may suggest pinning/promotion but never silently relocate an existing learned action.

## UI elements

UI elements are first-class V1 objects. Pulse may inspect any accessible element, but executable activation must pass policy.

Safe rule:

- inspect/copy metadata/describe/spool are allowed if privacy-safe;
- `AXPress` is exposed only when the element is classified safe and non-consequential;
- ambiguous/destructive-looking elements do not receive a generic Press capability in V1.

## Behavioral geometry

- visible annular sectors use matching annular hit tests;
- pointer travel from origin into Veil has no dead gap;
- sector selection uses hysteresis/overshoot tolerance;
- nested Reflex/Target disclosure preserves the origin and path;
- cancellation target remains reachable by pointer and keyboard;
- Escape always provides a safe cancel/dismiss path when no OS restriction prevents it.

Initial tuning targets (not immutable):

- 12–20 pt radial overshoot forgiveness;
- 5–8 degrees sector seam hysteresis after ATTUNE;
- no instantaneous sector flipping from minor tremor.

## Persistent tap vs gesture

V1 initially prioritizes visible, inspectable interaction.

Potential gesture grammar can be implemented behind feature flags, but Ghost Mode execution remains disabled until visible Veil reliability is proven and layouts are frozen.

## Policy communication

User-facing policy states:

- `GO` — capability can execute within current V1 policy;
- `ASK` — explicit confirmation/input required;
- `LOCKED` — execution unavailable by policy/configuration.

V1 destructive capability remains LOCKED structurally because no executor route exists.

## Long work

A Reflex must expose cancellation semantics and whether it may continue after the Veil is dismissed. Default is conservative: transient interaction does not imply permission for an unbounded background agent.

## Result Objects

Results appear as actionable Anchors/cards near the causal path. A Result can be pulsed again, pinned, kept, sent, or dismissed depending on applicable capabilities.

## Witness

Witness proof must be one action away from a Result. It should answer:

- what ran;
- on which machine/target;
- which object/reflex produced it;
- whether it succeeded;
- what evidence exists;
- what is not proven;
- whether there is a recovery/cancel path.

## Recede

Recede is the normal closing state.

Rules:

- Veil becomes non-interactive before disappearing;
- transient controls leave before the final causal/result anchor;
- no reverse-bounce animation;
- pending explicit background work is represented separately if it continues;
- Pulse Point extinguishes last;
- focus returns to the original application/element when possible and appropriate;
- clipboard remains unchanged unless an executed Reflex explicitly and visibly changed it.
