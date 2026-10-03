# Build Packet — Phase 4 Veil Interaction Engine

## Objective

Replace the rectangular Phase 3 debug surface with the first real DEX//PULSE **Veil interaction engine**. The Veil is a transient spatial control centered on a causal origin. It provides real annular geometry where visible paths match hit testing, stable per-object-class directional mappings, pointer hysteresis, overshoot tolerance, nested Reflex/Target disclosure, edge-aware placement preserving causal origin, multi-monitor coordinate correctness, keyboard-equivalent navigation without focus theft, non-activating AppKit presentation, and clean recede/cancellation behavior.

This phase builds the interaction substrate; it does not build the final Phase 6 canonical Strand ribbon aesthetic or Metal shaders.

## Scope

1. **Pure Geometry Model (`VeilGeometry`):**
   - Single source of truth for drawing paths, hit testing, debug overlay, and accessibility boundaries.
   - Annular sector model: causal center, inner radius, outer radius, angular start, angular end, compass direction, overshoot envelope.
   - Neutral center: hollow center (inner radius) preserves tracking without accidental dismissal or action trigger.
   - Centralized tuning tokens: radial overshoot forgiveness (16 pt, range 12–20 pt) and angular seam hysteresis (6°, range 5–8°).
   - Dense parity test between `CGPath` rendering and mathematical hit testing.

2. **Compass-Direction Model & Object Layout Registry (`VeilLayoutRegistry`):**
   - 8 stable cardinal and diagonal directions: N, NE, E, SE, S, SW, W, NW.
   - Typed registry keyed by `ObjectClass` covering all recognized V1 object classes.
   - Provisional mappings derived from `docs/OBJECT_LAYOUTS_V1.md`.
   - Layout lifecycle: explicitly `experimental` (Phase 5 owns layout freeze).
   - Invariant: Zero AI ranking, zero motor reflow, disabled/unavailable slots retain stable positions.

3. **Reflex Descriptors for Phase 4:**
   - Representation of stable ID, display label, compass direction, presentation state (`enabled`, `unavailable`, `locked`), optional nested Target choices, and keyboard hints.
   - Emits semantic interaction events (`VeilSelection`) and advances state machine without invoking external CLI/model executors.

4. **Annular Hit Testing & Pointer Lifecycle (`VeilPointerTracker`):**
   - True annular sector hit testing: inner boundary, outer boundary, angular seams, wraparound across 0°.
   - Pointer tracking exists strictly while Veil is visible (zero ambient surveillance during `QUIET`).
   - Seam hysteresis prevents fluttering; radial overshoot maintains selection during fast movements.
   - Smooth traversal from center through inner radius with no dead gap.
   - ATTUNE state machine integration on stable sector acquisition.

5. **Nested Reflex / Target Disclosure:**
   - Secondary outer ring expands outward from parent sector when Reflex has nested targets or choices.
   - Outer hit envelope expands only while nested disclosure is active; smooth retraction to main ring on backing out.
   - Preserves parent direction and causal path.

6. **Placement Planner & Multi-Monitor Support (`VeilPlacementPlanner`):**
   - Separate `causalOrigin` from `veilCenter`.
   - Smallest necessary shift to keep annular ring inside visible screen frame (excluding menu bar and Dock).
   - Does not teleport to screen center, mirror directions, or rotate compass mappings.
   - Multi-monitor correctness: supports non-zero and negative screen origins, differing display bounds, and backing scales.

7. **Non-Activating AppKit Presentation (`VeilWindow` / `VeilView`):**
   - Borderless, transient `NSPanel` (`nonactivatingPanel`).
   - Does not become key or main; preserves frontmost application focus, selection, and clipboard.
   - Transparent window corners and hollow center pass through clicks without swallowing background interactions.
   - Local Escape and keyboard route dismiss cleanly through `RECEDE -> QUIET`.

8. **Keyboard-Equivalent Route (`VeilKeyboardNavigator`):**
   - Deterministic keyboard route for every visible action without focus theft or global keyboard interception.
   - Step previous/next sector, enter nested ring, back out to parent, select/activate, cancel.

9. **Debug Geometry Mode:**
   - Inspectable visual overlay displaying causal origin, visual center, inner/outer radii, overshoot boundaries, sector seams, candidate/armed sectors, hysteresis margin, and nested rings.

10. **Reduced Motion Foundation:**
    - State changes, selections, nested disclosures, and cancellations communicate immediately and intelligibly without requiring animated geometry.

## Protected Invariants

- **INV-001 (DexDictate Priority / Focus & Clipboard Non-Theft):** Veil presentation and dismissal must never steal focus, activate the panel as key/main, collapse source selection, or mutate clipboard contents.
- **INV-002 (Central Policy & Non-Destructive Execution):** Selecting a Reflex emits an interaction event without triggering destructive or unauthorized capability execution.
- **INV-003 (Deterministic Precedence & Invocation Safety):** Invocation context resolves through Lens precedence before Veil presentation.
- **INV-006 (Core Runtime Independence):** Zero external dependencies; native Swift and AppKit.
- **INV-007 (State Machine Causal Convergence):** Cancellation or Escape cleanly converges through `RECEDE -> QUIET`.
- **V1-030 (Registry Coverage Foundation):** Every recognized object class maps to a registered layout.
- **V1-031 (Slot Stability):** No usage-learning or AI-ranking reorders directional slots.
- **V1-032 (Visible Geometry == Hit Geometry):** Visible drawing paths and mathematical hit testing share one identical geometry model.
- **V1-033 (Hysteresis & Overshoot):** Bounded radial overshoot and angular hysteresis prevent trivial flapping.
- **V1-034 (Edge & Corner Placement):** Screen-edge adjustments preserve causal origin and compass mappings.
- **V1-035 (Keyboard Route):** Every visible action has a deterministic keyboard path.

## Performance Constraints

- Zero model/network work before Veil presentation.
- Zero polling or active render loops while `QUIET`.
- Renderer and pointer tracking exist only while Veil is visible.
- Local, deterministic geometry calculations (O(1) sector evaluation).
- No repeated expensive Accessibility queries during pointer sweeps.

## Validation Plan

1. **Unit Tests (`Tests/PulseInteractionTests`):**
   - Cardinal and diagonal sector boundary math and 0° wraparound.
   - Inner radius, outer radius, outside, and neutral center boundaries.
   - Path geometry vs mathematical hit test dense parity test.
   - Radial overshoot and angular seam hysteresis synthetic pointer sweeps.
   - Layout registry completeness and determinism across all V1 `ObjectClass` values.
   - Screen-edge placement planner: edges, corners, and multi-monitor setups (positive and negative origins).
   - Keyboard navigation completeness for 4-slot, 6-slot, 8-slot, and nested layouts.
   - Window hit-test masking: clicks in transparent corners and neutral center pass through.
2. **Headless Verification Runner (`PulseVerification`):**
   - Automated assertions for geometry parity, registry stability, placement planner, and keyboard coverage.
3. **Live AppKit Probes:**
   - TextEdit, Brave, Terminal runtime sweeps confirming focus non-theft, clipboard preservation, and clean recede.

## Exit Criteria

- All unit tests pass across `PulseCoreTests`, `PulseLensTests`, `PulseKitTests`, `PulseVerificationTests`, and `PulseInteractionTests`.
- `PulseVerification` passes all automated checks including Phase 4 assertions.
- `make check` passes all verification stages cleanly.
- `make app` builds and signs the release application bundle.
- Operational State updated to Revision 11 recording experimental registry state, geometry evidence, edge/corner proof, and multi-monitor test status.

## Stop Conditions

- Visible sector geometry and hit testing cannot share one single mathematical source of truth.
- Veil panel requires becoming key or main window to receive pointer interactions.
- Keyboard navigation requires global keystroke interception or new privacy permissions.
- Pointer tracking continues while `QUIET`.
- Screen-edge adaptation rotates or mirrors compass mappings.
- Clipboard or focus non-theft invariants regress.
