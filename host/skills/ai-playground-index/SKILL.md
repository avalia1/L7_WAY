---
name: ai-playground-index
description: "Locate and route among local AI Playground codebases: LangChain, LlamaIndex, AutoGen, AutoGPT, Chroma, Qdrant, Anthropic/OpenAI cookbooks, Prompt Engineering Guide, Gemini generative-ai, and LLM course."
metadata:
  {
    "openclaw": {
      "emoji": "🗺️",
      "always": false
    },
    "l7": {
      "suite": "Codex",
      "does": "search",
      "tagline": "Map of the local AI Playground",
      "entity_id": "skill.ai-playground-index",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# AI Playground Index

Local root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground`

Use this skill first when the user asks about AI frameworks, RAG stacks, agent patterns, or cookbooks available on disk.


## Commands

```bash
l7 skills route "your task"
l7 skills list
```

## Repo map

| Skill | Path | Use when |
|-------|------|----------|
| agent-workflows | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/anthropic-cookbook/patterns/agents` | multi-step agent patterns (Claude) |
| tool-use-patterns | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/anthropic-cookbook/tool_use` + openai-cookbook | tools, structured output, memory tools |
| claude-skills-dev | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/anthropic-cookbook/skills` | building Agent Skills (SKILL.md) |
| financial-analysis | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/anthropic-cookbook/skills/custom_skills` | ratios, brand, DCF skill packages |
| multiagent-autogen | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/autogen` | multi-agent chat, Magentic-One |
| autonomous-agents | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/AutoGPT` | agent platform / graph workflows |
| langchain-agents | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/langchain` | LangChain v1 agents & LCEL |
| llamaindex-rag | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/llama_index` | indices, packs, query engines |
| vector-chroma | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/chroma` | embed + collection memory |
| vector-qdrant | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/qdrant` | production vector search |
| prompt-engineering | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/Prompt-Engineering-Guide` | prompting techniques |
| openai-patterns | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/openai-cookbook` | OpenAI API recipes |
| gemini-vertex | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/generative-ai` | Gemini / Vertex samples |
| llm-engineer | `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/llm-course` | LLM fundamentals → engineer path |
| rag-pipeline | (cross-stack) | design unified RAG |

## Routing rules

1. Vector store only → chroma or qdrant skill
2. Document Q&A / indices → llamaindex-rag
3. Chains / agents / LCEL → langchain-agents
4. Multi-agent teams → multiagent-autogen
5. Prompt craft → prompt-engineering
6. Claude-specific tools/skills → agent-workflows / tool-use / claude-skills-dev
7. OpenAI API recipes → openai-patterns
8. Gemini/Vertex → gemini-vertex

## Workflow

1. Identify the user goal (RAG, agents, prompts, vectors, multi-agent).
2. Load the matching specialized skill.
3. Prefer reading local notebooks/examples before inventing code.
4. Cite local file paths in answers so work is reproducible.

## L7 Declaration (Seven Seals)

- Capability 🔧: Catalog + path routing for AI libraries in the local playground
- Data 📦: Repo paths, capability map, when-to-use matrix
- Policy/Intent 🧭: Prefer local playground paths over re-cloning; do not invent APIs
- Presentation 🧩: Tables + path pointers
- Orchestration 🔗: Entry skill before specialized stack skills
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: Read-only over local disk; no network required

### Entity

- entity_id: skill.ai-playground-index
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → *
- domain: .work
