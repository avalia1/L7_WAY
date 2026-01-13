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
