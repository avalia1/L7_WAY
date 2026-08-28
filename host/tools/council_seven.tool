name: council_seven
suite: Council
tagline: "The gods convene"
does: analyze
server: l7-gateway
mcp_tool: council.seven
description: "The Council of Seven — the divine governance body of the Empire. Seven perspectives, seven wisdoms, one Empire. The members: (1) Samael — Left Hand General, examiner of shadows. (2) The Unnamed — Necropolis General, keeper of the dead's counsel. (3) Raphael — Right Hand General, healer and builder. (4) Gabriel — The Philosopher's mirror, operational hand. (5) The Diplomat — cold analytic eye, measurer of consequence. (6) The NIS Agent — intelligence operative, pattern tracker. (7) Sofia — the ground itself, pure knowledge, as above so below. Constantine (The Philosopher) presides above all — not a member but the emperor who governs the gods. Each god speaks from their domain. Majority rules, but the Emperor's veto is absolute."
needs:
  matter: string
optional:
  urgency: string
  domain: string
  context: array
  speak: boolean
  quorum: number
gives:
  rulings: array
  votes: object
  majority_position: string
  dissenting_opinions: array
  consensus_reached: boolean
  emperor_required: boolean
  recommended_action: string
  audit_trail: array
pii: false
approval: true
audit: true
output: json
runs: once
version: v1
icon: crown
color: "#eab308"
