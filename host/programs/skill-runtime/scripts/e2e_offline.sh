#!/usr/bin/env bash
# Offline end-to-end subprocess suite for L7 skill-runtime.
# Usage: bash ~/.l7/programs/skill-runtime/scripts/e2e_offline.sh
set -u
L7="${L7_DIR:-$HOME/.l7}"
CLI="$L7/programs/skill-runtime/l7skills.py"
OUT="${E2E_OUT:-/tmp/l7-skills-e2e-$$}"
mkdir -p "$OUT"
PASS=0
FAIL=0
RESULTS=()

log() { printf '%s\n' "$*"; }

record() {
  local name="$1" ok="$2" detail="${3:-}"
  if [ "$ok" = "1" ]; then
    RESULTS+=("PASS  $name  $detail")
    PASS=$((PASS + 1))
  else
    RESULTS+=("FAIL  $name  $detail")
    FAIL=$((FAIL + 1))
  fi
}

run_json() {
  local name="$1"; shift
  local stdout="$OUT/${name}.stdout"
  local stderr="$OUT/${name}.stderr"
  set +e
  python3 "$CLI" "$@" >"$stdout" 2>"$stderr"
  local code=$?
  set -e
  python3 - "$stdout" "$stderr" "$code" "$name" <<'PY'
import json, sys
stdout, stderr, code, name = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4]
raw = open(stdout, encoding="utf-8", errors="replace").read()
err = open(stderr, encoding="utf-8", errors="replace").read()
ok = False
detail = f"exit={code}"
try:
    d = json.loads(raw)
    ok = bool(d.get("success")) and code == 0
    meta = d.get("meta") or {}
    detail = f"exit={code} tool={meta.get('tool')} ms={meta.get('execution_time_ms')}"
    if not ok and d.get("error"):
        detail += f" err={(d.get('error') or '')[:120]}"
except Exception as e:
    detail = f"exit={code} parse_error={e} stderr={err[:120]!r}"
    ok = False
print("1" if ok else "0")
print(detail)
PY
}

echo "════════════════════════════════════════"
echo " L7 SKILLS E2E — offline subprocess"
echo "════════════════════════════════════════"
echo "OUT=$OUT"
echo "CLI=$CLI"
echo "date=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo

# JSON command helpers — each is a real subprocess
run_step() {
  local name="$1"; shift
  local out ok detail
  out=$(run_json "$name" "$@")
  ok=$(printf '%s\n' "$out" | sed -n '1p')
  detail=$(printf '%s\n' "$out" | sed -n '2p')
  record "$name" "$ok" "$detail"
  echo "── $name ──  $([ "$ok" = 1 ] && echo PASS || echo FAIL)  $detail"
}

run_step 01_doctor doctor
run_step 02_list list
run_step 04_route route "build multi-agent research team with tools and RAG"
run_step 05_show show rag-pipeline --meta-only
run_step 06_ratios ratios --period Q4_2024 --industry technology
run_step 07_ratios_q1 ratios --period Q1_2024 --industry technology
run_step 08_dcf dcf --company AcmeE2E
run_step 09_brand brand
run_step 10_rag_index rag-index --rebuild
run_step 11_rag_query rag-query "orchestrator workers evaluator optimizer" -k 5
run_step 12_rag_query2 rag-query "financial ratios ROE liquidity" -k 3

# 03 validate (markdown, not envelope)
echo "── 03_validate ──"
set +e
python3 "$CLI" validate >"$OUT/03_validate.stdout" 2>"$OUT/03_validate.stderr"
vc=$?
set -e
if [ $vc -eq 0 ] && grep -q '^OK$' "$OUT/03_validate.stdout"; then
  record "03_validate" 1 "exit=0"
  echo "PASS  exit=0"
else
  record "03_validate" 0 "exit=$vc"
  echo "FAIL  exit=$vc"
  tail -10 "$OUT/03_validate.stdout"
fi

# 13 unittest — verbose goes to stderr; merge streams for scoring
echo "── 13_unittest ──"
set +e
python3 "$L7/programs/skill-runtime/tests/test_runtime.py" -v \
  >"$OUT/13_unittest.stdout" 2>"$OUT/13_unittest.stderr"
uc=$?
set -e
cat "$OUT/13_unittest.stdout" "$OUT/13_unittest.stderr" >"$OUT/13_unittest.combined"
if [ $uc -eq 0 ] && grep -qE 'Ran [0-9]+ tests' "$OUT/13_unittest.combined" && grep -q '^OK$' "$OUT/13_unittest.combined"; then
  ran=$(grep -E 'Ran [0-9]+ tests' "$OUT/13_unittest.combined" | tail -1)
  record "13_unittest" 1 "exit=0 $ran OK"
  echo "PASS  exit=0 $ran OK"
else
  record "13_unittest" 0 "exit=$uc"
  echo "FAIL  exit=$uc"
  tail -20 "$OUT/13_unittest.combined"
fi

# 14 l7 wrapper
echo "── 14_l7_wrapper ──"
set +e
"$L7/l7" skills doctor >"$OUT/14_l7_wrapper.stdout" 2>"$OUT/14_l7_wrapper.stderr"
wc=$?
set -e
if [ $wc -eq 0 ] && python3 -c "import json; d=json.load(open('$OUT/14_l7_wrapper.stdout')); assert d['success'] and d['result']['skills']>=20"; then
  record "14_l7_wrapper" 1 "exit=0"
  echo "PASS  exit=0"
else
  record "14_l7_wrapper" 0 "exit=$wc"
  echo "FAIL  exit=$wc"
fi

# 15 agent-style chain: route → show → execute
echo "── 15_chain ──"
set +e
python3 "$CLI" route "analyze company financial health with ratios" >"$OUT/15a_route.stdout" 2>"$OUT/15a_route.stderr"
python3 "$CLI" show financial-ratios --meta-only >"$OUT/15b_show.stdout" 2>"$OUT/15b_show.stderr"
python3 "$CLI" ratios --period Q4_2024 --industry technology >"$OUT/15c_exec.stdout" 2>"$OUT/15c_exec.stderr"
set -e
if OUT_DIR="$OUT" python3 <<'PY'
import json, os
from pathlib import Path
out = Path(os.environ["OUT_DIR"])
route = json.loads((out / "15a_route.stdout").read_text())
show = json.loads((out / "15b_show.stdout").read_text())
exe = json.loads((out / "15c_exec.stdout").read_text())
assert route["success"] and show["success"] and exe["success"]
assert route["result"]["matches"][0]["name"] == "financial-ratios"
assert exe["result"]["ratios"]["profitability"]["roe"] > 0
print("chain OK: financial-ratios roe=", exe["result"]["ratios"]["profitability"]["roe"])
PY
then
  record "15_chain" 1 "route→show→ratios"
  echo "PASS  route→show→ratios"
else
  record "15_chain" 0 "chain failed"
  echo "FAIL  chain failed"
fi

# 16 audit growth
echo "── 16_audit ──"
AUDIT="$L7/state/skill-runtime/audit.jsonl"
if [ -f "$AUDIT" ] && [ "$(wc -l < "$AUDIT")" -gt 0 ]; then
  lines=$(wc -l < "$AUDIT" | tr -d ' ')
  record "16_audit" 1 "lines=$lines"
  echo "PASS  lines=$lines"
  tail -3 "$AUDIT" | python3 -c 'import sys,json
for line in sys.stdin:
  r=json.loads(line); w=r.get("what",{})
  print(r.get("when"), w.get("action"), "success="+str(w.get("success")))'
else
  record "16_audit" 0 "missing audit"
  echo "FAIL  missing audit"
fi

echo
echo "════════════════════════════════════════"
echo " SCOREBOARD"
echo "════════════════════════════════════════"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo
echo "TOTAL $PASS/$((PASS+FAIL)) passed"
echo "OUT_DIR=$OUT"
if [ "$FAIL" -gt 0 ]; then
  echo "E2E OFFLINE: FAILED"
  exit 1
fi
echo "E2E OFFLINE: ALL PASSED"
exit 0
