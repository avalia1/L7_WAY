name: resonance_voice
suite: Resonance
tagline: "Every voice tells a story"
does: analyze
server: l7-media
mcp_tool: resonance.voice
description: "Voice analysis that goes beyond transcription. Detects emotion, stress, confidence, deception cues, and vocal health markers. Synthesis mode creates natural speech."
needs:
  audio_source: string
  mode: string
  target_voice: string
gives:
  transcript: string
  emotion: object
  stress_level: number
  synthesized: stream
pii: true
approval: true
audit: true
output: json
runs: once
version: v1
icon: mic
color: "#ef4444"
