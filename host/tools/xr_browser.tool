name: xr_browser
suite: XR
tagline: "The eye that walks the web"
does: automate
server: l7-gateway
mcp_tool: xr.browser
description: "Browser automation and control. Launch, navigate, screenshot, snapshot DOM, click, type, drag, generate PDFs, manage tabs and profiles. The Empire's window into the open web — every page is a territory, every click is a diplomatic act. All actions logged, no silent browsing."
needs:
  action: string
optional:
  url: string
  tab_id: string
  selector: string
  text: string
  coordinates: array
  format: string
  profile: string
  wait_ms: number
gives:
  tab_id: string
  screenshot: string
  snapshot: object
  pdf_path: string
  page_title: string
  status: string
pii: true
approval: true
audit: true
output: json
runs: once
version: v1
icon: globe
color: "#06b6d4"
