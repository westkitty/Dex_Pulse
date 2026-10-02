# Build Packet — Phase 0/1 Bootstrap

## Objective

Turn the planning-only repository into a reproducible native macOS skeleton without prematurely implementing advanced visuals or Packs.

## Preconditions

- Read `PROJECT_BIBLE.md`, `OPERATIONAL_STATE.md`, `MASTER_IMPLEMENTATION_PLAN.md`.
- Verify visual fixture hashes.
- Fingerprint Big Mac and MacBook environments; do not guess tool versions.
- Preserve V1 no-destructive and DexDictate priority invariants.

## Tasks

1. Create `Package.swift` with initial targets: `PulseCore`, `PulseKit`, `PulseLens`, `PulseInteraction`, `PulseVisuals`, `PulseWitness`, `DexPulseApp`, `DexPulseCLI`, `PulseVerification`, and tests. Collapse modules only if build friction proves the split unjustified.
2. Add native app entry and minimal non-activating overlay window that can be shown/dismissed without focus theft.
3. Add configurable global-hotkey service; provisional default `Shift-Command-Space`.
4. Add semantic Pulse state machine with `QUIET`, `PULSE`, `VEIL`, `RECEDE` first; unused future states may exist as enum cases but not fake implementations.
5. Add `dexpulse doctor` exposing build/version, permission status, detected Targets, and Pack availability without secrets.
6. Add `PulseVerification` runner and basic state/policy tests.
7. Add `scripts/build_app.sh`, `scripts/install_user.sh`, and Makefile targets `check`, `app`, `install-user`, `verify-fixtures`.
8. Compile Metal source only if/when Phase 6 renderer source exists; scaffold resource path now without adding placeholder visual claims.
9. Add macOS CI build/test job.
10. Update `OPERATIONAL_STATE.md` with only directly proven results.

## Acceptance

- `make check` passes on Big Mac.
- `.app` bundle builds and launches.
- hotkey shows/dismisses a plain debug overlay without stealing focus.
- `dexpulse doctor` executes on the MacBook from installed artifact.
- opening/dismissing the debug overlay does not change clipboard content/change count.
- no prohibited runtime dependency is introduced.

## Stop conditions

Stop if app launch requires an unapproved runtime helper; global hotkey collides with DexDictate; overlay focus behavior is unsafe; clipboard changes merely from invocation; or the build path cannot be reproduced from repository instructions.
