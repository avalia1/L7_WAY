name: herald_cipher
suite: Herald
tagline: "Only you can read this"
does: automate
server: l7-media
mcp_tool: herald.encrypt
description: "End-to-end encrypted messaging with quantum-resistant key exchange. Messages exist only between sender and receiver. No server ever sees plaintext."
needs:
  message: string
  recipient: string
  algorithm: string
gives:
  encrypted_payload: string
  key_fingerprint: string
  expiry: string
pii: true
approval: true
audit: true
output: json
runs: once
version: v1
icon: lock
color: "#ec4899"
