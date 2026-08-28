#!/bin/zsh
# ================================================================
# PROVENANCE — The Mark of Empire (Law LXX)
# ================================================================
#
# Every work minted by Empire carries a signature:
#   AVALIA — the kingdom (commercial vessel)
#   AVD    — the Philosopher (personal seal)
#   AUD    — the listening (creative source)
#
# USAGE:
#   provenance mint <file> <mark> <craftsman> [lineage]
#   provenance verify <file>
#   provenance chain <file>
#   provenance search <mark|craftsman>
#   provenance inventory
#   provenance stamp-existing
#
# ================================================================

set -uo pipefail

L7="${L7_DIR:-$HOME/.l7}"
PROV_DIR="$L7/provenance"
PROV_DB="$PROV_DIR/provenance.jsonl"
PROV_INDEX="$PROV_DIR/index.json"
LEDGER="$L7/ledger.sh"

mkdir -p "$PROV_DIR"
touch "$PROV_DB"

# ─── Helpers ───

compute_sha256() {
    shasum -a 256 "$1" 2>/dev/null | cut -d' ' -f1
}

timestamp() {
    date -u +%Y-%m-%dT%H:%M:%SZ
}

valid_mark() {
    case "$1" in
        AVALIA|AVD|AUD) return 0 ;;
        *) return 1 ;;
    esac
}

# ─── MINT — Mark a work with Empire provenance ───

cmd_mint() {
    local file="$1"
    local mark="$2"
    local craftsman="$3"
    local lineage="${4:-ORIGIN}"

    if [[ ! -f "$file" ]]; then
        echo "ERROR: File not found: $file"
        return 1
    fi

    if ! valid_mark "$mark"; then
        echo "ERROR: Invalid mark '$mark'. Must be AVALIA, AVD, or AUD."
        return 1
    fi

    local filepath=$(realpath "$file")
    local filename=$(basename "$file")
    local hash=$(compute_sha256 "$file")
    local ts=$(timestamp)
    local size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)

    # Determine path classification from meta if available
    local path_class="W"
    local meta="${filepath%.txt}.meta.json"
    if [[ -f "$meta" ]]; then
        path_class=$(python3 -c "import json; d=json.load(open('$meta')); print(d.get('path_classification', d.get('classification','W')))" 2>/dev/null || echo "W")
    fi

    # Check if already minted
    if grep -q "\"filepath\": \"$filepath\"" "$PROV_DB" 2>/dev/null; then
        echo "NOTE: $filename already has provenance record. Adding new mark."
    fi

    # Write provenance record
    local record=$(python3 -c "
import json, sys
r = {
    'mark': '$mark',
    'craftsman': '$craftsman',
    'date': '$ts',
    'lineage': '$lineage',
    'hash': '$hash',
    'filepath': '$filepath',
    'filename': '$filename',
    'size': $size,
    'path': '$path_class',
    'commander': 'GABRIEL',
    'authority': 'THE_PHILOSOPHER'
}
print(json.dumps(r))
")
    echo "$record" >> "$PROV_DB"

    echo "✦ MINTED: $filename"
    echo "  Mark:      $mark"
    echo "  Craftsman: $craftsman"
    echo "  Hash:      ${hash:0:16}..."
    echo "  Lineage:   $lineage"
    echo "  Path:      $path_class"
}

# ─── VERIFY — Check provenance of a file ───

cmd_verify() {
    local file="$1"
    local filepath=$(realpath "$file" 2>/dev/null || echo "$file")
    local current_hash=$(compute_sha256 "$file")

    local records=$(grep "\"filepath\": \"$filepath\"" "$PROV_DB" 2>/dev/null)
    if [[ -z "$records" ]]; then
        echo "NO PROVENANCE: $file has no Empire mark."
        return 1
    fi

    echo "PROVENANCE RECORD(S) for $(basename "$file"):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$records" | while read -r line; do
        local mark=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['mark'])")
        local craftsman=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['craftsman'])")
        local date=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['date'])")
        local orig_hash=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['hash'])")
        local lineage=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['lineage'])")
        local path=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['path'])")

        echo "  Mark:      $mark"
        echo "  Craftsman: $craftsman"
        echo "  Date:      $date"
        echo "  Lineage:   $lineage"
        echo "  Path:      $path"

        if [[ "$current_hash" == "$orig_hash" ]]; then
            echo "  Integrity: ✓ INTACT (hash matches)"
        else
            echo "  Integrity: ✗ MODIFIED (hash changed)"
            echo "    Original: ${orig_hash:0:16}..."
            echo "    Current:  ${current_hash:0:16}..."
        fi
        echo "  ───────────────────────────────────────"
    done
}

# ─── CHAIN — Show derivative chain for a work ───

cmd_chain() {
    local file="$1"
    local filepath=$(realpath "$file" 2>/dev/null || echo "$file")
    local filename=$(basename "$file")

    echo "DERIVATIVE CHAIN for $filename:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Find this work
    local this_record=$(grep "\"filepath\": \"$filepath\"" "$PROV_DB" 2>/dev/null | head -1)
    if [[ -z "$this_record" ]]; then
        echo "  No provenance record found."
        return 1
    fi

    local lineage=$(echo "$this_record" | python3 -c "import json,sys; print(json.load(sys.stdin)['lineage'])")

    # Trace up
    if [[ "$lineage" != "ORIGIN" ]]; then
        echo "  PARENT → $lineage"
        # Find parent's parents recursively (max 10 levels)
        local current="$lineage"
        local depth=0
        while [[ "$current" != "ORIGIN" && $depth -lt 10 ]]; do
            local parent_rec=$(grep "\"filename\": \"$current\"" "$PROV_DB" 2>/dev/null | head -1)
            if [[ -z "$parent_rec" ]]; then
                break
            fi
            current=$(echo "$parent_rec" | python3 -c "import json,sys; print(json.load(sys.stdin)['lineage'])")
            if [[ "$current" != "ORIGIN" ]]; then
                depth=$((depth + 1))
                printf "  %*s↑ %s\n" $((depth*2)) "" "$current"
            fi
        done
    else
        echo "  ★ ORIGIN WORK"
    fi

    # Find derivatives
    local derivatives=$(grep "\"lineage\": \"$filename\"" "$PROV_DB" 2>/dev/null)
    if [[ -n "$derivatives" ]]; then
        echo "  DERIVATIVES:"
        echo "$derivatives" | while read -r line; do
            local d_name=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['filename'])")
            local d_mark=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['mark'])")
            local d_date=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['date'])")
            echo "    └── [$d_mark] $d_name ($d_date)"
        done
    fi
}

# ─── SEARCH — Find works by mark or craftsman ───

cmd_search() {
    local query="$1"
    echo "SEARCH: '$query'"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local results=$(grep -i "$query" "$PROV_DB" 2>/dev/null)
    if [[ -z "$results" ]]; then
        echo "  No records found."
        return 0
    fi

    local count=$(echo "$results" | wc -l | tr -d ' ')
    echo "  Found $count record(s):"
    echo ""

    echo "$results" | while read -r line; do
        local mark=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['mark'])")
        local name=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['filename'])")
        local craftsman=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['craftsman'])")
        local date=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['date'])")
        echo "  [$mark] $name — $craftsman ($date)"
    done
}

# ─── INVENTORY — Full provenance inventory ───

cmd_inventory() {
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║     THE EMPIRE'S PROVENANCE INVENTORY               ║"
    echo "║     Law LXX — The Mark of Provenance                ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""

    if [[ ! -s "$PROV_DB" ]]; then
        echo "  No provenance records yet."
        return 0
    fi

    local total=$(wc -l < "$PROV_DB" | tr -d ' ')
    local avalia=0; avalia=$(grep -c '"mark": "AVALIA"' "$PROV_DB" 2>/dev/null) || avalia=0
    local avd=0; avd=$(grep -c '"mark": "AVD"' "$PROV_DB" 2>/dev/null) || avd=0
    local aud=0; aud=$(grep -c '"mark": "AUD"' "$PROV_DB" 2>/dev/null) || aud=0
    local origins=0; origins=$(grep -c '"lineage": "ORIGIN"' "$PROV_DB" 2>/dev/null) || origins=0
    local derivatives=$((total - origins))

    echo "  TOTALS:"
    echo "  ─────────────────────────────"
    echo "  Total records:    $total"
    echo "  AVALIA marks:     $avalia"
    echo "  AVD marks:        $avd"
    echo "  AUD marks:        $aud"
    echo "  Origin works:     $origins"
    echo "  Derivative works: $derivatives"
    echo ""

    echo "  BY PATH:"
    echo "  ─────────────────────────────"
    local white=0; white=$(grep -c '"path": "W"' "$PROV_DB" 2>/dev/null) || white=0
    local grey=0; grey=$(grep -c '"path": "G"' "$PROV_DB" 2>/dev/null) || grey=0
    local red=0; red=$(grep -c '"path": "R"' "$PROV_DB" 2>/dev/null) || red=0
    echo "  White (Right Hand): $white"
    echo "  Grey (Middle):      $grey"
    echo "  Red (Left Hand):    $red"
    echo ""

    echo "  ALL RECORDS:"
    echo "  ─────────────────────────────"
    cat "$PROV_DB" | while read -r line; do
        local mark=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['mark'])" 2>/dev/null)
        local name=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['filename'])" 2>/dev/null)
        local craftsman=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['craftsman'])" 2>/dev/null)
        local path=$(echo "$line" | python3 -c "import json,sys; print(json.load(sys.stdin)['path'])" 2>/dev/null)
        echo "  [$mark|$path] $name — $craftsman"
    done
}

# ─── STAMP-EXISTING — Mark all existing Empire works ───

cmd_stamp_existing() {
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║  RETROACTIVE PROVENANCE — Marking Empire Works      ║"
    echo "║  By authority of the Philosopher (Law LXX)          ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""

    local count=0

    # ─── Salt Laws (The Philosopher's direct word) ───
    echo "▸ SALT LAWS (AVD — The Philosopher's Seal):"
    for f in "$L7/salt/"*.salt.md; do
        [[ -f "$f" ]] || continue
        local name=$(basename "$f")
        if ! grep -q "\"filepath\": \"$(realpath "$f")\"" "$PROV_DB" 2>/dev/null; then
            cmd_mint "$f" "AVD" "THE_PHILOSOPHER" "ORIGIN" | grep "MINTED"
            count=$((count + 1))
        else
            echo "  (already marked) $name"
        fi
    done
    echo ""

    # ─── Tools & Scripts (AVALIA — Empire infrastructure) ───
    echo "▸ TOOLS & INFRASTRUCTURE (AVALIA — The Kingdom):"
    for f in "$L7/sentinel.sh" "$L7/egress-gate.sh" "$L7/ledger.sh" \
             "$L7/provenance.sh" "$L7/council-voices.sh" "$L7/l7" \
             "$L7/council/server.py"; do
        [[ -f "$f" ]] || continue
        local name=$(basename "$f")
        if ! grep -q "\"filepath\": \"$(realpath "$f")\"" "$PROV_DB" 2>/dev/null; then
            cmd_mint "$f" "AVALIA" "GABRIEL" "ORIGIN" | grep "MINTED"
            count=$((count + 1))
        else
            echo "  (already marked) $name"
        fi
    done
    echo ""

    # ─── Swift Binaries (AVALIA — Empire craft) ───
    echo "▸ SWIFT APPLICATIONS (AVALIA — The Kingdom):"
    for f in "$L7/l7-forge.swift" "$L7/l7-canon.swift" "$L7/l7-gallery.swift" \
             "$L7/l7-bibliotheca.swift"; do
        [[ -f "$f" ]] || continue
        local name=$(basename "$f")
        if ! grep -q "\"filepath\": \"$(realpath "$f")\"" "$PROV_DB" 2>/dev/null; then
            cmd_mint "$f" "AVALIA" "GABRIEL" "ORIGIN" | grep "MINTED"
            count=$((count + 1))
        else
            echo "  (already marked) $name"
        fi
    done
    echo ""

    # ─── Compiled Binaries ───
    echo "▸ COMPILED BINARIES (AVD — The Philosopher's Forge):"
    for f in "$L7/l7-forge" "$L7/l7-canon" "$L7/l7-gallery" "$L7/l7-bibliotheca" "$L7/l7-wallet"; do
        [[ -f "$f" ]] || continue
        local name=$(basename "$f")
        if ! grep -q "\"filepath\": \"$(realpath "$f")\"" "$PROV_DB" 2>/dev/null; then
            cmd_mint "$f" "AVD" "THE_PHILOSOPHER" "ORIGIN" | grep "MINTED"
            count=$((count + 1))
        else
            echo "  (already marked) $name"
        fi
    done
    echo ""

    # ─── Research (AUD — The Listening) ───
    echo "▸ RESEARCH (AUD — The Listening):"
    for f in "$L7/research/"*.md; do
        [[ -f "$f" ]] || continue
        local name=$(basename "$f")
        if ! grep -q "\"filepath\": \"$(realpath "$f")\"" "$PROV_DB" 2>/dev/null; then
            cmd_mint "$f" "AUD" "FIRE" "ORIGIN" | grep "MINTED"
            count=$((count + 1))
        else
            echo "  (already marked) $name"
        fi
    done
    echo ""

    # ─── Library Texts (AUD — heard and preserved) ───
    echo "▸ LIBRARY TEXTS (AUD — Heard and Preserved):"
    for f in "$L7/library/texts/"*.txt; do
        [[ -f "$f" ]] || continue
        local name=$(basename "$f")
        # These are curated, not minted — mark as AUD (listened/received)
        if ! grep -q "\"filepath\": \"$(realpath "$f")\"" "$PROV_DB" 2>/dev/null; then
            # Determine craftsman from meta
            local meta="${f%.txt}.meta.json"
            local author="ANCIENT"
            if [[ -f "$meta" ]]; then
                author=$(python3 -c "import json; print(json.load(open('$meta')).get('author','ANCIENT')[:40])" 2>/dev/null || echo "ANCIENT")
            fi
            cmd_mint "$f" "AUD" "$author" "ORIGIN" | grep "MINTED"
            count=$((count + 1))
        else
            echo "  (already marked) $name"
        fi
    done
    echo ""

    # ─── Empire Database ───
    echo "▸ EMPIRE DATABASE (AVALIA):"
    for f in "$L7/canon/empire.db"; do
        [[ -f "$f" ]] || continue
        if ! grep -q "\"filepath\": \"$(realpath "$f")\"" "$PROV_DB" 2>/dev/null; then
            cmd_mint "$f" "AVALIA" "GABRIEL" "ORIGIN" | grep "MINTED"
            count=$((count + 1))
        fi
    done
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  TOTAL NEWLY MARKED: $count works"
    echo "  Provenance DB: $PROV_DB"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ─── MAIN ───

cmd="$1"
shift 2>/dev/null

case "$cmd" in
    mint)
        if [[ $# -lt 3 ]]; then
            echo "Usage: provenance mint <file> <mark> <craftsman> [lineage]"
            exit 1
        fi
        cmd_mint "$@"
        ;;
    verify)
        cmd_verify "$1"
        ;;
    chain)
        cmd_chain "$1"
        ;;
    search)
        cmd_search "$1"
        ;;
    inventory)
        cmd_inventory
        ;;
    stamp-existing|stamp)
        cmd_stamp_existing
        ;;
    help|*)
        echo "PROVENANCE — The Mark of Empire (Law LXX)"
        echo ""
        echo "Commands:"
        echo "  mint <file> <mark> <craftsman> [lineage]  Mark a work"
        echo "  verify <file>                             Check provenance"
        echo "  chain <file>                              Show derivative chain"
        echo "  search <query>                            Search by mark/craftsman"
        echo "  inventory                                 Full inventory"
        echo "  stamp-existing                            Mark all Empire works"
        echo ""
        echo "Marks: AVALIA (kingdom), AVD (philosopher), AUD (listening)"
        ;;
esac
