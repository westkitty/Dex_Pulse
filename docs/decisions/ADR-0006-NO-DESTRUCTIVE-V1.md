# ADR-0006 — No Executable Destructive Capability in V1

**Status:** accepted planning decision

V1 may reserve destructive risk types in schema for compatibility, but central policy rejects them before executor entry and V1 Packs expose no destructive implementation. This includes recursive deletion, force reset/push, irreversible overwrite, privilege-changing system mutation, and equivalent high-impact routes.
