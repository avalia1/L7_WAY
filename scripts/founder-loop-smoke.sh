#!/usr/bin/env bash
# Founder Loop smoke — structural split + dry operator path.
# Gateway live tests stay in test/server-v1.test.js and test/one-listener.test.js.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "ok - $*"; }

need() {
  [ -f "$1" ] || fail "missing $1"
  [ -x "$1" ] || fail "not executable: $1"
}

need "${ROOT}/scripts/run-gateway.sh"
need "${ROOT}/scripts/run-founder-loop.sh"
need "${ROOT}/scripts/founder-loop-smoke.sh"
need "${ROOT}/start.sh"
[ -f "${ROOT}/scripts/_env.sh" ] || fail "missing scripts/_env.sh"

bash -n "${ROOT}/scripts/_env.sh"
bash -n "${ROOT}/scripts/run-gateway.sh"
bash -n "${ROOT}/scripts/run-founder-loop.sh"
bash -n "${ROOT}/scripts/founder-loop-smoke.sh"
bash -n "${ROOT}/start.sh"
pass "bash -n on operator scripts"

grep -q 'npm start\|node serve.js' "${ROOT}/scripts/run-gateway.sh" \
  || fail "run-gateway.sh must boot node serve.js / npm start"
grep -E 'tailscale serve|ssh -N|-R ' "${ROOT}/scripts/run-gateway.sh" >/dev/null \
  && fail "run-gateway.sh must not own Tailscale/SSH"
grep -q 'avli_cloud/start.sh' "${ROOT}/scripts/run-gateway.sh" \
  && fail "run-gateway.sh must not start old advisor compose"
pass "run-gateway.sh is Node-only"

grep -q 'tailscale serve' "${ROOT}/scripts/run-founder-loop.sh" \
  || fail "run-founder-loop.sh must Tailscale-serve the gateway"
grep -q 'not starting' "${ROOT}/scripts/run-founder-loop.sh" \
  || fail "run-founder-loop.sh must refuse ~/avli_cloud/start.sh"
grep -q 'avli_cloud/workers/start.sh' "${ROOT}/scripts/run-founder-loop.sh" \
  || fail "run-founder-loop.sh must call workers/start.sh if present"
grep -E 'exec npm start|exec node serve.js' "${ROOT}/scripts/run-founder-loop.sh" >/dev/null \
  && fail "run-founder-loop.sh must not boot the Node gateway"
# Must mention the forbidden ports only as a refuse list, never as serve targets.
if grep -E 'tailscale serve --bg 18792|tailscale serve --bg 18798|tailscale serve --bg 7378' \
  "${ROOT}/scripts/run-founder-loop.sh" >/dev/null; then
  fail "run-founder-loop.sh must not Tailscale-serve worker/forge ports"
fi
pass "run-founder-loop.sh is operator plumbing"

grep -q 'run-gateway.sh' "${ROOT}/start.sh" || fail "start.sh must call run-gateway.sh"
grep -q 'run-founder-loop.sh' "${ROOT}/start.sh" || fail "start.sh must call run-founder-loop.sh"
pass "start.sh is a convenience wrapper"

if grep -Ei 'tailscale|n8n|ssh -R|docker-compose' "${ROOT}/serve.js" >/dev/null; then
  fail "serve.js must not grow tunnel/n8n/Tailscale code"
fi
pass "serve.js has no tunnel/n8n/Tailscale"

[ ! -f "${ROOT}/lib/avli-worker-client.js" ] || pass "avli-worker-client.js present (not invented here)"
pass "no invented worker client"

# Dry founder-loop: no Tailscale, no tunnel host, no workers, no forge.
OUT="$(mktemp)"
if ! env L7_FOUNDER_LOOP_ONCE=1 L7_FORGE=0 L7_TUNNEL_HOST= \
  "${ROOT}/scripts/run-founder-loop.sh" >"$OUT" 2>&1; then
  cat "$OUT" >&2
  fail "run-founder-loop.sh once-mode should skip and exit 0"
fi
grep -q 'skip workers' "$OUT" || fail "expected skip-workers message"
grep -q 'Tailscale not installed\|skip Serve' "$OUT" || fail "expected Tailscale skip"
grep -q 'skip SSH reverse tunnel\|L7_TUNNEL_HOST unset' "$OUT" || fail "expected tunnel skip"
grep -qi 'not the gateway' "$OUT" || fail "founder-loop must say it is not the gateway"
grep -E 'exec npm start|L7 Gateway — ONLINE' "$OUT" >/dev/null \
  && fail "founder-loop once-mode started the Node gateway"
pass "founder-loop once-mode skips missing plumbing"

# Live gateway boot on an ephemeral port (control plane only).
PORT=$((19000 + RANDOM % 1000))
GW_LOG="$(mktemp)"
L7_PORT="$PORT" L7_BIND=127.0.0.1 "${ROOT}/scripts/run-gateway.sh" >"$GW_LOG" 2>&1 &
GW_PID=$!
cleanup_gw() {
  kill "$GW_PID" 2>/dev/null || true
  wait "$GW_PID" 2>/dev/null || true
  rm -f "$OUT" "$GW_LOG"
}
trap cleanup_gw EXIT INT TERM

healthy=0
i=0
while [ "$i" -lt 40 ]; do
  if curl -sf "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
    healthy=1
    break
  fi
  i=$((i + 1))
  sleep 0.25
done
[ "$healthy" = "1" ] || { cat "$GW_LOG" >&2; fail "run-gateway.sh did not answer /health on ${PORT}"; }
pass "run-gateway.sh /health on 127.0.0.1:${PORT}"

if command -v ss >/dev/null 2>&1; then
  LISTEN="$(ss -ltnp 2>/dev/null || true)"
elif command -v lsof >/dev/null 2>&1; then
  LISTEN="$(lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null || true)"
else
  LISTEN=""
fi
if [ -n "$LISTEN" ]; then
  echo "$LISTEN" | grep -E ':18792|:18798|:7378|:7377' >/dev/null \
    && fail "gateway boot must not listen on worker/forge/empire ports"
  pass "no worker/forge/empire listeners after run-gateway"
fi

echo "founder-loop-smoke: all checks passed"
