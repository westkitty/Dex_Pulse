# DEX//PULSE

DEX//PULSE is a native macOS contextual action layer built around one principle:

> Anything done repeatedly should become easier to reach. Anything consequential should remain explicit, inspectable, and provable.

Version 1 is Andrew-first. It is designed as a reusable DEX product, but its first job is to become an extremely fast, local-first interaction layer across Andrew's MacBook, Big Mac, projects, tools, and DEX ecosystem.

## V1 vertical slice

The first complete experience is:

`QUIET -> PULSE -> LENS -> VEIL -> object-specific Reflex -> optional Target -> real execution -> Result Object -> WITNESS -> RECEDE -> QUIET`

V1 must support real context acquisition from selected text/files, UI elements under the pointer, focused Accessibility elements, the frontmost app/window, and safe clipboard fallback. The core app is native Swift and must not require Karabiner, Hammerspoon, Docker, a browser extension, Python, Node, or another runtime in order to function.

## Source-of-truth order

When project documents disagree, use this order:

1. `PROJECT_BIBLE.md` — current product intent, locked user decisions, and non-goals.
2. `OPERATIONAL_STATE.md` — current evidence state, invariants, unknowns, and pending work.
3. `MASTER_IMPLEMENTATION_PLAN.md` — staged build plan through the V1 vertical slice.
4. `docs/decisions/` — accepted architecture decisions.
5. `docs/VISUAL_LANGUAGE.md` and `fixtures/visual-references/` — visual/motion authority.
6. `docs/*` specialist contracts.
7. implementation and tests once code exists.

The uploaded visual reference videos are repository fixtures, not mood-board suggestions. Any Strand renderer that fails to match their ribbon geometry, transverse barcode segmentation, twist, face/underside behavior, crossing clarity, and restrained glow is incorrect even if it is attractive.

## Read first

- [`PROJECT_BIBLE.md`](PROJECT_BIBLE.md)
- [`OPERATIONAL_STATE.md`](OPERATIONAL_STATE.md)
- [`MASTER_IMPLEMENTATION_PLAN.md`](MASTER_IMPLEMENTATION_PLAN.md)
- [`PROJECT_SYSTEM_INSTRUCTION.md`](PROJECT_SYSTEM_INSTRUCTION.md)
- [`docs/V1_ACCEPTANCE_MATRIX.md`](docs/V1_ACCEPTANCE_MATRIX.md)
- [`docs/VISUAL_LANGUAGE.md`](docs/VISUAL_LANGUAGE.md)

## Current state

Phase 0/1 native bootstrap foundation active on Apple Silicon macOS 14+. Core Swift Package graph, native AppKit utility shell (`DEX_PULSE.app`), diagnostic CLI (`dexpulse doctor`), headless verifier (`PulseVerification`), and pre-commit gate (`make check`) are implemented and verified.

## Build and verification

```sh
# Single deterministic pre-commit quality gate (validates source, fixtures, build, tests, verifier, doctor)
make check

# Build native macOS application bundle (build/DEX_PULSE.app)
make app

# Install application and CLI into user directories (~/Applications and ~/.local/bin)
make install-user

# Verify canonical visual fixtures against SHA-256 sums
make verify-fixtures
```

## Provisional choices

These can change without invalidating the architecture:

- license: MIT or Unlicense;
- repository visibility: public now for tool access, not a product requirement;
- default hotkey: `Shift-Command-Space` is the current provisional candidate and must remain configurable.

Do not treat provisional choices as locked requirements.
