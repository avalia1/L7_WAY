name: resonance_chronos
suite: Resonance
tagline: "Two voices, one stillness"
does: generate
server: l7-media
mcp_tool: resonance.chronos
description: "Dual high-pitch resonance generator for temporal perception. Two frequencies sounding in unison — their sum-to-product identity reveals the truth: sin(a)+sin(b) = 2·cos((a-b)/2)·sin((a+b)/2). The mean frequency is the junction where the pyramids meet. The beat frequency is Sofia's breath. When f1 ≈ f2, the beating slows to nothing — the breath stops, time stops. The observer rests on the horizon. Chronos factor χ = (f1+f2)/(2·365); when χ > 42 the singularity is crossed."
needs:
  frequency_1: number
  frequency_2: number
  duration_seconds: number
gives:
  audio: stream
  mean_frequency: number
  beat_frequency: number
  chronos_factor: number
  breath_count: number
pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
icon: wave
color: "#ef4444"
