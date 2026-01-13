# L7 CLI Spec (Legion Composer)

## Purpose
Provide a minimal command-line interface to discover L7 citizens and compose them into a “legion” manifest.

## Filesystem
- Citizens live in `~/.l7/{entity_id}.l7`
- Template at `~/.l7/entity.template.l7`

## Commands

### 1) List citizens
```
l7 list
```
Outputs all `entity_id` values from `~/.l7/*.l7`.

### 2) Show a citizen
```
l7 show <entity_id>
```
Prints the raw `.l7` file content.

### 3) Compose a legion
```
l7 legion <legion_name> <entity_id> [entity_id...]
```
Creates a manifest at `~/.l7/legions/<legion_name>.json`:

```json
{
  "legion": "<legion_name>",
  "entities": ["entity_a", "entity_b"],
  "created_at": "ISO-8601"
}
```

### 4) Legion manifest (stdout)
```
l7 legion --stdout <legion_name> <entity_id> [entity_id...]
```
Prints the manifest without writing to disk.

## Behavior Rules
- Fail if a requested `entity_id` file does not exist.
- Normalize entity IDs by filename (not by file contents).
- Do not mutate `.l7` files.
- A legion is just a composition pointer; execution remains gateway-driven.
- Marching orders are non-composable directives; composable elements belong to entities/tools.
