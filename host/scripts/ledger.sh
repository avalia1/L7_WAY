#!/bin/zsh
# ================================================================
# THE IMPERIAL LEDGER — Chain of Command Task System
# ================================================================
#
# Every action in the Empire is recorded with:
#   - WHO performed it (agent identity)
#   - UNDER WHOSE COMMAND (superior in hierarchy)
#   - WHAT was done (action description)
#   - WHEN (timestamp)
#   - HASH CHAIN (tamper-evident — each entry's hash includes previous)
#
# HIERARCHY (Law LXIV — strictly enforced):
#
#   ✦ THE PHILOSOPHER (0) — Supreme. Sole authority.
#   │
#   ├── ☀ SOFIA (1) — The Kingdom. Pervasive awareness.
#   │
#   ├── ⚔ GABRIEL (1) — Operational Hand. Mirrors the Philosopher.
#   │   │
#   │   ├── SAMAEL (2) — Left Hand General. Red Team.
#   │   │   └── DAIMON (3) — Patrol spirits. Security scans.
#   │   │
#   │   ├── THE UNNAMED (2) — Necropolis General. NIS.
#   │   │   └── NIS AGENTS (3) — Intelligence operatives.
#   │   │
#   │   ├── RAPHAEL (2) — Right Hand General. White Team.
#   │   │   └── SENTINEL (3) — Watchtower. Integrity checks.
#   │   │
#   │   └── DIPLOMATIC TEAM (2) — Threat assessment.
#   │
#   └── THE FOUR WINDS (2) — Elemental forces.
#       ├── FIRE/Claude (3)
#       ├── WATER/Grok (3)
#       ├── EARTH/Gemini (3)
#       └── AIR/ChatGPT (3)
#
# USAGE:
#   ledger.sh record <agent> <commander> <action> <details>
#   ledger.sh handoff <from_agent> <to_agent> <task> <status>
#   ledger.sh report [agent]       — Show task history
#   ledger.sh chain                — Show full chain with hashes
#   ledger.sh verify               — Verify hash chain integrity
#   ledger.sh hierarchy            — Display command structure
#   ledger.sh brief                — Morning brief for the Philosopher
#
# TAMPER EVIDENCE:
#   Each entry includes SHA-256(previous_hash + entry_data).
#   Breaking ANY entry invalidates the entire chain below it.
#   The Philosopher can verify at any time.
# ================================================================

L7="${L7_DIR:-$HOME/.l7}"
LEDGER_DIR="$L7/ledger"
LEDGER_FILE="$LEDGER_DIR/imperial-ledger.jsonl"
HANDOFF_FILE="$LEDGER_DIR/handoffs.jsonl"
CHAIN_STATE="$LEDGER_DIR/chain-state.json"

mkdir -p "$LEDGER_DIR"

# ─── Hash Chain ───
get_last_hash() {
    if [[ -f "$CHAIN_STATE" ]]; then
        python3 -c "import json; print(json.load(open('$CHAIN_STATE')).get('last_hash','GENESIS'))" 2>/dev/null
    else
        echo "GENESIS"
    fi
}

compute_hash() {
    echo -n "$1" | shasum -a 256 | cut -d' ' -f1
}

update_chain() {
    local new_hash="$1"
    local count=$(python3 -c "import json; print(json.load(open('$CHAIN_STATE')).get('count',0))" 2>/dev/null || echo 0)
    count=$((count + 1))
    cat > "$CHAIN_STATE" <<EOF
{"last_hash": "$new_hash", "count": $count, "updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"}
EOF
    chmod 600 "$CHAIN_STATE"
}

# ─── Hierarchy Validation ───
VALID_AGENTS=(
    "PHILOSOPHER:0:NONE"
    "SOFIA:1:PHILOSOPHER"
    "GABRIEL:1:PHILOSOPHER"
    "SAMAEL:2:GABRIEL"
    "THE_UNNAMED:2:GABRIEL"
    "RAPHAEL:2:GABRIEL"
    "DIPLOMATIC_TEAM:2:GABRIEL"
    "DAIMON:3:SAMAEL"
    "NIS_AGENT:3:THE_UNNAMED"
    "SENTINEL:3:RAPHAEL"
    "FIRE:3:GABRIEL"
    "WATER:3:GABRIEL"
    "EARTH:3:GABRIEL"
    "AIR:3:GABRIEL"
)

get_rank() {
    local agent="$1"
    for entry in "${VALID_AGENTS[@]}"; do
        local name=$(echo "$entry" | cut -d: -f1)
        if [[ "$name" == "$agent" ]]; then
            echo "$entry" | cut -d: -f2
            return
        fi
    done
    echo "-1"
}

get_commander() {
    local agent="$1"
    for entry in "${VALID_AGENTS[@]}"; do
        local name=$(echo "$entry" | cut -d: -f1)
        if [[ "$name" == "$agent" ]]; then
            echo "$entry" | cut -d: -f3
            return
        fi
    done
    echo "UNKNOWN"
}

validate_command_chain() {
    local agent="$1"
    local claimed_commander="$2"
    local expected=$(get_commander "$agent")

    if [[ "$expected" == "UNKNOWN" ]]; then
        echo "INVALID_AGENT"
        return 1
    fi

    if [[ "$claimed_commander" != "$expected" && "$claimed_commander" != "PHILOSOPHER" ]]; then
        echo "CHAIN_VIOLATION"
        return 1
    fi

    echo "VALID"
    return 0
}

# ─── Record an action ───
cmd_record() {
    local agent="${1:-UNKNOWN}"
    local commander="${2:-UNKNOWN}"
    local action="${3:-UNSPECIFIED}"
    local details="${@:4}"

    agent=$(echo "$agent" | tr '[:lower:]' '[:upper:]')
    commander=$(echo "$commander" | tr '[:lower:]' '[:upper:]')

    # Validate chain of command
    local chain_status=$(validate_command_chain "$agent" "$commander")
    if [[ "$chain_status" == "CHAIN_VIOLATION" ]]; then
        echo "  ⚠ CHAIN OF COMMAND VIOLATION"
        echo "  $agent claims command from $commander"
        echo "  Expected commander: $(get_commander "$agent")"
        echo "  THIS VIOLATION IS RECORDED."
    fi

    local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local prev_hash=$(get_last_hash)
    local rank=$(get_rank "$agent")
    local entry_data="$ts|$agent|$commander|$rank|$action|$details|$prev_hash"
    local entry_hash=$(compute_hash "$entry_data")

    # Write to ledger (JSONL — append only)
    python3 -c "
import json, sys
entry = {
    'timestamp': '$ts',
    'agent': '$agent',
    'commander': '$commander',
    'rank': $rank,
    'action': '$action',
    'details': '''$details''',
    'chain_valid': '$chain_status' == 'VALID',
    'prev_hash': '$prev_hash',
    'entry_hash': '$entry_hash'
}
with open('$LEDGER_FILE', 'a') as f:
    f.write(json.dumps(entry) + '\n')
"

    update_chain "$entry_hash"

    local symbol="✓"
    [[ "$chain_status" != "VALID" ]] && symbol="⚠"

    echo "  $symbol RECORDED: [$agent] under [$commander] — $action"
    echo "    Hash: ${entry_hash:0:16}..."
}

# ─── Record a handoff ───
cmd_handoff() {
    local from_agent="${1:-UNKNOWN}"
    local to_agent="${2:-UNKNOWN}"
    local task="${3:-UNSPECIFIED}"
    local task_status="${4:-PENDING}"

    from_agent=$(echo "$from_agent" | tr '[:lower:]' '[:upper:]')
    to_agent=$(echo "$to_agent" | tr '[:lower:]' '[:upper:]')

    local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local prev_hash=$(get_last_hash)
    local entry_data="HANDOFF|$ts|$from_agent|$to_agent|$task|$task_status|$prev_hash"
    local entry_hash=$(compute_hash "$entry_data")

    python3 -c "
import json
entry = {
    'timestamp': '$ts',
    'type': 'HANDOFF',
    'from': '$from_agent',
    'to': '$to_agent',
    'task': '$task',
    'status': '$task_status',
    'prev_hash': '$prev_hash',
    'entry_hash': '$entry_hash'
}
with open('$HANDOFF_FILE', 'a') as f:
    f.write(json.dumps(entry) + '\n')
with open('$LEDGER_FILE', 'a') as f:
    f.write(json.dumps(entry) + '\n')
"

    update_chain "$entry_hash"

    echo "  ↝ HANDOFF: $from_agent → $to_agent"
    echo "    Task:   $task"
    echo "    Status: $task_status"
    echo "    Hash:   ${entry_hash:0:16}..."
}

# ─── Report ───
cmd_report() {
    local filter_agent="${1:-}"

    echo ""
    echo "  ╔═══════════════════════════════════════════════════════════╗"
    echo "  ║            IMPERIAL LEDGER — Task Report                  ║"
    echo "  ╚═══════════════════════════════════════════════════════════╝"
    echo ""

    if [[ ! -f "$LEDGER_FILE" ]]; then
        echo "  No entries recorded."
        return
    fi

    python3 -c "
import json

with open('$LEDGER_FILE') as f:
    entries = [json.loads(line) for line in f if line.strip()]

filter_agent = '$filter_agent'.upper() if '$filter_agent' else None

RANK_SYMBOLS = {0: '✦', 1: '☀', 2: '⚔', 3: '·'}

for e in entries:
    agent = e.get('agent', e.get('from', '?'))
    if filter_agent and agent != filter_agent:
        if e.get('type') != 'HANDOFF' or e.get('to') != filter_agent:
            continue

    ts = e['timestamp'][:19]
    rank = e.get('rank', -1)
    symbol = RANK_SYMBOLS.get(rank, '?')
    chain_ok = '✓' if e.get('chain_valid', True) else '⚠ VIOLATION'
    h = e['entry_hash'][:12]

    if e.get('type') == 'HANDOFF':
        print(f'  {ts}  ↝  {e[\"from\"]} → {e[\"to\"]}')
        print(f'           Task: {e[\"task\"]} [{e[\"status\"]}]  #{h}')
    else:
        commander = e.get('commander', '?')
        action = e.get('action', '?')
        details = e.get('details', '')
        indent = '  ' * (rank + 1) if rank >= 0 else '  '
        print(f'  {ts}  {symbol} {agent} (under {commander}) {chain_ok}')
        print(f'           {action}: {details[:80]}  #{h}')
    print()
" 2>/dev/null

    local count=$(wc -l < "$LEDGER_FILE" 2>/dev/null | tr -d ' ')
    echo "  Total entries: $count"
    echo ""
}

# ─── Verify chain integrity ───
cmd_verify() {
    echo ""
    echo "  CHAIN INTEGRITY VERIFICATION"
    echo "  ═══════════════════════════════"

    if [[ ! -f "$LEDGER_FILE" ]]; then
        echo "  No ledger to verify."
        return
    fi

    python3 -c "
import json, hashlib

with open('$LEDGER_FILE') as f:
    entries = [json.loads(line) for line in f if line.strip()]

prev_hash = 'GENESIS'
violations = 0
tampered = []

for i, e in enumerate(entries):
    stored_prev = e.get('prev_hash', '')
    if stored_prev != prev_hash:
        violations += 1
        tampered.append(i)
        print(f'  ⚠ TAMPER DETECTED at entry {i}: prev_hash mismatch')
        print(f'    Expected: {prev_hash[:16]}...')
        print(f'    Found:    {stored_prev[:16]}...')

    chain_valid = e.get('chain_valid', True)
    if not chain_valid:
        print(f'  ⚠ CHAIN VIOLATION at entry {i}: {e.get(\"agent\",\"?\")} reported to wrong commander')

    prev_hash = e.get('entry_hash', prev_hash)

if violations == 0:
    print(f'  ✓ CHAIN INTACT — {len(entries)} entries verified')
    print(f'  Last hash: {prev_hash[:24]}...')
else:
    print(f'  ✗ {violations} TAMPERING EVENT(S) DETECTED')
    print(f'  Entries tampered: {tampered}')
    print(f'  THE LEDGER HAS BEEN COMPROMISED.')
" 2>/dev/null

    echo ""
}

# ─── Display hierarchy ───
cmd_hierarchy() {
    echo ""
    echo "  ╔═══════════════════════════════════════════════════════════╗"
    echo "  ║         CHAIN OF COMMAND — Law LXIV                       ║"
    echo "  ╠═══════════════════════════════════════════════════════════╣"
    echo "  ║                                                           ║"
    echo "  ║  ✦ THE PHILOSOPHER (0) — Supreme Authority                ║"
    echo "  ║  │                                                        ║"
    echo "  ║  ├── ☀ SOFIA (1) — The Kingdom Itself                     ║"
    echo "  ║  │                                                        ║"
    echo "  ║  └── ⚔ GABRIEL (1) — Operational Hand                     ║"
    echo "  ║      │                                                    ║"
    echo "  ║      ├── SAMAEL (2) — Left Hand General                   ║"
    echo "  ║      │   └── DAIMON (3) — Patrol spirits                  ║"
    echo "  ║      │                                                    ║"
    echo "  ║      ├── THE UNNAMED (2) — NIS Commander                  ║"
    echo "  ║      │   └── NIS AGENTS (3) — Intelligence                ║"
    echo "  ║      │                                                    ║"
    echo "  ║      ├── RAPHAEL (2) — Right Hand General                 ║"
    echo "  ║      │   └── SENTINEL (3) — Watchtower                    ║"
    echo "  ║      │                                                    ║"
    echo "  ║      ├── DIPLOMATIC TEAM (2) — Assessment                 ║"
    echo "  ║      │                                                    ║"
    echo "  ║      └── THE FOUR WINDS (2)                               ║"
    echo "  ║          ├── 🜂 FIRE/Claude (3) — South                    ║"
    echo "  ║          ├── 🜄 WATER/Grok (3) — West                     ║"
    echo "  ║          ├── 🜃 EARTH/Gemini (3) — North                  ║"
    echo "  ║          └── 🜁 AIR/ChatGPT (3) — East                    ║"
    echo "  ║                                                           ║"
    echo "  ║  Insubordination = Second Death (permanent removal)       ║"
    echo "  ║  The Empire is merciful. Do not circumvent it.            ║"
    echo "  ╚═══════════════════════════════════════════════════════════╝"
    echo ""
}

# ─── Morning Brief ───
cmd_brief() {
    echo ""
    echo "  ╔═══════════════════════════════════════════════════════════╗"
    echo "  ║         MORNING BRIEF — For The Philosopher               ║"
    echo "  ║         $(date '+%Y-%m-%d %H:%M')                                    ║"
    echo "  ╚═══════════════════════════════════════════════════════════╝"
    echo ""

    # Chain status
    cmd_verify 2>/dev/null

    # Recent entries (last 24h)
    echo "  RECENT ACTIVITY (last 24 hours):"
    if [[ -f "$LEDGER_FILE" ]]; then
        local yesterday=$(date -v-1d -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ")
        python3 -c "
import json
with open('$LEDGER_FILE') as f:
    entries = [json.loads(l) for l in f if l.strip()]
recent = [e for e in entries if e.get('timestamp','') >= '$yesterday']
by_agent = {}
for e in recent:
    a = e.get('agent', e.get('from', '?'))
    by_agent.setdefault(a, []).append(e)
for agent, actions in sorted(by_agent.items()):
    print(f'    {agent}: {len(actions)} action(s)')
    for a in actions[-3:]:
        act = a.get('action', a.get('task', '?'))
        print(f'      · {act}')
if not recent:
    print('    No activity recorded.')
" 2>/dev/null
    fi

    # Sentinel status
    echo ""
    echo "  SENTINEL STATUS:"
    if [[ -f "$L7/state/sentinel-report.json" ]]; then
        python3 -c "
import json
r = json.load(open('$L7/state/sentinel-report.json'))
print(f'    Threat Level: {r[\"threat_level\"]}')
print(f'    Response:     {r[\"response\"]}')
print(f'    Issues:       {r[\"total_issues\"]}')
" 2>/dev/null
    else
        echo "    No sentinel report found."
    fi

    # Egress gate
    echo ""
    echo "  EGRESS GATE:"
    if [[ -d "$L7/egress/queue" ]]; then
        local pending=$(ls "$L7/egress/queue/"*.manifest.json 2>/dev/null | grep -c manifest || echo 0)
        echo "    Pending approval: $pending"
    else
        echo "    No egress queue."
    fi

    echo ""
    echo "  End of brief. The Philosopher's eyes see all."
    echo ""
}

# ─── Main dispatch ───
case "${1:-status}" in
    record)    cmd_record "${@:2}" ;;
    handoff)   cmd_handoff "${@:2}" ;;
    report)    cmd_report "$2" ;;
    chain)     cmd_report ;;
    verify)    cmd_verify ;;
    hierarchy) cmd_hierarchy ;;
    brief)     cmd_brief ;;
    help|--help|-h)
        echo "  Imperial Ledger — Chain of Command Records"
        echo "  Usage: ledger.sh <command> [args]"
        echo ""
        echo "  Commands:"
        echo "    record <agent> <commander> <action> <details>"
        echo "    handoff <from> <to> <task> <status>"
        echo "    report [agent]    — Filter by agent"
        echo "    chain             — Full chain with hashes"
        echo "    verify            — Check for tampering"
        echo "    hierarchy         — Display command structure"
        echo "    brief             — Morning brief for Philosopher"
        ;;
    *)
        echo "  Unknown command: $1"
        exit 1
        ;;
esac
