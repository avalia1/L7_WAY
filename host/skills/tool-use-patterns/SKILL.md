---
name: tool-use-patterns
description: "Design tool-using agents: parallel tools, tool choice, Pydantic schemas, memory tools, structured JSON extraction, and vision+tools from Anthropic and OpenAI cookbooks."
metadata:
  {
    "openclaw": {
      "emoji": "🛠️",
      "always": false
    },
    "l7": {
      "suite": "Herald",
      "does": "automate",
      "tagline": "Tool use & structured calling",
      "entity_id": "skill.tool-use-patterns",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# Tool Use Patterns

Primary: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/anthropic-cookbook/tool_use`
Also: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/openai-cookbook/examples`

## Core recipes

- `parallel_tools.ipynb` — concurrent tool calls
- `tool_choice.ipynb` — force / auto / none
- `tool_use_with_pydantic.ipynb` — typed tool schemas
- `extracting_structured_json.ipynb` — structured extraction
- `memory_cookbook.ipynb` + `memory_tool.py` — durable memory tools
- `customer_service_agent.ipynb` — multi-tool agent loop
- `vision_with_tools.ipynb` — multimodal + tools
- `programmatic_tool_calling_ptc.ipynb` — programmatic tool calling

## Workflow

1. Define tool contracts (name, description, JSON schema / Pydantic).
2. Decide tool_choice policy.
3. Implement tool runners with clear errors.
4. Parse/validate model tool calls before side effects.
5. Prefer structured outputs over free-text for machine steps.

## Safety

- Destructive tools need human approval (L7: approval=true).
- Log tool name + args + result to audit.
- Keep secrets out of tool results returned to the model when possible.

## L7 Declaration (Seven Seals)

- Capability 🔧: Tool calling, structured outputs, memory tools
- Data 📦: tool_use notebooks + openai cookbook tool examples
- Policy/Intent 🧭: Validate schemas; never hardcode API keys
- Presentation 🧩: Code-first patterns with schema examples
- Orchestration 🔗: Define tools → call policy → execute → parse
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Sandbox side effects; require approval for destructive tools

### Entity

- entity_id: skill.tool-use-patterns
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → anthropic-cookbook, openai-cookbook
- domain: .work
