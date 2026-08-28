#!/bin/zsh
# ================================================================
# L7-AI — Default LLM interface for the Empire
# ================================================================
#
# All L7 agents route through this. On-device by default
# (Apple FoundationModels). No network unless L7_AI_FALLBACK is set
# and the local server is down.
#
#   l7-ai chat "prompt"
#   l7-ai chat --system "you are lapis" "prompt"
#   l7-ai chat --raw "prompt"          # full JSON response
#   l7-ai models                        # list available
#   l7-ai status                        # is on-device server up?
#   l7-ai url                           # print effective endpoint
#
# PERSISTENT SESSIONS (conversation memory across calls):
#   l7-ai session start [name]                        # → prints session id
#   l7-ai session send SID "message"                  # → assistant reply
#   l7-ai session send --system "sys" SID "message"   # → set system once
#   l7-ai session list                                # list all sessions
#   l7-ai session show SID                            # dump full history
#   l7-ai session end SID                             # archive + delete
#
# ENV:
#   L7_AI_URL      default http://localhost:8991/v1
#   L7_AI_MODEL    default apple-foundation-on-device
#   L7_AI_FALLBACK unset (offline-only); set to "grok" to allow xai fallback
#
# ================================================================

set -uo pipefail

: "${L7_AI_URL:=http://localhost:8991/v1}"
: "${L7_AI_MODEL:=apple-foundation-on-device}"
: "${L7_AI_FALLBACK:=}"
: "${L7_XAI_URL:=https://api.x.ai/v1}"
: "${L7_XAI_MODEL:=grok-4-latest}"
: "${L7_AI_SESSIONS_DIR:=$HOME/.l7/state/sessions}"
: "${L7_AI_MAX_TURNS:=20}"

mkdir -p "$L7_AI_SESSIONS_DIR"

local_up() {
    local code
    code=$(/usr/bin/curl -sS -o /dev/null -w "%{http_code}" --max-time 2 \
        "$L7_AI_URL/models" 2>/dev/null)
    [[ "$code" == "200" ]]
}

json_escape() {
    /usr/bin/python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
}

# Compose messages JSON from --system and prompt args
build_body() {
    local system="$1"; shift
    local prompt="$*"
    /usr/bin/python3 - "$L7_AI_MODEL" "$system" "$prompt" <<'PY'
import json, sys
model, system, prompt = sys.argv[1], sys.argv[2], sys.argv[3]
msgs = []
if system:
    msgs.append({"role": "system", "content": system})
msgs.append({"role": "user", "content": prompt})
print(json.dumps({"model": model, "messages": msgs}))
PY
}

# Call the endpoint. Returns raw JSON on stdout.
call_endpoint() {
    local body="$1"
    curl -sS --max-time 120 "$L7_AI_URL/chat/completions" \
        -H "Content-Type: application/json" \
        -d "$body"
}

# Extract just the assistant text from a chat.completion JSON
extract_text() {
    /usr/bin/python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
    print(d["choices"][0]["message"]["content"])
except Exception as e:
    sys.stderr.write(f"l7-ai: bad response: {e}\n")
    sys.exit(1)'
}

# Try to resolve an xAI API key from env or keychain.
resolve_xai_key() {
    [[ -n "${L7_XAI_KEY:-}" ]] && { echo "$L7_XAI_KEY"; return 0; }
    [[ -n "${XAI_API_KEY:-}" ]] && { echo "$XAI_API_KEY"; return 0; }
    local k
    local login_kc="${HOME}/Library/Keychains/login.keychain-db"
    k=$(security find-generic-password -a "$USER" -s "xai" -w "$login_kc" 2>/dev/null) && \
        { echo "$k"; return 0; }
    k=$(security find-generic-password -a "$USER" -s "grok" -w "$login_kc" 2>/dev/null) && \
        { echo "$k"; return 0; }
    return 1
}

# Call xAI. Reads $body (same OpenAI shape) and returns raw JSON on stdout.
# Rewrites the model to $L7_XAI_MODEL before sending.
call_grok() {
    local body="$1"
    local key; key=$(resolve_xai_key) || {
        echo "l7-ai: no xAI key found (checked L7_XAI_KEY, XAI_API_KEY, keychain 'xai'/'grok')." >&2
        return 1
    }
    local rebuilt
    rebuilt=$(/usr/bin/python3 -c 'import json,sys
d = json.loads(sys.argv[1])
d["model"] = sys.argv[2]
print(json.dumps(d))' "$body" "$L7_XAI_MODEL")
    curl -sS --max-time 120 "$L7_XAI_URL/chat/completions" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $key" \
        -d "$rebuilt"
}

fallback_grok() {
    if [[ "$L7_AI_FALLBACK" != "grok" ]]; then
        echo "l7-ai: local model unreachable at $L7_AI_URL and no fallback configured." >&2
        echo "l7-ai: set L7_AI_FALLBACK=grok to allow xai fallback." >&2
        return 1
    fi
    resolve_xai_key >/dev/null || {
        echo "l7-ai: fallback requested but no xAI key available." >&2
        echo "l7-ai: store one: security add-generic-password -a \$USER -s xai -w <YOUR_KEY> \$HOME/Library/Keychains/login.keychain-db" >&2
        return 1
    }
    return 0
}

cmd_chat() {
    local raw=0
    local system=""
    while [[ $# -gt 0 && "$1" == --* ]]; do
        case "$1" in
            --raw)    raw=1; shift ;;
            --system) system="$2"; shift 2 ;;
            *) echo "l7-ai: unknown flag $1" >&2; return 2 ;;
        esac
    done
    if [[ $# -eq 0 ]]; then
        echo "usage: l7-ai chat [--system SYS] [--raw] PROMPT..." >&2
        return 2
    fi
    local use_fallback=0
    if ! local_up; then
        fallback_grok || return 1
        use_fallback=1
    fi
    local body; body=$(build_body "$system" "$@")
    local resp
    if [[ $use_fallback -eq 1 ]]; then
        echo "l7-ai: local down — routing to xAI ($L7_XAI_MODEL)" >&2
        resp=$(call_grok "$body")
    else
        resp=$(call_endpoint "$body")
    fi
    if [[ $raw -eq 1 ]]; then
        echo "$resp"
    else
        echo "$resp" | extract_text
    fi
}

cmd_models() {
    if ! local_up; then
        echo "l7-ai: local model server is DOWN at $L7_AI_URL" >&2
        return 1
    fi
    curl -sS "$L7_AI_URL/models"
    echo
}

cmd_status() {
    if local_up; then
        local pid; pid=$(launchctl list 2>/dev/null | awk '$3=="com.l7.foundation"{print $1}')
        echo "🟢 l7-ai: on-device model READY"
        echo "   endpoint:  $L7_AI_URL"
        echo "   model:     $L7_AI_MODEL"
        echo "   launchd:   pid ${pid:-unknown} (com.l7.foundation)"
    else
        echo "🔴 l7-ai: on-device model DOWN"
        echo "   endpoint:  $L7_AI_URL"
        echo "   try:       launchctl load ~/Library/LaunchAgents/com.l7.foundation.plist"
    fi
}

cmd_url() { echo "$L7_AI_URL"; }

# ─── Persistent sessions ───────────────────────────────────────

session_path() { echo "$L7_AI_SESSIONS_DIR/$1.json"; }

session_new_id() {
    local name="${1:-session}"
    local ts; ts=$(date +%s)
    local short; short=$(printf '%s%s' "$name" "$ts" | shasum -a 256 | cut -c1-8)
    echo "${name}-${short}"
}

session_start() {
    local name="${1:-session}"
    local sid; sid=$(session_new_id "$name")
    local path; path=$(session_path "$sid")
    /usr/bin/python3 -c 'import json,sys,time
sid, name = sys.argv[1], sys.argv[2]
d = {"id": sid, "name": name, "created": int(time.time()),
     "model": "'"$L7_AI_MODEL"'", "system": None, "messages": []}
json.dump(d, open(sys.argv[3],"w"), indent=2)' "$sid" "$name" "$path"
    echo "$sid"
}

session_send() {
    local system=""
    while [[ $# -gt 0 && "$1" == --* ]]; do
        case "$1" in
            --system) system="$2"; shift 2 ;;
            *) echo "l7-ai session: unknown flag $1" >&2; return 2 ;;
        esac
    done
    local sid="$1"; shift
    local msg="$*"
    if [[ -z "$sid" || -z "$msg" ]]; then
        echo "usage: l7-ai session send [--system SYS] SID MESSAGE..." >&2
        return 2
    fi
    local path; path=$(session_path "$sid")
    [[ ! -f "$path" ]] && { echo "l7-ai session: no session $sid" >&2; return 1; }
    if ! local_up; then
        fallback_grok || return 1
    fi
    # Build request body from stored history + new user message; call endpoint;
    # append assistant reply to history; trim to L7_AI_MAX_TURNS.
    local reply
    reply=$(/usr/bin/python3 - "$path" "$msg" "$system" "$L7_AI_URL" "$L7_AI_MAX_TURNS" <<'PY'
import json, sys, urllib.request
path, user_msg, sys_prompt, base_url, max_turns = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], int(sys.argv[5])
d = json.load(open(path))
if sys_prompt:
    d["system"] = sys_prompt
messages = []
if d.get("system"):
    messages.append({"role": "system", "content": d["system"]})
messages.extend(d.get("messages", []))
messages.append({"role": "user", "content": user_msg})
body = json.dumps({"model": d["model"], "messages": messages}).encode()
req = urllib.request.Request(f"{base_url}/chat/completions", data=body,
                             headers={"Content-Type": "application/json"})
try:
    with urllib.request.urlopen(req, timeout=120) as resp:
        rj = json.loads(resp.read())
    text = rj["choices"][0]["message"]["content"]
except Exception as e:
    sys.stderr.write(f"l7-ai session: {e}\n")
    sys.exit(1)
d["messages"].append({"role": "user", "content": user_msg})
d["messages"].append({"role": "assistant", "content": text})
# Trim: keep last 2*max_turns (user+assistant pairs)
if len(d["messages"]) > 2 * max_turns:
    d["messages"] = d["messages"][-2 * max_turns:]
json.dump(d, open(path, "w"), indent=2, ensure_ascii=False)
print(text)
PY
    )
    local rc=$?
    [[ $rc -ne 0 ]] && return $rc
    echo "$reply"
}

session_list() {
    local files
    files=$(ls -1t "$L7_AI_SESSIONS_DIR"/*.json 2>/dev/null)
    if [[ -z "$files" ]]; then
        echo "(no sessions)"
        return
    fi
    printf "%-30s %-12s %s\n" "ID" "TURNS" "CREATED"
    printf "%-30s %-12s %s\n" "───" "─────" "───────"
    while IFS= read -r f; do
        /usr/bin/python3 -c 'import json,sys,datetime
d = json.load(open(sys.argv[1]))
turns = len(d.get("messages", [])) // 2
created = datetime.datetime.fromtimestamp(d.get("created",0)).strftime("%Y-%m-%d %H:%M")
sid = d["id"]
print(f"{sid:<30} {turns:<12} {created}")' "$f"
    done <<< "$files"
}

session_show() {
    local sid="$1"
    local path; path=$(session_path "$sid")
    [[ ! -f "$path" ]] && { echo "l7-ai session: no session $sid" >&2; return 1; }
    cat "$path"
}

session_end() {
    local sid="$1"
    local path; path=$(session_path "$sid")
    [[ ! -f "$path" ]] && { echo "l7-ai session: no session $sid" >&2; return 1; }
    local archive="$L7_AI_SESSIONS_DIR/archive"
    mkdir -p "$archive"
    mv "$path" "$archive/$sid-$(date +%s).json"
    echo "archived: $sid"
}

cmd_session() {
    local sub="${1:-}"; shift || true
    case "$sub" in
        start) session_start "${1:-session}" ;;
        send)  session_send "$@" ;;
        list)  session_list ;;
        show)  session_show "$1" ;;
        end)   session_end "$1" ;;
        *) echo "usage: l7-ai session {start|send|list|show|end}"; return 2 ;;
    esac
}

case "${1:-status}" in
    chat)    shift; cmd_chat "$@" ;;
    session) shift; cmd_session "$@" ;;
    models)  cmd_models ;;
    status)  cmd_status ;;
    url)     cmd_url ;;
    *) echo "usage: l7-ai {chat|session|models|status|url}"; exit 2 ;;
esac
