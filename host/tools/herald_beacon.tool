name: herald_beacon
suite: Herald
tagline: "Find your tribe"
does: communicate
server: l7-media
mcp_tool: herald.discover
description: "Device and service discovery. Finds L7-compatible endpoints on local network, cloud, or mesh. Automatic capability negotiation and secure pairing."
needs:
  scan_range: string
  filter: object
gives:
  devices: array
  services: array
  pair_status: object
pii: false
approval: false
audit: true
output: json
runs: once
version: v1
icon: radar
color: "#ec4899"
