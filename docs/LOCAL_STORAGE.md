# DEX//PULSE Local Storage and Recovery Contract

## Storage classes

Use one application-support root with versioned schemas. Keep secrets in Keychain, not this root.

Suggested logical stores:

- `config` — settings, hotkey, enabled Packs, policy preferences;
- `pins` — durable object references and minimal metadata;
- `witness` — structured execution receipts;
- `habits` — content-free aggregate interaction counts/sequences;
- `cache` — bounded rebuildable metadata only.

Spool/live Results and AX references remain in memory.

## Schema rules

- every durable record format has explicit schema version;
- migrations are forward-only, tested, and preserve rollback backup for the pre-migration store until successful reopen;
- unknown future fields are preserved where safe rather than silently discarded;
- corrupt optional stores may be quarantined/rebuilt, not silently treated as valid;
- no migration may convert content-free habits into payload-bearing history.

## Pins

Prefer stable references: URL/bookmark/file bookmark/repo identity/project ID/etc. If the referenced object moves or becomes inaccessible, mark the pin stale and ask for repair; never silently bind a same-named substitute.

## Interrupted execution

A crash/relaunch must never infer that in-flight work succeeded.

- Witness records created before dispatch may reopen as `interrupted/unknown` if no terminal proof exists.
- Do not automatically resume shell/network/remote mutations after relaunch.
- Remote read/inference results may be re-requested only through a fresh Reflex unless the executor exposes a proven idempotent resume token.
- Stale AX element references die with their context and are never serialized as reusable live handles.
