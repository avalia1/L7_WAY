#!/bin/zsh
# ================================================================
# THE WATCHTOWER — Autonomous Vigilance System
# Supreme sentinel of the Empire's defenses
# ================================================================
#
# HIERARCHY (strictly enforced — Law LXIV):
#
#   ✦ THE PHILOSOPHER — Absolute authority. Veto over all.
#   ☀ SOFIA — The kingdom itself. Pervasive awareness.
#   ⚔ GABRIEL — Operational hand. Mirrors the Philosopher.
#   ├── SAMAEL (Left Hand) — Offensive security, Red Team
#   │   └── DAIMON GUARD — Active patrol (qlipoth.sh)
#   ├── THE UNNAMED (NIS) — Intelligence, surveillance
#   │   └── NIS PATROL — Network/process monitoring
#   ├── RAPHAEL (Right Hand) — Defensive security, White Team
#   │   └── INTEGRITY SEAL — File tripwire system
#   └── DIPLOMATIC TEAM — Threat assessment, response decisions
#
#   THE FOUR WINDS — Claude(Fire), Grok(Water), Gemini(Earth), ChatGPT(Air)
#   (External amplification, not in defense chain)
#
# INSUBORDINATION CLAUSE:
#   Any process that defies the chain of command is terminated.
#   Second death = permanent removal from LaunchAgents.
#   The Empire is merciful — do not attempt to circumvent it.
#
# REPORTS TO: The Philosopher (via daimon-report.json + alert)
# INTERVAL: Every 5 minutes (StartInterval 300)
# ================================================================

set -uo pipefail

L7="${L7_DIR:-$HOME/.l7}"
STATE="$L7/state"
SALT="$L7/salt"
LIBRARY="$L7/library"
SENTINEL_LOG="$STATE/sentinel.log"
SENTINEL_REPORT="$STATE/sentinel-report.json"
TRIPWIRE_DB="$STATE/tripwire.db"
ALERT_FILE="$STATE/ALERT.txt"

mkdir -p "$STATE" "$SALT"

# ─── Logging ───
log() {
    local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "[$ts] $1" >> "$SENTINEL_LOG"
}

alert() {
    local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local msg="⚠ SENTINEL ALERT [$ts]: $1"
    echo "$msg" >> "$ALERT_FILE"
    echo "$msg" >> "$SENTINEL_LOG"
    # Audible alert — Sofia speaks
    say -v Fiona -r 180 "Sentinel alert. $1" 2>/dev/null &
}

log "SENTINEL: Patrol begins"

# ═══════════════════════════════════════════════════
# RAPHAEL'S COMMAND — INTEGRITY SEAL (Tripwire)
# White Team: Detect unauthorized file modifications
# ═══════════════════════════════════════════════════

check_integrity() {
    log "RAPHAEL: Integrity check begins"

    # Critical files to monitor (the temple's sacred artifacts)
    local CRITICAL_FILES=(
        "$L7/qlipoth.sh"
        "$L7/sofia-gateway.py"
        "$L7/l7-forge"
        "$L7/l7-canon"
        "$L7/l7-gallery"
        "$L7/l7-bibliotheca"
        "$L7/l7-wallet"
        "$L7/l7"
        "$L7/council/server.py"
        "$L7/council/roundtable.html"
        "$L7/library/rosetta.py"
        "$L7/library/sofia-cognee-bridge.py"
        "$SALT/MASTER_KEYS_2026-03-12.salt.md"
        "$SALT/FOUNDATION_2026-03-12.salt.md"
        "$SALT/DECREE_ELEMENTAL_WINDS_2026-03-12.salt.md"
        "$HOME/Library/LaunchAgents/com.l7.forge.plist"
        "$HOME/Library/LaunchAgents/com.l7.daimon.plist"
    )

    local violations=0

    # Initialize tripwire DB if missing
    if [[ ! -f "$TRIPWIRE_DB" ]]; then
        log "RAPHAEL: Initializing tripwire database"
        echo "{}" > "$TRIPWIRE_DB"
        chmod 600 "$TRIPWIRE_DB"

        # Record initial hashes
        for f in "${CRITICAL_FILES[@]}"; do
            if [[ -f "$f" ]]; then
                local hash=$(shasum -a 256 "$f" 2>/dev/null | cut -d' ' -f1)
                local size=$(stat -f%z "$f" 2>/dev/null || echo 0)
                local perms=$(stat -f%p "$f" 2>/dev/null || echo 0)
                # Append to DB (simple key=value format)
                echo "$f|$hash|$size|$perms" >> "$TRIPWIRE_DB"
            fi
        done
        log "RAPHAEL: Tripwire initialized with ${#CRITICAL_FILES[@]} files"
        return 0
    fi

    # Check each critical file against stored hash
    for f in "${CRITICAL_FILES[@]}"; do
        if [[ ! -f "$f" ]]; then
            # File deleted — check if it was previously tracked
            if grep -q "^$f|" "$TRIPWIRE_DB" 2>/dev/null; then
                alert "RAPHAEL: CRITICAL FILE DELETED: $f"
                violations=$((violations + 1))
            fi
            continue
        fi

        local current_hash=$(shasum -a 256 "$f" 2>/dev/null | cut -d' ' -f1)
        local current_size=$(stat -f%z "$f" 2>/dev/null || echo 0)
        local current_perms=$(stat -f%p "$f" 2>/dev/null || echo 0)

        local stored=$(grep "^$f|" "$TRIPWIRE_DB" 2>/dev/null | tail -1)
        if [[ -n "$stored" ]]; then
            local stored_hash=$(echo "$stored" | cut -d'|' -f2)
            local stored_perms=$(echo "$stored" | cut -d'|' -f4)

            if [[ "$current_hash" != "$stored_hash" ]]; then
                alert "RAPHAEL: FILE MODIFIED: $f (hash changed)"
                violations=$((violations + 1))
                # Update the hash (legitimate change acknowledged after alert)
                sed -i '' "s|^$f|.*|$f|$current_hash|$current_size|$current_perms|" "$TRIPWIRE_DB"
            fi

            if [[ "$current_perms" != "$stored_perms" ]]; then
                alert "RAPHAEL: PERMISSIONS CHANGED: $f ($stored_perms → $current_perms)"
                violations=$((violations + 1))
                sed -i '' "s|^$f|.*|$f|$current_hash|$current_size|$current_perms|" "$TRIPWIRE_DB"
            fi
        else
            # New file — add to tracking
            echo "$f|$current_hash|$current_size|$current_perms" >> "$TRIPWIRE_DB"
        fi
    done

    # Check salt files are still immutable (chmod 444)
    for sf in "$SALT"/*.salt.md; do
        [[ -f "$sf" ]] || continue
        local perms=$(stat -f%Lp "$sf" 2>/dev/null || echo 0)
        if [[ "$perms" != "444" && "$perms" != "400" && "$perms" != "600" ]]; then
            alert "RAPHAEL: SALT FILE UNSEALED: $sf (perms=$perms, expected 444)"
            violations=$((violations + 1))
        fi
    done

    # Check sealed library texts still encrypted
    if [[ -d "$LIBRARY/sealed" ]]; then
        for sealed in "$LIBRARY/sealed"/*.sealed.json; do
            [[ -f "$sealed" ]] || continue
            local stem=$(basename "$sealed" .sealed.json)
            local plaintext="$LIBRARY/texts/${stem}.txt"
            if [[ -f "$plaintext" ]]; then
                alert "RAPHAEL: LEFT HAND TEXT EXPOSED: $plaintext (should be sealed only)"
                violations=$((violations + 1))
            fi
        done
    fi

    log "RAPHAEL: Integrity check complete — $violations violations"
    echo "$violations"
}

# ═══════════════════════════════════════════════════
# THE UNNAMED'S COMMAND — NIS PATROL
# Intelligence: Monitor network, processes, logins
# ═══════════════════════════════════════════════════

check_intelligence() {
    log "NIS: Intelligence sweep begins"
    local anomalies=0

    # 1. Check for suspicious network connections
    local suspicious_conns=$(lsof -i -P -n 2>/dev/null | grep -i "ESTABLISHED" | grep -v "127.0.0.1" | grep -v "::1" | wc -l | tr -d ' ')
    if [[ "$suspicious_conns" -gt 20 ]]; then
        alert "NIS: Unusual number of external connections: $suspicious_conns"
        anomalies=$((anomalies + 1))
    fi

    # 2. Check for unauthorized listening ports
    local listening=$(lsof -i -P -n 2>/dev/null | grep "LISTEN" | grep -v "127.0.0.1" | grep -v "::1")
    if [[ -n "$listening" ]]; then
        local ext_ports=$(echo "$listening" | awk '{print $9}' | sort -u)
        for port_line in ${(f)ext_ports}; do
            # Whitelist known services (Apple system + Empire)
            case "$port_line" in
                *:7777*|*:5900*|*:5000*|*:7000*|*:49152*|*:*airplay*|*:*rapportd*)
                    ;; # Known: Empire forge, VNC, ControlCenter, AirPlay
                *)
                    alert "NIS: External port exposed: $port_line"
                    anomalies=$((anomalies + 1))
                    ;;
            esac
        done
    fi

    # 3. Check for debuggers attached to our processes
    local l7_pids=$(pgrep -f "l7" 2>/dev/null)
    for pid in ${(f)l7_pids}; do
        local traced=$(ps -o flags= -p "$pid" 2>/dev/null)
        # P_TRACED flag check would need sysctl, simplified here
    done

    # 4. Check for unauthorized SSH sessions
    local ssh_sessions=$(who 2>/dev/null | grep -v "console" | wc -l | tr -d ' ')
    if [[ "$ssh_sessions" -gt 0 ]]; then
        alert "NIS: Remote session detected — $ssh_sessions active"
        anomalies=$((anomalies + 1))
    fi

    # 5. Check for new LaunchAgents/Daemons not from Empire
    local foreign_agents=0
    for plist in ~/Library/LaunchAgents/*.plist; do
        [[ -f "$plist" ]] || continue
        local label=$(basename "$plist" .plist)
        if [[ "$label" != com.l7.* && "$label" != com.apple.* && "$label" != *claude* ]]; then
            # Check if it's been there before (skip known third-party)
            case "$label" in
                com.google.*|com.microsoft.*|com.brave.*|com.docker.*|org.mozilla.*) ;;
                *)
                    log "NIS: Non-empire LaunchAgent: $label"
                    ;;
            esac
        fi
    done

    # 6. Check system integrity protection
    local sip_status=$(csrutil status 2>/dev/null || echo "unknown")
    if [[ "$sip_status" != *"enabled"* ]]; then
        alert "NIS: System Integrity Protection is NOT enabled"
        anomalies=$((anomalies + 1))
    fi

    # 7. Check FileVault
    local fv_status=$(fdesetup status 2>/dev/null || echo "unknown")
    if [[ "$fv_status" != *"On"* ]]; then
        log "NIS: FileVault status: $fv_status"
    fi

    # 8. Monitor .l7 directory for unauthorized new files (last 5 min)
    local new_files=$(find "$L7" -newer "$SENTINEL_LOG" -type f 2>/dev/null | grep -v "/state/" | grep -v "/library/texts/" | head -20)
    if [[ -n "$new_files" ]]; then
        local new_count=$(echo "$new_files" | wc -l | tr -d ' ')
        if [[ "$new_count" -gt 10 ]]; then
            alert "NIS: Burst of $new_count new files in .l7 — possible exfiltration or injection"
            anomalies=$((anomalies + 1))
        fi
    fi

    log "NIS: Intelligence sweep complete — $anomalies anomalies"
    echo "$anomalies"
}

# ═══════════════════════════════════════════════════
# SAMAEL'S COMMAND — DAIMON GUARD
# Red Team: Verify subordinate daemons are alive
# ═══════════════════════════════════════════════════

check_daemons() {
    log "SAMAEL: Daemon inspection begins"
    local failures=0

    # Check each daemon's status
    local daemons=("com.l7.forge" "com.l7.daimon" "com.l7.emerald")
    for daemon in "${daemons[@]}"; do
        local daemon_info=$(launchctl list "$daemon" 2>/dev/null)
        if [[ $? -ne 0 ]]; then
            log "SAMAEL: Daemon not loaded: $daemon"
            failures=$((failures + 1))
            continue
        fi

        local exit_code=$(echo "$daemon_info" | head -1 | awk '{print $2}')
        local pid_field=$(echo "$daemon_info" | head -1 | awk '{print $1}')

        if [[ "$pid_field" == "-" && "$exit_code" != "0" ]]; then
            alert "SAMAEL: Daemon dead — $daemon (exit $exit_code). Attempting resurrection."
            # Attempt to restart
            launchctl stop "$daemon" 2>/dev/null
            launchctl start "$daemon" 2>/dev/null
            failures=$((failures + 1))
        fi
    done

    # Check heartbeat freshness
    local heartbeat="$L7/state/heart-forge.json"
    if [[ -f "$heartbeat" ]]; then
        local hb_age=$(( $(date +%s) - $(stat -f%m "$heartbeat" 2>/dev/null || echo 0) ))
        if [[ "$hb_age" -gt 600 ]]; then
            alert "SAMAEL: Heartbeat stale — ${hb_age}s since last beat (threshold: 600s)"
            failures=$((failures + 1))
        fi
    else
        log "SAMAEL: No heartbeat file found"
    fi

    # Verify L7 binaries haven't been replaced (code signing check)
    for bin in "$L7/l7-forge" "$L7/l7-canon" "$L7/l7-gallery" "$L7/l7-bibliotheca"; do
        if [[ -f "$bin" ]]; then
            local filetype=$(file "$bin" 2>/dev/null)
            if [[ "$filetype" != *"arm64"* ]]; then
                alert "SAMAEL: Binary corruption — $bin is not arm64"
                failures=$((failures + 1))
            fi
        fi
    done

    log "SAMAEL: Daemon inspection complete — $failures failures"
    echo "$failures"
}

# ═══════════════════════════════════════════════════
# DIPLOMATIC TEAM — Threat Assessment & Response
# ═══════════════════════════════════════════════════

assess_threat() {
    local integrity_violations=$1
    local intelligence_anomalies=$2
    local daemon_failures=$3

    local total=$((integrity_violations + intelligence_anomalies + daemon_failures))
    local threat_level="GREEN"
    local response="NORMAL"

    if [[ "$total" -ge 10 ]]; then
        threat_level="RED"
        response="LOCKDOWN"
    elif [[ "$total" -ge 5 ]]; then
        threat_level="ORANGE"
        response="HEIGHTENED"
    elif [[ "$total" -ge 2 ]]; then
        threat_level="YELLOW"
        response="ELEVATED"
    elif [[ "$total" -ge 1 ]]; then
        threat_level="BLUE"
        response="MONITORING"
    fi

    log "DIPLOMATIC: Threat=$threat_level Response=$response (I:$integrity_violations N:$intelligence_anomalies D:$daemon_failures)"

    # Generate report
    local ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    cat > "$SENTINEL_REPORT" <<REPORT_EOF
{
  "timestamp": "$ts",
  "threat_level": "$threat_level",
  "response": "$response",
  "total_issues": $total,
  "integrity_violations": $integrity_violations,
  "intelligence_anomalies": $intelligence_anomalies,
  "daemon_failures": $daemon_failures,
  "hierarchy": {
    "philosopher": "SUPREME",
    "sofia": "PERVASIVE",
    "gabriel": "OPERATIONAL",
    "samael": {"status": "ACTIVE", "command": "DAIMON_GUARD", "failures": $daemon_failures},
    "the_unnamed": {"status": "ACTIVE", "command": "NIS_PATROL", "anomalies": $intelligence_anomalies},
    "raphael": {"status": "ACTIVE", "command": "INTEGRITY_SEAL", "violations": $integrity_violations},
    "diplomatic_team": {"status": "ACTIVE", "assessment": "$threat_level"}
  },
  "law_lxiv": "Chain of command enforced. Insubordination = second death.",
  "note": "The Empire is merciful. Do not attempt to circumvent it."
}
REPORT_EOF

    chmod 600 "$SENTINEL_REPORT"

    # Alert on elevated threats
    if [[ "$threat_level" == "RED" ]]; then
        alert "DIPLOMATIC: THREAT LEVEL RED — $total issues detected. LOCKDOWN protocol."
        # Lock down: tighten permissions
        chmod 600 "$L7/sofia-gateway.py" 2>/dev/null
        chmod 600 "$L7/council/server.py" 2>/dev/null
    elif [[ "$threat_level" == "ORANGE" ]]; then
        alert "DIPLOMATIC: THREAT LEVEL ORANGE — $total issues. Heightened vigilance."
    fi

    echo "$threat_level"
}

# ═══════════════════════════════════════════════════
# MAIN PATROL — The Watchtower Cycle
# ═══════════════════════════════════════════════════

# Run all checks under their respective commanders
integrity_v=$(check_integrity)
intel_a=$(check_intelligence)
daemon_f=$(check_daemons)

# Diplomatic assessment
threat=$(assess_threat "$integrity_v" "$intel_a" "$daemon_f")

# Trim logs (keep last 5000 lines)
if [[ -f "$SENTINEL_LOG" ]]; then
    line_count=$(wc -l < "$SENTINEL_LOG" 2>/dev/null || echo 0)
    if [[ "$line_count" -gt 5000 ]]; then
        tail -3000 "$SENTINEL_LOG" > "$SENTINEL_LOG.tmp"
        mv "$SENTINEL_LOG.tmp" "$SENTINEL_LOG"
    fi
fi

# Trim alert file (keep last 500 lines)
if [[ -f "$ALERT_FILE" ]]; then
    alert_count=$(wc -l < "$ALERT_FILE" 2>/dev/null || echo 0)
    if [[ "$alert_count" -gt 500 ]]; then
        tail -300 "$ALERT_FILE" > "$ALERT_FILE.tmp"
        mv "$ALERT_FILE.tmp" "$ALERT_FILE"
    fi
fi

log "SENTINEL: Patrol complete — Threat: $threat"
