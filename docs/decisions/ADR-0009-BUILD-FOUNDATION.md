# ADR-0009 — Reproducible Command-Line Build Foundation

**Status:** proposed; validate during Phase 0/1

Prefer Swift Package Manager plus standard macOS toolchain/build scripts as the source-of-truth build path so Big Mac development and MacBook operator tooling do not depend on a third-party project generator. App bundling/signing/Metal compilation should be scripted with standard Apple tools. If the real AppKit/Metal workflow proves materially safer with an Xcode project, revise this ADR before implementation rather than silently drifting.
