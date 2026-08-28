name: claude_skills_dev
suite: Codex
tagline: "Build Agent Skills the right way"
does: automate
server: l7-gateway
mcp_tool: skill.claude-skills-dev
description: "Create and package Claude/OpenClaw Agent Skills (SKILL.md, progressive disclosure, scripts, references) using Anthropic skills cookbook patterns."
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
l7_skill: claude-skills-dev
source: ai-playground
