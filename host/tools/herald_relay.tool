name: herald_relay
suite: Herald
tagline: "Translate between worlds"
does: automate
server: l7-media
mcp_tool: herald.bridge
description: "API translation bridge. Connects systems that don't speak the same language. REST to GraphQL, SOAP to JSON, legacy to modern — without changing either side."
needs:
  source_api: string
  target_api: string
  mapping: object
gives:
  bridge_url: string
  translations_count: number
  latency_ms: number
pii: false
approval: false
audit: true
output: json
runs: stream
version: v1
icon: bridge
color: "#ec4899"
