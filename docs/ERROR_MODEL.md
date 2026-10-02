# DEX//PULSE Error and Result Model

Executors and UI must use explicit terminal semantics rather than a generic `Error` bucket.

## Terminal states

- `succeeded` — requested executor operation completed; may still be only `executed`, not `verified`.
- `cancelled` — user/system cancellation acknowledged.
- `blocked` — central policy or permission intentionally prevented execution.
- `unavailable` — capability/target/service currently cannot run.
- `timedOut` — deadline expired without a trustworthy terminal result.
- `failed` — executor returned a concrete failure.
- `interrupted` — app/process ended before terminal evidence.
- `unknown` — evidence is insufficient to determine what happened.

## Proof states

Witness separately records:

- `observed`
- `executed`
- `verified`
- `claimed`
- `unknown`

A successful process exit may prove `executed`; it does not automatically prove the user's larger goal.

## Recovery contract

Every non-success result declares applicable recovery actions: retry, choose another Target, inspect evidence, reauthorize, reopen source, or dismiss. Recovery is never invented from unavailable evidence.
