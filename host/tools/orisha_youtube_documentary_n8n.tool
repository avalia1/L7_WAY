name: orisha_youtube_documentary_n8n
suite: Codex
tagline: "Orisha documentary n8n pipeline"
does: orchestrate
server: l7-gateway
mcp_tool: skill.orisha-youtube-documentary-n8n
description: "Build and operate epic 16:9 Orisha documentaries with n8n, Suno songs, genuine-motion loops, review gates, and YouTube packaging."
needs:
  task: string
optional:
  orisha: string
  job_id: string
  paid_generation_approved: boolean
  youtube_publish_approved: boolean
gives:
  result: object
  summary: string
pii: false
approval: true
audit: true
output: json
runs: once
version: v1
icon: bolt
color: "#22c55e"
l7_skill: orisha-youtube-documentary-n8n
source: l7-way
executable: false
