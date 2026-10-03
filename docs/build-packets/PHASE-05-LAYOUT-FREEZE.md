# Build Packet — Phase 5 Object Layout Freeze Trial

## Objective

Establish the formal **Object Layout Freeze Trial** foundation for DEX//PULSE. Phase 5 is the quality gate where provisional and experimental directional layouts are elevated to **Candidate** status (`.candidate`, version `1.0.0-candidate`), evaluated across mechanical simulations and privacy-safe trial metrics, and prepared for real owner-use evaluation.

**Authority Boundary:** Automated tests and synthetic harnesses **must never** mark any layout as `.frozen-v1`. Freezing is an explicit owner authority boundary reserved for human review and real-world habit verification.

---

## 1. Current Experimental vs. Candidate Layouts

All 11 primary V1 `ObjectClass` families have established directional slot layouts in `VeilLayoutRegistry`. In Phase 4, these layouts were classified as `.experimental` (`1.0.0-experimental`). In Phase 5, they advance to `.candidate` (`1.0.0-candidate`):

| Object Family | Object Classes | Primary Compass Slots | Status |
|---|---|---|---|
| **Text** | `selectedText`, `jsonText`, `url` | N: Explain, NE: Research, E: Transform, SE: Send, S: Keep, SW: Find Source, W: Inspect Structure, NW: Route | `1.0.0-candidate` |
| **Error Log** | `errorLog` | N: Explain, NE: Research, E: Diagnose, SE: Send (nested agent), S: Keep/Witness, SW: Find Source, W: Repair (locked), NW: Fixture | `1.0.0-candidate` |
| **Repo / Path** | `code`, `path`, `file`, `selectedFile` | N: Status, NE: Changes, E: Validate, SE: Target (nested machine), S: Keep, SW: Open/Reveal, W: Search, NW: Checkpoint (locked) | `1.0.0-candidate` |
| **UI Element** | `uiElement`, `focusedElement` | N: Inspect, NE: Explain, E: Actions, SE: Spool Reference, S: Keep Reference, SW: Parent/Context, W: Search Related, NW: Bind (placeholder) | `1.0.0-candidate` |
| **Window / App** | `window`, `application` | N: Inspect/State, NE: Windows/Tabs, E: Focus/Front, SE: Target, S: Keep Context, SW: Reveal, W: Search, NW: Quit/Dismiss | `1.0.0-candidate` |
| **Clipboard Fallback** | `clipboard` | Inherits Text family directional slots | `1.0.0-candidate` |
| **Result Object** | `result`, `machineTarget` | N: Inspect, NE: Re-run, E: Share/Export, SE: Target, S: Pin/Witness, SW: Copy/Spool, W: Diff, NW: Dismiss | `1.0.0-candidate` |

---

## 2. Candidate Layout Criteria

A directional layout qualifies for `.candidate` lifecycle only when it satisfies all of the following invariants:

1. **Semantic & Motor Coherence:**
   - Urgent/frequent actions (e.g. Explain, Status, Inspect) occupy primary cardinal positions (N, E, S, W).
   - High-consequence or secondary routing choices (e.g. Send Agent, Target Machine) occupy diagonal directions (SE) with optional nested disclosure.
   - Preserves consistency across neighboring families (e.g. N is consistently inspection/explanation, S is consistently persistence/witness).

2. **Full Directional Reachability:**
   - Every occupied slot can be armed by pointer gesture and reached by keyboard chord.
   - Neutral center allows resting and traversals without unintentional arming or dismissals.

3. **Disabled Slot Stability (INV-004 / V1-031):**
   - When a capability is disabled or locked in V1 (e.g. Repair Packet, Checkpoint), the slot retains its exact directional position (`.locked` or `.unavailable`).
   - Neighbors never slide over, collapse, or dynamically re-center.

4. **Edge & Corner Invariance (INV-034):**
   - Placement clamping at screen boundaries shifts the visual center minimally and preserves 100% of the directional relative angles from the causal center.

5. **Keyboard Equivalent Parity (INV-035):**
   - Every visible Reflex slot maps to a deterministic keyboard step or direct shortcut chord.

---

## 3. Privacy-Safe Trial Ledger Methodology

Layout performance and motor ergonomics are evaluated using an in-memory, privacy-safe ledger (`VeilLayoutTrialLedger`):

### Recorded Metrics:
- `objectClass`: Target object classification.
- `layoutVersion`: e.g. `"1.0.0-candidate"`.
- `sectorChosen`: Armed compass direction.
- `intendedDirection`: Target compass direction in trial.
- `distanceTraveledPt`: Total cumulative pointer path distance.
- `seamCrossings`: Count of sector seam traversals.
- `radialOvershootPt`: Peak radial excursion past outer radius.
- `latencyMs`: Elapsed time from presentation to arming/selection.
- `inputRoute`: `.pointer` vs `.keyboard`.
- `misfires`: Bitfield tracking wrong sector, excessive seam crossings, re-arms, or aborts.

### Strict Privacy Guarantee:
- **Zero Content Payloads:** The trial recorder strictly forbids storing selected text strings, URLs, file paths, UI element accessibility names, window titles, AX hierarchies, or clipboard bytes.
- Only geometric, temporal, and categorical telemetry is retained.

---

## 4. Non-Owner vs. Owner Validation Boundaries

| Responsibility | Automated / CI Agent Boundary | Human Owner Boundary |
|---|---|---|
| **Promotion to Candidate** | Automatically marks `.candidate` once mechanical tests pass | Confirms candidate status |
| **Reachability Simulation** | Simulates 8-direction sweeps and measures distance/seams | Evaluates hand motor feel |
| **Slot Stability Checks** | Asserts 0 reflow when slots are disabled | Assesses intuitive memory |
| **Keyboard Navigation** | Exercises all chords and traversal sequences | Verifies chord mnemonics |
| **Edge Clamping** | Verifies coordinates on screen edges and corners | Tests on multi-monitor desk |
| **Layout Freeze (`.frozen-v1`)** | **PROHIBITED** (must never freeze autonomously) | **EXCLUSIVE AUTHORITY** |

---

## 5. Candidate Freeze Checklist (Owner Review Gate)

Before any layout can be frozen (`.frozen-v1` via explicit migration/ADR):

- [ ] Autonomous mechanical trial simulation passed across all 11 object classes.
- [ ] Privacy-safe trial ledger confirms low misfire rate (< 5% seam flapping).
- [ ] Edge and corner clamping verified on physical displays.
- [ ] Keyboard chords verified conflict-free with global shortcuts.
- [ ] `docs/layout-trials/PHASE-05-OWNER-REVIEW.md` generated with ASCII compass diagrams.
- [ ] Real-world owner trials conducted on primary development machine (MacBook Air / Big Mac).
- [ ] Owner approval or explicit no-objection recorded.
