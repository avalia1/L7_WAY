name: kinesis_gesture
suite: Kinesis
tagline: "Intent, not just motion"
does: analyze
server: l7-media
mcp_tool: kinesis.gesture
description: "Gesture recognition that reads intent, not just shape. Distinguishes a wave from a dismissal, a point from a reach. Trained on cultural gesture vocabularies."
needs:
  source: string
  vocabulary: string
gives:
  gesture: string
  intent: string
  confidence: number
  cultural_context: string
pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
icon: hand
color: "#8b5cf6"
