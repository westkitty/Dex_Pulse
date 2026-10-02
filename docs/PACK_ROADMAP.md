# DEX//PULSE Pack Roadmap

Packs are adapters over PulseKit. This file tracks intended integration families without forcing them into V1 completion.

| Pack | V1 role | Initial allowed scope |
|---|---|---|
| Core macOS | mandatory | AX inspect, file/app/window metadata, open/reveal safe actions |
| Git | mandatory | status/diff/history/read-only repo inspection |
| Ollama | mandatory | local Diagnose/Explain; model is executor detail |
| GitHub | useful V1 | authenticated/public read context; no mutation required for V1 |
| DEX//REACH | useful V1 | safe read/inference target routing; machine identity visible |
| DexGate | boundary V1 | inspect unknown scripts; no execution route in V1 |
| DexSpeak | post-core Pack | text -> local speech result |
| DexDiffusion / DexGen | post-core Pack | visual brief -> image-generation job/result |
| DexSprite | post-core Pack | image/art -> sprite asset workflow |
| DexEnhance | post-core Pack | image enhancement/upscale pipeline |
| DexCast | post-core Pack | casting/media target actions |

A Pack must not require a change to the Object grammar, policy engine, Witness model, or Veil core to integrate.
