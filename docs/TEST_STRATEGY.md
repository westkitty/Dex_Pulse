# DEX//PULSE Test Strategy

## Principle

Test the claim at the layer where it exists. A unit test cannot prove a non-activating overlay preserves browser focus; a screenshot cannot prove clipboard immutability; source presence cannot prove installed-app performance.

## 1. Pure tests

- object refinement/precedence;
- state transitions and cancellation;
- layout registry determinism;
- annular geometry/hit tests;
- pointer hysteresis/overshoot;
- capability applicability;
- risk/policy rejection;
- Target resolution;
- retention clocks;
- habit redaction/content-free schema;
- Strand spline/mesh/barcode math where pure.

## 2. Local integration tests

- capability registry -> Pack -> Result -> Witness;
- Git read operations against disposable fixture repo;
- Ollama adapter with deterministic fake server + optional live local test;
- Big Mac/DEX//REACH adapter with mock transport + separate real endpoint proof;
- Pack cancellation/timeouts;
- storage migrations.

## 3. Accessibility fixture application

Build a small native test fixture app containing:

- selectable text;
- buttons;
- checkbox/menu/pop-up controls;
- text field and multiline editor;
- secure text field;
- focusable elements with duplicated labels;
- disabled control;
- moving/replaced control to test stale AX identity.

Use it to prove pointer hit testing, focused-element fallback, privacy behavior, and no focus theft.

## 4. External app matrix

V1 mandatory:

- Brave/Chromium;
- Terminal;
- at least one native editor such as TextEdit;
- Finder/file selection path;
- DexDictate coexistence.

Electron/VS Code should be included before V1 completion because QDuo parity and owner workflow make Electron important.

## 5. Visual fixtures

Original MP4s are canonical input fixtures. Build deterministic renderer scenes and capture output at fixed dimensions/times. Human visual review remains required because a numeric pixel metric alone cannot prove ribbon/material correctness.

Future golden outputs go under `fixtures/renderer-goldens/`; never replace owner originals.

## 6. Performance harness

Use os_signpost + controlled invocation scripts/manual runner. Store summarized measurements in test artifacts. Benchmark candidate installed app on MacBook, not only Big Mac.

## 7. End-to-end acceptance

Run `docs/V1_ACCEPTANCE_MATRIX.md` against the installed candidate. Every mandatory row needs specific evidence. Failed/unknown rows remain visible in `OPERATIONAL_STATE.md`.
