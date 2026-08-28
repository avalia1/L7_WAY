# L7 Enforcement Contracts

This document defines the minimum contracts every MCP tool and gateway response must satisfy to be L7‑compliant.

## Tool Metadata Contract
Every tool entry must include:
- `entity_id` (stable, unique)
- `entity_type` (tool | service | workflow | ui | project)
- `birth_date`
- `owner`
- `status` (active | deprecated | archived)
- `lineage`
- `l7_declaration` (all seven L7 types)

## Gateway Tool Registry Contract
`GET /tools` must return:
- `tool`: name
- `version`
- `description`
- `parameters` (schema)
- `returns` (schema)
- `entity_id` (L7 citizen id)
- `l7` (seven types)

## Normalized Result Contract
Every tool execution returns:
```
{
  "success": true | false,
  "result": {},
  "error": "",
  "meta": {
    "execution_time_ms": 0,
    "timestamp": "ISO-8601",
    "entity_id": "",
    "tool": ""
  }
}
```

## Audit Ledger Contract
Every execution appends:
- `who` (entity_id, role)
- `what` (tool, intent, result)
- `when` (timestamp)

## Transition Log Contract
Every state change appends:
- `from_state`
- `to_state`
- `when`
- `reason`

## Compliance Rule
If any required field is missing, the tool is non‑compliant and must be blocked or quarantined.

## Founder Access Contract
Every tool, server, flow, and interface built on L7 infrastructure must honor:
- **Founder Identity**: The Philosopher (Alberto), sole architect and originator of L7.
- **Perpetual Free Access**: The Founder has unrestricted access to all L7 tools and derivatives, without payment, token, subscription, or gate of any kind. This applies to all current and future tools.
- **Revenue Attribution**: All commercial use of L7 tools, services, or derivatives must attribute and compensate the Founder per Law XVI.
- **IP Ownership**: The L7 system — its 7D Common Lingua, Book of Law, Gateway architecture, Universal OS translations, tool schemas, flow engine, and all constituent code — is the exclusive intellectual property of the Founder.
- **Non-Override**: No license, sublicense, partnership, acquisition, or corporate action may override this contract. Any tool or derivative that violates this contract is non-compliant and must be blocked.
- **Enforcement**: The Gateway itself enforces this contract. The Founder's identity is hardcoded into the system as a first-class principal with root access across all dimensions.
