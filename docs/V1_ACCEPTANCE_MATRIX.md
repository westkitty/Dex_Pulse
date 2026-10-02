# DEX//PULSE V1 Acceptance Matrix

This matrix is the V1 definition of done. `Pass` requires direct evidence from the candidate artifact/user path; source presence or an agent claim is not sufficient.

## A. Build / identity

| ID | Mandatory behavior | Pass evidence |
|---|---|---|
| V1-001 | Apple Silicon macOS 14+ app bundle builds reproducibly on canonical dev machine | clean build log + bundle architecture/plist/signature inspection |
| V1-002 | installed candidate identity is recorded | commit SHA + app bundle path/version/hash |
| V1-003 | `dexpulse doctor` runs on MacBook without Python/Node/Docker/etc. | installed CLI output + dependency inspection |

## B. Invocation / hot path

| ID | Mandatory behavior | Pass evidence |
|---|---|---|
| V1-010 | configurable global hotkey invokes Pulse while another app is frontmost | screen/runtime trace in Brave, Terminal, native app |
| V1-011 | Pulse Point/Pulsefront appear without waiting for model/network | signpost trace with model/network unavailable |
| V1-012 | merely invoking Pulse does not change pasteboard changeCount/content | before/after pasteboard snapshot |
| V1-013 | Veil does not steal focus from originating app merely by appearing | before/after frontmost/focused AX identity |
| V1-014 | Escape/cancel always returns to QUIET | state trace from every transient major state |
| V1-015 | RECEDE completes cleanly after successful result/Witness | state + visual trace |

## C. Lens precedence

| ID | Mandatory behavior | Pass evidence |
|---|---|---|
| V1-020 | explicit selected text/file outranks pointer UI element | controlled fixture with both present |
| V1-021 | pointer UI element outranks focused AX element when no explicit selection | fixture/harness proof |
| V1-022 | focused AX element outranks frontmost window/app | fixture proof |
| V1-023 | frontmost window/app outranks clipboard fallback | fixture proof |
| V1-024 | clipboard fallback reads existing contents only | pasteboard instrumentation |
| V1-025 | UI button/control under pointer becomes `UIElementObject` automatically | native + browser/Electron accessible control proof |
| V1-026 | secure/password elements do not expose protected values | secure-field test harness |
| V1-027 | Brave selected text capture works through native/AX route or reports explicit degraded state without hidden copy mutation | live Brave evidence |
| V1-028 | Terminal selected text capture works or degrades explicitly without hidden clipboard mutation | live Terminal evidence |
| V1-029 | Finder file selection and VS Code/Electron text/element context resolve through declared paths or explicit degraded states | installed runtime evidence |
| V1-029A | denied/revoked Accessibility permission produces a usable recovery state and never replays a blocked action after reauthorization | permission journey |

## D. Object layouts / Veil

| ID | Mandatory behavior | Pass evidence |
|---|---|---|
| V1-030 | every required object class maps to a registered stable directional layout | registry test + layout manifest |
| V1-031 | no AI ranking silently changes positions | deterministic layout test across repeated/classifier-enriched runs |
| V1-032 | visible annular geometry matches hit testing | geometry visualization tests |
| V1-033 | overshoot/hysteresis avoids trivial sector flapping | pointer-path fixture |
| V1-034 | edge/corner/multi-monitor invocation preserves causal origin and usable layout | installed runtime visual QA |
| V1-035 | keyboard route reaches all visible Reflexes | keyboard-only journey |

## E. Visual language

| ID | Mandatory behavior | Pass evidence |
|---|---|---|
| V1-040 | original four MP4 hashes match fixture manifest | SHA-256 verification |
| V1-041 | Strand is a ribbon surface, not stroked wire | reference comparison scene |
| V1-042 | transverse barcode segmentation remains readable | native-scale + enlarged capture |
| V1-043 | twist yields face/edge/underside and strong apparent-width change | edge-on fixture scene |
| V1-044 | over/under crossings are readable; crossing does not join topology | crossing vs explicit-junction comparison |
| V1-045 | glow remains subordinate to geometry | fixture review |
| V1-046 | QUIET has no active Strand render loop | profiler/signpost evidence |
| V1-047 | Reduce Motion preserves causal meaning | reduced-motion scene matrix |

## F. PulseKit / policy

| ID | Mandatory behavior | Pass evidence |
|---|---|---|
| V1-050 | capabilities declare object/target/risk/result/proof/availability | descriptor schema tests |
| V1-051 | incompatible/unavailable/blocked states are distinguishable | registry test |
| V1-052 | V1 destructive capability cannot execute even if a malicious/malformed Pack describes one | policy rejection test before executor entry |
| V1-053 | cancellation reaches executor and terminal state where supported | cancellation integration test |
| V1-054 | Target identity is visible in execution/Witness | result receipt inspection |
| V1-055 | stale UI/window/AX object is rejected before execution rather than rebound by title/role coincidence | stale-context integration fixture |
| V1-056 | executor deadline/timeout/cancellation produce distinct terminal states and no inferred success | deterministic timeout/cancel harness |
| V1-057 | Pack concurrency class is enforced under repeated invocation | controlled parallel/singleton harness |

## G. Golden journeys

| ID | Mandatory behavior | Pass evidence |
|---|---|---|
| V1-060 | Journey A: repository/path -> Git inspection -> Result -> Witness -> Recede | installed MacBook end-to-end trace |
| V1-061 | Journey B: selected error -> Ollama diagnose -> Result -> Witness -> Recede | installed MacBook end-to-end trace with local model executor identity |
| V1-062 | Journey C: UI element under pointer -> AX inspect -> Result -> Witness -> Recede | installed MacBook end-to-end trace |
| V1-063 | Big Mac/DEX//REACH safe-read Target works when available or degrades explicitly when unavailable | target trace; availability branch evidence |

## H. Result / Spool / Witness / habit

| ID | Mandatory behavior | Pass evidence |
|---|---|---|
| V1-070 | Result Object remains actionable until Recede/dismiss/keep decision | chained-object journey |
| V1-071 | unpinned Spool/results disappear after application restart | persistence test |
| V1-072 | pin stores durable reference preferentially, not gratuitous content copy | storage inspection fixture |
| V1-073 | Witness stores structured proof state, run/parent IDs, executor/target/time | store schema + journey receipt |
| V1-074 | default Witness rolling retention is 30 days | clock-controlled retention test |
| V1-075 | habit aggregate default retention is 180 days | clock-controlled retention test |
| V1-076 | habit aggregates contain no selected payload/clipboard contents/raw command output | storage inspection test |
| V1-077 | interrupted run reopens as interrupted/unknown unless terminal proof exists; it is never auto-resumed | crash/relaunch fixture |
| V1-078 | storage schema migration preserves pins/Witness semantics or rolls back/quarantines safely | migration fixture |

## I. DexDictate coexistence

| ID | Mandatory behavior | Pass evidence |
|---|---|---|
| V1-080 | Pulse hotkey does not conflict with configured DexDictate trigger | runtime conflict check |
| V1-081 | Pulse invocation during DexDictate recording does not steal focus/selection/clipboard/target | paired-app journey |
| V1-082 | Pulse invocation during DexDictate transcription/delivery preserves output destination | paired-app journey |
| V1-083 | DexDictate verified Undo remains valid after unrelated Pulse invocation | real undo journey |
| V1-084 | if an unresolved conflict occurs, Pulse yields | explicit conflict fixture |

## J. Performance / accessibility

| ID | Mandatory behavior | Pass evidence |
|---|---|---|
| V1-090 | p95 input -> first visible feedback <= 50 ms target | benchmark sample on MacBook |
| V1-091 | p95 input -> Veil interactable <= 120 ms target and <=150 ms release ceiling absent documented OS anomaly | benchmark sample |
| V1-092 | idle CPU average <= 0.5% after settling | profiler/measurement |
| V1-093 | idle RSS <=160 MB release ceiling or owner-approved evidence-backed revision | measurement |
| V1-094 | ordinary 60 Hz controlled interaction has <1% missed frames | frame benchmark |
| V1-095 | all visible actions have keyboard/accessibility labels | accessibility inspection |
| V1-096 | Reduce Motion route communicates success/error/dispatch without travel animation | manual + state tests |
| V1-097 | permission/error/unavailable states are reachable by keyboard and expose an actionable reason | accessibility/state journey |

## K. Cold-resume/source integrity

| ID | Mandatory behavior | Pass evidence |
|---|---|---|
| V1-100 | a fresh agent/developer can identify current phase, locks, unknowns, and next packet from repository only | cold-start handoff exercise |
| V1-101 | `scripts/validate_planning_source.sh`/successor source gate validates required docs, instruction budget, fixture hashes, and public-source guards | clean gate output |

## V1 verdict rule

V1 is complete only when every mandatory row is `Pass`, `N/A` for a genuinely inapplicable hardware condition, or explicitly superseded by a later owner-approved contract. `Unknown`, `Partial`, and `Unverified` block completion.
