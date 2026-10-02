# DEX//PULSE Reference Projects and Transferable Lessons

This is a mechanism reference list, not a dependency list. Prefer original implementations and platform APIs; do not copy protected/GPL code into Pulse without an explicit license decision.

| Project/system | Transferable lesson | Boundary |
|---|---|---|
| QDuo — https://github.com/XueshiQiao/qduo | selection-at-cursor UX, AX/clipboard edge cases, radial disclosure, model/actions coexistence | behavioral reference; GPL source is not a code donor |
| Quicksilver — https://qsapp.com / developer docs | direct object -> action -> indirect object grammar; results can become objects | conceptual grammar |
| Kando — https://kando.menu | stable marking-menu geometry, gesture expertise, nested radial depth | interaction mechanism only |
| Alfred Universal Actions — https://www.alfredapp.com/help/workflows/triggers/universal-action/ | typed compatible actions and chaining | conceptual |
| LaunchBar — https://www.obdev.at/products/launchbar/ | Instant Send / object-to-target flow | conceptual |
| BetterTouchTool — https://docs.folivora.ai | reusable named actions, contextual trigger layers, merged global/app context | do not make BTT a runtime dependency |
| Shortcat — https://shortcat.app | Accessibility elements as first-class targets | conceptual/platform API lesson |
| Raycast — https://manual.raycast.com | typed tool contracts, permissioned actions, compact launcher ergonomics | conceptual |
| Model Context Protocol — https://modelcontextprotocol.io | tools/resources/prompts as a future integration boundary | future Pack transport, not V1 core dependency |
| Apple App Intents — https://developer.apple.com/documentation/appintents | native action/entity exposure | post-core system integration |
| Hammerspoon — https://www.hammerspoon.org | modular automation packages and macOS capability surface | do not require Lua/Hammerspoon |
| Node-RED — https://nodered.org | message envelopes, flow/global scopes, causal IDs | Witness/context model inspiration |
| Home Assistant — https://developers.home-assistant.io | explicit action registry, context IDs, automation traces | proof/trace inspiration |
| Keysmith — https://www.keysmith.app | demonstrate a routine then replay | post-V1 Teach DEX inspiration |
| OpenAdapt — https://github.com/OpenAdaptAI | demonstrations -> governed workflows + independent verification | post-V1 Teach DEX inspiration |
| Dropover — https://dropoverapp.com | temporary cross-app Carry shelf | Spool inspiration |
| Hookmark — https://hookproductivity.com | durable contextual links/related objects | provenance/reference inspiration |
| Karabiner-Elements — https://karabiner-elements.pqrs.org | rich trigger state/conditions | reference only; forbidden runtime dependency |

## Derived design rules

- Context and type should filter capabilities before AI ranking.
- Spatial layouts are learned motor mappings and must be stable after freeze.
- Actions/results/targets are typed objects, not unstructured strings.
- Capability execution needs traceable causality and proof state.
- Repeated workflows should eventually compress into explicit user-approved Threads, not silent automation.
