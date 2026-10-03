# DEX//PULSE Environment Fingerprint

Do not fill unknown values from memory. Record direct command/tool evidence during Phase 0.

## Big Mac — canonical development/heavy compute

| Field | Current evidence |
|---|---|
| machine identity | pending direct fingerprint (unreachable on local network during Phase 0) |
| architecture | pending direct fingerprint |
| macOS | pending direct fingerprint |
| Xcode / build version | pending direct fingerprint |
| Swift | pending direct fingerprint |
| Metal compiler/metallib | pending direct fingerprint |
| signing identities | pending direct fingerprint |
| available disk | pending direct fingerprint |
| Ollama endpoint/models | pending direct fingerprint |
| DEX//REACH identity | pending direct fingerprint |

## MacBook — primary runtime/operator/CLI

| Field | Current evidence |
|---|---|
| machine identity | `MacBook-Air.local` (Model: `MacBookAir10,1`, Apple Silicon M1 7-core GPU, 8-core CPU) |
| architecture | `arm64` (Apple Silicon T8103) |
| macOS | macOS 26.6.2 (Darwin 25.6.0, Build 25G83) |
| memory | 8 GB unified memory (8589934592 bytes) |
| toolchain | Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101), Command Line Tools `/Library/Developer/CommandLineTools` |
| Metal compiler | Standalone `xcrun metal` not in Command Line Tools; runtime Metal 4 supported |
| signing identities | `DexDictate Development` (valid identity present) |
| display refresh paths | Dual display detected: External ELEFW328 (1280x768 @ 60.00Hz, Main), Internal Color LCD (2560x1600 Retina) |
| Accessibility permission | Runtime check required on app launch |
| DexDictate install/bundle/version | Installed at `/Applications/DexDictate.app`, active PID running, bundle `com.westkitty.dexdictate.macos` |
| provisional Pulse hotkey conflicts | No conflict observed: DexDictate trigger is Middle Mouse (button 2); Pulse provisional is `Shift-Command-Space` |
| local Ollama availability | Available on `http://127.0.0.1:11434`; model `qwen3.8:27b-mlx` detected |
| Big Mac reachability | `bigmac.local` unreachable on current network; marked pending |

## Fingerprint rule

Pin toolchain/build assumptions only after this table has direct evidence. A later OS/Xcode update invalidates affected build/performance evidence and triggers recheck.
