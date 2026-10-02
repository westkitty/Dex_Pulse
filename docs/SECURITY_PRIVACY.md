# DEX//PULSE V1 Security and Privacy Model

## Threat model

Pulse sits near selected text, Accessibility elements, files, local executors, models, and remote targets. The primary V1 risks are accidental context capture, wrong-target execution, secret leakage, malicious Pack behavior, shell injection, stale object references, and cross-app focus/clipboard corruption.

## Data minimization

- Context is captured on explicit invocation, not continuously.
- No screen recording or ambient screenshot history.
- OCR is explicit user capture only.
- Habit learning uses Pulse interaction metadata, not ambient activity or payload contents.
- Witness stores the narrowest proof needed for the claimed action.
- Secure/password field values are never read into ordinary Pulse objects.

## Storage classes

### Memory-only

- ordinary Spool entries;
- transient Result Objects;
- live AX element references;
- unpinned context envelopes.

### Durable local

- user configuration;
- pinned object references;
- Witness structured receipts (30-day default);
- content-free habit aggregates (180-day default);
- optional user-preserved Result payloads.

### Secrets

Use Keychain or executor-owned secure storage. Never write API tokens, passwords, SSH keys, private endpoints with credentials, or model secrets to Git/config/Witness.

## Execution safety

- V1 has no executable destructive capability.
- Capability policy is enforced centrally before Pack execution.
- Pack descriptor claims cannot elevate risk authority.
- Shell arguments must use structured process invocation where possible; avoid shell-string concatenation.
- Any explicit shell-script capability must pass text only through a defined boundary and quote/escape correctly; unknown downloaded scripts route to DexGate inspection and still do not execute in V1.
- Remote Target identity must be visible in the interaction/Witness record.
- Result state must distinguish executor success from user-visible verification.

## Pack trust boundary

V1 Packs are compiled, repository-owned adapters. Dynamic arbitrary code loading is not part of V1. A Pack cannot grant itself permission, bypass central policy, replace object/Target identity after confirmation, or write directly to Witness/habit storage outside typed interfaces. Pack network/locality requirements must be declared before applicability.

## Public-repository boundary

Never commit:

- real Witness/habit databases;
- personal selected text;
- machine credentials;
- API tokens;
- SSH material;
- private repo data;
- absolute private paths unless intentionally generic/test fixture paths;
- user-specific endpoint credentials;
- crash dumps containing private payloads.

Fixture data must be synthetic except for owner-approved visual-reference media.
