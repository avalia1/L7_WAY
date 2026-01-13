#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${HOME}/L7_WAY"
REPORT_DIR="${BASE_DIR}/daemon/reports"
mkdir -p "${REPORT_DIR}"

DATE_STAMP="$(date +%Y-%m-%d_%H%M%S)"
REPORT_FILE="${REPORT_DIR}/compliance_${DATE_STAMP}.txt"

REQUIRED_DECLARATION="This project uses the MCP Gateway as the universal entry point for tools. UI uses adapters only."
L7_DECLARATION="L7 lingua: Capability 🔧, Data 📦, Policy/Intent 🧭, Presentation 🧩, Orchestration 🔗, Time/Versioning 🕒, Identity/Security 🛡️."
MCP_GATEWAY_URL="${MCP_GATEWAY_URL:-}"

# Heuristic project roots: contains package.json, pyproject.toml, or README.md
find "${HOME}" -maxdepth 4 -type f \( -name "package.json" -o -name "pyproject.toml" -o -name "README.md" \) \
  | sed 's#/[^/]*$##' \
  | sort -u > "${REPORT_DIR}/_project_roots_${DATE_STAMP}.txt"

{
  echo "L7_WAY Compliance Report"
  echo "Generated: ${DATE_STAMP}"
  echo ""
  if [[ -n "${MCP_GATEWAY_URL}" ]]; then
    if curl -fsS "${MCP_GATEWAY_URL}/health" >/dev/null 2>&1; then
      echo "Gateway Health: OK (${MCP_GATEWAY_URL})"
    else
      echo "Gateway Health: UNREACHABLE (${MCP_GATEWAY_URL})"
    fi
  else
    echo "Gateway Health: SKIPPED (MCP_GATEWAY_URL not set)"
  fi
  echo ""

  while read -r project_root; do
    start_files=("${project_root}/README.md" "${project_root}/PLAN.md" "${project_root}/AGENTS.md" "${project_root}/ARCHITECTURE.md")
    found_gateway=0
    found_l7=0

    for file in "${start_files[@]}"; do
      if [[ -f "${file}" ]]; then
        if rg -q "${REQUIRED_DECLARATION}" "${file}"; then
          found_gateway=1
        fi
        if rg -q "${L7_DECLARATION}" "${file}"; then
          found_l7=1
        fi
      fi
    done

    if [[ ${found_gateway} -eq 0 || ${found_l7} -eq 0 ]]; then
      echo "NON-COMPLIANT: ${project_root}"
    fi
  done < "${REPORT_DIR}/_project_roots_${DATE_STAMP}.txt"
} > "${REPORT_FILE}"

echo "Report written to ${REPORT_FILE}"
