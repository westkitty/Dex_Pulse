# DEX//PULSE Development Workflow

## Branch/change discipline

V1 work should be phase-scoped. Prefer one cohesive branch/change set per build packet or bounded repair. Do not mix architecture rewrites with visual polish and Pack additions.

Before substantive work:

1. read Project Bible + Operational State + active build packet;
2. verify target machine/repo/branch;
3. run planning/fixture validation;
4. declare affected invariants and acceptance rows.

Before merge to `main`:

- `make check` (once implementation exists);
- relevant installed-app/manual acceptance for behavior claims;
- visual fixture QA for renderer changes;
- DexDictate coexistence checks for focus/clipboard/AX/hotkey changes;
- update Operational State from evidence;
- update ADR/plan only when the durable contract changed.

## Commit policy

Commit messages should name the behavior/scope, not the agent/tool. Do not claim `verified` in a commit message unless the associated proof actually ran.

## Release posture

V1 vertical-slice completion is not automatically a public binary release. Developer ID signing/notarization/update-channel decisions may follow after the native V1 acceptance gate. Direct-distribution vs Mac App Store/App Sandbox remains a deliberate decision; do not contort V1 architecture around App Store requirements without owner approval.

## Planning-source publication

The planning package itself is a governed artifact. Before publication run `scripts/validate_planning_source.sh`, verify the remote repository by re-reading required files, and record the resulting commit identity in Operational State. Binary canonical visual fixtures must be hash-verified after clone; a manifest without the original bytes is not equivalent evidence.

## Agent cold-start rule

A new agent starts from README -> PROJECT_BIBLE -> OPERATIONAL_STATE -> active MASTER plan phase. It must not require hidden chat history to identify the next build packet.
