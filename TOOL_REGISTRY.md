# L7_WAY Tool Registry (Canonical)

This registry defines how tools are discovered and used. It is intentionally minimal: the live source of truth is the gateway `/tools` endpoint.

## Live Source of Truth
- `GET {MCP_GATEWAY_URL}/tools`
- Cache locally if needed, but always treat gateway results as authoritative.

## Core Tool Categories (Minimal)
- **Comms**: email, SMS, voice, messaging
- **Data**: fetch teachers, reports, analytics, exports
- **Automation**: workflows, batch operations, schedulers
- **UI**: renderable UI components or layout outputs
- **Search/Research**: knowledge retrieval, summarization, web search

## Registry Rules
- Tool names are stable and versioned for breaking changes.
- New tools must be registered in the gateway before client adoption.
- Clients should not assume tool availability; they must discover tools at runtime.

## Update Procedure (Latest State Only)
1. Query gateway `/tools`.
2. Verify tool schema (params, returns, auth).
3. Update adapters in clients as needed.
4. Do not store stale or expanded copies of tool lists here.
