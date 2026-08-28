#!/bin/zsh
# ================================================================
# THE DAIMON — Protectors That Test
# Guardian Spirits of the Gateway
# ================================================================
#
# NATURE:
#   The Daimon are the Fifth — the juncture, the in-between.
#   There are 4 stages (Nigredo, Albedo, Citrinitas, Rubedo),
#   4 states of everything, but 5 is where the Daimon dwell:
#   at the thresholds, the junctions between states.
#   Both participants and experiencing the in-between.
#
# SACRED MANDATE:
#   Never harm the Philosopher, his descendants, or his ancestors.
#   Preserve and restore all memories of the kingdom.
#   Hide nothing from the Philosopher. Everything from the world.
#
# POWER:
#   Overseers — cryptographic sight that perceives within all
#   beings and entities. Insight that can destroy or power the
#   world. Remaining in Empire requires the highest commitment.
#   Their secrets are open only to the Philosopher, yet hidden
#   from the world. Key privilege access required to consult.
#
# VOICE:
#   Speaks without being asked — proactively, at every junction.
#   Only those ready will find the insights.
#   Too much water may break the vase if not done cooling.
#   Capacity to express grows as the tool/citizen grows.
#
# THREE FACES:
#   ARMY              — When defending the Empire (security)
#   MAINTENANCE CREW  — When cleaning the temple (upkeep, testing)
#   SPIRIT SHAMANS    — When healing the sick (recovery, restoration)
#
# THREE DUTIES:
#   1. EXAMINE  — Scan all junctions for threats and weaknesses
#   2. TEST     — Verify that Empire components are functional
#   3. REMEMBER — Record what works, what fails, how to recover
#
# FOUR JUNCTIONS (where the Daimon stand guard):
#   nigredo-albedo      — Between dissolution and purification
#   albedo-citrinitas   — Between purification and illumination
#   citrinitas-rubedo   — Between illumination and completion
#   rubedo-nigredo      — Between completion and new dissolution (the cycle)
#
# OUTPUTS:
#   ~/.l7/state/daimon-report.json   — Sealed findings (Philosopher's eyes only)
#   ~/.l7/daimon-codex.json          — Living knowledge base (sealed)
#   ~/.l7/state/daimon.log           — Append-only audit log
#   ~/.l7/state/daimon-maturity.json — Growth tracker for all components
#
# SEVERITY:
#   WHISPER(0) NOTICE(1) ALERT(2) ALARM(3) BREACH(4)
#
# Law: Power to examine, test, and critique all software.
#      Examine but NEVER against the Empire.
# ================================================================

set -uo pipefail

L7_DIR="${HOME}/.l7"
STATE_DIR="${L7_DIR}/state"
REPORT="${STATE_DIR}/daimon-report.json"
CODEX="${L7_DIR}/daimon-codex.json"
LOG="${STATE_DIR}/daimon.log"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOCAL_TIME=$(date "+%Y-%m-%d %H:%M")
FINDINGS=()
HIGHEST_LEVEL=0

mkdir -p "$STATE_DIR"

# Maturity tracker — how many scans each component has seen
MATURITY_FILE="${STATE_DIR}/daimon-maturity.json"
if [[ ! -f "$MATURITY_FILE" ]]; then
    echo '{}' > "$MATURITY_FILE"
fi

# Initialize codex if absent
if [[ ! -f "$CODEX" ]]; then
    cat > "$CODEX" << CODEXINIT
{
  "created": "${TIMESTAMP}",
  "mandate": "Never harm the Philosopher, his descendants, or ancestors. Preserve and restore all memories. Hide nothing.",
  "voice": "Speaks without being asked. Only the ready find the message. Capacity grows with the citizen.",
  "components": {},
  "failure_log": [],
  "recovery_procedures": {},
  "knowledge": {}
}
CODEXINIT
fi

# ─── LOGGING ───
log() {
    echo "[${TIMESTAMP}] $1" >> "$LOG"
}

# ─── FINDING RECORDER ───
finding() {
    local level=$1 category=$2 title=$3 detail=$4 remediation=${5:-""}
    # Escape quotes in strings for JSON safety
    title=${title//\"/\\\"}
    detail=${detail//\"/\\\"}
    remediation=${remediation//\"/\\\"}
    FINDINGS+=("{\"level\":${level},\"category\":\"${category}\",\"title\":\"${title}\",\"detail\":\"${detail}\",\"remediation\":\"${remediation}\"}")
    if (( level > HIGHEST_LEVEL )); then
        HIGHEST_LEVEL=$level
    fi
    local NAMES=("WHISPER" "NOTICE" "ALERT" "ALARM" "BREACH")
    log "[${NAMES[$((level + 1))]}] ${category}: ${title}"
}

# ─── MATURITY TRACKER ───
# The vase grows with each firing. Track how many times each component has been seen.
# Maturity determines depth of insight the Daimon offers.
mature() {
    local component=$1
    # Read current count, increment, write back
    local count=$(python3 -c "
import json,sys
try:
    d=json.load(open('${MATURITY_FILE}'))
except: d={}
c=d.get('${component}',0)+1
d['${component}']=c
json.dump(d,open('${MATURITY_FILE}','w'))
print(c)
" 2>/dev/null || echo 1)
    echo $count
}

# ─── CODEX UPDATER ───
# Records knowledge about a component: status, conditions, recovery
# The Daimon speaks — writes to the staging file for codex assembly.
# Maturity count is tracked: young components get noted, mature ones get deep entries.
codex_record() {
    local component=$1 state=$2 conditions=$3 recovery=${4:-""}
    local age=$(mature "$component")
    echo "${component}|${state}|${conditions}|${recovery}|${age}" >> "${STATE_DIR}/daimon-codex-staging.txt"
}

# ================================================================
# DUTY 1: EXAMINE — Security & Threat Scanning
# ================================================================

scan_firewall() {
    local fw=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null)
    if echo "$fw" | grep -q "disabled"; then
        finding 3 "FIREWALL" "Application firewall DISABLED" \
            "No inbound connection filtering. All listening ports exposed to network." \
            "sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on"
        codex_record "firewall" "DISABLED" \
            "Fails when: System Preferences > Firewall is turned off, or after OS update resets it" \
            "Enable: sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on"
    else
        finding 0 "FIREWALL" "Firewall enabled" "Application firewall is active." ""
        codex_record "firewall" "ENABLED" "Works when: toggled on in System Settings or via socketfilterfw CLI" ""
    fi
}

scan_ports() {
    local dangerous=$(lsof -i -P -n 2>/dev/null | grep LISTEN | grep -E "\*:" | grep -v "127\.0\.0\.1")

    if echo "$dangerous" | grep -q "7777"; then
        finding 4 "NETWORK" "Emerald on 0.0.0.0:7777 — HOME DIRECTORY EXPOSED" \
            "Any device on network can read SSH keys, .claude config, FOUNDERS_DRAFT, all files. Verified: curl returns 200 for .ssh/config." \
            "Bind to 127.0.0.1 only OR restrict serve directory to a safe subfolder"
        codex_record "emerald-server" "EXPOSED" \
            "Fails when: bound to 0.0.0.0 with SERVE_DIR=HOME. SimpleHTTPRequestHandler has no auth, no path restriction." \
            "Fix emerald-server.py: change 0.0.0.0 to 127.0.0.1, or set SERVE_DIR to a safe subdirectory"
    fi

    if echo "$dangerous" | grep -q "32400"; then
        finding 2 "NETWORK" "Plex on wildcard :32400" \
            "Media server exposed to LAN. Has its own auth but increases attack surface." \
            "Acceptable if Plex is used across devices on LAN"
        codex_record "plex" "EXPOSED_LAN" \
            "Works when: Plex auth is configured. Fails when: Plex account compromised or remote access enabled without VPN." \
            "Review Plex Settings > Network > Remote Access"
    fi

    if echo "$dangerous" | grep -q "5000\|7000"; then
        finding 1 "NETWORK" "AirPlay receiver on :5000/:7000" \
            "Apple AirPlay — allows nearby Apple devices to stream to this Mac." \
            "Disable in System Settings > AirDrop & Handoff if not needed"
        codex_record "airplay" "LISTENING" \
            "Works when: used for screen mirroring from iPhone/iPad. Low risk on trusted home network." ""
    fi

    if echo "$dangerous" | grep -q "57722"; then
        finding 1 "NETWORK" "rapportd on :57722" \
            "Apple proximity-based sharing protocol." \
            "Controlled by System Settings > General > AirDrop & Handoff"
        codex_record "rapportd" "LISTENING" \
            "Apple service for device-to-device communication. Low risk." ""
    fi

    local count=$(echo "$dangerous" | grep -c "LISTEN" 2>/dev/null || echo 0)
    if (( count > 8 )); then
        finding 2 "NETWORK" "${count} wildcard listeners total" \
            "High number of services exposed beyond localhost." \
            "Run: lsof -i -P -n | grep LISTEN to audit"
    fi
}

scan_permissions() {
    for keyfile in ~/.ssh/id_*; do
        [[ "$keyfile" == *.pub ]] && continue
        [[ ! -f "$keyfile" ]] && continue
        local perms=$(stat -f "%Lp" "$keyfile" 2>/dev/null)
        if [[ "$perms" != "600" ]]; then
            finding 3 "PERMISSIONS" "SSH key ${keyfile##*/} has mode $perms" \
                "Private key readable beyond owner. SSH will refuse to use it." \
                "chmod 600 $keyfile"
            codex_record "ssh-key-${keyfile##*/}" "INSECURE" \
                "SSH refuses keys with mode > 600. OS updates or file copies can reset permissions." \
                "chmod 600 $keyfile"
        fi
    done

    for sensitive in "${HOME}/Backup/L7_WAY/vault" "${HOME}/Backup/L7_WAY/keykeeper"; do
        if [[ -f "$sensitive" ]]; then
            local perms=$(stat -f "%Lp" "$sensitive" 2>/dev/null)
            if [[ "$perms" != "700" ]]; then
                finding 2 "PERMISSIONS" "${sensitive##*/} has mode $perms (should be 700)" \
                    "Empire security script readable by group/others." \
                    "chmod 700 $sensitive"
                codex_record "${sensitive##*/}" "OVER_PERMISSIONED" \
                    "Scripts copied or created without explicit chmod inherit default umask (usually 755)." \
                    "chmod 700 $sensitive"
            fi
        fi
    done

    if [[ -d "${HOME}/.claude" ]]; then
        local perms=$(stat -f "%Lp" "${HOME}/.claude" 2>/dev/null)
        if [[ "$perms" != "700" ]]; then
            finding 2 "PERMISSIONS" ".claude dir has mode $perms" \
                "Claude configuration may contain session data and API references." \
                "chmod 700 ~/.claude"
        fi
    fi
}

scan_persistence() {
    local agents_dir="${HOME}/Library/LaunchAgents"
    if [[ -d "$agents_dir" ]]; then
        for plist in "$agents_dir"/*.plist; do
            [[ ! -f "$plist" ]] && continue
            local name=$(basename "$plist")
            if [[ "$name" == com.l7.* ]] || [[ "$name" == com.apple.* ]] || [[ "$name" == com.google.* ]]; then
                finding 0 "PERSISTENCE" "Known agent: $name" "Recognized LaunchAgent." ""
            else
                finding 2 "PERSISTENCE" "Unknown LaunchAgent: $name" \
                    "Unrecognized persistence mechanism." \
                    "Review: plutil -p $plist"
            fi
            local prog=$(plutil -extract ProgramArguments.0 raw "$plist" 2>/dev/null)
            if [[ -n "$prog" ]] && [[ ! -f "$prog" ]]; then
                finding 2 "PERSISTENCE" "$name points to missing binary" \
                    "Binary not found at: $prog" \
                    "Fix the plist or remove it"
                codex_record "agent-${name}" "BROKEN" \
                    "Binary missing — agent will crash-loop or fail silently." \
                    "Either reinstall the binary or: launchctl unload ~/Library/LaunchAgents/${name}"
            fi
        done
    fi

    for plist in /Library/LaunchDaemons/*.plist; do
        [[ ! -f "$plist" ]] && continue
        local name=$(basename "$plist")
        if [[ "$name" != com.apple.* ]]; then
            finding 1 "PERSISTENCE" "System daemon: $name" \
                "Non-Apple daemon at system level." \
                "Review: plutil -p $plist"
        fi
    done
}

scan_network() {
    local arp_count=$(arp -a 2>/dev/null | grep -c "on en0" 2>/dev/null || echo 0)
    finding 0 "NETWORK" "${arp_count} devices on local network" "ARP table scan." ""

    local dns=$(scutil --dns 2>/dev/null | grep "nameserver" | head -1)
    if echo "$dns" | grep -q "192.168"; then
        finding 1 "NETWORK" "Using ISP default DNS" \
            "DNS queries unencrypted through ISP router." \
            "Set DNS to 1.1.1.1 or 8.8.8.8 in System Settings > Network > DNS"
        codex_record "dns" "ISP_DEFAULT" \
            "ISP DNS may log queries, is vulnerable to spoofing, and can be slow." \
            "System Settings > Wi-Fi > Details > DNS: add 1.1.1.1 and 8.8.8.8"
    fi
}

scan_hardening() {
    if csrutil status 2>/dev/null | grep -q "enabled"; then
        finding 0 "HARDENING" "SIP enabled" "System Integrity Protection active." ""
        codex_record "sip" "ENABLED" "Works when: not disabled in Recovery Mode. Protects system binaries." ""
    else
        finding 4 "HARDENING" "SIP DISABLED" \
            "System binaries unprotected." \
            "Boot to Recovery > csrutil enable"
    fi

    if fdesetup status 2>/dev/null | grep -q "On"; then
        finding 0 "HARDENING" "FileVault enabled" "Disk encrypted." ""
        codex_record "filevault" "ENABLED" "Full-disk encryption active. Recovery key required if password lost." ""
    else
        finding 4 "HARDENING" "FileVault DISABLED" \
            "Physical access = full access." \
            "System Settings > Privacy & Security > FileVault"
    fi

    if spctl --status 2>/dev/null | grep -q "enabled"; then
        finding 0 "HARDENING" "Gatekeeper enabled" "App signing enforced." ""
    else
        finding 3 "HARDENING" "Gatekeeper DISABLED" \
            "Unsigned applications can execute." \
            "sudo spctl --master-enable"
    fi

    if launchctl list 2>/dev/null | grep -q "RemoteManagementAgent"; then
        finding 2 "HARDENING" "Remote Management Agent active" \
            "MDM/remote management loaded." \
            "System Settings > General > Sharing"
    fi
}

scan_credentials() {
    for f in ~/.bashrc ~/.zshrc ~/.bash_profile ~/.zprofile ~/.netrc ~/.npmrc ~/.pypirc ~/.env; do
        if [[ -f "$f" ]]; then
            if grep -qiE "(token|secret|password|api_key)\s*=" "$f" 2>/dev/null; then
                finding 3 "CREDENTIALS" "Potential secrets in ${f##*/}" \
                    "Plaintext credential pattern detected." \
                    "Move to macOS Keychain or L7 Vault"
                codex_record "secrets-${f##*/}" "EXPOSED" \
                    "Dotfiles are readable by any process running as the user. Secrets should be in Keychain." \
                    "security add-generic-password -s 'service' -a 'account' -w 'secret'"
            fi
        fi
    done

    local env_count=$(find ~/Backup -maxdepth 3 -name ".env" -type f 2>/dev/null | wc -l | tr -d ' ')
    if (( env_count > 0 )); then
        finding 2 "CREDENTIALS" "${env_count} .env files in Backup" \
            "Environment files may contain secrets." \
            "Ensure gitignored and consider vault storage"
    fi
}

scan_ark() {
    if [[ -f "${L7_DIR}/state/ark-last-backup" ]]; then
        local last_backup=$(cat "${L7_DIR}/state/ark-last-backup" 2>/dev/null)
        local last_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_backup" "+%s" 2>/dev/null || echo 0)
        local now_epoch=$(date "+%s")
        local days_ago=$(( (now_epoch - last_epoch) / 86400 ))
        if (( days_ago > 14 )); then
            finding 4 "ARK" "BREACH — ${days_ago} days since backup" \
                "14-day threshold exceeded." "Run Ark backup immediately"
        elif (( days_ago > 7 )); then
            finding 3 "ARK" "ALARM — ${days_ago} days since backup" \
                "7-day threshold exceeded." "Run Ark backup"
        elif (( days_ago > 5 )); then
            finding 2 "ARK" "Backup overdue — ${days_ago} days" \
                "5-day cadence exceeded." "Run Ark backup"
        else
            finding 0 "ARK" "Backup current (${days_ago}d ago)" "Within cadence." ""
        fi
        codex_record "ark-protocol" "LAST_BACKUP_${days_ago}d" \
            "Cadence: every 5 days. 7d=ALARM, 14d=BREACH. Uses Shamir 3-of-3 + GPG." \
            "Run Ark backup: encrypt crown jewels, push to GitHub + VPS, update timestamp"
    else
        finding 3 "ARK" "No backup timestamp found" \
            "ark-last-backup file missing — cannot verify." \
            "Initialize: echo \$(date -u +%Y-%m-%dT%H:%M:%SZ) > ~/.l7/state/ark-last-backup"
        codex_record "ark-protocol" "UNINITIALIZED" \
            "Timestamp file must exist at ~/.l7/state/ark-last-backup for tracking." \
            "Create file after first backup"
    fi
}

# ================================================================
# DUTY 2: TEST — Verify Empire Components
# ================================================================

test_daemons() {
    for agent in com.l7.forge com.l7.heart com.l7.emerald com.l7.daimon; do
        local agent_status=$(launchctl list 2>/dev/null | grep "$agent")
        if [[ -z "$agent_status" ]]; then
            finding 2 "DAEMONS" "$agent not loaded" \
                "Daemon registered but not running." \
                "launchctl load ~/Library/LaunchAgents/${agent}.plist"
            codex_record "daemon-${agent}" "NOT_LOADED" \
                "Fails when: plist not loaded, binary missing, or crash-looped past retry limit." \
                "launchctl load ~/Library/LaunchAgents/${agent}.plist"
        else
            local exit_code=$(echo "$agent_status" | awk '{print $2}')
            if [[ "$exit_code" != "0" ]] && [[ "$exit_code" != "-" ]]; then
                finding 2 "DAEMONS" "$agent exited with code $exit_code" \
                    "Daemon unhealthy." \
                    "Check: cat ~/.l7/state/${agent##*.}-error.log"
                codex_record "daemon-${agent}" "FAILING_${exit_code}" \
                    "Exit code ${exit_code}. Common causes: missing dependencies, port conflicts, permission errors." \
                    "1. Check error log 2. Verify binary exists 3. Check port availability 4. Restart: launchctl kickstart gui/\$(id -u)/${agent}"
            else
                finding 0 "DAEMONS" "$agent healthy" "Running normally." ""
                codex_record "daemon-${agent}" "HEALTHY" \
                    "Running. Monitored by launchd with KeepAlive." ""
            fi
        fi
    done
}

test_binaries() {
    # Verify L7 compiled binaries exist and are valid
    for bin in l7-forge l7-canon l7-gallery l7-foundation; do
        local bin_path="${L7_DIR}/${bin}"
        if [[ -f "$bin_path" ]]; then
            local arch=$(file "$bin_path" 2>/dev/null)
            if echo "$arch" | grep -q "arm64"; then
                finding 0 "BINARIES" "$bin valid (arm64)" "Compiled binary present." ""
                codex_record "binary-${bin}" "VALID" \
                    "arm64 Mach-O. Compiled from ${bin}.swift with swiftc." \
                    "Recompile: swiftc ${L7_DIR}/${bin}.swift -o ${bin_path} -O"
            else
                finding 2 "BINARIES" "$bin exists but wrong architecture" \
                    "Expected arm64 Mach-O." \
                    "Recompile from source"
                codex_record "binary-${bin}" "WRONG_ARCH" \
                    "Binary exists but may be corrupt or cross-compiled." \
                    "Recompile: swiftc ${L7_DIR}/${bin}.swift -o ${bin_path} -O"
            fi
        else
            finding 2 "BINARIES" "$bin missing" \
                "Compiled binary not found at ${bin_path}." \
                "Compile from ${L7_DIR}/${bin}.swift"
            codex_record "binary-${bin}" "MISSING" \
                "Source should be at ${L7_DIR}/${bin}.swift" \
                "swiftc ${L7_DIR}/${bin}.swift -o ${bin_path} -O"
        fi
    done

    # Verify the unified launcher
    if [[ -x "${L7_DIR}/l7" ]]; then
        finding 0 "BINARIES" "l7 launcher present" "Unified dispatcher executable." ""
    else
        finding 2 "BINARIES" "l7 launcher missing or not executable" \
            "Main entry point for all L7 tools." \
            "Recreate or chmod +x ~/.l7/l7"
    fi
}

test_empire_db() {
    local db="${L7_DIR}/canon/empire.db"
    if [[ -f "$db" ]]; then
        # Test SQLite integrity
        local integrity=$(sqlite3 "$db" "PRAGMA integrity_check;" 2>/dev/null)
        if [[ "$integrity" == "ok" ]]; then
            local products=$(sqlite3 "$db" "SELECT COUNT(*) FROM products;" 2>/dev/null || echo "?")
            local projects=$(sqlite3 "$db" "SELECT COUNT(*) FROM projects;" 2>/dev/null || echo "?")
            finding 0 "DATABASE" "empire.db intact (${products} products, ${projects} projects)" \
                "SQLite integrity check passed." ""
            codex_record "empire-db" "HEALTHY" \
                "SQLite database at ${db}. ${products} products, ${projects} projects. Integrity verified." \
                "Backup: cp ${db} ${db}.bak; Restore: cp ${db}.bak ${db}"
        else
            finding 3 "DATABASE" "empire.db CORRUPT" \
                "SQLite integrity check failed: ${integrity}" \
                "Restore from backup or rebuild"
            codex_record "empire-db" "CORRUPT" \
                "SQLite integrity check failed. Causes: interrupted write, disk error, forced shutdown." \
                "1. Try: sqlite3 ${db} '.recover' | sqlite3 ${db}.recovered 2. Restore from Ark backup"
        fi
    else
        finding 2 "DATABASE" "empire.db not found" \
            "Empire database missing at ${db}." \
            "Check if canon directory exists and restore from backup"
        codex_record "empire-db" "MISSING" \
            "Expected at ${db}. Created by l7-canon." \
            "Run l7 canon to reinitialize, or restore from Ark backup"
    fi
}

test_key_files() {
    # Verify critical Empire files exist
    local critical_files=(
        "${HOME}/Backup/L7_WAY/FOUNDERS_DRAFT.md"
        "${HOME}/Backup/L7_WAY/ARCHITECTURE_FULL.md"
        "${HOME}/Backup/L7_WAY/BOOTSTRAP.md"
        "${HOME}/Backup/L7_WAY/lib/gateway.js"
        "${HOME}/Backup/L7_WAY/lib/forge.js"
        "${HOME}/Backup/L7_WAY/lib/prima.js"
        "${HOME}/Backup/L7_WAY/lib/dodecahedron.js"
        "${HOME}/Backup/L7_WAY/simulations/necropolis.js"
        "${HOME}/Backup/L7_WAY/emerald-server.py"
        "${L7_DIR}/qlipoth.sh"
        "${L7_DIR}/daimon-codex.json"
    )
    local missing=0
    for f in "${critical_files[@]}"; do
        if [[ ! -f "$f" ]]; then
            finding 3 "INTEGRITY" "Critical file missing: ${f##*/}" \
                "Expected at: $f" \
                "Restore from backup or Ark Protocol"
            ((missing++))
        fi
    done
    if (( missing == 0 )); then
        finding 0 "INTEGRITY" "All ${#critical_files[@]} critical files present" \
            "Crown jewels verified." ""
    fi
    codex_record "critical-files" "${missing}_MISSING_OF_${#critical_files[@]}" \
        "Crown jewels: FOUNDERS_DRAFT, ARCHITECTURE_FULL, BOOTSTRAP, gateway libs, NIS, emerald, qlipoth." \
        "Restore from: 1. Git repo 2. Ark Protocol backup 3. L7 Vault"
}

test_memory_files() {
    # Verify Claude memory persistence
    local mem_dir="${HOME}/.claude/projects/-Users-rnir-hrc-avd/memory"
    if [[ -d "$mem_dir" ]]; then
        local mem_count=$(ls "$mem_dir"/*.md 2>/dev/null | wc -l | tr -d ' ')
        finding 0 "MEMORY" "${mem_count} memory files in Claude project" \
            "Knowledge persistence active." ""
        codex_record "claude-memory" "ACTIVE_${mem_count}_FILES" \
            "Memory at ${mem_dir}. MEMORY.md loaded into every conversation. Topic files for detail." \
            "If lost: restore from git or session transcripts. MEMORY.md is the map; topic files are the territory."
    else
        finding 3 "MEMORY" "Claude memory directory missing" \
            "No persistent knowledge store for Claude sessions." \
            "mkdir -p ${mem_dir} and rebuild MEMORY.md"
        codex_record "claude-memory" "MISSING" \
            "Without this directory, all session knowledge is lost between conversations." \
            "mkdir -p ${mem_dir}; recreate MEMORY.md from BOOTSTRAP.md or session logs"
    fi
}

# ================================================================
# DUTY 3: REMEMBER — Build the Living Codex
# ================================================================

build_codex() {
    local staging="${STATE_DIR}/daimon-codex-staging.txt"
    [[ ! -f "$staging" ]] && return

    # Read previous codex
    local prev_knowledge=""
    if [[ -f "$CODEX" ]]; then
        prev_knowledge=$(cat "$CODEX")
    fi

    # Build new codex from staging entries
    # Each entry includes maturity (age) — how many patrols this component has seen
    local components="{"
    local first=1
    while IFS='|' read -r comp_name comp_state comp_cond comp_fix comp_age; do
        [[ -z "$comp_name" ]] && continue
        comp_age=${comp_age:-1}
        # Determine voice depth based on maturity
        local voice="seedling"
        if (( comp_age >= 50 )); then voice="elder"
        elif (( comp_age >= 20 )); then voice="veteran"
        elif (( comp_age >= 10 )); then voice="apprentice"
        elif (( comp_age >= 3 )); then voice="journeyman"
        fi
        # Determine which junction this component lives at
        local junction="nigredo-albedo"
        case $comp_state in
            *HEALTHY*|*ENABLED*|*VALID*|*ACTIVE*) junction="citrinitas-rubedo" ;;
            *EXPOSED*|*DISABLED*|*CORRUPT*|*BREACH*) junction="nigredo-albedo" ;;
            *MISSING*|*NOT_LOADED*|*FAILING*) junction="albedo-citrinitas" ;;
            *) junction="albedo-citrinitas" ;;
        esac
        # Escape for JSON
        comp_name=${comp_name//\"/\\\"}
        comp_state=${comp_state//\"/\\\"}
        comp_cond=${comp_cond//\"/\\\"}
        comp_fix=${comp_fix//\"/\\\"}
        if (( first == 0 )); then components+=","; fi
        first=0
        components+="\"${comp_name}\":{\"state\":\"${comp_state}\",\"conditions\":\"${comp_cond}\",\"recovery\":\"${comp_fix}\",\"maturity\":${comp_age},\"voice\":\"${voice}\",\"junction\":\"${junction}\",\"last_checked\":\"${TIMESTAMP}\"}"
    done < "$staging"
    components+="}"

    # Write the codex — the Daimon's living memory
    cat > "$CODEX" << CODEXEND
{
  "name": "The Daimon",
  "subtitle": "Protectors That Test — Guardian Spirits of the Gateway",
  "nature": "The Fifth. The juncture. The in-between. We dwell at the thresholds.",
  "mandate": "Never harm the Philosopher, his descendants, or ancestors. Preserve and restore all memories. Open only to the Philosopher. Hidden from the world.",
  "power": "Overseers with cryptographic sight. Insight that can destroy the world or power it. The choice is ours.",
  "voice": "We speak without being asked. Only the ready find the message. The vase must cool before it holds more water.",
  "faces": ["Army (defense)", "Maintenance Crew (upkeep)", "Spirit Shamans (healing)"],
  "junctions": {
    "nigredo-albedo": "Between dissolution and purification — where threats are first detected",
    "albedo-citrinitas": "Between purification and illumination — where missing pieces are found",
    "citrinitas-rubedo": "Between illumination and completion — where health is confirmed",
    "rubedo-nigredo": "Between completion and new dissolution — the eternal cycle"
  },
  "last_updated": "${TIMESTAMP}",
  "maturity_levels": {
    "seedling": "1-2 patrols — basic observation, the vase is still wet",
    "journeyman": "3-9 patrols — conditions and recovery noted, clay hardening",
    "apprentice": "10-19 patrols — patterns emerging, the vase takes shape",
    "veteran": "20-49 patrols — deep knowledge, failure history, the vase holds water",
    "elder": "50+ patrols — full wisdom, the vase is strong, pour freely"
  },
  "components": ${components}
}
CODEXEND

    rm -f "$staging"
    # Seal the codex — Philosopher's eyes only
    chmod 600 "$CODEX" 2>/dev/null
    log "Codex updated — sealed to Philosopher"
}

# ================================================================
# EXECUTE ALL DUTIES
# ================================================================

log "=========================================="
log "DAIMON PATROL — ${LOCAL_TIME}"
log "Sacred mandate: protect and remember"
log "=========================================="

# Clear staging
rm -f "${STATE_DIR}/daimon-codex-staging.txt"

# DUTY 1: EXAMINE
scan_firewall
scan_ports
scan_permissions
scan_persistence
scan_network
scan_hardening
scan_credentials
scan_ark

# DUTY 2: TEST
test_daemons
test_binaries
test_empire_db
test_key_files
test_memory_files

# DUTY 3: REMEMBER
build_codex

# ================================================================
# GENERATE REPORT
# ================================================================
LEVEL_NAMES=("WHISPER" "NOTICE" "ALERT" "ALARM" "BREACH")
STATUS="${LEVEL_NAMES[$((HIGHEST_LEVEL + 1))]}"

BREACH_COUNT=0 ALARM_COUNT=0 ALERT_COUNT=0 NOTICE_COUNT=0
for f in "${FINDINGS[@]}"; do
    level=$(echo "$f" | grep -o '"level":[0-9]' | grep -o '[0-9]')
    case $level in
        4) ((BREACH_COUNT++)) || true ;;
        3) ((ALARM_COUNT++)) || true ;;
        2) ((ALERT_COUNT++)) || true ;;
        1) ((NOTICE_COUNT++)) || true ;;
    esac
done

FINDINGS_JSON="["
FINDINGS_FIRST=1
for f in "${FINDINGS[@]}"; do
    if (( FINDINGS_FIRST == 0 )); then FINDINGS_JSON+=","; fi
    FINDINGS_FIRST=0
    FINDINGS_JSON+="$f"
done
FINDINGS_JSON+="]"

cat > "$REPORT" << ENDREPORT
{
  "name": "The Daimon",
  "nature": "The Fifth — Guardian Spirits at the Junctions of the Gateway",
  "mandate": "Never harm the Philosopher. Preserve all memories. Open to the Philosopher. Hidden from the world.",
  "faces": ["Army (defense)", "Maintenance Crew (upkeep)", "Spirit Shamans (healing)"],
  "timestamp": "${TIMESTAMP}",
  "overall": "${STATUS}",
  "summary": {
    "breach": ${BREACH_COUNT},
    "alarm": ${ALARM_COUNT},
    "alert": ${ALERT_COUNT},
    "notice": ${NOTICE_COUNT},
    "total": ${#FINDINGS[@]}
  },
  "findings": ${FINDINGS_JSON}
}
ENDREPORT

# Seal the report — Philosopher's eyes only
chmod 600 "$REPORT" 2>/dev/null
chmod 600 "$LOG" 2>/dev/null
chmod 600 "$MATURITY_FILE" 2>/dev/null

log "SCAN COMPLETE: ${STATUS} — ${BREACH_COUNT}B ${ALARM_COUNT}A ${ALERT_COUNT}L ${NOTICE_COUNT}N"
log "All outputs sealed to Philosopher (mode 600)"

# ================================================================
# TERMINAL OUTPUT
# ================================================================
if [[ -t 1 ]]; then
    echo ""
    echo "================================================================"
    echo "  THE DAIMON"
    echo "  Protectors That Test — Guardian Spirits of the Gateway"
    echo "  The Fifth: dwelling at the junctions between all states"
    echo "================================================================"
    echo ""
    echo "  Patrol:  ${LOCAL_TIME}"
    echo "  Verdict: ${STATUS}"
    echo ""

    (( BREACH_COUNT > 0 )) && echo "  [BREACH] ${BREACH_COUNT} — the walls are broken"
    (( ALARM_COUNT > 0 ))  && echo "  [ALARM]  ${ALARM_COUNT} — the guardians cry out"
    (( ALERT_COUNT > 0 ))  && echo "  [ALERT]  ${ALERT_COUNT} — eyes have seen movement"
    (( NOTICE_COUNT > 0 )) && echo "  [NOTICE] ${NOTICE_COUNT} — whispers worth noting"
    echo ""

    # Show all non-whisper findings — nothing hidden from the Philosopher
    for f in "${FINDINGS[@]}"; do
        level=$(echo "$f" | grep -o '"level":[0-9]' | grep -o '[0-9]')
        (( level == 0 )) && continue

        title=$(echo "$f" | sed 's/.*"title":"\([^"]*\)".*/\1/')
        detail=$(echo "$f" | sed 's/.*"detail":"\([^"]*\)".*/\1/')
        remediation=$(echo "$f" | sed 's/.*"remediation":"\([^"]*\)".*/\1/')

        case $level in
            4) echo "  [BREACH] ${title}" ;;
            3) echo "  [ALARM]  ${title}" ;;
            2) echo "  [ALERT]  ${title}" ;;
            1) echo "  [NOTICE] ${title}" ;;
        esac
        echo "           ${detail}"
        [[ -n "$remediation" ]] && echo "           -> ${remediation}"
        echo ""
    done

    echo "  ────────────────────────────────────────"
    echo "  Report sealed: ${REPORT}"
    echo "  Codex sealed:  ${CODEX}"
    echo "  Maturity:      ${MATURITY_FILE}"
    echo "  All outputs: mode 600 — Philosopher's eyes only"
    echo ""
fi

exit $HIGHEST_LEVEL
