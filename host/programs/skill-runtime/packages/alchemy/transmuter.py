"""
Alchemy stages (Law XXV / Prima Great Work):

  Nigredo   — decompose: inventory the prima materia
  Albedo    — purify: find dross (junk, secrets risk, clutter)
  Citrinitas— illuminate: map to L7 skills / forge tools / domains
  Rubedo    — complete: seal a citizen-like manifest of the work

Full transmute runs all four and writes under ~/.l7/state/skill-runtime/alchemy/
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

HOME = Path.home()
L7 = HOME / ".l7"
OUT_ROOT = L7 / "state" / "skill-runtime" / "alchemy"
SKILLS = L7 / "skills"
FORGE_MAP = L7 / "programs" / "skill-runtime" / "forge" / "TOOL_MAP.json"

JUNK_DIR_NAMES = {
    "node_modules",
    ".venv",
    "venv",
    "__pycache__",
    ".pytest_cache",
    ".tox",
    "dist",
    "build",
    ".next",
    "target",
    ".turbo",
    "coverage",
}
SECRET_HINTS = re.compile(
    r"(password|secret|api[_-]?key|token|credential|\.pem$|\.p12$|id_rsa|\.env$)",
    re.I,
)
CODE_EXT = {
    ".py",
    ".js",
    ".ts",
    ".tsx",
    ".jsx",
    ".go",
    ".rs",
    ".swift",
    ".java",
    ".rb",
    ".php",
    ".md",
    ".json",
    ".yml",
    ".yaml",
    ".sh",
    ".toml",
}


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


def _resolve_path(path: str) -> Path:
    p = Path(path).expanduser()
    if not p.is_absolute():
        # allow short names under Projects / home
        for base in (HOME / "Projects", HOME, L7, HOME / "L7_WAY"):
            cand = base / path
            if cand.exists():
                return cand.resolve()
        p = (Path.cwd() / path).resolve()
    return p.resolve()


def _walk_stats(root: Path, max_files: int = 50000) -> Dict[str, Any]:
    n_files = 0
    n_dirs = 0
    by_ext: Dict[str, int] = {}
    total_bytes = 0
    samples: List[str] = []
    junk_hits: List[str] = []
    secret_hits: List[str] = []
    code_files = 0

    if root.is_file():
        st = root.stat()
        return {
            "kind": "file",
            "files": 1,
            "dirs": 0,
            "bytes": st.st_size,
            "by_ext": {root.suffix.lower() or "(none)": 1},
            "samples": [str(root)],
            "junk_paths": [],
            "secret_candidates": [],
            "code_files": 1 if root.suffix.lower() in CODE_EXT else 0,
        }

    for dirpath, dirnames, filenames in os.walk(root):
        # record junk dirs but prune walk into them
        pruned = []
        for d in list(dirnames):
            if d in JUNK_DIR_NAMES or d == ".git":
                rel = str(Path(dirpath, d).relative_to(root))
                junk_hits.append(rel)
                if d in JUNK_DIR_NAMES:
                    pruned.append(d)
        for d in pruned:
            dirnames.remove(d)
        if ".git" in dirnames:
            dirnames.remove(".git")

        n_dirs += 1
        for name in filenames:
            n_files += 1
            if n_files > max_files:
                break
            p = Path(dirpath) / name
            try:
                sz = p.stat().st_size
            except OSError:
                continue
            total_bytes += sz
            ext = p.suffix.lower() or "(none)"
            by_ext[ext] = by_ext.get(ext, 0) + 1
            if ext in CODE_EXT:
                code_files += 1
            rel = str(p.relative_to(root))
            if SECRET_HINTS.search(rel) or SECRET_HINTS.search(name):
                secret_hits.append(rel)
            if len(samples) < 40 and ext in CODE_EXT:
                samples.append(rel)
        if n_files > max_files:
            break

    top_ext = sorted(by_ext.items(), key=lambda x: -x[1])[:15]
    return {
        "kind": "directory",
        "files": n_files,
        "dirs": n_dirs,
        "bytes": total_bytes,
        "bytes_human": _human(total_bytes),
        "by_ext_top": top_ext,
        "samples": samples,
        "junk_paths": junk_hits[:50],
        "junk_count": len(junk_hits),
        "secret_candidates": secret_hits[:30],
        "secret_count": len(secret_hits),
        "code_files": code_files,
        "truncated": n_files > max_files,
    }


def _human(n: int) -> str:
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if n < 1024:
            return f"{n:.1f}{unit}" if unit != "B" else f"{n}B"
        n /= 1024
    return f"{n:.1f}PB"


def nigredo(path: str) -> Dict[str, Any]:
    """Decompose: inventory prima materia."""
    root = _resolve_path(path)
    if not root.exists():
        raise FileNotFoundError(f"path not found: {root}")
    stats = _walk_stats(root)
    git = None
    if (root / ".git").exists() or (root.is_file() and (root.parent / ".git").exists()):
        git = "present"
    return {
        "stage": "nigredo",
        "stage_name": "Decomposition",
        "element": "earth→black",
        "path": str(root),
        "name": root.name,
        "inventory": stats,
        "git": git,
        "seal": "NIGREDO",
        "teaching": "Break the prima materia into atoms. Count what is, without judgment.",
    }


def albedo(path: str) -> Dict[str, Any]:
    """Purify: name the dross."""
    root = _resolve_path(path)
    stats = _walk_stats(root)
    actions = []
    for j in stats.get("junk_paths") or []:
        actions.append({"action": "consider_remove_or_gitignore", "path": j, "reason": "regenerable junk"})
    for s in stats.get("secret_candidates") or []:
        actions.append({"action": "review_secret", "path": s, "reason": "name matches secret pattern"})
    purity_score = 1.0
    if stats.get("files"):
        purity_score = max(
            0.0,
            1.0
            - (stats.get("junk_count", 0) * 0.02)
            - (stats.get("secret_count", 0) * 0.05),
        )
    return {
        "stage": "albedo",
        "stage_name": "Purification",
        "element": "water→white",
        "path": str(root),
        "purity_score": round(min(1.0, purity_score), 3),
        "junk_count": stats.get("junk_count", 0),
        "secret_count": stats.get("secret_count", 0),
        "recommended_actions": actions[:40],
        "seal": "ALBEDO",
        "teaching": "Wash away dross. node_modules and venvs are ash, not gold. Secrets must not enter .work unsealed.",
    }


def citrinitas(path: str) -> Dict[str, Any]:
    """Illuminate: map to L7 forge tools and skills."""
    root = _resolve_path(path)
    stats = _walk_stats(root)
    name = root.name.lower()
    text_blob = " ".join(stats.get("samples") or []) + " " + name

    skill_hits: List[Dict[str, Any]] = []
    if SKILLS.exists():
        for sk in SKILLS.iterdir():
            sm = sk / "SKILL.md"
            if not sm.exists():
                continue
            body = sm.read_text(encoding="utf-8", errors="replace")[:3000].lower()
            score = 0
            for tok in re.findall(r"[a-z0-9]{3,}", name + " " + text_blob[:500]):
                if tok in body:
                    score += 1
            if score >= 2 or any(k in body and k in name for k in ("rag", "finance", "agent", "forge", "alchemy")):
                skill_hits.append({"skill": sk.name, "score": score})
    skill_hits.sort(key=lambda x: -x["score"])

    forge_tools = []
    if FORGE_MAP.exists():
        tmap = json.loads(FORGE_MAP.read_text())
        # heuristic tool suggestions
        hints = []
        if any(x in text_blob for x in (".py", "ratio", "finance", "dcf")):
            hints += ["financial_ratios", "dcf_valuation"]
        if any(x in text_blob for x in ("rag", "embed", "vector", "md")):
            hints += ["rag_pipeline"]
        if "agent" in text_blob or "autogen" in name:
            hints += ["multiagent_autogen", "agent_workflows"]
        hints += ["alchemy_transmute", "l7_empire", "project_index"]
        for h in dict.fromkeys(hints):
            if h in tmap or h.startswith("alchemy"):
                forge_tools.append(h)

    domain = ".work"
    if any(x in name for x in ("backup", "archive", "salt")):
        domain = ".salt"
    if any(x in name for x in ("experiment", "morph", "draft")):
        domain = ".morph"

    return {
        "stage": "citrinitas",
        "stage_name": "Illumination",
        "element": "air→yellow/gold dawn",
        "path": str(root),
        "suggested_domain": domain,
        "related_skills": skill_hits[:10],
        "forge_tools": forge_tools,
        "code_files": stats.get("code_files"),
        "seal": "CITRINITAS",
        "teaching": "See which citizens and tools of the Empire already speak this matter's language.",
    }


def rubedo(path: str, prior: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Complete: seal citizen-like manifest."""
    root = _resolve_path(path)
    prior = prior or {}
    nig = prior.get("nigredo") or nigredo(str(root))
    alb = prior.get("albedo") or albedo(str(root))
    cit = prior.get("citrinitas") or citrinitas(str(root))

    inv = nig.get("inventory") or {}
    citizen_id = "project." + re.sub(r"[^a-z0-9]+", "_", root.name.lower()).strip("_")
    manifest = {
        "name": citizen_id,
        "type": "citizen",
        "status": "formed",
        "domain": cit.get("suggested_domain", ".work"),
        "born": _now(),
        "lineage": "alchemy-transmutation",
        "description": f"Transmuted project {root.name} via L7 alchemy forge",
        "path": str(root),
        "does": "analyze",
        "gives": {"inventory": "object", "purity": "number", "forge_tools": "array"},
        "metrics": {
            "files": inv.get("files"),
            "bytes": inv.get("bytes"),
            "purity_score": alb.get("purity_score"),
            "junk_count": alb.get("junk_count"),
            "secret_count": alb.get("secret_count"),
        },
        "forge_tools": cit.get("forge_tools"),
        "related_skills": [s["skill"] for s in (cit.get("related_skills") or [])[:8]],
        "l7_declaration": {
            "capability": "Project inventory and forge routing after alchemy",
            "data": str(root),
            "policy": "Secrets reviewed in albedo; junk not gold",
            "presentation": "JSON manifest sealed under alchemy state",
            "orchestration": "nigredo→albedo→citrinitas→rubedo",
            "time": "v1",
            "identity": "lineage alchemy-transmutation",
        },
        "seal": "RUBEDO",
        "stage_name": "Completion",
        "teaching": "The Stone is not the pile of files. It is the ordered citizen ready for the Empire.",
    }
    return {
        "stage": "rubedo",
        "manifest": manifest,
        "path": str(root),
        "seal": "RUBEDO",
    }


def transmute(path: str, write: bool = True) -> Dict[str, Any]:
    """Full Great Work: all four stages + optional sealed write."""
    t0 = time.time()
    root = _resolve_path(path)
    stages = {
        "nigredo": nigredo(str(root)),
        "albedo": albedo(str(root)),
        "citrinitas": citrinitas(str(root)),
    }
    stages["rubedo"] = rubedo(str(root), stages)
    work_id = hashlib.sha256(f"{root}:{_now()}".encode()).hexdigest()[:12]
    out = {
        "great_work": work_id,
        "path": str(root),
        "name": root.name,
        "stages": stages,
        "manifest": stages["rubedo"]["manifest"],
        "elapsed_ms": int((time.time() - t0) * 1000),
        "sealed_at": _now(),
        "law": "XXV — Forge / transmutation; redemption not destruction",
    }
    if write:
        OUT_ROOT.mkdir(parents=True, exist_ok=True)
        slug = re.sub(r"[^a-z0-9]+", "_", root.name.lower()).strip("_")
        out_path = OUT_ROOT / f"{slug}_{work_id}.json"
        out_path.write_text(json.dumps(out, indent=2, default=str))
        # also write/update citizen-like stamp in alchemy dir
        cit_path = OUT_ROOT / f"{slug}.citizen.json"
        cit_path.write_text(json.dumps(stages["rubedo"]["manifest"], indent=2, default=str))
        out["written"] = {"work": str(out_path), "citizen": str(cit_path)}
    return out


def run_stage(stage: str, path: str, **kwargs) -> Dict[str, Any]:
    stage = stage.lower().strip()
    if stage in ("nigredo", "decompose", "inventory"):
        return nigredo(path)
    if stage in ("albedo", "purify", "clean"):
        return albedo(path)
    if stage in ("citrinitas", "illuminate", "map"):
        return citrinitas(path)
    if stage in ("rubedo", "complete", "seal"):
        return rubedo(path)
    if stage in ("transmute", "full", "great_work", "all"):
        return transmute(path, write=kwargs.get("write", True))
    raise ValueError(f"unknown alchemy stage: {stage}")
