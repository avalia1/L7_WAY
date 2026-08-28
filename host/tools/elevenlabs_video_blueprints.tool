name: elevenlabs_video_blueprints
suite: Codex
tagline: "ElevenLabs visual blueprints"
does: render
server: l7-gateway
mcp_tool: skill.elevenlabs-video-blueprints
description: "Build/download ElevenLabs character sheets and storyboards while enforcing paid-generation approval and visual QA."
needs:
  task: string
optional:
  project_root: string
  paid_generation_approved: boolean
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
l7_skill: elevenlabs-video-blueprints
source: l7-way
executable: false
