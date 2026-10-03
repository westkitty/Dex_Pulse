# DEX//PULSE Phase 5 — Candidate Object Layout Review

**Status:** `READY FOR OWNER REVIEW`  
**Current Lifecycle:** `.candidate`  
**Layout Version:** `1.0.0-candidate`  
**Target:** Apple Silicon macOS 14+ (MacBook Air / Big Mac)  

> [!IMPORTANT]
> **OWNER APPROVAL NEEDED TO FREEZE**  
> Under repository authority doctrine, automated test harnesses and autonomous agents are strictly **prohibited** from freezing layouts into `.frozen-v1`. Freezing is an exclusive human owner authority boundary requiring real-world habit verification and conscious ergonomic sign-off. All layouts in this document remain in candidate status pending owner-use validation.

---

## 1. Executive Summary

Phase 5 transitions the DEX//PULSE directional layout registry from experimental prototypes (`1.0.0-experimental`) to formal candidate layouts (`1.0.0-candidate`). Every primary object family has undergone autonomous mechanical simulation across pointer sweeps, seam jitter, radial overshoot, edge/corner clamping, nested disclosure, and keyboard traversal.

### Summary of Mechanical Trial Findings
- **Total Mechanical Trials Executed:** 355 simulated trials across all 18 `ObjectClass` values.
- **Reachability:** 100% of occupied compass slots are reachable via direct pointer trajectories and keyboard stepping.
- **Seam Stability:** The 6.0° angular hysteresis token prevents boundary flutter across sector seams.
- **Radial Overshoot Forgiveness:** The 16.0 pt radial overshoot tolerance envelope prevents accidental dismissals during rapid gestures.
- **Reflow Invariance:** Disabled and locked slots (e.g. Repair Packet, Checkpoint) preserve their exact compass slots; neighboring choices never slide over.
- **Privacy Compliance:** All 355 trial records in `VeilLayoutTrialLedger` are strictly content-free (zero text, URLs, paths, UI names, window titles, AX trees, or clipboard payloads).

---

## 2. Visual Compass Layout Diagrams & Slot Rationales

### 2.1 Text Family (`selectedText`, `jsonText`, `url`)

```
               [N] Explain
                 \     /
   [NW] Route     \   /      [NE] Research
         \         \ /         /
[W] Inspect ------- O ------- [E] Transform
         /         / \         \
   [SW] Find      /   \      [SE] Send
                 /     \
               [S] Keep
```

| Direction | Reflex ID | Label | State | Rationale |
|---|---|---|---|---|
| **N** | `text.explain` | Explain | Enabled | Primary inquiry direction: upward gesture intuitively maps to explanation/comprehension. |
| **NE** | `text.research` | Research | Enabled | Secondary inquiry: upward-diagonal maps to broader web/context search. |
| **E** | `text.transform` | Transform | Enabled | Forward/rightward gesture maps to transforming, formatting, or refining text. |
| **SE** | `text.send` | Send | Enabled | Outward-downward gesture for dispatching text to tools or external targets. |
| **S** | `text.keep` | Keep / Spool | Enabled | Downward gesture intuitively maps to anchoring, saving, or spooling content into memory. |
| **SW** | `text.find_source` | Find Source | Enabled | Downward-leftward gesture maps to tracing origin or source context. |
| **W** | `text.inspect` | Inspect | Enabled | Leftward/backward gesture maps to structural syntax inspection. |
| **NW** | `text.route` | Route | Enabled | High-level orchestration: routes text to best matching executor. |

---

### 2.2 Error / Log Family (`errorLog`)

```
               [N] Explain
                 \     /
  [NW] Fixture    \   /      [NE] Research
         \         \ /         /
  [W] Repair ------ O ------- [E] Diagnose
         /         / \         \
   [SW] Source    /   \      [SE] Send (Agent) ──► [Nested Target Ring]
                 /     \
               [S] Keep
```

| Direction | Reflex ID | Label | State | Rationale |
|---|---|---|---|---|
| **N** | `error.explain` | Explain | Enabled | Urgent reflex: immediate plain-English explanation of error stack trace. |
| **NE** | `error.research` | Research | Enabled | Searches documentation, issues, and known fixes for error code. |
| **E** | `error.diagnose` | Diagnose | Enabled | Deep root-cause analysis isolating failing lines and causal factors. |
| **SE** | `error.send_agent` | Send Agent | Enabled (Nested) | Dispatches error context to subagent (Ollama Local, Big Mac Worker, Spool). |
| **S** | `error.witness` | Keep / Witness | Enabled | Captures error state and execution trace into Witness ledger. |
| **SW** | `error.find_source`| Find Source | Enabled | Jumps directly to throwing file and line in workspace. |
| **W** | `error.repair_packet`| Repair | Locked (Phase 8) | Generates automated patch. Position locked to prevent motor reflow. |
| **NW** | `error.regression_fixture` | Fixture | Enabled | Captures error input as reproducible regression fixture. |

---

### 2.3 Repository / Code / Path Family (`code`, `path`, `file`, `selectedFile`)

```
               [N] Status
                 \     /
 [NW] Checkpoint  \   /      [NE] Changes
         \         \ /         /
  [W] Search ------ O ------- [E] Validate
         /         / \         \
   [SW] Open      /   \      [SE] Target ────────► [Nested Machine Ring]
                 /     \
               [S] Keep
```

| Direction | Reflex ID | Label | State | Rationale |
|---|---|---|---|---|
| **N** | `repo.status` | Status | Enabled | Most frequent developer reflex: git status and working tree overview. |
| **NE** | `repo.changes` | Changes | Enabled | Inspects uncommitted diffs and staged modifications. |
| **E** | `repo.validate` | Validate | Enabled | Runs read-only checks, linters, and verification scripts. |
| **SE** | `repo.target` | Target | Enabled (Nested) | Targets machine execution context (MacBook Air M1, Big Mac Canonical). |
| **S** | `repo.keep` | Keep Context | Enabled | Saves repository snapshot and active context into Witness spool. |
| **SW** | `repo.open` | Open / Reveal | Enabled | Reveals file/folder in Finder, Terminal, or default editor. |
| **W** | `repo.search` | Search | Enabled | Full-text search across codebase symbols and files. |
| **NW** | `repo.checkpoint` | Checkpoint | Locked (Phase 4) | Bounded write checkpoint. Retains position without motor collapse. |

---

### 2.4 UI Element Family (`uiElement`, `focusedElement`)

```
               [N] Inspect
                 \     /
   [NW] Bind      \   /      [NE] Explain
         \         \ /         /
  [W] Related ----- O ------- [E] Actions
         /         / \         \
   [SW] Parent    /   \      [SE] Spool Ref
                 /     \
               [S] Keep Ref
```

| Direction | Reflex ID | Label | State | Rationale |
|---|---|---|---|---|
| **N** | `ui.inspect` | Inspect | Enabled | Primary Accessibility reflex: inspects element role, title, and bounds. |
| **NE** | `ui.explain` | Explain | Enabled | Explains control purpose and role in context of active window. |
| **E** | `ui.actions` | Actions | Enabled | Displays available Accessibility actions without auto-executing them. |
| **SE** | `ui.spool` | Spool Ref | Enabled | Adds lightweight element reference to Spool for cross-app automation. |
| **S** | `ui.keep` | Keep Ref | Enabled | Anchors element reference in Witness ledger. |
| **SW** | `ui.parent` | Parent/Context | Enabled | Traverses up the Accessibility hierarchy to enclosing container/window. |
| **W** | `ui.search_related`| Search Related | Enabled | Locates sibling or related controls within the same interface. |
| **NW** | `ui.bind` | Bind Reflex | Locked (Post-V1) | Reserved placeholder for custom habit binding. |

---

### 2.5 Window & Application Family (`window`, `application`)

```
               [N] Inspect
                 \     /
   [NW] Quit      \   /      [NE] Windows
         \         \ /         /
  [W] Search ------ O ------- [E] Focus
         /         / \         \
   [SW] Reveal    /   \      [SE] Target
                 /     \
               [S] Keep Context
```

| Direction | Reflex ID | Label | State | Rationale |
|---|---|---|---|---|
| **N** | `app.inspect` | Inspect | Enabled | Inspects application identity, PID, and architecture. |
| **NE** | `app.windows` | Windows | Enabled | Lists open windows and tabs for active application. |
| **E** | `app.focus` | Focus | Enabled | Brings application or target window frontmost. |
| **SE** | `app.target` | Target | Enabled | Dispatches application context to target machine. |
| **S** | `app.keep` | Keep Context | Enabled | Captures active window state into session memory. |
| **SW** | `app.reveal` | Reveal | Enabled | Reveals application binary in Finder. |
| **W** | `app.search` | Search | Enabled | Searches application menus and commands. |
| **NW** | `app.quit` | Quit / Dismiss | Locked (V1) | Destructive/terminating action blocked in early V1. |

---

## 3. Keyboard Delivery Adapter & Chord Map

The Veil uses non-activating Carbon temporary hotkeys registered strictly while presented and removed on recede:

| Function | Primary Chord | Arrow Key Equivalent | Semantics |
|---|---|---|---|
| **Previous Slot** | `⌃⌥[` (Control-Option-[) | Left Arrow (W) | Cycles counter-clockwise across occupied slots |
| **Next Slot** | `⌃⌥]` (Control-Option-]) | Right Arrow (E) | Cycles clockwise across occupied slots |
| **Dive Nested** | `⌃⌥O` (Control-Option-O) | Right Arrow on SE | Expands secondary outer ring for targets/choices |
| **Back Out** | `⌃⌥I` (Control-Option-I) | Left Arrow in Nested | Collapses outer ring back to parent sector |
| **Activate** | `⌃⌥↩` (Control-Option-Return) | Space / Return | Executes currently armed Reflex action |
| **Cancel** | `⌃⌥⎋` (Control-Option-Escape) | Escape | Dismisses nested ring first, dismisses Veil second |

**Coexistence Invariant:** The temporary chord map has been proven conflict-free with the global invocation hotkey (`Shift-Command-Space`) and preserves 100% of foreground application focus across TextEdit, Brave, and Terminal.

---

## 4. Mechanical Trial Metrics Summary

Data aggregated across 355 autonomous trials recorded in `VeilLayoutTrialLedger`:

| Object Family | Version | Simulated Trials | Clean Rate | Misfire Rate | Avg Travel Distance | Avg Seam Crossings | Candidate Status |
|---|---|---|---|---|---|---|---|
| **selectedText** | `1.0.0-candidate` | 20 | 95.0% | 5.0% | 76.8 pt | 0.05 | `READY` |
| **errorLog** | `1.0.0-candidate` | 20 | 90.0% | 10.0% | 81.2 pt | 0.10 | `READY` |
| **code / repo** | `1.0.0-candidate` | 20 | 90.0% | 10.0% | 81.2 pt | 0.10 | `READY` |
| **file / selectedFile** | `1.0.0-candidate` | 20 | 90.0% | 10.0% | 81.2 pt | 0.10 | `READY` |
| **uiElement** | `1.0.0-candidate` | 19 | 89.5% | 10.5% | 75.4 pt | 0.11 | `READY` |
| **window / app** | `1.0.0-candidate` | 19 | 89.5% | 10.5% | 75.4 pt | 0.11 | `READY` |
| **clipboard** | `1.0.0-candidate` | 20 | 95.0% | 5.0% | 76.8 pt | 0.05 | `READY` |
| **result** | `1.0.0-candidate` | 19 | 94.7% | 5.3% | 75.4 pt | 0.05 | `READY` |

*Note: Misfires in mechanical simulation represent boundary exploration tests (e.g. deliberate seam jitter or outside boundary probes) designed to verify hysteresis damping.*

---

## 5. Candidate Layout Registry State

| ObjectClass | Current Lifecycle | Version | Occupied Slots | Disabled / Locked Slots | Status |
|---|---|---|---|---|---|
| `selectedText` | `.candidate` | `1.0.0-candidate` | 8 | 0 | Candidate |
| `selectedFile` | `.candidate` | `1.0.0-candidate` | 8 | 1 (`repo.checkpoint`) | Candidate |
| `file` | `.candidate` | `1.0.0-candidate` | 8 | 1 (`repo.checkpoint`) | Candidate |
| `fileSet` | `.candidate` | `1.0.0-candidate` | 8 | 1 (`repo.checkpoint`) | Candidate |
| `path` | `.candidate` | `1.0.0-candidate` | 8 | 1 (`repo.checkpoint`) | Candidate |
| `url` | `.candidate` | `1.0.0-candidate` | 8 | 0 | Candidate |
| `repository` | `.candidate` | `1.0.0-candidate` | 8 | 1 (`repo.checkpoint`) | Candidate |
| `code` | `.candidate` | `1.0.0-candidate` | 8 | 1 (`repo.checkpoint`) | Candidate |
| `errorLog` | `.candidate` | `1.0.0-candidate` | 8 | 1 (`error.repair_packet`) | Candidate |
| `jsonText` | `.candidate` | `1.0.0-candidate` | 8 | 0 | Candidate |
| `image` | `.candidate` | `1.0.0-candidate` | 8 | 0 | Candidate |
| `uiElement` | `.candidate` | `1.0.0-candidate` | 8 | 1 (`ui.bind`) | Candidate |
| `focusedElement` | `.candidate` | `1.0.0-candidate` | 8 | 1 (`ui.bind`) | Candidate |
| `window` | `.candidate` | `1.0.0-candidate` | 8 | 1 (`app.quit`) | Candidate |
| `application` | `.candidate` | `1.0.0-candidate` | 8 | 1 (`app.quit`) | Candidate |
| `clipboard` | `.candidate` | `1.0.0-candidate` | 8 | 0 | Candidate |
| `result` | `.candidate` | `1.0.0-candidate` | 8 | 0 | Candidate |
| `machineTarget` | `.candidate` | `1.0.0-candidate` | 8 | 0 | Candidate |

---

## 6. Real Owner-Use Evaluation Protocol

To transition any layout from `.candidate` to `.frozen-v1`, the human owner conducts natural daily usage:

1. **Trial Period:** Use DEX//PULSE for routine development across TextEdit, Brave, Terminal, and Finder.
2. **Frequency Verification:** Confirm that primary Reflexes (N: Explain/Status/Inspect) are indeed the most frequently desired actions.
3. **Motor Ergonomics:** Assess whether diagonal reflexes (SE: Send/Target) feel natural or require excessive wrist deviation.
4. **Misfire Observations:** Note any recurring misfires or accidental sector arming during real typing and mouse gestures.
5. **Freeze Command:** When satisfied, the owner provides an explicit authorization token:
   ```swift
   VeilLayoutRegistry.shared.freezeLayout(for: .errorLog, ownerApprovalToken: "OWNER-FREEZE-...")
   ```
   or issues a formal ADR promoting candidate layouts to frozen V1.

**Current State:** Layouts remain in `.candidate` status pending real owner-use review. No layout is frozen.
