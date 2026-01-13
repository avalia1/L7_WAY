# L7_WAY Entity Registry

This registry defines the minimal metadata every entity must declare. An entity can be a tool, service, workflow, UI component, or project.

## Required Fields
- `entity_id`: stable identifier (string)
- `entity_type`: tool | service | workflow | ui | project
- `birth_date`: ISO-8601 date
- `owner`: accountable person or team
- `status`: active | deprecated | archived
- `lineage`: parent entity or predecessor (if any)
- `l7_declaration`: full L7 metadata block

## Lifecycle Stages
- **summoned**: scoped and named
- **oath**: L7 + gateway compliance declared
- **formed**: adapters and interfaces exist
- **serving**: in active use
- **mature**: stable, versioned, documented
- **sunset**: decommission in progress
- **archived**: fully decommissioned

## Composition Rule
Entities should be small and composable. New entities are formed by citizen groups (composed units), not monoliths.

## Registry Rule
Entities without a birth date, L7 declaration, or owner are non-compliant.
