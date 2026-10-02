# ADR-0008 — Transient by Default

**Status:** accepted planning decision

Spool entries and ordinary Result Objects are memory-only unless explicitly pinned/kept. Pinning prefers durable references over payload copies. Witness structured records retain 30 days by default; content-free habit aggregates retain 180 days by default. These defaults may be owner-revised later without changing the object grammar.
