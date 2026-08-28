"""Validate skill packages and L7 declarations for quality."""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import List

from .loader import Skill, load_all_skills, load_all_tools, load_all_citizens, L7_DIR


@dataclass
class Finding:
    level: str  # error | warn | info
    skill: str
    message: str


@dataclass
class Report:
    findings: List[Finding] = field(default_factory=list)

    def add(self, level: str, skill: str, message: str) -> None:
        self.findings.append(Finding(level, skill, message))

    @property
    def errors(self) -> List[Finding]:
        return [f for f in self.findings if f.level == "error"]

    @property
    def warns(self) -> List[Finding]:
        return [f for f in self.findings if f.level == "warn"]

    def ok(self) -> bool:
        return not self.errors


SEVEN_SEALS = [
    "Capability",
    "Data",
    "Policy",
    "Presentation",
    "Orchestration",
    "Time",
    "Identity",
]


EXECUTABLE_SKILLS = {
    "financial-ratios",
    "dcf-valuation",
    "brand-guidelines",
    "l7-empire",
    "rag-pipeline",
    "ai-playground-index",
}


def validate_skill(skill: Skill) -> List[Finding]:
    out: List[Finding] = []
    name = skill.name
    body_l = skill.body.lower()
    if not re.match(r"^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$", name):
        out.append(Finding("error", name, "invalid skill name"))
    if not skill.description or len(skill.description) < 20:
        out.append(Finding("error", name, "description too short (<20 chars)"))
    if len(skill.description) > 1024:
        out.append(Finding("error", name, "description exceeds 1024 chars (prompt bloat)"))
    elif len(skill.description) > 400:
        out.append(Finding("warn", name, "description long; may bloat skill list prompt"))
    if "l7 declaration" not in body_l and "seven seals" not in body_l:
        out.append(Finding("error", name, "missing L7 Declaration / Seven Seals"))
    for seal in SEVEN_SEALS:
        if seal.lower() not in body_l:
            out.append(Finding("warn", name, f"seal '{seal}' not clearly declared"))
    if len(skill.body) < 200:
        out.append(Finding("warn", name, "body very short; may lack actionable steps"))
    if "workflow" not in body_l:
        out.append(Finding("warn", name, "no Workflow section"))
    ref_dir = skill.path.parent / "references"
    if not ref_dir.exists():
        out.append(Finding("warn", name, "no references/ directory"))
    elif not any(ref_dir.iterdir()):
        out.append(Finding("warn", name, "references/ is empty"))
    if skill.entity_id and not skill.entity_id.startswith("skill."):
        out.append(Finding("warn", name, f"entity_id should start with skill. (got {skill.entity_id})"))
    # executable skill contract
    if name in EXECUTABLE_SKILLS or "l7 skills" in body_l:
        if "l7 skills" not in body_l and name in EXECUTABLE_SKILLS:
            out.append(Finding("warn", name, "executable skill should document `l7 skills` commands"))
    # broken absolute playground paths mentioned in body
    for m in re.finditer(r"`(/[^`]+)`", skill.body):
        p = Path(m.group(1))
        if "Obsidian Vault" in str(p) or str(p).startswith(str(Path.home())):
            if not p.exists():
                out.append(Finding("warn", name, f"referenced path missing: {p}"))
    return out


def validate_cross_links() -> Report:
    report = Report()
    skills = load_all_skills()
    skill_names = {s.name for s in skills}
    tools = load_all_tools()
    citizens = load_all_citizens()
    citizen_names = {c.get("name") for c in citizens if isinstance(c, dict)}

    for skill in skills:
        for f in validate_skill(skill):
            report.findings.append(f)
        tool_name = skill.name.replace("-", "_")
        tool_path = L7_DIR / "tools" / f"{tool_name}.tool"
        if not tool_path.exists():
            report.add("error", skill.name, f"missing tool {tool_path.name}")
        cit_path = L7_DIR / "citizens" / f"{tool_name}.citizen"
        if not cit_path.exists():
            report.add("warn", skill.name, f"missing citizen {cit_path.name}")
        elif tool_name not in citizen_names:
            report.add("info", skill.name, "citizen file present but not loadable as JSON?")

    for t in tools:
        name = t.get("name", "")
        if t.get("source") == "ai-playground" or t.get("l7_skill"):
            sk = t.get("l7_skill") or name.replace("_", "-")
            if sk not in skill_names:
                report.add("warn", sk, f"tool {name} has no matching skill")
            # required tool fields
            for req in ("does", "server", "description"):
                if not t.get(req):
                    report.add("warn", name, f"tool missing field: {req}")

    if len(skills) < 10:
        report.add("warn", "*", f"only {len(skills)} skills discovered")

    # RAG health (optional files)
    rag_idx = L7_DIR / "state" / "skill-runtime" / "rag" / "tfidf_real-corpus.json"
    if not rag_idx.exists():
        report.add("info", "rag", "real-corpus index not built yet (run rag-index --profile real-corpus)")
    else:
        report.add("info", "rag", f"real-corpus index present ({rag_idx.stat().st_size // 1024} KB)")

    report.add(
        "info",
        "*",
        f"inventory skills={len(skills)} tools={len(tools)} citizens={len(citizens)}",
    )
    return report


def format_report(report: Report) -> str:
    lines = ["# Skill Validation Report", ""]
    lines.append(
        f"Errors: {len(report.errors)}  Warns: {len(report.warns)}  "
        f"Info: {len([f for f in report.findings if f.level == 'info'])}  "
        f"Total: {len(report.findings)}"
    )
    lines.append("")
    for level in ("error", "warn", "info"):
        bucket = [f for f in report.findings if f.level == level]
        if not bucket:
            continue
        lines.append(f"## {level.upper()}")
        for f in bucket:
            lines.append(f"- `{f.skill}`: {f.message}")
        lines.append("")
    lines.append("OK" if report.ok() else "FAILED")
    return "\n".join(lines)
