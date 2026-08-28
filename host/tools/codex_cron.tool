name: codex_cron
suite: Codex
tagline: "Time serves the Empire"
does: automate
server: l7-gateway
mcp_tool: codex.cron
description: "Scheduled automation engine. Create, list, edit, enable, disable, and execute recurring tasks within the L7 system. Each cron job is a sealed contract with time — it fires at the appointed hour, runs its flow or tool, and logs the result. Supports standard cron expressions, one-shot timers, and lifecycle hooks. All jobs audited, no silent execution."
needs:
  action: string
optional:
  schedule: string
  job_id: string
  tool: string
  flow: string
  args: object
  enabled: boolean
gives:
  job_id: string
  schedule: string
  next_run: string
  last_run: string
  status: string
  history: array
pii: false
approval: true
audit: true
output: json
runs: once
version: v1
icon: clock
color: "#14b8a6"
