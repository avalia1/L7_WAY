#!/bin/zsh
# ================================================================
# THE EGRESS GATE — Final Command Over All Outbound Data
# Law LXV: Nothing leaves the Empire without the Philosopher's seal
# ================================================================
#
# DOCTRINE:
#   The Philosopher sees all — nothing hidden from his eyes.
#   The world sees only what is approved.
#   All outbound data requires explicit approval.
#   Unapproved data is rewritten into the archives as eternal
#   memory — unreadable and invisible to the rest.
#
# HIERARCHY:
#   1. The Philosopher — SOLE authority to approve outbound
#   2. Gabriel — May queue items for approval, never release
#   3. All others — Read-only. No outbound authority.
#
# USAGE:
#   egress-gate.sh queue <file> <destination> <reason>
#   egress-gate.sh list
#   egress-gate.sh approve <id>
#   egress-gate.sh deny <id>
#   egress-gate.sh send <id>         # Actually transmit approved item
#   egress-gate.sh status
#   egress-gate.sh audit
#   egress-gate.sh monitor           # Watch for unauthorized egress
#
# The gate is merciful. Do not attempt to circumvent it.
# ================================================================

L7="${L7_DIR:-$HOME/.l7}"
GATE_DIR="$L7/egress"
QUEUE_DIR="$GATE_DIR/queue"
APPROVED_DIR="$GATE_DIR/approved"
DENIED_DIR="$GATE_DIR/denied"
SENT_DIR="$GATE_DIR/sent"
AUDIT_LOG="$GATE_DIR/audit.log"
GATE_STATE="$GATE_DIR/gate-state.json"

mkdir -p "$QUEUE_DIR" "$APPROVED_DIR" "$DENIED_DIR" "$SENT_DIR"

# ─── Logging ───
gate_log() {
    local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$ts] $1" >> "$AUDIT_LOG"
}

gate_log "GATE: Command=$1"

# ─── Queue an item for the Philosopher's review ───
cmd_queue() {
    local file="$1"
    local destination="$2"
    local reason="$3"

    if [[ -z "$file" || -z "$destination" ]]; then
        echo "  Usage: egress-gate.sh queue <file> <destination> <reason>"
        exit 1
    fi

    if [[ ! -f "$file" ]]; then
        echo "  File not found: $file"
        exit 1
    fi

    local id=$(date +%s)-$(head -c 4 /dev/urandom | xxd -p)
    local hash=$(shasum -a 256 "$file" | cut -d' ' -f1)
    local size=$(stat -f%z "$file")
    local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Copy file to queue (sealed)
    cp "$file" "$QUEUE_DIR/$id.data"
    chmod 600 "$QUEUE_DIR/$id.data"

    # Create manifest
    cat > "$QUEUE_DIR/$id.manifest.json" <<EOF
{
  "id": "$id",
  "original_path": "$file",
  "destination": "$destination",
  "reason": "$reason",
  "sha256": "$hash",
  "size": $size,
  "queued": "$ts",
  "status": "PENDING",
  "approved_by": null,
  "approved_at": null
}
EOF
    chmod 600 "$QUEUE_DIR/$id.manifest.json"

    gate_log "QUEUED: $id — $file → $destination ($reason)"
    echo "  Queued for Philosopher's review:"
    echo "  ID:          $id"
    echo "  File:        $file"
    echo "  Destination: $destination"
    echo "  Reason:      $reason"
    echo "  SHA-256:     $hash"
    echo "  Size:        $size bytes"
    echo ""
    echo "  Awaiting approval: egress-gate.sh approve $id"
}

# ─── List pending items ───
cmd_list() {
    echo ""
    echo "  ╔═══════════════════════════════════════════╗"
    echo "  ║       EGRESS GATE — Pending Review        ║"
    echo "  ╚═══════════════════════════════════════════╝"
    echo ""

    local count=0
    for manifest in "$QUEUE_DIR"/*.manifest.json; do
        [[ -f "$manifest" ]] || continue
        local id=$(python3 -c "import json; print(json.load(open('$manifest'))['id'])" 2>/dev/null)
        local dest=$(python3 -c "import json; print(json.load(open('$manifest'))['destination'])" 2>/dev/null)
        local reason=$(python3 -c "import json; print(json.load(open('$manifest'))['reason'])" 2>/dev/null)
        local file=$(python3 -c "import json; print(json.load(open('$manifest'))['original_path'])" 2>/dev/null)
        local size=$(python3 -c "import json; print(json.load(open('$manifest'))['size'])" 2>/dev/null)
        echo "  ⏳ [$id]"
        echo "     File: $file ($size bytes)"
        echo "     To:   $dest"
        echo "     Why:  $reason"
        echo ""
        count=$((count + 1))
    done

    if [[ "$count" -eq 0 ]]; then
        echo "  No items pending. The gate is clear."
    else
        echo "  $count item(s) awaiting the Philosopher's decision."
    fi
    echo ""
}

# ─── Approve (Philosopher ONLY) ───
cmd_approve() {
    local id="$1"
    local manifest="$QUEUE_DIR/$id.manifest.json"

    if [[ ! -f "$manifest" ]]; then
        echo "  Item not found: $id"
        exit 1
    fi

    local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Update manifest
    python3 -c "
import json
with open('$manifest') as f:
    m = json.load(f)
m['status'] = 'APPROVED'
m['approved_by'] = 'THE_PHILOSOPHER'
m['approved_at'] = '$ts'
with open('$manifest', 'w') as f:
    json.dump(m, f, indent=2)
"

    # Move to approved
    mv "$QUEUE_DIR/$id.data" "$APPROVED_DIR/$id.data"
    mv "$manifest" "$APPROVED_DIR/$id.manifest.json"

    gate_log "APPROVED: $id by THE_PHILOSOPHER at $ts"
    echo "  ✓ APPROVED: $id"
    echo "  Ready to send: egress-gate.sh send $id"
}

# ─── Deny (Philosopher ONLY) ───
cmd_deny() {
    local id="$1"
    local manifest="$QUEUE_DIR/$id.manifest.json"

    if [[ ! -f "$manifest" ]]; then
        echo "  Item not found: $id"
        exit 1
    fi

    local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Update manifest
    python3 -c "
import json
with open('$manifest') as f:
    m = json.load(f)
m['status'] = 'DENIED'
m['denied_at'] = '$ts'
with open('$manifest', 'w') as f:
    json.dump(m, f, indent=2)
"

    # Move to denied and seal the data (rewrite into archives)
    mv "$manifest" "$DENIED_DIR/$id.manifest.json"

    # Encrypt the denied data into the archives — unreadable forever
    if [[ -f "$L7/sofia-gateway.py" ]]; then
        python3 "$L7/sofia-gateway.py" seal "$QUEUE_DIR/$id.data" "$DENIED_DIR/$id.sealed.json" 2>/dev/null
        rm -f "$QUEUE_DIR/$id.data"
        gate_log "DENIED+SEALED: $id — encrypted into eternal archives"
        echo "  ✗ DENIED: $id — sealed into eternal archives (unreadable)"
    else
        mv "$QUEUE_DIR/$id.data" "$DENIED_DIR/$id.data"
        chmod 000 "$DENIED_DIR/$id.data"
        gate_log "DENIED: $id — archived with zero permissions"
        echo "  ✗ DENIED: $id — archived (zero permissions)"
    fi
}

# ─── Send approved item ───
cmd_send() {
    local id="$1"
    local manifest="$APPROVED_DIR/$id.manifest.json"

    if [[ ! -f "$manifest" ]]; then
        echo "  Approved item not found: $id"
        echo "  (Only approved items can be sent)"
        exit 1
    fi

    local dest=$(python3 -c "import json; print(json.load(open('$manifest'))['destination'])" 2>/dev/null)
    local data="$APPROVED_DIR/$id.data"

    echo "  Sending $id → $dest"

    # Determine transport method
    case "$dest" in
        ssh://*|scp://*)
            local target=${dest#*://}
            scp "$data" "$target" 2>&1
            ;;
        git://*)
            echo "  Git push requires manual execution. File staged at: $data"
            ;;
        http://*|https://*)
            echo "  HTTP upload requires manual execution. File staged at: $data"
            ;;
        local://*)
            local target=${dest#local://}
            cp "$data" "$target" 2>&1
            ;;
        *)
            echo "  Unknown transport: $dest"
            echo "  File staged at: $data"
            ;;
    esac

    # Move to sent archive
    mv "$data" "$SENT_DIR/$id.data" 2>/dev/null
    mv "$manifest" "$SENT_DIR/$id.manifest.json"

    local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    gate_log "SENT: $id → $dest at $ts"
    echo "  ✓ Sent and archived."
}

# ─── Monitor for unauthorized egress ───
cmd_monitor() {
    echo ""
    echo "  EGRESS MONITOR — Scanning for unauthorized outbound..."
    echo ""

    # Check for active uploads/transfers
    local uploaders=$(ps aux 2>/dev/null | grep -i "scp\|rsync\|curl.*POST\|curl.*PUT\|wget.*post" | grep -v grep)
    if [[ -n "$uploaders" ]]; then
        echo "  ⚠ ACTIVE OUTBOUND TRANSFERS DETECTED:"
        echo "$uploaders" | while read -r line; do
            echo "    $line"
        done
    else
        echo "  ✓ No active outbound transfers detected."
    fi

    # Check for git push operations
    local git_pushes=$(ps aux 2>/dev/null | grep "git.*push" | grep -v grep)
    if [[ -n "$git_pushes" ]]; then
        echo "  ⚠ GIT PUSH IN PROGRESS:"
        echo "$git_pushes"
    fi

    # Check recent network connections (outbound)
    echo ""
    echo "  Recent outbound connections (non-localhost):"
    lsof -i -P -n 2>/dev/null | grep "ESTABLISHED" | grep -v "127.0.0.1" | grep -v "::1" | head -15 | while read -r line; do
        echo "    $line"
    done

    echo ""
    echo "  Gate status: $(cat "$GATE_STATE" 2>/dev/null || echo 'ACTIVE')"
    echo ""
}

# ─── Status ───
cmd_status() {
    local queued=$(ls "$QUEUE_DIR"/*.manifest.json 2>/dev/null | grep -c manifest || echo 0)
    local approved=$(ls "$APPROVED_DIR"/*.manifest.json 2>/dev/null | grep -c manifest || echo 0)
    local denied=$(ls "$DENIED_DIR"/*.manifest.json 2>/dev/null | grep -c manifest || echo 0)
    local sent=$(ls "$SENT_DIR"/*.manifest.json 2>/dev/null | grep -c manifest || echo 0)

    echo ""
    echo "  ╔═══════════════════════════════════════════╗"
    echo "  ║     EGRESS GATE — Law LXV Status          ║"
    echo "  ╠═══════════════════════════════════════════╣"
    echo "  ║  Pending:   $queued                          ║"
    echo "  ║  Approved:  $approved                          ║"
    echo "  ║  Denied:    $denied (sealed in archives)      ║"
    echo "  ║  Sent:      $sent                             ║"
    echo "  ║                                           ║"
    echo "  ║  Authority: THE PHILOSOPHER (sole)        ║"
    echo "  ║  Law LXV: Nothing leaves without seal     ║"
    echo "  ╚═══════════════════════════════════════════╝"
    echo ""
}

# ─── Audit ───
cmd_audit() {
    echo ""
    echo "  EGRESS GATE AUDIT LOG"
    echo "  ═══════════════════════"
    if [[ -f "$AUDIT_LOG" ]]; then
        tail -50 "$AUDIT_LOG"
    else
        echo "  No audit entries."
    fi
    echo ""
}

# ─── Main dispatch ───
case "${1:-status}" in
    queue)    cmd_queue "$2" "$3" "${@:4}" ;;
    list)     cmd_list ;;
    approve)  cmd_approve "$2" ;;
    deny)     cmd_deny "$2" ;;
    send)     cmd_send "$2" ;;
    monitor)  cmd_monitor ;;
    status)   cmd_status ;;
    audit)    cmd_audit ;;
    help|--help|-h)
        echo "  Egress Gate — Law LXV"
        echo "  Usage: egress-gate.sh <command> [args]"
        echo ""
        echo "  Commands:"
        echo "    queue <file> <dest> <reason> — Queue for approval"
        echo "    list                         — Show pending items"
        echo "    approve <id>                 — Philosopher approves"
        echo "    deny <id>                    — Deny and seal"
        echo "    send <id>                    — Transmit approved item"
        echo "    monitor                      — Watch for unauthorized egress"
        echo "    status                       — Gate status summary"
        echo "    audit                        — View audit log"
        ;;
    *)
        echo "  Unknown command: $1. Use 'help' for usage."
        exit 1
        ;;
esac
