# DEX//PULSE Adversarial Review

This review attacks the planning/source package before it becomes project authority. The optimized repository files already incorporate the repairs below; this document preserves why those changes exist.

## 1. 25 Problems Found

1. **Architecture was beginning to outshine the daily product loop.** A large module map could encourage building abstractions before proving summon -> context -> action -> proof -> Recede.
2. **The Project instruction had insufficient headroom.** OpenAI documents Project instructions but does not publish a stable character ceiling; a ~5K instruction is safer than riding an unknown limit.
3. **The visual fixture checksum path was initially wrong.** The checksum file referenced basenames even though the authoritative MP4s live under `original/`.
4. **Binary visual fixtures risk becoming “described references” instead of byte-authoritative fixtures.** A manifest alone does not substitute for original media.
5. **Lens clipboard fallback was under-specified.** “Safe clipboard fallback” could be misread as silently synthesizing Cmd-C, conflicting with DexDictate priority.
6. **Accessibility permissions were treated too much like setup plumbing.** Denied/revoked AX permission is a runtime product state and must have recovery UX.
7. **Live AX objects lacked an explicit stale-reference contract.** A button/window can disappear or change between Lens resolution and execution.
8. **Capability execution lacked hard deadline semantics.** Cancellation without deadlines leaves hung model/network/Pack work ambiguous.
9. **Pack concurrency was unspecified.** Repeated invocation could race singleton services, duplicate work, or corrupt local state.
10. **Crash/interrupted-run semantics were missing.** Relaunch must not infer that an in-flight command/model/remote operation succeeded.
11. **Durable storage migration behavior was missing.** Pins/Witness/habit schemas will evolve; bad migrations could silently lose or broaden retained data.
12. **Privacy classification existed conceptually but was not enforceable.** Sensitive content could otherwise drift to remote Targets through a generic capability.
13. **Main-thread ownership was insufficiently explicit.** Network/model/Git/storage work could accidentally migrate onto the UI actor and destroy reflex latency.
14. **Error states were too generic.** `failed`, `blocked`, `unavailable`, `timedOut`, `cancelled`, `interrupted`, and `unknown` have different recovery semantics.
15. **Performance targets lacked a reproducible sampling protocol.** A p95 number without warm-up, sample count, hardware/build identity, and raw evidence is weak proof.
16. **Finder and Electron coverage were implied but not acceptance-gated.** QDuo-like parity requires more than Brave/Terminal examples.
17. **DexDictate coexistence could still be broken by hidden selection-copy fallback.** Clipboard restoration after synthetic copy is not equivalent to never interfering.
18. **UI-element inspection could accidentally drift into generic AXPress automation.** AX availability does not imply safe activation authority.
19. **Remote Big Mac routing could become a hidden dependency.** The “holy-shit” V1 slice must still prove itself with Big Mac offline.
20. **Public-repository privacy was policy-only.** The source gate needed an actual check for obvious private home paths and secret patterns.
21. **Reference-project inspiration could ossify into copying.** QDuo and other products must remain mechanism references, not source donors or visual templates.
22. **The first build packet did not explicitly prove cold resumability.** A future agent could still depend on this chat to understand current authority.
23. **Distribution/sandbox posture was unresolved and easy to accidentally hard-code.** Global AX/input tooling and future signing/notarization need an explicit decision lane.
24. **A result was not sufficiently separated from proof.** Executor success must never imply that the larger user goal was verified.
25. **The plan risked scope creep into Teach DEX/Loom/Ghost execution before the fundamental interaction earned trust.** Those are strategically important but not V1 prerequisites.

## 2. 25 Targeted Fixes Applied

1. Keep the three V1 golden journeys and phase gates centered on the complete interaction loop; abstractions may collapse if they lack a V1 consumer.
2. Set an internal 5,000-character Project-instruction budget and reduce the current instruction below it; detailed truth lives in repository docs.
3. Correct `SHA256SUMS.txt` paths to `original/<filename>` and validate them in the source gate.
4. Treat original MP4 bytes + SHA-256 as authority; contact sheets are explicitly derived convenience views.
5. Lock automatic Lens clipboard fallback to **read existing clipboard only**. No synthetic Cmd-C on invocation.
6. Add permission-denied/revoked states and acceptance tests; reauthorization never replays a blocked Reflex.
7. Give transient AX/window/selection objects context-generation identity and revalidate them immediately before execution.
8. Add capability deadlines and distinct timeout state; no timeout may be converted into success.
9. Add descriptor-level concurrency classes (`singleton`, `perObject`, `parallelSafe`) enforced centrally.
10. Define `interrupted/unknown` after crash/relaunch unless terminal proof exists; never auto-resume mutation-like work.
11. Add versioned local-store schemas, tested forward migrations, pre-migration rollback backup, and quarantine/rebuild behavior for optional corrupted stores.
12. Make privacy classes enforce routing: classifiers can increase sensitivity but cannot silently downgrade it.
13. Define Swift concurrency/actor ownership and prohibit shell/model/network/Git/database work on the main actor.
14. Add the explicit terminal/error vocabulary in `docs/ERROR_MODEL.md` with recovery semantics.
15. Add benchmark methodology: exact candidate identity, warm-up, >=100 warm samples, p50/p95/p99, 60-second idle sample, raw evidence retention.
16. Add Finder file selection and VS Code/Electron context rows to V1 acceptance.
17. Make DexDictate coexistence a hard invariant and reject any “fallback” that mutates clipboard merely by opening Pulse.
18. Keep V1 UI-element capability read-only (`Inspect Element`) unless a separately reviewed safe action is later introduced.
19. Make Journeys A-C MacBook-independent of Big Mac; Big Mac/DEX//REACH is an additional target proof with an explicit offline branch.
20. Add source-gate grep checks for obvious private home paths, private-key markers, and token-like secrets.
21. Preserve a clean-room boundary: observed behavior/platform APIs/tests may inform implementation; copied GPL QDuo source may not.
22. Add a V1 cold-start acceptance row: a fresh agent/developer must recover locks, phase, unknowns, and next packet from the repo alone.
23. Add an ADR that keeps sandbox/distribution posture an explicit unresolved decision rather than an accidental implementation side effect.
24. Keep `ResultObject` and `Witness` proof state separate; `executed` is not automatically `verified`.
25. Freeze post-V1 Teach DEX/Loom/Ghost execution outside V1 unless the owner explicitly reslices scope.

## 3. 25 Additional Polish / Uplift Improvements

1. Use stable run IDs and parent run IDs so retries form causal trees instead of rewriting history.
2. Make Target identity visible in Veil/Result/Witness whenever execution may leave the MacBook.
3. Keep Spool and Results memory-only by default to make forgetting the default behavior rather than a cleanup task.
4. Prefer security-scoped bookmarks/stable references for pins over payload copies.
5. Record habit sequences as capability/object/Target IDs, not raw content.
6. Keep visual Strand topology semantic: crossing never means joining; junction nodes do.
7. Treat `RECEDE` as semantic closure and `DISSOLVE` as only a rendering primitive.
8. Pause/release the Metal Strand renderer completely in QUIET.
9. Require reduced-motion parity rather than merely disabling animation.
10. Keep sound subordinate and optional; never use sound as the sole state channel.
11. Preserve whole visible annular hit areas, hysteresis, overshoot tolerance, and pointer-intent stability.
12. Make object-layout changes versioned after layout freeze to protect motor memory.
13. Show reasons for unavailable/blocked capabilities during development instead of silently hiding them.
14. Make Pack trust explicit: V1 Packs are compiled repository-owned adapters, not arbitrary dynamic code.
15. Keep unknown downloaded scripts inspectable via DexGate but non-executable in V1.
16. Use task names for Reflexes rather than model/provider names.
17. Route deterministic/typed operations before model inference to protect latency, privacy, and predictability.
18. Keep local-model classification asynchronous so the Veil can appear from deterministic object knowledge.
19. Make the CLI (`dexpulse doctor`) part of V1 so environment/permissions/Pack routing can be diagnosed without opening debug UI.
20. Store large benchmark artifacts outside Witness; Witness records concise evidence references.
21. Keep the visual reference manifest explicit about provenance and filename timestamp semantics.
22. Make `scripts/validate_planning_source.sh` the phase-zero contract and fold it into `make check` once implementation begins.
23. Make Big Mac a literal Target rather than a hidden backend detail.
24. Preserve public-source hygiene even if the repository later becomes private.
25. Keep the long-term product thesis visible: V1 proves the reflex substrate; Teach DEX/Loom later compress repeated approved behavior into Threads.

## 4. Optimized Output

The optimized output is the **current repository source package**, not a second competing plan. The following files are the revised authority produced from this review:

- `MASTER_IMPLEMENTATION_PLAN.md`
- `PROJECT_BIBLE.md`
- `OPERATIONAL_STATE.md`
- `PROJECT_SYSTEM_INSTRUCTION.md`
- `docs/ARCHITECTURE.md`
- `docs/OBJECT_MODEL.md`
- `docs/PULSEKIT_CAPABILITY_CONTRACT.md`
- `docs/LOCAL_STORAGE.md`
- `docs/ERROR_MODEL.md`
- `docs/PERFORMANCE_BUDGETS.md`
- `docs/V1_ACCEPTANCE_MATRIX.md`
- `docs/VISUAL_LANGUAGE.md`
- `fixtures/visual-references/`

The review is complete only when the source gate passes, required files are published/read back from the canonical repository, and the fixture originals are present with matching hashes. Planning completeness does **not** imply runtime V1 completeness.
