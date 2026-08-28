#!/bin/bash
# L7 Heart Sentinel — The Immortality Watcher
# Checks every 5 seconds. Resurrects if dead.

HEART_PID="/Users/rnir_hrc_avd/.l7/heart.pid"
NODE_BIN="/Users/rnir_hrc_avd/.config/goose/mcp-hermit/bin/node"
L7_SRC="/Users/rnir_hrc_avd/Backup/L7_WAY"
LOG="/Users/rnir_hrc_avd/.l7/state/heart.log"

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
