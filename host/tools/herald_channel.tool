name: herald_channel
suite: Herald
tagline: "Every voice finds its wire"
does: communicate
server: l7-gateway
mcp_tool: herald.channel
description: "Multi-platform messaging gateway. Manages channels across WhatsApp, Telegram, Slack, Discord, Signal, iMessage, Matrix, IRC, and any WebSocket-compatible endpoint. Send, receive, react, thread, pin. Each channel is an independent wire — no cross-leak between platforms. All messages pass through the Gateway forge before dispatch."
needs:
  action: string
  channel: string
optional:
  message: string
  peer: string
  thread_id: string
  reaction: string
  media: string
  credentials: object
gives:
  message_id: string
  channel_status: string
  delivery: object
  thread: object
  timestamp: string
pii: true
approval: true
audit: true
output: json
runs: once
version: v1
icon: radio
color: "#3b82f6"
