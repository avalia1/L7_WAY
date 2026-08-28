name: gateway_node
suite: Gateway
tagline: "Every device, one empire"
does: automate
server: l7-gateway
mcp_tool: gateway.node
description: "Device node management for the L7 network. List, describe, invoke, and control connected devices — macOS, iOS, Android, any machine running an L7 agent. Expose device capabilities (camera, screen, location, notifications, local commands) through the Gateway. Each node is a sovereign territory with declared atoms — no capability leaks between nodes."
needs:
  action: string
optional:
  node_id: string
  capability: string
  command: string
  args: object
gives:
  node_id: string
  capabilities: array
  result: object
  status: string
  last_seen: string
pii: true
approval: true
audit: true
output: json
runs: once
version: v1
icon: server
color: "#64748b"
