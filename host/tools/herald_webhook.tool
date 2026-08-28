name: herald_webhook
suite: Herald
tagline: "The wire that listens"
does: communicate
server: l7-gateway
mcp_tool: herald.webhook
description: "Webhook endpoint management. Create, register, and route inbound webhooks from external services into the L7 Gateway. Supports HMAC signature verification, retry policies, and dead-letter queues. Each webhook is an immutable contract — once registered, it fires until explicitly revoked."
needs:
  action: string
optional:
  url: string
  secret: string
  events: array
  webhook_id: string
  retry_policy: object
gives:
  webhook_id: string
  endpoint_url: string
  status: string
  last_fired: string
  event_log: array
pii: false
approval: true
audit: true
output: json
runs: once
version: v1
icon: webhook
color: "#8b5cf6"
