name: ai_playground_index
suite: Codex
tagline: "Map of the local AI Playground"
does: search
server: l7-gateway
mcp_tool: skill.ai-playground-index
description: "Locate and route among local AI Playground codebases: LangChain, LlamaIndex, AutoGen, AutoGPT, Chroma, Qdrant, Anthropic/OpenAI cookbooks, Prompt Engineering Guide, Gemini generative-ai, and LLM course."
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
l7_skill: ai-playground-index
source: ai-playground
