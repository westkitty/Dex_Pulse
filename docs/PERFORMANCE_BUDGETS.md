# DEX//PULSE Performance Budgets

Performance is product correctness because Pulse is intended to behave like a reflex, not an application switch.

## Reference runtime

Primary V1 performance target: Andrew's MacBook Air M1, 8 GB unified memory. Big Mac is the canonical development/heavy-compute machine, not an excuse for weak MacBook runtime behavior.

## Initial budgets

| Metric | V1 target | Release ceiling / rule |
|---|---:|---|
| hotkey -> first visible Pulse feedback | p95 <= 50 ms | investigate any repeatable >75 ms path |
| hotkey -> Veil interactable using deterministic state | p95 <= 120 ms | p95 <=150 ms unless documented OS scheduling anomaly |
| deterministic Lens routing | preferred <=30 ms | must not wait for LLM/network |
| idle CPU after settle | <=0.5% average / 60 s | no polling/render loop in QUIET |
| idle RSS | preferred <=120 MB | <=160 MB unless evidence-backed owner revision |
| controlled 60 Hz Veil interaction | <1% missed frames | no recurring visible hitch |
| representative Strand GPU time | target <=4 ms/frame | profile before increasing scene complexity |
| model/network work before Veil | 0 | prohibited |

These are initial engineering budgets, not claims of achieved performance. Change them only with benchmark evidence and an ADR.

## Performance architecture rules

- No continuously active `CVDisplayLink`, `CADisplayLink` equivalent, MTKView draw loop, animation timer, or polling task while `QUIET`.
- Use event-driven Accessibility/window/app observations where available.
- Cache only bounded, invalidatable routing metadata; never build an ambient surveillance index.
- UI animation and hit testing remain on the native hot path; model work runs asynchronously.
- Cancel work promptly when interaction is dismissed if result is no longer useful.
- Metal rendering is demand-driven and paused/released when the Strand surface is absent.
- Do not hide long executor latency with fake visual progress. Witness/Weave must distinguish known progress from indeterminate work.

## Measurement protocol

Release comparisons must be reproducible:

- record exact commit, installed bundle hash/version, macOS version, display refresh rate, power mode, and foreground test app;
- discard a declared warm-up set, then collect at least 100 warm invocations for p50/p95/p99 timing;
- capture raw signpost/benchmark output as an external artifact and store only concise proof references in Witness/Operational State;
- idle CPU/RSS sampling begins after a 10 s settle and runs for at least 60 s;
- renderer tests use fixed fixture scenes and report CPU frame preparation plus GPU frame time separately;
- performance claims must be made on MacBook runtime hardware; Big Mac results are development diagnostics only.

## Required benchmarks

1. cold app launch -> first usable invocation;
2. warm invocation x100 in native editor;
3. warm invocation x100 in Brave;
4. warm invocation x100 in Terminal;
5. UI-element hit-test invocation x100;
6. Veil directional sweep synthetic pointer path;
7. canonical renderer scenes at 60 Hz;
8. 120 Hz where actual display supports it;
9. low-memory-pressure run on MacBook;
10. Big Mac unavailable / Ollama timeout branch.

Record raw result files outside Witness when large; store concise summarized evidence in Operational State.
