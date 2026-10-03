# Build Packet — Phase 5 Object Layout Freeze Trial

## Objective

Establish the formal **Object Layout Freeze Trial** foundation for DEX//PULSE. Phase 5 is the quality gate where provisional and experimental directional layouts are evaluated across mechanical simulations and privacy-safe trial metrics, elevated to **Candidate** status (`.candidate`, version `1.0.0-candidate`) where justified by governing planning source (`docs/OBJECT_LAYOUTS_V1.md`), or held in `.experimental` (`1.0.0-experimental`) pending owner decision, and prepared for real owner-use evaluation.

**Authority Boundary:** Automated tests and synthetic harnesses **must never** mark any layout as `.frozen-v1`. Freezing is an explicit owner authority boundary reserved for human review and real-world habit verification via an explicit source code change and ADR/migration record.

---

## 1. Candidate vs. Experimental Layouts

Governing source `docs/OBJECT_LAYOUTS_V1.md` defines 5 provisional families. Classes covered by these families or with declared inheritance advance to `.candidate` (`1.0.0-candidate`). Ambiguous classes not defined in governing source remain `.experimental` (`1.0.0-experimental`) as `OWNER DECISION REQUIRED`:

| Object Family | Object Classes | Lifecycle / Version | Source Authority | Status |
|:---|:---|:---:|:---|:---:|
| **Text** | `selectedText` | `.candidate` (`1.0.0-candidate`) | `docs/OBJECT_LAYOUTS_V1.md: Text` | Candidate for Owner Review |
| **Error / log** | `errorLog` | `.candidate` (`1.0.0-candidate`) | `docs/OBJECT_LAYOUTS_V1.md: Error / log` | Candidate for Owner Review |
| **Repository / project / path** | `repository`, `path` | `.candidate` (`1.0.0-candidate`) | `docs/OBJECT_LAYOUTS_V1.md: Repository / project / path` | Candidate for Owner Review |
| **UI element** | `uiElement`, `focusedElement` | `.candidate` (`1.0.0-candidate`) | `docs/OBJECT_LAYOUTS_V1.md: UI element` | Candidate for Owner Review |
| **Image / file** | `image`, `file`, `selectedFile`, `fileSet` | `.candidate` (`1.0.0-candidate`) | `docs/OBJECT_LAYOUTS_V1.md: Image/file` | Candidate for Owner Review |
| **Ambiguous: Code** | `code` | `.experimental` (`1.0.0-experimental`) | None (unresolved in source) | **OWNER DECISION REQUIRED** |
| **Ambiguous: URL** | `url` | `.experimental` (`1.0.0-experimental`) | None (unresolved in source) | **OWNER DECISION REQUIRED** |
| **Ambiguous: JSONText** | `jsonText` | `.experimental` (`1.0.0-experimental`) | None (unresolved in source) | **OWNER DECISION REQUIRED** |
| **Ambiguous: Window** | `window` | `.experimental` (`1.0.0-experimental`) | None (unresolved in source) | **OWNER DECISION REQUIRED** |
| **Ambiguous: Application** | `application` | `.experimental` (`1.0.0-experimental`) | None (unresolved in source) | **OWNER DECISION REQUIRED** |
| **Ambiguous: Clipboard** | `clipboard` | `.experimental` (`1.0.0-experimental`) | None (unresolved in source) | **OWNER DECISION REQUIRED** |
| **Ambiguous: Result** | `result` | `.experimental` (`1.0.0-experimental`) | `docs/INTERACTION_MODEL.md` (Result hold) | **OWNER DECISION REQUIRED** |
| **Ambiguous: MachineTarget** | `machineTarget` | `.experimental` (`1.0.0-experimental`) | None (unresolved in source) | **OWNER DECISION REQUIRED** |

---

## 2. Candidate Layout Criteria

A directional layout qualifies for `.candidate` lifecycle only when it satisfies all of the following invariants:

1. **Source Justification:**
   - Directional mapping is explicitly defined in `docs/OBJECT_LAYOUTS_V1.md`, OR
   - Explicit family inheritance is justified and documented from governing source.

2. **Semantic & Motor Coherence:**
   - Urgent/frequent actions (e.g. Explain, Status, Inspect) occupy primary cardinal positions (N, E, S, W).
   - High-consequence or secondary routing choices (e.g. Send Agent, Target Machine) occupy diagonal directions (SE) with optional nested disclosure.
   - Preserves consistency across neighboring families (e.g. N is consistently inspection/explanation, S is consistently persistence/witness).

3. **Full Directional Reachability:**
   - Every occupied slot can be armed by pointer gesture and reached by keyboard chord.
   - Neutral center allows resting and traversals without unintentional arming or dismissals.

4. **Disabled Slot Stability (INV-004 / V1-031):**
   - When a capability is disabled or locked in V1 (e.g. Repair Packet, Checkpoint, Enhance), the slot retains its exact directional position (`.locked` or `.unavailable`).
   - Neighbors never slide over, collapse, or dynamically re-center.

5. **Edge & Corner Invariance (INV-034):**
   - Placement clamping at screen boundaries shifts the visual center minimally and preserves 100% of the directional relative angles from the causal center.

6. **Keyboard Equivalent Parity (INV-035):**
   - Every visible Reflex slot maps to a deterministic keyboard step or direct shortcut chord.

---

## 3. Privacy-Safe Trial Ledger Methodology

Layout performance and motor ergonomics are evaluated using an in-memory, privacy-safe ledger (`VeilLayoutTrialLedger`):

### Recorded Telemetry:
- `objectClass`: Target object classification.
- `layoutVersion`: e.g. `"1.0.0-candidate"` or `"1.0.0-experimental"`.
- `sectorChosen`: Armed compass direction.
- `intendedDirection`: Target compass direction in trial.
- `distanceTraveledPt`: Total cumulative pointer path distance.
- `seamCrossings`: Count of sector seam traversals.
- `radialOvershootPt`: Peak radial excursion past outer radius.
- `latencyMs`: Elapsed time from presentation to arming/selection.
- `inputRoute`: `.pointer` vs `.keyboard`.
- `misfires`: Bitfield tracking simulated boundary challenges (wrong sector, excessive traversal, re-arms, aborts).

### Strict Accounting Separation:
- **Synthetic Mechanical Trials:** Diagnostic simulations testing tracker math and geometry (355 trials).
- **Real Owner Invocations:** Separate counter strictly reserved for human owner trials (currently 0). Synthetic counts never satisfy real-use requirements.

### Strict Privacy Guarantee:
- **Zero Content Payloads:** The trial recorder strictly forbids storing selected text strings, URLs, file paths, UI element accessibility names, window titles, AX hierarchies, or clipboard bytes.
- Only geometric, temporal, and categorical telemetry is retained.

---

## 4. Non-Owner vs. Owner Validation Boundaries

| Responsibility | Automated / CI Agent Boundary | Human Owner Boundary |
|:---|:---|:---|
| **Promotion to Candidate** | Automatically marks `.candidate` only if source-justified | Confirms candidate status |
| **Reachability Simulation** | Simulates 8-direction sweeps and measures distance/seams | Evaluates hand motor feel |
| **Slot Stability Checks** | Asserts 0 reflow when slots are disabled | Assesses intuitive memory |
| **Keyboard Navigation** | Exercises all chords and traversal sequences | Verifies chord mnemonics |
| **Edge Clamping** | Verifies coordinates on screen edges and corners | Tests on multi-monitor desk |
| **Layout Freeze (`.frozen-v1`)** | **PROHIBITED** (no runtime mutation API) | **EXCLUSIVE AUTHORITY** (via source migration/ADR) |

---

## 5. Candidate Freeze Checklist (Owner Review Gate)

Per `docs/OBJECT_LAYOUTS_V1.md`, before any layout can move from `candidate` to `frozen-v1`:

- [ ] At least 20 real invocations recorded, OR deliberate owner review conducted for lower-frequency classes.
- [ ] Misfire and overshoot notes recorded from real motor usage.
- [ ] Repeated desired actions not represented noted and resolved.
- [ ] Direction conflicts with neighboring classes identified and resolved.
- [ ] Edge-screen usability verified during live workflow.
- [ ] Keyboard equivalents verified and comfortable.
- [ ] Owner approval or explicit no-objection recorded.
- [ ] Explicit source code migration and ADR committed identifying approved candidate version/snapshot.
