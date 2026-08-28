#!/usr/bin/env bash
# Founder Loop — operator plumbing. This is not the gateway.
#
# Owns: Tailscale Serve of :18793, SSH reverse tunnel + docker-bridge,
# Avli loopback workers (if present), optional l7 forge on :7378.
#
# Does not: start the Node control plane, start ~/avli_cloud/start.sh,
# Tailscale-serve worker ports (:18792, :18794, :18795, :18798) or forge :7378,
# apply VPS compose, or grow tunnel code inside serve.js.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "${SCRIPT_DIR}/_env.sh"
l7_load_env

PIDS=""

hold_pid() {
  PIDS="${PIDS} $1"
}

refuse_worker_or_forge_port() {
  case "$1" in
    18792|18794|18795|18798|7378)
      echo "founder-loop: refusing Tailscale Serve of :$1 (workers/forge are not the gateway)" >&2
      return 1
      ;;
  esac
  return 0
}

wait_for_gateway() {
  local i=0
  local max="${L7_GATEWAY_WAIT_TRIES:-50}"
  if [ "${L7_FOUNDER_LOOP_ONCE:-}" = "1" ]; then
    max=1
  fi
  while [ "$i" -lt "$max" ]; do
    if l7_gateway_healthy; then
      echo "founder-loop: gateway answering on 127.0.0.1:${L7_PORT}"
      return 0
    fi
    i=$((i + 1))
    sleep 0.2
  done
  echo "founder-loop: gateway not answering /health or /v1/tools on 127.0.0.1:${L7_PORT}; continuing with operator plumbing"
  return 0
}

serve_gateway_tailscale() {
  refuse_worker_or_forge_port "$L7_PORT" || return 1
  if ! command -v tailscale >/dev/null 2>&1; then
    echo "founder-loop: Tailscale not installed; skip Serve of :${L7_PORT}"
    return 0
  fi
  echo "founder-loop: Tailscale Serve of gateway :${L7_PORT} only (not 18792/18794/18795/18798/7378)"
  # --bg returns; Tailscale keeps the serve mapping. Do not serve other ports.
  if ! tailscale serve --bg "$L7_PORT"; then
    echo "founder-loop: tailscale serve failed; skip"
  fi
}

start_ssh_tunnel() {
  if [ -z "${L7_TUNNEL_HOST:-}" ]; then
    echo "founder-loop: L7_TUNNEL_HOST unset; skip SSH reverse tunnel"
    return 0
  fi
  if ! command -v ssh >/dev/null 2>&1; then
    echo "founder-loop: ssh not found; skip reverse tunnel"
    return 0
  fi
  local remote_port="${L7_TUNNEL_REMOTE_PORT:-18793}"
  local target="${L7_TUNNEL_HOST}"
  if [ -n "${L7_TUNNEL_USER:-}" ]; then
    target="${L7_TUNNEL_USER}@${target}"
  fi
  echo "founder-loop: SSH reverse tunnel remote:${remote_port} -> 127.0.0.1:${L7_PORT}"
  if [ -n "${L7_TUNNEL_IDENTITY:-}" ]; then
    ssh -N -o BatchMode=yes -o ExitOnForwardFailure=yes \
      -i "$L7_TUNNEL_IDENTITY" \
      -R "${remote_port}:127.0.0.1:${L7_PORT}" \
      "$target" &
  else
    ssh -N -o BatchMode=yes -o ExitOnForwardFailure=yes \
      -R "${remote_port}:127.0.0.1:${L7_PORT}" \
      "$target" &
  fi
  hold_pid $!
}

start_docker_bridge() {
  if [ -z "${L7_TUNNEL_HOST:-}" ]; then
    echo "founder-loop: skip docker-bridge forwarder (no L7_TUNNEL_HOST)"
    return 0
  fi
  if [ "${L7_DOCKER_BRIDGE:-1}" = "0" ]; then
    echo "founder-loop: docker-bridge disabled"
    return 0
  fi
  if ! command -v ssh >/dev/null 2>&1; then
    echo "founder-loop: ssh not found; skip docker-bridge"
    return 0
  fi
  local remote_port="${L7_TUNNEL_REMOTE_PORT:-18793}"
  local bridge_port="${L7_DOCKER_BRIDGE_PORT:-18793}"
  local bind_addr="${L7_DOCKER_BRIDGE_BIND:-172.17.0.1}"
  local target="${L7_TUNNEL_HOST}"
  if [ -n "${L7_TUNNEL_USER:-}" ]; then
    target="${L7_TUNNEL_USER}@${target}"
  fi
  echo "founder-loop: docker-bridge forwarder (remote docker -> reverse-tunneled gateway). Not compose."
  ssh -o BatchMode=yes "$target" \
    "command -v socat >/dev/null 2>&1 && exec socat TCP-LISTEN:${bridge_port},bind=${bind_addr},fork,reuseaddr TCP:127.0.0.1:${remote_port}" &
  hold_pid $!
}

start_workers() {
  local old_compose="${HOME}/avli_cloud/start.sh"
  if [ -e "$old_compose" ]; then
    echo "founder-loop: not starting ${old_compose} (old advisor compose is out of scope)"
  fi
  local w="${L7_WORKERS_START:-${HOME}/avli_cloud/workers/start.sh}"
  if [ -f "$w" ]; then
    echo "founder-loop: starting Avli loopback workers via ${w}"
    bash "$w" &
    hold_pid $!
  else
    echo "founder-loop: skip workers — ${w} not found (Phase 2 in flight)"
  fi
}

start_forge() {
  if [ "${L7_FORGE:-1}" = "0" ]; then
    echo "founder-loop: forge disabled"
    return 0
  fi
  local forge="${L7_FORGE_JS:-${HOME}/.l7/servers/universal-xr/server.js}"
  if [ -f "$forge" ]; then
    echo "founder-loop: optional l7 forge on :7378 (loopback only; not Tailscale-served)"
    node "$forge" &
    hold_pid $!
  else
    echo "founder-loop: skip forge — ${forge} not found"
  fi
}

echo "founder-loop: operator plumbing (not the gateway)"
echo "founder-loop: gateway is scripts/run-gateway.sh / npm start on 127.0.0.1:${L7_PORT}"

wait_for_gateway
serve_gateway_tailscale
start_ssh_tunnel
start_docker_bridge
start_workers
start_forge

if [ "${L7_FOUNDER_LOOP_ONCE:-}" = "1" ]; then
  echo "founder-loop: once mode — not holding tunnels"
  exit 0
fi

if [ -z "${PIDS}" ]; then
  echo "founder-loop: nothing to hold (Tailscale/SSH/workers/forge all skipped or backgrounded by Tailscale)"
  exit 0
fi

cleanup() {
  local pid
  for pid in $PIDS; do
    kill "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT INT TERM
echo "founder-loop: holding operator processes:${PIDS}"
wait
