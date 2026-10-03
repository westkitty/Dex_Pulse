# DEX//PULSE Phase 5 — Candidate Object Layout Review

**Status:** `READY FOR OWNER REVIEW`<br>
**Candidate Classes (10):** `selectedText`, `errorLog`, `repository`, `path`, `uiElement`, `focusedElement`, `image`, `file`, `selectedFile`, `fileSet`<br>
**Ambiguous / Experimental Classes (8):** `code`, `url`, `jsonText`, `window`, `application`, `clipboard`, `result`, `machineTarget`<br>
**Frozen Classes:** `0` (Freeze strictly prohibited prior to real owner review)<br>
**Target:** Apple Silicon macOS 14+ (MacBook Air / Big Mac)

> [!IMPORTANT]
> **OWNER APPROVAL NEEDED TO FREEZE**<br>
> Under repository authority doctrine, automated test harnesses and autonomous agents are strictly **prohibited** from freezing layouts into `.frozen-v1`. There is no runtime token or API that mutates `.candidate` into `.frozen-v1`. Freeze occurs strictly via an explicit source code change with an ADR/migration record approved by the human owner. All layouts in this document remain in candidate or experimental status pending real owner-use validation.

---

## 1. Executive Summary

Phase 5 establishes the directional layout candidate foundation for DEX//PULSE. Each object class recognizes a stable compass wheel mapped to high-frequency Reflexes without AI reordering or dynamic reflow.

### Candidate Promotion Criteria
A layout is promoted to `.candidate` (`1.0.0-candidate`) only when:
1. Its directional mapping is explicitly present in governing planning source (`docs/OBJECT_LAYOUTS_V1.md`), OR
2. Explicit family inheritance is justified by governing source;
3. Mechanical reachability is proven via synthetic simulations;
4. No unresolved source contradictions exist.

Classes not meeting these criteria remain `.experimental` (`1.0.0-experimental`) and are marked `OWNER DECISION REQUIRED`.

### Non-Binding Mechanical Diagnostics Summary
- **Synthetic Mechanical Trials:** 350 simulated trials across all 18 `ObjectClass` values.
- **Real Owner Invocations Recorded:** 0 (real-world trial ledger active; real habit evidence pending).
- **Diagnostic Status:** `NON-BINDING MECHANICAL DIAGNOSTIC` — simulated trials prove geometry and tracker math, but do NOT constitute human muscle-memory evidence or owner approval.
- **Controlling Freeze Evidence:** Per `docs/OBJECT_LAYOUTS_V1.md`, product freeze requires:
  - At least 20 real invocations OR deliberate owner review;
  - Misfire/overshoot notes from real motor use;
  - Repeated desired actions not represented;
  - Direction conflict notes;
  - Edge-screen usability verification;
  - Keyboard equivalent verification;
  - Explicit owner approval or no-objection.

---

## 2. Candidate Families (10 Classes with Source Authority)

### 2.1 Text Family (`selectedText`)

**Lifecycle:** `.candidate` (`1.0.0-candidate`)

Authority: `docs/OBJECT_LAYOUTS_V1.md: Text`. Primary text inquiry, refinement, and routing.

```text
               [N] Explain
                 \     /
   [NW] Route \   / [NE] Verify
         \     \ /     /
[W] Structure ----- O ----- [E] Transform
         /     / \     \
   [SW] Find Source /   \ [SE] Send
             /     \
           [S] Keep / Spool```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `text.explain` | Explain | enabled | — | Candidate Reflex |
| **NE** | `text.verify` | Verify | enabled | — | Candidate Reflex |
| **E** | `text.transform` | Transform | enabled | — | Candidate Reflex |
| **SE** | `text.send` | Send | enabled | Ollama Summarizer, Copy Structured | Candidate Reflex |
| **S** | `text.spool` | Keep / Spool | enabled | — | Candidate Reflex |
| **SW** | `text.source` | Find Source | enabled | — | Candidate Reflex |
| **W** | `text.structure` | Structure | enabled | — | Candidate Reflex |
| **NW** | `text.route` | Route | enabled | — | Candidate Reflex |

### 2.2 Error / Log Family (`errorLog`)

**Lifecycle:** `.candidate` (`1.0.0-candidate`)

Authority: `docs/OBJECT_LAYOUTS_V1.md: Error / log`. Rapid error triage, stack trace diagnosis, and regression capture.

```text
               [N] Explain
                 \     /
   [NW] Fixture \   / [NE] Research
         \     \ /     /
[W] Repair ----- O ----- [E] Diagnose
         /     / \     \
   [SW] Find Source /   \ [SE] Send
             /     \
           [S] Keep / Witness```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `error.explain` | Explain | enabled | — | Candidate Reflex |
| **NE** | `error.research` | Research | enabled | — | Candidate Reflex |
| **E** | `error.diagnose` | Diagnose | enabled | — | Candidate Reflex |
| **SE** | `error.send_agent` | Send | enabled | Local Ollama, Big Mac Worker, Queue to Spool | Candidate Reflex |
| **S** | `error.witness` | Keep / Witness | enabled | — | Candidate Reflex |
| **SW** | `error.find_source` | Find Source | enabled | — | Candidate Reflex |
| **W** | `error.repair_packet` | Repair | locked: Repair execution locked until Phase 8 | — | Candidate Reflex |
| **NW** | `error.regression_fixture` | Fixture | enabled | — | Candidate Reflex |

### 2.3 Repository / Project / Path Family (`repository`, `path`)

**Lifecycle:** `.candidate` (`1.0.0-candidate`)

Authority: `docs/OBJECT_LAYOUTS_V1.md: Repository / project / path`. Developer project state, git status, and target execution.

```text
               [N] Status
                 \     /
   [NW] Checkpoint \   / [NE] Changes
         \     \ /     /
[W] Search ----- O ----- [E] Validate
         /     / \     \
   [SW] Open / Reveal /   \ [SE] Target
             /     \
           [S] Keep```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `repo.status` | Status | enabled | — | Candidate Reflex |
| **NE** | `repo.changes` | Changes | enabled | — | Candidate Reflex |
| **E** | `repo.validate` | Validate | enabled | — | Candidate Reflex |
| **SE** | `repo.target` | Target | enabled | MacBook Air M1, Big Mac Canonical | Candidate Reflex |
| **S** | `repo.keep` | Keep | enabled | — | Candidate Reflex |
| **SW** | `repo.open` | Open / Reveal | enabled | — | Candidate Reflex |
| **W** | `repo.search` | Search | enabled | — | Candidate Reflex |
| **NW** | `repo.checkpoint` | Checkpoint | locked: Automated write checkpoints locked in early V1 | — | Candidate Reflex |

### 2.4 UI Element Family (`uiElement`, `focusedElement`)

**Lifecycle:** `.candidate` (`1.0.0-candidate`)

Authority: `docs/OBJECT_LAYOUTS_V1.md: UI element`. Accessibility element inspection and hierarchy traversal.

```text
               [N] Inspect
                 \     /
   [NW] Bind Reflex \   / [NE] Explain
         \     \ /     /
[W] Related ----- O ----- [E] AX Actions
         /     / \     \
   [SW] Parent /   \ [SE] Add to Spool
             /     \
           [S] Keep```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `ui.inspect` | Inspect | enabled | — | Candidate Reflex |
| **NE** | `ui.explain` | Explain | enabled | — | Candidate Reflex |
| **E** | `ui.actions` | AX Actions | enabled | — | Candidate Reflex |
| **SE** | `ui.spool` | Add to Spool | enabled | — | Candidate Reflex |
| **S** | `ui.keep` | Keep | enabled | — | Candidate Reflex |
| **SW** | `ui.parent` | Parent | enabled | — | Candidate Reflex |
| **W** | `ui.related` | Related | enabled | — | Candidate Reflex |
| **NW** | `ui.bind` | Bind Reflex | unavailable: Custom binding unavailable in V1 | — | Candidate Reflex |

### 2.5 Image / File Family (`image`, `file`, `selectedFile`, `fileSet`)

**Lifecycle:** `.candidate` (`1.0.0-candidate`)

Authority: `docs/OBJECT_LAYOUTS_V1.md: Image/file`. Asset and file metadata inspection, reveal, and conversion.

```text
               [N] Inspect Metadata
                 \     /
   [NW] Variant \   / [NE] Enhance
         \     \ /     /
[W] Related ----- O ----- [E] Convert
         /     / \     \
   [SW] Reveal / Open /   \ [SE] Send / Target
             /     \
           [S] Spool / Keep```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `file.metadata` | Inspect Metadata | enabled | — | Candidate Reflex |
| **NE** | `file.enhance` | Enhance | unavailable: Visual enhance pack unavailable in V1 baseline | — | Candidate Reflex |
| **E** | `file.convert` | Convert | unavailable: Asset conversion pack unavailable in V1 baseline | — | Candidate Reflex |
| **SE** | `file.send` | Send / Target | enabled | MacBook Air M1, Big Mac Canonical | Candidate Reflex |
| **S** | `file.spool` | Spool / Keep | enabled | — | Candidate Reflex |
| **SW** | `file.reveal` | Reveal / Open | enabled | — | Candidate Reflex |
| **W** | `file.related` | Related | unavailable: Asset discovery pack unavailable in V1 baseline | — | Candidate Reflex |
| **NW** | `file.variant` | Variant | unavailable: Variant generation pack unavailable in V1 baseline | — | Candidate Reflex |

---

## 3. Ambiguous / Experimental Classes (8 Classes — Owner Decision Required)

These classes are not fully assigned in `docs/OBJECT_LAYOUTS_V1.md`. They are registered with provisional slots under `.experimental` lifecycle (`1.0.0-experimental`) and require deliberate owner decision before candidate promotion.

### 3.1 CodeObject — `OWNER DECISION REQUIRED`

**Lifecycle:** `.experimental` (`1.0.0-experimental`)<br>
**Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define Code family)<br>
**Unresolved Question:** Unresolved family: evaluate whether Code belongs to Repository, Text, or dedicated Code layout.

```text
               [N] Explain
                 \     /
   [NW] Format \   / [NE] Refactor
         \     \ /     /
[W] Document ----- O ----- [E] Copy Block
         /     / \     \
   [SW] Lint /   \ [SE] Tests
             /     \
           [S] Run Scratchpad```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `code.explain` | Explain | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NE** | `code.refactor` | Refactor | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **E** | `code.copy` | Copy Block | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SE** | `code.test` | Tests | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **S** | `code.run` | Run Scratchpad | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SW** | `code.lint` | Lint | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **W** | `code.doc` | Document | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NW** | `code.format` | Format | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |

### 3.2 URLObject — `OWNER DECISION REQUIRED`

**Lifecycle:** `.experimental` (`1.0.0-experimental`)<br>
**Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define URL family)<br>
**Unresolved Question:** Unresolved family: evaluate whether URL inherits Text with link actions or standalone Web/Browser family.

```text
               [N] Open Browser
                 \     /
   [NW] Domain Search \   / [NE] Copy Link
         \     \ /     /
[W] Share ----- O ----- [E] Fetch Meta
         /     / \     \
   [SW] Headers /   \ [SE] Archive
             /     \
           [S] Scan Security```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `url.open` | Open Browser | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NE** | `url.copy` | Copy Link | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **E** | `url.fetch` | Fetch Meta | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SE** | `url.archive` | Archive | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **S** | `url.scan` | Scan Security | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SW** | `url.headers` | Headers | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **W** | `url.share` | Share | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NW** | `url.search` | Domain Search | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |

### 3.3 JSONTextObject — `OWNER DECISION REQUIRED`

**Lifecycle:** `.experimental` (`1.0.0-experimental`)<br>
**Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define JSONText family)<br>
**Unresolved Question:** Unresolved family: evaluate whether JSONText inherits Text with formatting or standalone Structured Data family.

```text
               [N] Validate
                 \     /
   [NW] Codable Swift \   / [NE] Prettify
         \     \ /     /
[W] Inspect ----- O ----- [E] Minify
         /     / \     \
   [SW] To YAML /   \ [SE] Gen Schema
             /     \
           [S] Extract Path```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `json.validate` | Validate | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NE** | `json.format` | Prettify | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **E** | `json.compact` | Minify | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SE** | `json.schema` | Gen Schema | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **S** | `json.path` | Extract Path | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SW** | `json.yaml` | To YAML | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **W** | `json.inspect` | Inspect | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NW** | `json.types` | Codable Swift | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |

### 3.4 WindowObject — `OWNER DECISION REQUIRED`

**Lifecycle:** `.experimental` (`1.0.0-experimental`)<br>
**Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define Window family)<br>
**Unresolved Question:** Unresolved family: evaluate whether Window inherits UI element or dedicated OS Window Management family.

```text
               [N] Inspect Window
                 \     /
   [NW] Tile \   / [NE] Focus
         \     \ /     /
[W] Child Elements ----- O ----- [E] Bounds
         /     / \     \
   [SW] Parent App /   \ [SE] Add to Spool
             /     \
           [S] Keep```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `window.inspect` | Inspect Window | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NE** | `window.focus` | Focus | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **E** | `window.bounds` | Bounds | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SE** | `window.spool` | Add to Spool | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **S** | `window.keep` | Keep | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SW** | `window.parent` | Parent App | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **W** | `window.elements` | Child Elements | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NW** | `window.tile` | Tile | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |

### 3.5 ApplicationObject — `OWNER DECISION REQUIRED`

**Lifecycle:** `.experimental` (`1.0.0-experimental`)<br>
**Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define Application family)<br>
**Unresolved Question:** Unresolved family: evaluate whether Application inherits UI element or dedicated OS Process/App family.

```text
               [N] Inspect App
                 \     /
   [NW] Hide App \   / [NE] Bundle Info
         \     \ /     /
[W] Related Apps ----- O ----- [E] Windows
         /     / \     \
   [SW] Process State /   \ [SE] Add to Spool
             /     \
           [S] Keep```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `app.inspect` | Inspect App | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NE** | `app.info` | Bundle Info | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **E** | `app.windows` | Windows | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SE** | `app.spool` | Add to Spool | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **S** | `app.keep` | Keep | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SW** | `app.running` | Process State | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **W** | `app.related` | Related Apps | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NW** | `app.hide` | Hide App | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |

### 3.6 ClipboardObject — `OWNER DECISION REQUIRED`

**Lifecycle:** `.experimental` (`1.0.0-experimental`)<br>
**Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define Clipboard family)<br>
**Unresolved Question:** Unresolved family: evaluate whether Clipboard inherits Text or dynamic multi-type container.

```text
               [N] Inspect Types
                 \     /
   [NW] Paste Rich \   / [NE] Paste Plain
         \     \ /     /
[W] Clear History ----- O ----- [E] Transform
         /     / \     \
   [SW] Trace Source /   \ [SE] Send
             /     \
           [S] Spool / Keep```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `clip.inspect` | Inspect Types | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NE** | `clip.paste_plain` | Paste Plain | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **E** | `clip.transform` | Transform | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SE** | `clip.send` | Send | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **S** | `clip.spool` | Spool / Keep | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SW** | `clip.source` | Trace Source | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **W** | `clip.clear` | Clear History | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NW** | `clip.rich` | Paste Rich | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |

### 3.7 ResultObject — `OWNER DECISION REQUIRED`

**Lifecycle:** `.experimental` (`1.0.0-experimental`)<br>
**Authority:** docs/INTERACTION_MODEL.md: Result Object (hold and inspection lifecycle)<br>
**Unresolved Question:** Unresolved family: Result hold layout mentioned in docs/INTERACTION_MODEL.md requires deliberate owner validation before candidate promotion.

```text
               [N] Re-Pulse
                 \     /
   [NW] Dismiss \   / [NE] Evidence
         \     \ /     /
[W] Diff ----- O ----- [E] Witness Proof
         /     / \     \
   [SW] Reveal /   \ [SE] Send / Target
             /     \
           [S] Keep / Pin```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `result.repulse` | Re-Pulse | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NE** | `result.evidence` | Evidence | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **E** | `result.witness` | Witness Proof | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SE** | `result.target` | Send / Target | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **S** | `result.spool` | Keep / Pin | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SW** | `result.open` | Reveal | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **W** | `result.diff` | Diff | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NW** | `result.dismiss` | Dismiss | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |

### 3.8 MachineTarget — `OWNER DECISION REQUIRED`

**Lifecycle:** `.experimental` (`1.0.0-experimental`)<br>
**Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define MachineTarget family)<br>
**Unresolved Question:** Unresolved family: Machine execution target selection layout is not defined in docs/OBJECT_LAYOUTS_V1.md and requires deliberate owner validation.

```text
               [N] Ping Target
                 \     /
   [NW] Disconnect \   / [NE] System Stats
         \     \ /     /
[W] Capabilities ----- O ----- [E] Run Remote
         /     / \     \
   [SW] Open Shell /   \ [SE] Target Context
             /     \
           [S] Keep Target```

| Direction | Reflex ID | Label | State | Nested Choices | Authority / Notes |
|:---|:---|:---|:---|:---|:---|
| **N** | `target.ping` | Ping Target | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NE** | `target.stats` | System Stats | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **E** | `target.run` | Run Remote | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SE** | `target.context` | Target Context | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **S** | `target.keep` | Keep Target | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **SW** | `target.shell` | Open Shell | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **W** | `target.caps` | Capabilities | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |
| **NW** | `target.disconnect` | Disconnect | enabled | — | HYPOTHESIS — REQUIRES OWNER REVIEW |

---

## 4. Non-Binding Mechanical Diagnostics & Telemetry Ledger

> [!NOTE]
> All synthetic metrics below are **non-binding mechanical diagnostics** proving reachability and tracker math. They do NOT satisfy the product freeze requirement for real owner invocations.

| Object Class | Lifecycle | Synthetic Trials | Boundary Challenges | Simulated Recovery Rate | Real Owner Invocations |
|:---|:---:|:---:|:---:|:---:|:---:|
| `SelectedTextObject` | `.candidate` | 20 | 1 | 95.0% | 0 |
| `SelectedFileObject` | `.candidate` | 20 | 5 | 75.0% | 0 |
| `FileObject` | `.candidate` | 20 | 5 | 75.0% | 0 |
| `FileSetObject` | `.candidate` | 20 | 5 | 75.0% | 0 |
| `PathObject` | `.candidate` | 20 | 2 | 90.0% | 0 |
| `URLObject` | `.experimental` | 19 | 1 | 94.7% | 0 |
| `RepositoryObject` | `.candidate` | 20 | 2 | 90.0% | 0 |
| `CodeObject` | `.experimental` | 19 | 1 | 94.7% | 0 |
| `ErrorLogObject` | `.candidate` | 20 | 2 | 90.0% | 0 |
| `JSONTextObject` | `.experimental` | 19 | 1 | 94.7% | 0 |
| `ImageObject` | `.candidate` | 20 | 5 | 75.0% | 0 |
| `UIElementObject` | `.candidate` | 19 | 2 | 89.5% | 0 |
| `FocusedElementObject` | `.candidate` | 19 | 2 | 89.5% | 0 |
| `WindowObject` | `.experimental` | 19 | 1 | 94.7% | 0 |
| `ApplicationObject` | `.experimental` | 19 | 1 | 94.7% | 0 |
| `ClipboardObject` | `.experimental` | 19 | 1 | 94.7% | 0 |
| `ResultObject` | `.experimental` | 19 | 1 | 94.7% | 0 |
| `MachineTarget` | `.experimental` | 19 | 1 | 94.7% | 0 |

---

## 5. Owner Decision Matrix

Andrew: Use this decision matrix to review, accept, or modify directional layouts for V1.

### Text Family (`selectedText`)

**Current Lifecycle:** `.candidate` (1.0.0-candidate)<br>
**Source Authority:** docs/OBJECT_LAYOUTS_V1.md: Text

Current mapping:

```text
           N: Explain
     NW: Route   NE: Verify
   W: Structure         E: Transform
     SW: Find Source   SE: Send
           S: Keep / Spool```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### Error / Log Family (`errorLog`)

**Current Lifecycle:** `.candidate` (1.0.0-candidate)<br>
**Source Authority:** docs/OBJECT_LAYOUTS_V1.md: Error / log

Current mapping:

```text
           N: Explain
     NW: Fixture   NE: Research
   W: Repair         E: Diagnose
     SW: Find Source   SE: Send
           S: Keep / Witness```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### Repository / Project / Path Family (`repository`, `path`)

**Current Lifecycle:** `.candidate` (1.0.0-candidate)<br>
**Source Authority:** docs/OBJECT_LAYOUTS_V1.md: Repository / project / path

Current mapping:

```text
           N: Status
     NW: Checkpoint   NE: Changes
   W: Search         E: Validate
     SW: Open / Reveal   SE: Target
           S: Keep```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### UI Element Family (`uiElement`, `focusedElement`)

**Current Lifecycle:** `.candidate` (1.0.0-candidate)<br>
**Source Authority:** docs/OBJECT_LAYOUTS_V1.md: UI element

Current mapping:

```text
           N: Inspect
     NW: Bind Reflex   NE: Explain
   W: Related         E: AX Actions
     SW: Parent   SE: Add to Spool
           S: Keep```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### Image / File Family (`image`, `file`, `selectedFile`, `fileSet`)

**Current Lifecycle:** `.candidate` (1.0.0-candidate)<br>
**Source Authority:** docs/OBJECT_LAYOUTS_V1.md: Image/file

Current mapping:

```text
           N: Inspect Metadata
     NW: Variant   NE: Enhance
   W: Related         E: Convert
     SW: Reveal / Open   SE: Send / Target
           S: Spool / Keep```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### Code Layout (`code`)

**Current Lifecycle:** `.experimental` (1.0.0-experimental)<br>
**Source Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define Code family)

Current mapping:

```text
           N: Explain
     NW: Format   NE: Refactor
   W: Document         E: Copy Block
     SW: Lint   SE: Tests
           S: Run Scratchpad```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION
- [ ] UNRESOLVED FAMILY (assign to existing family or declare new family)

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### URL Layout (`url`)

**Current Lifecycle:** `.experimental` (1.0.0-experimental)<br>
**Source Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define URL family)

Current mapping:

```text
           N: Open Browser
     NW: Domain Search   NE: Copy Link
   W: Share         E: Fetch Meta
     SW: Headers   SE: Archive
           S: Scan Security```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION
- [ ] UNRESOLVED FAMILY (assign to existing family or declare new family)

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### JSONText Layout (`jsonText`)

**Current Lifecycle:** `.experimental` (1.0.0-experimental)<br>
**Source Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define JSONText family)

Current mapping:

```text
           N: Validate
     NW: Codable Swift   NE: Prettify
   W: Inspect         E: Minify
     SW: To YAML   SE: Gen Schema
           S: Extract Path```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION
- [ ] UNRESOLVED FAMILY (assign to existing family or declare new family)

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### Window Layout (`window`)

**Current Lifecycle:** `.experimental` (1.0.0-experimental)<br>
**Source Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define Window family)

Current mapping:

```text
           N: Inspect Window
     NW: Tile   NE: Focus
   W: Child Elements         E: Bounds
     SW: Parent App   SE: Add to Spool
           S: Keep```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION
- [ ] UNRESOLVED FAMILY (assign to existing family or declare new family)

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### Application Layout (`application`)

**Current Lifecycle:** `.experimental` (1.0.0-experimental)<br>
**Source Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define Application family)

Current mapping:

```text
           N: Inspect App
     NW: Hide App   NE: Bundle Info
   W: Related Apps         E: Windows
     SW: Process State   SE: Add to Spool
           S: Keep```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION
- [ ] UNRESOLVED FAMILY (assign to existing family or declare new family)

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### Clipboard Layout (`clipboard`)

**Current Lifecycle:** `.experimental` (1.0.0-experimental)<br>
**Source Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define Clipboard family)

Current mapping:

```text
           N: Inspect Types
     NW: Paste Rich   NE: Paste Plain
   W: Clear History         E: Transform
     SW: Trace Source   SE: Send
           S: Spool / Keep```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION
- [ ] UNRESOLVED FAMILY (assign to existing family or declare new family)

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### Result Layout (`result`)

**Current Lifecycle:** `.experimental` (1.0.0-experimental)<br>
**Source Authority:** docs/INTERACTION_MODEL.md: Result Object (hold and inspection lifecycle)

Current mapping:

```text
           N: Re-Pulse
     NW: Dismiss   NE: Evidence
   W: Diff         E: Witness Proof
     SW: Reveal   SE: Send / Target
           S: Keep / Pin```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION
- [ ] UNRESOLVED FAMILY (assign to existing family or declare new family)

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |

### MachineTarget Layout (`machineTarget`)

**Current Lifecycle:** `.experimental` (1.0.0-experimental)<br>
**Source Authority:** None (docs/OBJECT_LAYOUTS_V1.md does not define MachineTarget family)

Current mapping:

```text
           N: Ping Target
     NW: Disconnect   NE: System Stats
   W: Capabilities         E: Run Remote
     SW: Open Shell   SE: Target Context
           S: Keep Target```

- [ ] KEEP AS SHOWN
- [ ] CHANGE (specify replacements in table below)
- [ ] NEEDS LIVE USE BEFORE DECISION
- [ ] UNRESOLVED FAMILY (assign to existing family or declare new family)

If CHANGE, specify replacement slots:

| Slot | New Reflex ID | New Label | Rationale |
|:---|:---|:---|:---|
| N | | | |
| NE | | | |
| E | | | |
| SE | | | |
| S | | | |
| SW | | | |
| W | | | |
| NW | | | |
