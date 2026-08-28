name: gemini_vertex
suite: Herald
tagline: "Gemini & Vertex generative AI"
does: analyze
server: l7-gateway
mcp_tool: skill.gemini-vertex
description: "Build with Google Gemini / Vertex AI using the local generative-ai samples: agents, embeddings, RAG grounding, search, vision, audio, and Genkit."
needs:
  task: string
optional:
  context: string
  path: string
gives:
  guidance: string
  paths: array
  next_steps: array
pii: false
approval: false
audit: true
output: text
runs: once
version: v1
icon: book
color: #6366f1
l7_skill: gemini-vertex
source: ai-playground
