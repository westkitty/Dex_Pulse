# ADR-0002 — Lens Context Precedence

**Status:** accepted planning decision

Primary object resolution order is fixed: explicit selected text/file -> UI element under pointer -> focused Accessibility element -> frontmost window/application -> existing clipboard fallback. Automatic Lens resolution may read the existing clipboard but must never synthesize copy/replace clipboard contents merely to invoke Pulse.
