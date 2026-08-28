# L7_WAY Architecture

## Mission
Create a single common language that lets any tool, workflow, UI, or project plug into MCP systems without fragmentation.

## System Model
- **Registry**: Canonical index of tool names, schemas, versions, and metadata.
- **Gateway**: Universal access layer (`/tools`, `/execute`) that routes to MCP servers.
- **Tools**: Capabilities exposed via MCP servers; discoverable, versioned, swappable.
- **Clients**: Adapter layer + UI (UI is a renderable tool consuming structured data).

## 7D Common Lingua (System Dimensions)
Every entity must declare itself using the same seven L7 types:
1. **Capability** 🔧: what tools and actions exist.
2. **Data** 📦: schemas, inputs, outputs, and sources.
3. **Policy/Intent** 🧭: what is allowed, required, and prioritized.
4. **Presentation** 🧩: how information is rendered.
5. **Orchestration** 🔗: sequencing, workflows, and automation.
6. **Time/Versioning** 🕒: evolution, compatibility, and deprecation.
7. **Identity/Security** 🛡️: access control, audit, and trust.

## Citizenship Rule (Empire Minimum)
Every project, tool, or client must declare itself through the gateway using the L7 types above. This declaration is the minimum requirement for interoperability.

## Registry Rule
Every entity must register with:
- `entity_id`, `entity_type`, `birth_date`, `owner`, `status`, `lineage`, and `l7_declaration`.
- See `ENTITY_REGISTRY.md` and `REGISTRY_SCHEMA.json`.

## Type Boundary
Entity type is absolute and sits outside the L7 declaration. L7 describes the entity; type defines what it is.

## Interoperability Rule
The registry is automatically propagated through the gateway. Clients do not maintain their own copies; they discover tools at runtime.
Once an entity is inside, provinces do not need explicit change notices; the gateway is the propagation layer.

## Uniqueness and Composition Rule
- **Uniqueness prevents duplication**, not experimentation.
- **Units should be small and composable** at the base layer.
- **New L7 entities are formed by citizen groups** (composed units), not monoliths.

## Marching Orders Rule (Non-Composable)
Marching orders are non-composable mission logic and constraints for a legion. They define what must be done and under what constraints, while composition stays with citizens and legions. If something is composable, it belongs to the entity/tool layer, not the orders. This keeps missions simple and preserves composability.

## Non-Negotiables
1. **Gateway-only access** for tools (no direct MCP server calls from clients).
2. **Adapters only** in clients; UI never references tool names or endpoints.
3. **Schema validation** before execution.
4. **Normalized results**: `{ data, error, meta }`.
5. **Config-only credentials**.

## Common Language
- All tool calls use gateway contract: `GET /tools`, `POST /execute`.
- Tools are addressed by stable names and versions.
- Responses are normalized and human-safe for UI.

## Migration Rule
Any project not aligned to this architecture must be called to migrate before new feature work.

## Doctrine
**Doctrine I — The Translator**  
All complexity must be expressed through L7.  
If it cannot be translated, it cannot enter the empire.

**Doctrine II — The Apprentice**  
Every new project is an apprentice.  
It earns agency by declaring L7, registering its birth, and speaking through adapters.

**Doctrine III — The Sacred Work**  
Work and space are sacred.  
The gateway prevents duplication, enforces composability, and turns similarity into reuse.
