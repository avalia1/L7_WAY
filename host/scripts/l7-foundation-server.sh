#!/bin/bash
# L7 Foundation Server — daemon wrapper for `l7-foundation serve`
# Offline, on-device inference (Apple FoundationModels), OpenAI-compatible HTTP API.
# Usage: l7-foundation-server.sh {start|stop|status|restart}

L7_DIR="$HOME/.l7"
BIN="$L7_DIR/l7-foundation"
PORT="${L7_FOUNDATION_PORT:-8991}"
PID_FILE="$L7_DIR/foundation.pid"
LOG="$L7_DIR/state/foundation.log"

mkdir -p "$(dirname "$LOG")"

is_running() {
  [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

start() {
  if is_running; then
    echo "l7-foundation server already running (pid $(cat "$PID_FILE"))"
    exit 0
  fi
  if [ ! -x "$BIN" ]; then
    echo "error: $BIN not found or not executable. Build with:"
    echo "  swiftc $L7_DIR/l7-foundation.swift -o $BIN -O"
    exit 1
  fi
  nohup "$BIN" serve --port "$PORT" >> "$LOG" 2>&1 &
  echo $! > "$PID_FILE"
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) started pid $! on port $PORT" >> "$LOG"
  sleep 1
  if is_running; then
    echo "l7-foundation server started (pid $(cat "$PID_FILE"), port $PORT)"
  else
    echo "l7-foundation server failed to start — check $LOG"
    exit 1
  fi
}

stop() {
  if is_running; then
    kill "$(cat "$PID_FILE")"
    rm -f "$PID_FILE"
    echo "l7-foundation server stopped"
  else
    echo "l7-foundation server not running"
  fi
}

status() {
  if is_running; then
    echo "l7-foundation server running (pid $(cat "$PID_FILE"), port $PORT)"
  else
    echo "l7-foundation server not running"
  fi
}

case "$1" in
  start) start ;;
  stop) stop ;;
  restart) stop; start ;;
  status) status ;;
  *)
    echo "usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac
