# DEX//PULSE Environment Fingerprint

Do not fill unknown values from memory. Record direct command/tool evidence during Phase 0.

## Big Mac — canonical development/heavy compute

| Field | Current evidence |
|---|---|
| machine identity | pending direct fingerprint |
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
| architecture | owner states M1; verify in Phase 0 |
| macOS | verify current installed version |
| memory | owner states 8 GB; verify if used in benchmark report |
| display refresh paths | enumerate actual connected displays during performance QA |
| Accessibility permission | runtime test required |
| DexDictate install/bundle/version | runtime test required |
| provisional Pulse hotkey conflicts | runtime test required |
| local Ollama availability | detect, never assume |
| Big Mac reachability | detect per run |

## Fingerprint rule

Pin toolchain/build assumptions only after this table has direct evidence. A later OS/Xcode update invalidates affected build/performance evidence and triggers recheck.
