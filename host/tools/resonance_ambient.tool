name: resonance_ambient
suite: Resonance
tagline: "Worlds made of sound"
does: render
server: l7-media
mcp_tool: resonance.generate
description: "Generative soundscape engine. Creates living audio environments from seed parameters — forests, cities, oceans, alien worlds. Never loops, always evolving."
needs:
  environment: string
  duration: number
  density: number
  mood: string
gives:
  audio_stream: stream
  layer_count: number
  seed: string
pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
icon: waves
color: "#ef4444"
