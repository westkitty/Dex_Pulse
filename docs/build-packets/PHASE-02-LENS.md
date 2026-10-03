# Build Packet — Phase 2 Context Envelope + Lens

## Objective

Build the native invocation-time context acquisition system (`PulseLens`) that captures a bounded, typed, provenance-aware `PulseContextEnvelope` at the exact moment of explicit Pulse invocation, strictly adhering to the deterministic 5-tier context precedence hierarchy without synthetic copy events, clipboard mutation, screen recording, or focus theft.

## Scope

- Centralized coordinate translation (`LensCoordinates`) between AppKit screen coordinates (bottom-left origin) and CoreGraphics/Accessibility coordinates (top-left origin).
- Accessibility authorization probe (`AccessibilityAuthorizer`) checking process trust status non-invasively.
- Native candidate providers implementing `LensAcquisitionProvider`:
  1. `SelectedTextProvider` & `SelectedFileProvider` (Tier 1: Explicit selected content).
  2. `PointerElementProvider` (Tier 2: UI element under pointer via `AXUIElementCopyElementAtPosition`).
  3. `FocusedElementProvider` (Tier 3: Focused Accessibility element).
  4. `FrontmostAppProvider` (Tier 4: Frontmost application and window).
  5. `ClipboardFallbackProvider` (Tier 5: Read-only existing clipboard snapshot).
- Deterministic resolver (`LensResolver`) enforcing Tier 1 > Tier 2 > Tier 3 > Tier 4 > Tier 5 with confidence and evidence rationale.
- Deterministic type refinement (`TypeRefiners`) recognizing URL, file path, code snippet, error log, and JSON from raw text while preserving original object ancestry and provenance.
- Security and privacy protection: blocking payload capture from secure/password fields (`privacyClass = .secureBlocked`).
- Stale context validation (`StaleContextValidator`) with generation tokens and live reference verification.
- Synthetic Accessibility test fixture application (`PulseLensFixtureApp`) for headless and interactive validation of controls, secure fields, selectable text, and duplicated labels.
- Integration into `dexpulse doctor`, `PulseVerification`, and unit test suite.

## Protected Invariants

- **INV-001 (DexDictate Priority):** Pulse invocation and Lens acquisition must never mutate the clipboard, clear/swap pasteboard contents, alter frontmost application focus, or inject synthetic keystrokes (`Cmd-C`). Existing clipboard content is strictly read-only and evaluated only as the lowest fallback tier.
- **INV-002 (No Destructive Execution):** Lens only inspects UI elements and context metadata; it never invokes UI actions or executes destructive reflexes.
- **INV-003 (Deterministic Precedence):** Precedence order is locked (Selected Content > Pointer Element > Focused Element > Frontmost App/Window > Clipboard Fallback). Resolution does not rely on heuristics, AI, or timing races.
- **INV-006 (Core Runtime Independence):** Zero third-party dependencies; uses native macOS frameworks (`ApplicationServices`, `AppKit`, `Foundation`).

## Tasks

1. **Build Packet & State Alignment:** Verify and maintain `docs/build-packets/PHASE-02-LENS.md` and correct phase numbering in `OPERATIONAL_STATE.md`.
2. **PulseCore Extensions:** Enhance `PulseObject.swift` with privacy classifications (`public`, `ordinary`, `sensitive`, `secureBlocked`), extended V1 object models (`SelectedFileObject`, `WindowObject`, `ApplicationObject`, `CodeSnippetObject`, `ErrorLogObject`, `URLObject`, `PathObject`, `JSONTextObject`), context generation tokens, and complete `PulseContextEnvelope`.
3. **Coordinate Engine:** Implement `LensCoordinates` for bidirectional AppKit <-> Carbon/CG/AX point mapping and screen frame handling across multi-monitor setups.
4. **Accessibility Authorizer:** Implement `AccessibilityAuthorizer` checking `AXIsProcessTrusted()` cleanly without prompting or blocking.
5. **Context Acquisition Providers:**
   - `SelectedTextProvider`: native AX selected text extraction with whitespace rejection and secure-field payload blocking.
   - `SelectedFileProvider`: Finder/desktop file selection extraction via AX or explicit degraded status.
   - `PointerElementProvider`: pointer hit-testing via `AXUIElementCopyElementAtPosition` extracting role, title, and bounds.
   - `FocusedElementProvider`: focused element extraction.
   - `FrontmostAppProvider`: frontmost application bundle, PID, and window title.
   - `ClipboardFallbackProvider`: read-only pasteboard inspection without writing or altering `changeCount`.
6. **Deterministic Resolver & Refiners:**
   - Enforce 5-tier resolution and generate explanatory acquisition reason.
   - Refine text objects into URL, Path, Code, ErrorLog, or JSON while retaining source provenance.
7. **Stale Context Guard:** Implement token-based and AX-element revalidation.
8. **Synthetic AX Fixture App:** Build `PulseLensFixtureApp` executable target with native AppKit window, text view, secure field, buttons, and disabled controls.
9. **Diagnostics & Verification:** Update `dexpulse doctor` and `PulseVerification` with Lens diagnostics.
10. **Test Suite:** Implement comprehensive unit and integration tests in `Tests/PulseLensTests`.
11. **Live System Probes:** Run live checks against fixture app, TextEdit, Terminal, Brave, Finder, documenting exact behavior and graceful degradation.

## Acceptance Criteria

- `make check` passes cleanly.
- `PulseLensTests` verify precedence hierarchy (Tier 1 through 5), whitespace rejection, secure field blocking, refinement provenance, stale context rejection, coordinate translation, and clipboard read-only immutability.
- Synthetic fixture app builds, runs, and exposes inspectable AX elements.
- `dexpulse doctor` reports Accessibility authorization status and Lens provider readiness without errors.
- Opening and resolving Lens context never changes `NSPasteboard` changeCount or content.
- Graceful degradation occurs when Accessibility permissions are not granted (falling back to frontmost app or clipboard without crashing).

## Stop Conditions

- Stop if context acquisition requires synthesizing keystrokes or `Cmd-C`.
- Stop if clipboard contents or changeCount are modified during Lens resolution.
- Stop if frontmost application loses focus or is activated during passive hit-testing.
- Stop if secure text fields leak unmasked text into `PulseObject`.
- Stop if third-party libraries or browser extensions are required.
