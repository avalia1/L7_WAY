#!/usr/bin/env python3
"""
L7 Forge bridge — map .tool names to skill-runtime CLI and return L7 envelopes.

Used by:
  - forge_server.py (HTTP)
  - gateway.js executeViaSkillRuntime (Node spawn)
  - CLI: python3 skill_bridge.py execute financial_ratios '{"period":"Q4_2024"}'
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

FORGE_DIR = Path(__file__).resolve().parent
RUNTIME_DIR = FORGE_DIR.parent
L7SKILLS = RUNTIME_DIR / "l7skills.py"
TOOL_MAP_PATH = FORGE_DIR / "TOOL_MAP.json"
L7_DIR = Path.home() / ".l7"
TOOLS_DIR = L7_DIR / "tools"
AUDIT_PATH = L7_DIR / "state" / "skill-runtime" / "forge_audit.jsonl"


def _load_map() -> Dict[str, Any]:
    return json.loads(TOOL_MAP_PATH.read_text(encoding="utf-8"))


def list_skill_tools() -> List[Dict[str, Any]]:
    """List tools that the forge can execute (mapped + present as .tool)."""
    tmap = _load_map()
    out = []
    for name, spec in sorted(tmap.items()):
        tool_path = TOOLS_DIR / f"{name}.tool"
        meta = {"name": name, "executable": True, "server": "skill-runtime", "forge": True}
        if tool_path.exists():
            # light parse for description
            for line in tool_path.read_text(encoding="utf-8", errors="replace").splitlines():
                if line.startswith("description:"):
                    meta["description"] = line.split(":", 1)[1].strip().strip('"')
                if line.startswith("does:"):
                    meta["does"] = line.split(":", 1)[1].strip()
                if line.startswith("l7_skill:"):
                    meta["l7_skill"] = line.split(":", 1)[1].strip()
        meta["cli"] = spec.get("cli")
        out.append(meta)
    return out


def can_execute(tool_name: str) -> bool:
    return tool_name in _load_map()


def _build_argv(tool_name: str, params: Dict[str, Any]) -> List[str]:
    tmap = _load_map()
    if tool_name not in tmap:
        raise KeyError(f"tool not in forge map: {tool_name}")
    spec = dict(tmap[tool_name])
    params = dict(params or {})

    # action dispatch for multi-action tools
    action = params.pop("action", None)
    if action and isinstance(spec.get("actions"), dict) and action in spec["actions"]:
        spec = {**spec, **spec["actions"][action]}

    # defaults
    for k, v in (spec.get("defaults") or {}).items():
        params.setdefault(k, v)

    argv: List[str] = [sys.executable, str(L7SKILLS)] + list(spec.get("cli") or [])

    # fixed args (e.g. show skill-name)
    for a in spec.get("fixed_args") or []:
        argv.append(str(a))

    param_map = spec.get("param_map") or {}
    flags = set(spec.get("flags") or [])
    positionals: List[str] = []

    for key, flag in param_map.items():
        if key not in params or params[key] is None:
            continue
        val = params[key]
        if flag == "POSITIONAL":
            positionals.append(str(val))
            continue
        if key in flags or isinstance(val, bool):
            if val:
                argv.append(flag)
            continue
        argv.extend([flag, str(val)])

    # bare query/task for route/rag if not mapped as POSITIONAL but present
    if not positionals:
        for k in ("query", "task", "message"):
            if k in params and params[k] is not None and k not in param_map:
                positionals.append(str(params[k]))
                break

    argv.extend(positionals)
    return argv


def execute_tool(
    tool_name: str,
    params: Optional[Dict[str, Any]] = None,
    *,
    who: str = "forge",
    timeout: float = 120.0,
) -> Dict[str, Any]:
    """Run mapped tool; return L7 envelope {success, result, error, meta}."""
    started = time.time()
    params = params or {}
    try:
        argv = _build_argv(tool_name, params)
    except KeyError as exc:
        return {
            "success": False,
            "ok": False,
            "result": {},
            "error": str(exc),
            "meta": {
                "tool": tool_name,
                "entity_id": f"tool.{tool_name}",
                "execution_time_ms": 0,
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "who": who,
                "source": "skill-runtime-forge",
            },
        }

    env = os.environ.copy()
    env["L7_FORGE_WHO"] = who
    try:
        proc = subprocess.run(
            argv,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=str(RUNTIME_DIR),
            env=env,
        )
        stdout = (proc.stdout or "").strip()
        stderr = (proc.stderr or "").strip()
        payload: Dict[str, Any]
        if stdout:
            try:
                payload = json.loads(stdout)
            except json.JSONDecodeError:
                payload = {
                    "success": proc.returncode == 0,
                    "result": {"raw": stdout},
                    "error": stderr if proc.returncode else "",
                }
        else:
            payload = {
                "success": False,
                "result": {},
                "error": stderr or f"empty stdout (exit {proc.returncode})",
            }

        # Normalize to L7 envelope + gateway-friendly ok
        if "success" not in payload and "ok" in payload:
            payload["success"] = bool(payload["ok"])
        payload.setdefault("result", {})
        payload.setdefault("error", "")
        meta = payload.get("meta") or {}
        meta.update(
            {
                "tool": tool_name,
                "entity_id": meta.get("entity_id") or f"tool.{tool_name}",
                "execution_time_ms": int((time.time() - started) * 1000),
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "who": who,
                "source": "skill-runtime-forge",
                "argv": argv[2:],  # without python path
                "exit_code": proc.returncode,
            }
        )
        payload["meta"] = meta
        payload["ok"] = bool(payload.get("success"))
        if proc.returncode != 0 and payload.get("success"):
            # CLI may return success false with 0; if nonzero, force fail unless success explicit true
            pass
        _audit(who, tool_name, params, payload)
        return payload
    except subprocess.TimeoutExpired:
        env_out = {
            "success": False,
            "ok": False,
            "result": {},
            "error": f"timeout after {timeout}s",
            "meta": {
                "tool": tool_name,
                "who": who,
                "source": "skill-runtime-forge",
                "execution_time_ms": int((time.time() - started) * 1000),
                "timestamp": datetime.now(timezone.utc).isoformat(),
            },
        }
        _audit(who, tool_name, params, env_out)
        return env_out
    except Exception as exc:
        env_out = {
            "success": False,
            "ok": False,
            "result": {},
            "error": str(exc),
            "meta": {
                "tool": tool_name,
                "who": who,
                "source": "skill-runtime-forge",
                "execution_time_ms": int((time.time() - started) * 1000),
                "timestamp": datetime.now(timezone.utc).isoformat(),
            },
        }
        _audit(who, tool_name, params, env_out)
        return env_out


def _audit(who: str, tool: str, params: Dict[str, Any], envelope: Dict[str, Any]) -> None:
    AUDIT_PATH.parent.mkdir(parents=True, exist_ok=True)
    rec = {
        "who": who,
        "what": {
            "tool": tool,
            "params_keys": list(params.keys()),
            "success": envelope.get("success"),
            "error": (envelope.get("error") or None),
        },
        "when": datetime.now(timezone.utc).isoformat(),
    }
    with open(AUDIT_PATH, "a", encoding="utf-8") as f:
        f.write(json.dumps(rec) + "\n")
    # mirror main audit
    try:
        with open(L7_DIR / "audit.log", "a", encoding="utf-8") as f:
            f.write(json.dumps({"source": "forge", **rec}) + "\n")
    except Exception:
        pass


def main(argv: Optional[List[str]] = None) -> int:
    argv = list(argv or sys.argv[1:])
    if not argv or argv[0] in ("-h", "--help"):
        print("Usage: skill_bridge.py list|can <tool>|execute <tool> [json_params]")
        return 0
    cmd = argv[0]
    if cmd == "list":
        print(json.dumps({"tools": list_skill_tools()}, indent=2))
        return 0
    if cmd == "can" and len(argv) >= 2:
        print(json.dumps({"tool": argv[1], "can": can_execute(argv[1])}))
        return 0
    if cmd == "execute" and len(argv) >= 2:
        tool = argv[1]
        params = json.loads(argv[2]) if len(argv) > 2 else {}
        who = os.environ.get("L7_FORGE_WHO", "forge-cli")
        print(json.dumps(execute_tool(tool, params, who=who), indent=2, default=str))
        return 0
    print("Unknown command", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
