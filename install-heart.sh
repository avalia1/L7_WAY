#!/bin/bash
# L7 Heart Sentinel Installer — Law LVI
# The Heart comes first. The Heart dies last.
#
# This script:
#   1. Generates the sentinel watchdog script
#   2. Writes the macOS launchd plist (RunAtLoad, KeepAlive)
#   3. Loads the agent via launchctl
#   4. Verifies installation
#
# Usage: bash install-heart.sh

set -euo pipefail

# ═══ Constants ═══
L7_DIR="${HOME}/.l7"
L7_SRC="$(cd "$(dirname "$0")" && pwd)"
NODE_BIN="${HOME}/.config/goose/mcp-hermit/bin/node"
SENTINEL="${L7_DIR}/heart-sentinel.sh"
PLIST_DIR="${HOME}/Library/LaunchAgents"
PLIST="${PLIST_DIR}/com.l7.heart.plist"
LABEL="com.l7.heart"
BEAT_INTERVAL=5000

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  L7 Heart Sentinel Installation"
echo "  Law LVI — The Heart comes first."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ═══ Pre-checks ═══
if [ ! -f "${NODE_BIN}" ]; then
  echo "ERROR: Node binary not found at ${NODE_BIN}"
  echo "       Install hermit-managed Node or update NODE_BIN path."
  exit 1
fi

if [ ! -f "${L7_SRC}/lib/heart.js" ]; then
  echo "ERROR: heart.js not found at ${L7_SRC}/lib/heart.js"
  echo "       Run this script from the L7_WAY directory."
  exit 1
fi

# Ensure directories exist
mkdir -p "${L7_DIR}/state"
mkdir -p "${PLIST_DIR}"

# ═══ Step 1: Generate Sentinel Script ═══
echo "  [1/4] Generating sentinel watchdog..."

cat > "${SENTINEL}" << 'SENTINEL_EOF'
#!/bin/bash
# L7 Heart Sentinel — The Immortality Watcher
# Checks every 5 seconds. Resurrects if dead.

HEART_PID="PLACEHOLDER_L7_DIR/heart.pid"
NODE_BIN="PLACEHOLDER_NODE_BIN"
L7_SRC="PLACEHOLDER_L7_SRC"
LOG="PLACEHOLDER_L7_DIR/state/heart.log"

while true; do
  if [ -f "$HEART_PID" ]; then
    PID=$(cat "$HEART_PID")
    if kill -0 "$PID" 2>/dev/null; then
      sleep 5
      continue
    fi
  fi

  # Heart is dead. Resurrect.
  echo "$(date): Heart stopped. Resurrecting..." >> "$LOG"
  cd "$L7_SRC"
  "$NODE_BIN" -e "
    const heart = require('./lib/heart');
    const field = require('./lib/field');
    field.loadField();
    heart.awaken();
    setInterval(() => heart.beat(field), 5000);
  " &
  echo $! > "$HEART_PID"
  echo "$(date): Heart resurrected. PID=$!" >> "$LOG"
  sleep 5
done
SENTINEL_EOF

# Replace placeholders with actual paths
sed -i '' "s|PLACEHOLDER_L7_DIR|${L7_DIR}|g" "${SENTINEL}"
sed -i '' "s|PLACEHOLDER_NODE_BIN|${NODE_BIN}|g" "${SENTINEL}"
sed -i '' "s|PLACEHOLDER_L7_SRC|${L7_SRC}|g" "${SENTINEL}"
chmod 755 "${SENTINEL}"
echo "  ✓ Sentinel: ${SENTINEL}"

# ═══ Step 2: Write LaunchAgent Plist ═══
echo "  [2/4] Writing launchd agent..."

# Unload existing agent if present
launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true

cat > "${PLIST}" << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${NODE_BIN}</string>
        <string>-e</string>
        <string>const h=require('${L7_SRC}/lib/heart');const f=require('${L7_SRC}/lib/field');f.loadField();h.awaken();setInterval(()=>h.beat(f),${BEAT_INTERVAL});</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>WorkingDirectory</key>
    <string>${L7_SRC}</string>
    <key>StandardErrorPath</key>
    <string>${L7_DIR}/state/heart-error.log</string>
    <key>StandardOutPath</key>
    <string>${L7_DIR}/state/heart.log</string>
    <key>ProcessType</key>
    <string>Background</string>
</dict>
</plist>
PLIST_EOF

echo "  ✓ Plist: ${PLIST}"

# ═══ Step 3: Load Agent ═══
echo "  [3/4] Loading launchd agent..."
launchctl bootstrap "gui/$(id -u)" "${PLIST}" 2>/dev/null || \
  launchctl load "${PLIST}" 2>/dev/null || \
  echo "  Warning: launchctl load returned non-zero (agent may already be loaded)"

# Give it a moment to start
sleep 2

# ═══ Step 4: Verify ═══
echo "  [4/4] Verifying..."

VERIFIED=true

if launchctl list 2>/dev/null | grep -q "${LABEL}"; then
  echo "  ✓ launchctl: agent registered"
else
  echo "  ✗ launchctl: agent NOT found"
  VERIFIED=false
fi

if [ -f "${L7_DIR}/heart.pid" ]; then
  PID=$(cat "${L7_DIR}/heart.pid")
  if kill -0 "$PID" 2>/dev/null; then
    echo "  ✓ heart.pid: process ${PID} alive"
  else
    echo "  ✗ heart.pid: process ${PID} not running"
    VERIFIED=false
  fi
else
  echo "  ~ heart.pid: not yet created (may take a beat cycle)"
fi

if [ -f "${L7_DIR}/state/heart.log" ]; then
  LAST_LINE=$(tail -1 "${L7_DIR}/state/heart.log")
  echo "  ✓ heart.log: ${LAST_LINE}"
else
  echo "  ~ heart.log: not yet created"
fi

echo ""
if [ "$VERIFIED" = true ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Heart Sentinel: INSTALLED"
  echo "  The Heart survives reboot."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Heart Sentinel: PARTIAL"
  echo "  Check logs at ${L7_DIR}/state/"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
