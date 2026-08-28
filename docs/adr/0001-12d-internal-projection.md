# ADR 0001 — 12D is an internal projection

Status: accepted
Date: 2026-08-28

## Decision

The public lingua is **declared 7D** (`schema/v1/common-lingua.schema.json`). The dodecahedron 12D coordinate is an internal projection for field scoring. It does not grant **identity** or **domain**.

`GET /v1/tools` returns `l7` only when a tool declares it. `dodecahedron.fromTool()` must not mint identity, domain, or a public 7D block.

Phase 6 (identity) and Phase 7 (domains) are out of scope for this contract.
