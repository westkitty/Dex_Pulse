# ADR-0001 — Native macOS Foundation

**Status:** accepted planning decision

DEX//PULSE V1 is Apple-Silicon-native macOS 14+ Swift. Runtime core must not depend on Karabiner, Hammerspoon, Docker, browser extensions, Python, or Node. Use AppKit for event/window/AX control, Core Animation for ordinary transient visuals, Metal for canonical Strand ribbon rendering, and SwiftUI only where persistent surfaces benefit.
