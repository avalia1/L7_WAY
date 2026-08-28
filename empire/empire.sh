#!/usr/bin/env bash
# Frozen: Empire is not a second HTTP gateway.
# Product API: npm start → http://127.0.0.1:18793
set -euo pipefail
echo "Empire HTTP server is archived (archive/empire/server.js)."
echo "Start the control plane: npm start"
echo "empire/public/ is a frozen client, not a listener."
exit 1
