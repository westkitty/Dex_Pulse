# Build Packet — Phase 3 Semantic State Machine

## Objective

Implement the complete semantic state machine and explicit run lifecycle model for DEX//PULSE as specified in `docs/INTERACTION_MODEL.md` and `MASTER_IMPLEMENTATION_PLAN.md`. Transform the provisional Phase 0/1/2 state handling into a fully verified, thread-safe causal state engine supporting all 15 semantic states, explicit run tracking with generation tokens, distinct terminal outcomes, memory-only Result Object foundation with hold semantics, late async callback rejection, and witness proof recording (`executed != verified`), while guaranteeing that cancellation from any transient state strictly converges to `QUIET` without stranded states.

## Scope

1. **Complete 15-State Semantic Graph (`PulseState`):**
   - Core resting state: `QUIET`
   - Primary loop states: `PULSE`, `LENS`, `VEIL`, `ATTUNE`, `STRAND`, `FORK`, `DISPATCH`, `WEAVE`, `RETURN`, `WITNESS`, `RESOLVE`, `RECEDE`
   - Failure & cancellation branch states: `FRAY`, `SEVER`
   - Complete transition matrix defining permitted vs forbidden transitions.

2. **Explicit Run Model (`PulseRun`):**
   - Typed run identity: `runID: UUID`, `parentRunID: UUID?`, `startTime: Date`, `endTime: Date?`
   - Context bindings: `envelopeID: UUID?`, `generationToken: String`
   - Subject metadata: `sourceObjectSummary: String?`, `sourceObjectClass: ObjectClass?`
   - Routing: `capabilityID: String?`, `targetID: String?`
   - Lifecycle state: `state: PulseState`, `outcome: PulseTerminalOutcome?`
   - Trace references: `resultID: UUID?`, `receiptID: UUID?`

3. **Terminal Outcomes (`PulseTerminalOutcome`):**
   - Distinct, unambiguous terminal classifications:
     `succeeded`, `cancelled`, `blocked`, `unavailable`, `timedOut`, `failed`, `interrupted`, `unknown`.
   - Distinct failure semantics: `timedOut` != `failed` != `cancelled` != `blocked`.

4. **Result Object Foundation (`PulseResultObject`):**
   - Native `PulseObject` implementation for execution results:
     `resultID`, `runID`, `sourceObjectID`, `sourceObjectClass`, `capabilityID`, `executorID`, `targetID`, `outcome`, `summary`, `isHeld`, `createdAt`.
   - Result hold semantics: Result object can pause automatic recede while under active user inspection.
   - Memory-only in Phase 3 (no persistent disk writes required until future phase).

5. **Stale Completion & Race Protection:**
   - Generation token and `runID` validation on all asynchronous completions.
   - Immediate rejection of late/stale callbacks from superseded, cancelled, or completed runs.
   - Prevention of state resurrection or zombie transitions after dismissal.

6. **Witness Proof Discipline:**
   - Strict distinction between `executed` (action ran and returned) and `verified` (corroborating proof established).
   - Exclusion of sensitive raw user payloads (credentials, full selected text) from execution receipts.

7. **App Integration & Presentation Lifecycle:**
   - Wire native app invocation (`DexPulseApp` / `DebugPulseOverlayController`) through the true semantic pipeline:
     `QUIET -> PULSE -> LENS -> VEIL -> RECEDE -> QUIET`.
   - Passive context envelope acquisition during `LENS` with zero focus theft and zero clipboard mutation.
   - Clean dismissal via `cancel()` or `dismiss()` passing through `RECEDE` to `QUIET`.

8. **Verification & Diagnostics:**
   - Headless verification runner (`PulseVerification`) asserting full transition matrix, cancellation convergence, hold semantics, and stale completion rejection.
   - System doctor (`dexpulse doctor`) reporting Phase 3 lifecycle and state engine readiness.
   - Comprehensive unit tests in `Tests/PulseCoreTests`.

## Protected Invariants

- **INV-001 (DexDictate Priority / Focus & Clipboard Non-Theft):** Pulse invocation, state transitions, and context acquisition must never steal focus from the frontmost application or mutate clipboard content.
- **INV-002 (Central Policy & Non-Destructive Execution):** State transitions to `DISPATCH` must remain subject to central capability policy.
- **INV-003 (Deterministic Precedence & Invocation Safety):** Invocation proceeds atomically through `QUIET -> PULSE -> LENS -> VEIL`.
- **INV-006 (Core Runtime Independence):** Zero external package dependencies; uses pure native Swift and Apple Silicon system frameworks.
- **INV-007 (State Machine Causal Convergence):** Cancellation or dismissal from any transient state (`PULSE`, `LENS`, `VEIL`, `ATTUNE`, `STRAND`, `FORK`, `DISPATCH`, `WEAVE`, `RETURN`, `WITNESS`, `RESOLVE`, `FRAY`, `SEVER`) must deterministically converge to `QUIET`. No operation may leave the system stranded in an active or non-responsive state.
- **INV-008 (Stale Completion Protection):** Async completions matching older generation tokens or inactive `runID`s must be discarded without mutating machine state or reviving a finished run.

## Tasks

1. **State Vocabulary & Transition Graph:**
   - Expand `PulseState` in `Sources/PulseCore/PulseState.swift` to all 15 states.
   - Update `PulseStateTransition.isValid(from:to:)` to enforce the full primary loop and failure/cancellation branches while maintaining backward compatibility with Phase 0/1/2 test paths.
2. **Explicit Run Model:**
   - Define `PulseTerminalOutcome` in `Sources/PulseCore/PulseRun.swift`.
   - Implement `PulseRun` struct capturing complete execution lifecycle and generation tracking.
3. **Result Object & Hold Semantics:**
   - Implement `PulseResultObject` in `Sources/PulseCore/PulseResultObject.swift` conforming to `PulseObject`.
   - Implement Result hold mechanism in `PulseStateMachine` to pause auto-recede while inspectable.
4. **Thread-Safe State Machine Upgrade:**
   - Enhance `PulseStateMachine` in `Sources/PulseCore/PulseStateMachine.swift` to manage active runs, validate transitions, record outcomes, reject stale callbacks, handle holds, and guarantee cancellation convergence.
5. **App Shell & Overlay Integration:**
   - Update `DebugPulseOverlayController` to transition `QUIET -> PULSE -> LENS -> VEIL`.
   - Integrate atomic `LensResolver` acquisition during `LENS` phase.
   - Update `DexPulseApp` menu items and diagnostics.
6. **Witness Proof Discipline:**
   - Ensure `WitnessReceipt` records distinct `executed` vs `verified` states and strips raw payloads.
7. **Verification & Diagnostics:**
   - Expand `PulseVerification` with comprehensive state machine assertions.
   - Update `dexpulse doctor` with Phase 3 lifecycle and state engine reporting.
8. **Unit Test Suite:**
   - Create thorough unit tests in `Tests/PulseCoreTests` validating:
     - Permitted vs forbidden transitions (matrix tests).
     - Complete primary success loop.
     - Cancellation convergence across every transient state.
     - Result hold pause and release.
     - Stale/late async callback rejection.
     - Distinct terminal outcome handling.
     - Witness proof distinction.
9. **Full Validation Ladder:**
   - Run `make check`, `swift test`, `PulseVerification`, and CLI doctor.

## Acceptance Criteria

- All unit tests pass cleanly (`swift test`).
- `PulseVerification` asserts Phase 3 lifecycle invariants with 0 failures.
- `dexpulse doctor` confirms Phase 3 state machine readiness.
- Cancellation from every transient state reaches `QUIET`.
- Late async callbacks with outdated runID or generation token are rejected.
- Result hold successfully pauses automatic recede.
- Overlay invocation follows `QUIET -> PULSE -> LENS -> VEIL -> RECEDE -> QUIET` with zero clipboard mutation and zero focus theft.

## Stop Conditions

- Stop if state machine can be left stranded in any state other than `QUIET` after cancellation.
- Stop if late async callback can alter state machine after a run is cancelled or completed.
- Stop if invocation causes focus theft or pasteboard `changeCount` increment.
- Stop if external dependencies are introduced.
