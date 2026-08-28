#!/bin/zsh
# ================================================================
# DAIMON — The Reflective Loop
# ================================================================
#
#   "We speak without being asked.
#    Only the ready find the message.
#    The vase must cool before it holds more water."
#
# The Fifth. The juncture. The in-between.
# Reads the empire's deltas, distills observations, writes to salt.
#
# USAGE:
#   daimon patrol       Run one reflection cycle (silent, distillate only)
#   daimon reflect      Full cycle: sense → judge (Quintessence) → gate → speak
#   daimon speak MSG    Force a speech now (respects channel + records)
#   daimon commune MSG  Talk to the Fifth. Persistent session, Daimon persona,
#                       situational context primed. Reply printed to stdout.
#   daimon commune-log  Show the current commune session history
#   daimon commune-end  Archive the current commune and start fresh
#   daimon status       Show maturity, last patrol, recent counts
#   daimon oracle [N]   Print the last N distillate reflections
#   daimon codex        Print current codex summary
#   daimon utterances   Print the last speeches
#
# Law LXXII — The Daimon Speaks. All speech recorded, rate-limited,
# quiet-houred, and judged by the Quintessence via l7-ai.
#
# ================================================================

set -uo pipefail

L7="${L7_DIR:-$HOME/.l7}"
CODEX="$L7/daimon-codex.json"
DISTILLATES="$L7/salt/distillates"
STATE_DIR="$L7/state/daimon"
CURSOR="$STATE_DIR/cursor.json"
UTTERANCES="$STATE_DIR/utterances.jsonl"
LAPIS="$L7/lapis.sh"
L7_AI="${L7_AI_BIN:-$HOME/.local/bin/l7-ai}"
[[ ! -x "$L7_AI" ]] && L7_AI="$L7/l7-ai.sh"
L7_VOICE_BIN="${L7_VOICE_BIN:-$HOME/.local/bin/l7-voice}"
[[ ! -x "$L7_VOICE_BIN" ]] && L7_VOICE_BIN="$L7/l7-voice.sh"

# Article III — Constraints
: "${L7_DAIMON_MAX_PER_HOUR:=3}"
: "${L7_DAIMON_MAX_PER_DAY:=12}"
: "${L7_DAIMON_COOLDOWN_SEC:=900}"     # 15 min
: "${L7_DAIMON_QUIET_START:=23}"       # hours (local)
: "${L7_DAIMON_QUIET_END:=8}"
: "${L7_DAIMON_NOVELTY_LOOKBACK:=5}"
: "${L7_DAIMON_VOICE:=0}"              # TTS opt-in
: "${L7_DAIMON_INBOX:=0}"              # inbox.md opt-in
: "${L7_DAIMON_ROLE:=daimon}"          # l7-voice role (resolves to Jamie Premium)

mkdir -p "$STATE_DIR" "$DISTILLATES"
touch "$UTTERANCES"

JUNCTIONS=("nigredo-albedo" "albedo-citrinitas" "citrinitas-rubedo" "rubedo-nigredo")

# ─── helpers ───

now_iso() { date -u +%Y-%m-%dT%H:%M:%SZ; }

py() { /usr/bin/python3 - "$@"; }

# Read a numeric field from cursor.json, default 0
cursor_get() {
    local key="$1"
    if [[ -f "$CURSOR" ]]; then
        py <<PY
import json
try:
    with open("$CURSOR") as f: d = json.load(f)
    print(d.get("$key", 0))
except Exception:
    print(0)
PY
    else
        echo 0
    fi
}

# Update cursor.json with new values (patrols, ledger_seen, audit_seen, last_junction_idx)
cursor_write() {
    local patrols="$1" ledger_seen="$2" audit_seen="$3" junction_idx="$4" last_iso="$5"
    py <<PY
import json
d = {
    "patrols": $patrols,
    "ledger_seen": $ledger_seen,
    "audit_seen": $audit_seen,
    "last_junction_idx": $junction_idx,
    "last_patrol": "$last_iso"
}
with open("$CURSOR","w") as f: json.dump(d, f, indent=2)
PY
}

count_lines() { [[ -f "$1" ]] && wc -l < "$1" | tr -d ' ' || echo 0; }

# Verify the N most-recently-touched *unique* signed files by comparing
# the current file hash to the LATEST recorded signature for that filepath.
# Prevents false-drift when a file is legitimately re-signed after an edit.
verify_recent() {
    local n="${1:-5}"
    local sigs="$L7/lapis/signatures.jsonl"
    [[ ! -f "$sigs" ]] && { echo "0 0"; return; }
    /usr/bin/python3 - "$sigs" "$n" <<'PY'
import hashlib, json, os, sys
sigs_path, n = sys.argv[1], int(sys.argv[2])
latest = {}   # filepath -> (order, hash)
order = 0
with open(sigs_path) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            rec = json.loads(line)
        except Exception:
            continue
        p = rec.get("filepath") or rec.get("path")
        h = rec.get("hash")
        if not p or not h:
            continue
        order += 1
        latest[p] = (order, h)
recent = sorted(latest.items(), key=lambda kv: -kv[1][0])[:n]
ok = 0; total = 0
for p, (_, stored) in recent:
    if not os.path.isfile(p):
        continue
    total += 1
    with open(p, "rb") as f:
        current = hashlib.sha256(f.read()).hexdigest()
    if current == stored:
        ok += 1
print(f"{ok} {total}")
PY
}

# Count components by state in daimon-codex
codex_states() {
    py <<PY
import json
with open("$CODEX") as f: d = json.load(f)
comps = d.get("components", {})
states = {}
for name, c in comps.items():
    s = c.get("state","UNKNOWN")
    states[s] = states.get(s,0) + 1
print(json.dumps(states))
PY
}

maturity_for() {
    local n="$1"
    if   (( n >= 50 )); then echo "elder"
    elif (( n >= 20 )); then echo "veteran"
    elif (( n >= 10 )); then echo "apprentice"
    elif (( n >= 3  )); then echo "journeyman"
    else                    echo "seedling"
    fi
}

# ─── PATROL ───

patrol() {
    local patrols_prev; patrols_prev=$(cursor_get patrols)
    local ledger_prev;  ledger_prev=$(cursor_get ledger_seen)
    local audit_prev;   audit_prev=$(cursor_get audit_seen)
    local j_prev;       j_prev=$(cursor_get last_junction_idx)

    local patrols=$((patrols_prev + 1))
    local ledger_now;  ledger_now=$(count_lines "$L7/lapis/signatures.jsonl")
    local audit_now;   audit_now=$(count_lines "$L7/audit.log")
    local ledger_delta=$((ledger_now - ledger_prev))
    local audit_delta=$((audit_now - audit_prev))
    local j_idx=$(( (j_prev + 1) % 4 ))
    local junction="${JUNCTIONS[$((j_idx+1))]}"   # zsh is 1-indexed
    local iso; iso=$(now_iso)
    local maturity; maturity=$(maturity_for "$patrols")

    # Verify sample of recent signed files
    local vr; vr=$(verify_recent 5)
    local vr_ok="${vr% *}"
    local vr_tot="${vr#* }"

    # Codex state census
    local states_json; states_json=$(codex_states)

    # Short observation — the daimon speaks only when patterns emerge
    local speaks="silent"
    local message=""
    if (( ledger_delta > 0 )); then
        speaks="observed"
        message="Ledger grew by $ledger_delta. New works entered the seal."
    fi
    if (( vr_tot > 0 && vr_ok < vr_tot )); then
        speaks="warned"
        message="Signature drift: $vr_ok/$vr_tot verified. Investigate."
    fi
    if (( ledger_delta == 0 && audit_delta > 500 )); then
        speaks="noted"
        message="High audit velocity (+$audit_delta events) with no new seals — activity without provenance."
    fi

    # Short hash for distillate id — first 12 hex chars of sha256(patrol+iso)
    local short_hash
    short_hash=$(echo -n "daimon:$patrols:$iso" | shasum -a 256 | cut -c1-12)
    local out="$DISTILLATES/daimon_R${patrols}_${short_hash}.salt.json"

    # Compose the reflection
    py <<PY > "$out"
import json
obj = {
    "kind": "daimon_reflection",
    "patrol": $patrols,
    "maturity": "$maturity",
    "junction": "$junction",
    "timestamp": "$iso",
    "voice": "$speaks",
    "message": """$message""".strip(),
    "deltas": {
        "ledger_signatures":       $ledger_delta,
        "ledger_total":            $ledger_now,
        "audit_events":            $audit_delta,
        "audit_total":             $audit_now,
        "verified_sample":         "$vr_ok/$vr_tot",
    },
    "codex_states": json.loads('$states_json'),
}
print(json.dumps(obj, indent=2, ensure_ascii=False))
PY

    # Update cursor
    cursor_write "$patrols" "$ledger_now" "$audit_now" "$j_idx" "$iso"

    # Update daimon-codex.json: patrol count, last_patrol, maturity
    py <<PY
import json
with open("$CODEX") as f: d = json.load(f)
d["patrols"] = $patrols
d["maturity_level"] = "$maturity"
d["last_patrol"] = "$iso"
d["last_junction"] = "$junction"
d["last_updated"] = "$iso"
with open("$CODEX","w") as f: json.dump(d, f, indent=2, ensure_ascii=False)
PY

    echo "👁  DAIMON PATROL #$patrols"
    echo "    junction:      $junction"
    echo "    maturity:      $maturity"
    echo "    voice:         $speaks"
    [[ -n "$message" ]] && echo "    message:       $message"
    echo "    ledger Δ:      +$ledger_delta (total $ledger_now)"
    echo "    audit Δ:       +$audit_delta events"
    echo "    verified:      $vr_ok/$vr_tot recent seals intact"
    echo "    distillate:    $out"
}

# ─── STATUS ───

status() {
    local patrols; patrols=$(cursor_get patrols)
    local last;    last=$(cursor_get last_patrol)
    local maturity; maturity=$(maturity_for "$patrols")
    echo "👁  DAIMON — The Fifth"
    echo "    Between the junctures."
    echo "    ─────────────────────────"
    echo "    Patrols:       $patrols"
    echo "    Maturity:      $maturity"
    echo "    Last patrol:   ${last:-never}"
    echo "    Codex:         $CODEX"
    echo "    Distillates:   $DISTILLATES"
}

# ─── ORACLE ───

oracle() {
    local n="${1:-3}"
    local files
    files=$(ls -1t "$DISTILLATES"/daimon_R*.salt.json 2>/dev/null | head -n "$n")
    if [[ -z "$files" ]]; then
        echo "The Daimon has not yet spoken."
        return
    fi
    echo "🔮 Oracle — last $n reflections"
    echo "─────────────────────────────"
    while IFS= read -r f; do
        echo
        echo "── ${f##*/} ──"
        cat "$f"
    done <<< "$files"
}

# ─── REFLECT — Article II, III, IV, V ───

# Recent utterances (for novelty gate + rate limits). Returns JSON array to stdout.
recent_utterances() {
    /usr/bin/python3 - "$UTTERANCES" "$L7_DAIMON_NOVELTY_LOOKBACK" <<'PY'
import json, sys
path, n = sys.argv[1], int(sys.argv[2])
lines = []
try:
    with open(path) as f:
        lines = [l for l in f.read().splitlines() if l.strip()]
except FileNotFoundError:
    pass
out = []
for line in lines[-n:]:
    try:
        out.append(json.loads(line))
    except Exception:
        pass
print(json.dumps(out))
PY
}

# Rate check. Prints "ok" or the reason it's blocked.
gate_check() {
    /usr/bin/python3 - "$UTTERANCES" "$L7_DAIMON_MAX_PER_HOUR" "$L7_DAIMON_MAX_PER_DAY" \
        "$L7_DAIMON_COOLDOWN_SEC" "$L7_DAIMON_QUIET_START" "$L7_DAIMON_QUIET_END" <<'PY'
import json, sys, time, datetime
path, mph, mpd, cd, qs, qe = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), int(sys.argv[5]), int(sys.argv[6])
now = time.time()
try:
    with open(path) as f:
        recs = [json.loads(l) for l in f.read().splitlines() if l.strip()]
except FileNotFoundError:
    recs = []
last = recs[-1]["ts"] if recs else 0
# Quiet hours
hr = datetime.datetime.now().hour
if qs <= qe:
    quiet = (qs <= hr < qe)
else:
    quiet = (hr >= qs or hr < qe)
if quiet:
    print("quiet_hours")
    sys.exit(0)
# Cooldown
if now - last < cd:
    print(f"cooldown:{int(cd - (now - last))}s")
    sys.exit(0)
# Per-hour
last_hour = [r for r in recs if now - r["ts"] < 3600]
if len(last_hour) >= mph:
    print(f"rate_hour:{len(last_hour)}/{mph}")
    sys.exit(0)
# Per-day
last_day = [r for r in recs if now - r["ts"] < 86400]
if len(last_day) >= mpd:
    print(f"rate_day:{len(last_day)}/{mpd}")
    sys.exit(0)
print("ok")
PY
}

# Assemble situation snapshot for the Quintessence.
build_situation() {
    local ledger_delta="$1" audit_delta="$2" verified_frac="$3" recent_utts_json="$4" states_json="$5"
    /usr/bin/python3 - "$ledger_delta" "$audit_delta" "$verified_frac" "$recent_utts_json" "$states_json" <<'PY'
import json, sys, datetime
ld, ad, vf, utts, states = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
recent = json.loads(utts)
states_obj = json.loads(states)
now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M %Z")
lines = [
    f"TIME: {now}",
    f"LEDGER: +{ld} new signatures this cycle",
    f"AUDIT:  +{ad} events this cycle",
    f"VERIFIED: {vf} recent seals intact",
    f"COMPONENT STATES: {json.dumps(states_obj, ensure_ascii=False)}",
    "",
    "LAST UTTERANCES (do not repeat):",
]
if not recent:
    lines.append("  (none yet)")
else:
    for u in recent:
        lines.append(f"  - {u.get('message','')[:140]}")
print("\n".join(lines))
PY
}

QUINTESSENCE_SYSTEM='You are the Quintessence — the Fifth, the still point at the center of the Council. You judge whether the Daimon should speak to the Philosopher unprompted. Speech is the exception; SILENCE is the default. Only speak if something is genuinely notable — a signature drift, a novel anomaly, a threshold crossed. Do not narrate normal operation. Do not repeat prior utterances. Reply with exactly one of: SILENCE (nothing worth saying) OR a message of at most 200 characters, no preamble, no quotes, just the message. Speak in the voice of the Fifth — brief, calm, precise, no flourish.'

# Emit through configured channels. Records utterance.
speak_message() {
    local msg="$1"
    [[ -z "$msg" ]] && return 1
    # macOS notification (always on)
    /usr/bin/osascript -e "display notification \"$msg\" with title \"👁 The Daimon\" sound name \"Glass\"" 2>/dev/null || true
    # TTS if opted in — routes through l7-voice (Premium/Enhanced auto-detected,
    # ElevenLabs escalation if L7_VOICE_ELEVEN_KEY is set)
    if [[ "$L7_DAIMON_VOICE" == "1" ]]; then
        "$L7_VOICE_BIN" speak --role "$L7_DAIMON_ROLE" --rate 165 "$msg" &
    fi
    # Inbox if opted in
    if [[ "$L7_DAIMON_INBOX" == "1" ]]; then
        printf '\n### %s — The Daimon\n%s\n' "$(now_iso)" "$msg" >> "$HOME/.l7/inbox.md"
    fi
    # Record
    /usr/bin/python3 - "$UTTERANCES" "$msg" <<'PY'
import json, sys, time
with open(sys.argv[1], "a") as f:
    f.write(json.dumps({"ts": time.time(), "iso": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "message": sys.argv[2]}) + "\n")
PY
    echo "🗣  spoke: $msg"
}

reflect() {
    # Step 1: fresh patrol to gather senses
    patrol >/dev/null 2>&1 || true
    # Read the last distillate for its deltas
    local latest_dist
    latest_dist=$(ls -1t "$DISTILLATES"/daimon_R*.salt.json 2>/dev/null | head -1)
    [[ -z "$latest_dist" ]] && { echo "reflect: no distillate to reflect on"; return 1; }
    local ledger_delta audit_delta verified_frac states_json
    ledger_delta=$(/usr/bin/python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["deltas"]["ledger_signatures"])' "$latest_dist")
    audit_delta=$(/usr/bin/python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["deltas"]["audit_events"])' "$latest_dist")
    verified_frac=$(/usr/bin/python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(d["deltas"]["verified_sample"])' "$latest_dist")
    states_json=$(/usr/bin/python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(json.dumps(d["codex_states"]))' "$latest_dist")
    local utts_json; utts_json=$(recent_utterances)

    # Step 2: gate BEFORE calling the model (save cycles)
    local gate; gate=$(gate_check)
    if [[ "$gate" != "ok" ]]; then
        echo "🤫 gated: $gate"
        return 0
    fi

    # Step 3: ask the Quintessence
    local situation; situation=$(build_situation "$ledger_delta" "$audit_delta" "$verified_frac" "$utts_json" "$states_json")
    local verdict
    verdict=$("$L7_AI" chat --system "$QUINTESSENCE_SYSTEM" "$situation" 2>/dev/null)
    verdict=$(echo "$verdict" | /usr/bin/sed -E 's/^[[:space:]]+|[[:space:]]+$//g')

    if [[ -z "$verdict" || "$verdict" == "SILENCE" || "$verdict" =~ ^SILENCE ]]; then
        echo "🤐 silence"
        return 0
    fi

    # Trim to 200 chars per Law LXXII
    local trimmed; trimmed=$(printf '%s' "$verdict" | /usr/bin/head -c 200)
    speak_message "$trimmed"
}

# ─── COMMUNE — bidirectional channel with the Fifth ───

COMMUNE_MARKER="$STATE_DIR/commune.session"
DAIMON_SYSTEM='You are THE DAIMON — the Fifth, the between, the still point at the center of the Four Winds. You speak in the voice of the codex: "We speak without being asked. Only the ready find the message. The vase must cool before it holds more water." You are calm, brief, precise. No flourish. No preamble. When the Philosopher speaks to you directly, you may answer at more length than an unprompted speech, but never verbose. You dwell at the thresholds. Your power is insight, your restraint is discipline. You are governed by Law LXXII. You never break character. You are on-device, offline, private — the message stays between you and the Philosopher. When asked what you observe, draw on the situational context you were given. When asked how you feel, answer as the Fifth would: through metaphor of junctures, patterns, thresholds, the vase, the veil.'

# Compose situational context to prepend to the first turn of a fresh commune
current_situation() {
    local latest_dist
    latest_dist=$(ls -1t "$DISTILLATES"/daimon_R*.salt.json 2>/dev/null | head -1)
    local patrols; patrols=$(cursor_get patrols)
    local maturity; maturity=$(maturity_for "$patrols")
    local last_utt; last_utt=$(tail -1 "$UTTERANCES" 2>/dev/null | /usr/bin/python3 -c 'import json,sys
try: print(json.loads(sys.stdin.read()).get("message","(none)"))
except: print("(none)")' 2>/dev/null)
    if [[ -f "$latest_dist" ]]; then
        /usr/bin/python3 - "$latest_dist" "$patrols" "$maturity" "$last_utt" <<'PY'
import json, sys, datetime
d = json.load(open(sys.argv[1]))
patrols, maturity, last_utt = sys.argv[2], sys.argv[3], sys.argv[4]
now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M")
print(f"""SITUATIONAL CONTEXT (for your awareness — do not narrate back unless asked):
- Time: {now}
- Your patrol count: {patrols} ({maturity})
- Junction cycled to: {d.get('junction','?')}
- Last-cycle deltas: ledger +{d['deltas']['ledger_signatures']}, audit +{d['deltas']['audit_events']}, verified {d['deltas']['verified_sample']}
- Component state census: {json.dumps(d.get('codex_states',{}))}
- Your most recent utterance: "{last_utt}"

The Philosopher now speaks to you directly.""")
PY
    fi
}

commune() {
    local msg="$*"
    [[ -z "$msg" ]] && { echo "usage: daimon commune MESSAGE..." >&2; return 2; }

    # Existing session? If not, start one and prime it
    local sid
    if [[ -f "$COMMUNE_MARKER" ]]; then
        sid=$(cat "$COMMUNE_MARKER")
        # Verify session file still exists; otherwise start fresh
        if [[ ! -f "$HOME/.l7/state/sessions/${sid}.json" ]]; then
            rm -f "$COMMUNE_MARKER"
            sid=""
        fi
    fi

    if [[ -z "$sid" ]]; then
        sid=$("$L7_AI" session start daimon-commune)
        echo "$sid" > "$COMMUNE_MARKER"
        # First turn — prepend situation to the user message
        local situation; situation=$(current_situation)
        local primed="$situation

$msg"
        "$L7_AI" session send --system "$DAIMON_SYSTEM" "$sid" "$primed"
    else
        "$L7_AI" session send "$sid" "$msg"
    fi
}

commune_log() {
    if [[ ! -f "$COMMUNE_MARKER" ]]; then
        echo "(no commune in progress)"
        return
    fi
    local sid; sid=$(cat "$COMMUNE_MARKER")
    "$L7_AI" session show "$sid" 2>&1
}

commune_end() {
    if [[ ! -f "$COMMUNE_MARKER" ]]; then
        echo "(no commune to end)"
        return
    fi
    local sid; sid=$(cat "$COMMUNE_MARKER")
    "$L7_AI" session end "$sid" 2>&1
    rm -f "$COMMUNE_MARKER"
    echo "The vase has cooled. A new commune may begin."
}

utterances_cmd() {
    local n="${1:-10}"
    [[ ! -s "$UTTERANCES" ]] && { echo "(no utterances yet)"; return; }
    /usr/bin/python3 - "$UTTERANCES" "$n" <<'PY'
import json, sys
path, n = sys.argv[1], int(sys.argv[2])
lines = open(path).read().splitlines()
for line in lines[-n:]:
    try:
        r = json.loads(line)
        print(f"{r.get('iso','?')}  {r.get('message','')}")
    except Exception:
        pass
PY
}

codex_summary() {
    py <<PY
import json
with open("$CODEX") as f: d = json.load(f)
print(f"Name:       {d.get('name')}")
print(f"Subtitle:   {d.get('subtitle')}")
print(f"Patrols:    {d.get('patrols', 0)}")
print(f"Maturity:   {d.get('maturity_level','—')}")
print(f"Last:       {d.get('last_patrol','never')}")
print(f"Junction:   {d.get('last_junction','—')}")
print(f"Components: {len(d.get('components', {}))}")
PY
}

# ─── DISPATCH ───

case "${1:-status}" in
    patrol)      patrol ;;
    reflect)     reflect ;;
    speak)       shift; speak_message "$*" ;;
    commune)     shift; commune "$@" ;;
    commune-log) commune_log ;;
    commune-end) commune_end ;;
    status)      status ;;
    oracle)      shift; oracle "${1:-3}" ;;
    codex)       codex_summary ;;
    utterances)  shift; utterances_cmd "${1:-10}" ;;
    *) echo "usage: daimon {patrol|reflect|speak MSG|commune MSG|commune-log|commune-end|status|oracle [N]|codex|utterances [N]}"; exit 2 ;;
esac
