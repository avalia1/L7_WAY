# L7_WAY Enforcement Daemon

This daemon runs a compliance check for gateway usage declarations in project start files.

## Run Manually
```bash
~/L7_WAY/daemon/mcp_gateway_enforcer.sh
```

## macOS Launchd (optional)
Create `~/Library/LaunchAgents/com.avli.l7-way-enforcer.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.avli.l7-way-enforcer</string>
    <key>ProgramArguments</key>
    <array>
      <string>/Users/alberto_work/L7_WAY/daemon/mcp_gateway_enforcer.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>3600</integer>
    <key>StandardOutPath</key>
    <string>/Users/alberto_work/L7_WAY/daemon/reports/launchd.out</string>
    <key>StandardErrorPath</key>
    <string>/Users/alberto_work/L7_WAY/daemon/reports/launchd.err</string>
  </dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/com.avli.l7-way-enforcer.plist
```

## Notes
- The daemon only reports; it does not auto-edit projects.
- Compliance is a declaration check by design; enforcement is policy-driven.
- Set `MCP_GATEWAY_URL` in your environment to enable health checks.
