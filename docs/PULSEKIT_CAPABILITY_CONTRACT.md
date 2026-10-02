# PulseKit Capability Contract

## Purpose

PulseKit lets DEX//PULSE grow without turning the core into an ever-expanding switch statement for every DEX application, model, script, or service.

V1 uses compiled adapters. Dynamic third-party code loading is explicitly unnecessary for the vertical slice.

## Conceptual Swift protocol

```swift
protocol PulseCapability {
    static var descriptor: PulseCapabilityDescriptor { get }
    func isAvailable(in context: PulseExecutionContext) async -> Availability
    func execute(
        object: AnyPulseObject,
        target: AnyPulseTarget?,
        context: PulseExecutionContext
    ) async throws -> PulseExecutionResult
}
```

The final API may differ, but the contract below is mandatory.

## Descriptor fields

- `id`: stable reverse-DNS or DEX stable identifier;
- `schemaVersion`;
- `title` and short accessible label;
- `acceptedObjectTypes`;
- `acceptedTargetTypes`;
- `targetRequirement`: none | optional | required;
- `sector/layout metadata` by supported object layout;
- `riskClass`;
- `locality`: local-only | remote-allowed | remote-preferred-safe-read;
- `executorKind`;
- `resultType`;
- `supportsCancellation`;
- `requiresNetwork`;
- `requiresAccessibility`;
- `requiresUserConfirmation`;
- `estimatedLatencyClass`;
- `proofContract`;
- `availabilityRequirements`;
- `defaultDeadline`;
- `concurrencyClass`: singleton | perObject | parallelSafe;
- `idempotency`: readOnly | idempotent | nonIdempotentFuture;
- `backgroundContinuation`: forbidden | explicitOnly.

## V1 risk classes

- `observe` — read/inspect only;
- `safeLocal` — bounded reversible/local action with no user-data mutation beyond explicit transient output;
- `projectWriteFuture` — schema-reserved but not executable in V1 by default;
- `destructiveFuture` — schema-reserved and always rejected by the V1 policy engine.

No registered V1 capability may advertise an executable destructive route.

## Execution lifecycle contract

Every invocation receives a unique run ID, cancellation token, deadline, and immutable object/Target identity snapshot. Packs must not silently extend deadlines, replace Targets, or retry non-idempotent work. V1 rules:

- availability checks are bounded and cancellable; slow availability cannot block Veil presentation;
- executors run off the main actor unless a documented AppKit/AX operation requires it;
- concurrency is enforced by the registry/execution layer, not ad-hoc Pack globals;
- timeout produces `timedOut`, never inferred success;
- app termination before proof produces `interrupted/unknown`;
- background continuation is opt-in per Reflex and is forbidden by default in V1;
- retry creates a new run linked to the failed/unknown run rather than rewriting history.

## Proof contract

A capability must declare what evidence it can produce. Examples:

- output bytes/hash;
- command exit status;
- parsed structured response;
- Git status observation;
- file existence after an explicit safe write;
- model response receipt;
- unsupported/unverifiable.

Witness must distinguish `observed`, `executed`, `verified`, `claimed`, and `unknown` rather than treating executor success as proof of every user-visible claim.

## Pack boundary

A Pack is a cohesive set of capabilities plus availability/configuration logic.

V1 planned Pack families:

- Core macOS Pack;
- Git Pack;
- GitHub Pack;
- Ollama Pack;
- DEX//REACH Pack (after standalone endpoint contract proof);
- DexGate Pack;
- DexSpeak Pack;
- DexDiffusion Pack;
- DexSprite Pack;
- DexEnhance Pack;
- DexCast Pack.

Only Packs needed by the vertical slice must be production-complete before V1. All others must be representable without changing the object/capability core.

## Availability

The registry must distinguish:

- capability exists but is unavailable;
- capability requires configuration;
- capability is blocked by policy;
- capability is incompatible with current object;
- capability is temporarily offline;
- capability is ready.

Do not hide every unavailable capability without explanation during development; the debug/inspection surface must expose why routing excluded it.
