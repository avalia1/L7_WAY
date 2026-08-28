name: resonance_beat
suite: Resonance
tagline: "The rhythm beneath"
does: analyze
server: l7-media
mcp_tool: resonance.rhythm
description: "Rhythm intelligence. Detects tempo, time signature, groove feel, and micro-timing patterns. Can decompose any audio into its rhythmic skeleton."
needs:
  audio_source: string
  detail: string
gives:
  bpm: number
  time_signature: string
  groove_map: array
  beat_positions: array
  swing_factor: number
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: music
color: "#ef4444"
