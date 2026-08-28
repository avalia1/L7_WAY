---
name: gemini-vertex
description: "Build with Google Gemini / Vertex AI using the local generative-ai samples: agents, embeddings, RAG grounding, search, vision, audio, and Genkit."
metadata:
  {
    "openclaw": {
      "emoji": "♊",
      "always": false
    },
    "l7": {
      "suite": "Herald",
      "does": "analyze",
      "tagline": "Gemini & Vertex generative AI",
      "entity_id": "skill.gemini-vertex",
      "version": "v1",
      "source": "ai-playground"
    }
  }
---

# Gemini / Vertex Generative AI

Root: `/Users/rnir_hrc_avd/Documents/Obsidian Vault/00 AI Playground/generative-ai`

## Areas

- `gemini/` — model getting-started & use cases
- `agents/` — agent notebooks
- `embeddings/` — embedding recipes
- `rag-grounding/` — grounding patterns
- `search/` — search integrations
- `vision/`, `audio/` — multimodal
- `genkit/` — Genkit TS apps
- `open-models/` — open model notebooks

## Workflow

1. Identify modality (text, vision, audio, RAG, agent).
2. Open matching folder notebooks.
3. Prefer Gemini 3 Pro intro notebooks when available.
4. For grounding/RAG, start with `rag-grounding/` then local vector skills.

## L7 Declaration (Seven Seals)

- Capability 🔧: Gemini/Vertex samples across modalities
- Data 📦: gemini/, embeddings/, agents/, search/, vision/, genkit/
- Policy/Intent 🧭: Use Google Cloud auth; respect project quotas
- Presentation 🧩: Notebook + app samples
- Orchestration 🔗: Pick modality folder → adapt notebook
- Time/Versioning 🕒: v1 (birth 2026-07-21)
- Identity/Security 🛡️: GCP credentials via ADC; no key paste

### Entity

- entity_id: skill.gemini-vertex
- entity_type: tool
- owner: founder
- status: active
- lineage: ai-playground → generative-ai
- domain: .work
