# L7_WAY Enforcement

## Compliance Criteria
A project is compliant if:
- It uses the MCP Gateway as the only tool entry point.
- UI and components only use adapters.
- Adapters validate schema and normalize results.
- Project start files declare MCP Gateway usage.
- Project declares L7 emoji markers for the common lingua.

## Project Start Files (must declare compliance)
At least one of the following must include the MCP gateway declaration:
- `README.md`
- `PLAN.md`
- `AGENTS.md`
- `ARCHITECTURE.md`

## Required Declarations (examples)
"This project uses the MCP Gateway as the universal entry point for tools. UI uses adapters only."
"L7 lingua: Capability 🔧, Data 📦, Policy/Intent 🧭, Presentation 🧩, Orchestration 🔗, Time/Versioning 🕒, Identity/Security 🛡️."

## Enforcement Flow
1. Detect projects under home directory.
2. Find project start files.
3. Check for the required declaration strings.
4. Report non-compliant projects.

## Output
- Write reports to `~/L7_WAY/daemon/reports/`.
- Do not auto-edit projects; report only.
