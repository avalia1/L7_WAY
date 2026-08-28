name: studio_visual
suite: Resonance
tagline: "See the music"
does: render
server: l7-gateway
mcp_tool: studio.visualize
description: "Real-time audio-reactive visual generation. Waveform oscilloscope, frequency spectrum, particle fields, and mandala patterns — all driven by live audio. What you see is what you export as video."
needs:
  mode: string
  audio_source: stream
  palette: string
gives:
  canvas_stream: stream
  frame_rate: number
  resolution: string
pii: false
approval: false
audit: true
output: stream
runs: stream
version: v1
icon: sparkles
color: "#ec4899"
patent: "Integrated Audio-Visual Synthesis Engine"
inventor: "Alberto Valido Delgado"
