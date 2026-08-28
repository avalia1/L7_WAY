"""Execute skill actions with normalized L7 result envelopes."""

from __future__ import annotations

import json
import sys
import time
import traceback
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Optional

from .loader import (
    L7_DIR,
    PLAYGROUND,
    load_all_skills,
    load_skill,
    discover_skill_paths,
    route_task,
)
from . import audit

PKG = Path(__file__).resolve().parent.parent / "packages"
FIN_DIR = PKG / "financial"
BRAND_DIR = PKG / "brand"
RAG_DIR = PKG / "rag"
ALCHEMY_DIR = PKG / "alchemy"


def _envelope(
    success: bool,
    result: Any = None,
    error: str = "",
    tool: str = "",
    entity_id: str = "",
    started: Optional[float] = None,
) -> Dict[str, Any]:
    elapsed = int((time.time() - started) * 1000) if started is not None else 0
    return {
        "success": success,
        "result": result if result is not None else {},
        "error": error,
        "meta": {
            "execution_time_ms": elapsed,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "entity_id": entity_id,
            "tool": tool,
        },
    }


def show_skill(name: str, include_body: bool = True) -> Dict[str, Any]:
    started = time.time()
    for p in discover_skill_paths():
        if p.parent.name == name:
            skill = load_skill(p)
            payload = {
                "name": skill.name,
                "description": skill.description,
                "path": skill.location,
                "suite": skill.suite,
                "does": skill.does,
                "emoji": skill.emoji,
                "entity_id": skill.entity_id,
                "references": [str(r) for r in skill.references],
            }
            if include_body:
                payload["body"] = skill.body
            env = _envelope(True, payload, tool="skill.show", entity_id=skill.entity_id, started=started)
            audit.log_execution("skill.show", {"name": name}, env)
            return env
    env = _envelope(False, error=f"skill not found: {name}", tool="skill.show", started=started)
    audit.log_execution("skill.show", {"name": name}, env)
    return env


def route(query: str, limit: int = 5) -> Dict[str, Any]:
    started = time.time()
    ranked = route_task(query)[:limit]
    env = _envelope(
        True,
        {"query": query, "matches": ranked, "playground": str(PLAYGROUND)},
        tool="skill.route",
        entity_id="skill.ai-playground-index",
        started=started,
    )
    audit.log_execution("skill.route", {"query": query}, env)
    return env


def list_skills() -> Dict[str, Any]:
    started = time.time()
    skills = load_all_skills()
    items = [
        {
            "name": s.name,
            "description": s.description,
            "does": s.does,
            "suite": s.suite,
            "emoji": s.emoji,
            "path": s.location,
        }
        for s in skills
    ]
    return _envelope(True, {"count": len(items), "skills": items}, tool="skill.list", started=started)


def run_financial_ratios(
    period: str = "Q4_2024",
    industry: str = "technology",
    data_path: Optional[str] = None,
) -> Dict[str, Any]:
    started = time.time()
    sys.path.insert(0, str(FIN_DIR))
    try:
        from calculate_ratios import calculate_ratios_from_data  # type: ignore
        from interpret_ratios import RatioInterpreter  # type: ignore

        if data_path:
            from load_statements import load_statements_json, DataQualityError  # type: ignore

            try:
                statements, load_meta = load_statements_json(Path(data_path))
            except DataQualityError as dq:
                env = _envelope(
                    False,
                    error=str(dq),
                    tool="financial.ratios",
                    entity_id="skill.financial-ratios",
                    started=started,
                )
                audit.log_execution("financial.ratios", {"data_path": data_path, "mode": "real"}, env)
                return env
            period = statements.get("period") or period
            mode = "real"
        else:
            from csv_to_statements import load_csv_period, default_sample_path  # type: ignore

            path = default_sample_path()
            statements = load_csv_period(path, period=period)
            load_meta = {
                "mode": "demo",
                "source": str(path),
                "period": period,
                "data_quality": {
                    "status": "demo",
                    "required_ok": True,
                    "proxies_used": [
                        "cash/AR/inventory shares of current assets (CSV mapping)",
                        "ebitda soft proxy from op_inc + fraction of R&D when missing",
                    ],
                    "note": "DEMO mode — not for investment decisions. Use --data for real JSON.",
                },
                "assumptions": {
                    "demo": True,
                    "market_data": "sample share_price/shares if not in CSV",
                },
            }
            mode = "demo"

        calc = calculate_ratios_from_data(statements)
        interpreter = RatioInterpreter(industry=industry)
        industry_view = {}
        for category, ratios in calc["ratios"].items():
            industry_view[category] = {}
            for rname, value in ratios.items():
                try:
                    industry_view[category][rname] = interpreter.interpret_ratio(rname, value)
                except Exception:
                    industry_view[category][rname] = {"value": value, "note": "no benchmark"}
        result = {
            "mode": mode,
            "period": period,
            "industry": industry,
            "company": statements.get("company") or load_meta.get("company"),
            "source": load_meta.get("source"),
            "ratios": calc["ratios"],
            "interpretations": calc["interpretations"],
            "industry_benchmarks": industry_view,
            "summary": calc["summary"],
            "data_quality": load_meta.get("data_quality"),
            "assumptions": load_meta.get("assumptions"),
        }
        env = _envelope(
            True,
            result,
            tool="financial.ratios",
            entity_id="skill.financial-ratios",
            started=started,
        )
    except Exception as exc:
        env = _envelope(
            False,
            error=f"{exc}\n{traceback.format_exc()}",
            tool="financial.ratios",
            entity_id="skill.financial-ratios",
            started=started,
        )
    audit.log_execution(
        "financial.ratios",
        {"period": period, "industry": industry, "data_path": data_path},
        env,
    )
    return env


def run_dcf(
    company: str = "SampleCo",
    revenue_hist: Optional[list] = None,
    ebitda_hist: Optional[list] = None,
    data_path: Optional[str] = None,
) -> Dict[str, Any]:
    started = time.time()
    sys.path.insert(0, str(FIN_DIR))
    try:
        from dcf_model import DCFModel  # type: ignore

        if data_path:
            from load_statements import load_dcf_case_json, DataQualityError  # type: ignore

            try:
                case, load_meta = load_dcf_case_json(Path(data_path))
            except DataQualityError as dq:
                env = _envelope(
                    False,
                    error=str(dq),
                    tool="financial.dcf",
                    entity_id="skill.dcf-valuation",
                    started=started,
                )
                audit.log_execution("financial.dcf", {"data_path": data_path, "mode": "real"}, env)
                return env
            company = case["company"] or company
            hist = case["historical"]
            assump = case["assumptions"]
            wacc_in = case["wacc"]
            eq = case["equity"]
            model = DCFModel(company)
            model.set_historical_financials(
                hist["revenue"],
                hist["ebitda"],
                hist["capex"],
                hist["nwc"],
                [int(y) for y in hist["years"]],
            )
            model.set_assumptions(
                projection_years=int(assump.get("projection_years", 5)),
                revenue_growth=assump.get("revenue_growth"),
                ebitda_margin=assump.get("ebitda_margin"),
                tax_rate=float(assump.get("tax_rate", 0.25)),
                capex_percent=assump.get("capex_percent"),
                nwc_percent=assump.get("nwc_percent"),
                terminal_growth=float(assump.get("terminal_growth", 0.025)),
            )
            wacc = model.calculate_wacc(
                risk_free_rate=float(wacc_in["risk_free_rate"]),
                beta=float(wacc_in["beta"]),
                market_premium=float(wacc_in["market_premium"]),
                cost_of_debt=float(wacc_in["cost_of_debt"]),
                debt_to_equity=float(wacc_in["debt_to_equity"]),
                tax_rate=float(wacc_in.get("tax_rate", assump.get("tax_rate", 0.25))),
            )
            model.project_cash_flows()
            valuation = model.calculate_enterprise_value(terminal_method="growth")
            equity = model.calculate_equity_value(
                net_debt=float(eq.get("net_debt", 0)),
                cash=float(eq.get("cash", 0)),
                shares_outstanding=float(eq.get("shares_outstanding", 100)),
            )
            mode = "real"
            dq = load_meta.get("data_quality")
            assumptions_meta = load_meta.get("assumptions")
            source = load_meta.get("source")
        else:
            # Defaults derived from sample growth story (in $M) — DEMO
            revenue_hist = revenue_hist or [11.0, 11.5, 12.0, 12.3, 12.5, 13.2, 13.8, 14.5]
            ebitda_hist = ebitda_hist or [x * 0.22 for x in revenue_hist]
            capex = [x * 0.04 for x in revenue_hist]
            nwc = [x * 0.10 for x in revenue_hist]
            years = list(range(2017, 2017 + len(revenue_hist)))

            model = DCFModel(company)
            model.set_historical_financials(revenue_hist, ebitda_hist, capex, nwc, years)
            model.set_assumptions(
                projection_years=5,
                revenue_growth=[0.08, 0.07, 0.06, 0.05, 0.04],
                tax_rate=0.25,
                terminal_growth=0.025,
            )
            wacc = model.calculate_wacc(
                risk_free_rate=0.04,
                beta=1.15,
                market_premium=0.05,
                cost_of_debt=0.055,
                debt_to_equity=0.45,
                tax_rate=0.25,
            )
            model.project_cash_flows()
            valuation = model.calculate_enterprise_value(terminal_method="growth")
            equity = model.calculate_equity_value(net_debt=2.5, cash=1.2, shares_outstanding=100)
            mode = "demo"
            source = "builtin-demo-history"
            dq = {
                "status": "demo",
                "required_ok": True,
                "proxies_used": ["illustrative revenue/ebitda series"],
                "note": "DEMO mode — not for investment decisions. Use --data for real JSON.",
            }
            assumptions_meta = {
                "demo": True,
                "model": "FCFF DCF with Gordon growth terminal value",
                "units": "$M illustrative",
            }

        result = {
            "mode": mode,
            "company": company,
            "source": source,
            "wacc": wacc,
            "wacc_components": model.wacc_components,
            "projections": model.projections,
            "valuation": valuation,
            "equity": equity,
            "summary": model.generate_summary(),
            "data_quality": dq,
            "assumptions": assumptions_meta,
        }
        env = _envelope(True, result, tool="financial.dcf", entity_id="skill.dcf-valuation", started=started)
    except Exception as exc:
        env = _envelope(
            False,
            error=f"{exc}\n{traceback.format_exc()}",
            tool="financial.dcf",
            entity_id="skill.dcf-valuation",
            started=started,
        )
    audit.log_execution("financial.dcf", {"company": company, "data_path": data_path}, env)
    return env


def run_brand_palette() -> Dict[str, Any]:
    started = time.time()
    sys.path.insert(0, str(BRAND_DIR))
    try:
        from apply_brand import BrandFormatter  # type: ignore

        fmt = BrandFormatter()
        result = {
            "company": fmt.company,
            "colors": fmt.colors,
            "fonts": fmt.fonts,
            "excel_header_style": fmt.format_excel({}).get("header_style"),
            "reference": str(BRAND_DIR / "REFERENCE.md"),
        }
        env = _envelope(True, result, tool="brand.guidelines", entity_id="skill.brand-guidelines", started=started)
    except Exception as exc:
        env = _envelope(False, error=str(exc), tool="brand.guidelines", started=started)
    audit.log_execution("brand.guidelines", {}, env)
    return env


def run_rag_index(
    rebuild: bool = False,
    profile: str = "default",
    roots: Optional[list] = None,
) -> Dict[str, Any]:
    started = time.time()
    try:
        from packages.rag.simple_rag import build_index, index_path  # type: ignore
    except ImportError:
        sys.path.insert(0, str(PKG.parent))
        from packages.rag.simple_rag import build_index, index_path  # type: ignore
    try:
        from runtime.corpus_config import resolve_profile_roots

        resolved = resolve_profile_roots(profile, extra_roots=roots or [])
        root_paths = list(resolved["roots"])
        use_builtin = bool(resolved["use_builtin"])
        builtin = resolved.get("builtin")

        # Profile routing:
        # - real-corpus: doctrine collector (+ optional extra roots)
        # - default: playground/skills collector (+ optional roots)
        # - other: roots only (or default collector if use_builtin)
        if profile == "real-corpus" or builtin == "real-corpus":
            index_profile = "real-corpus"
            include_default = False
        elif profile == "default":
            index_profile = "default"
            include_default = True
        else:
            index_profile = profile
            include_default = use_builtin

        stats = build_index(
            force=rebuild,
            profile=index_profile,
            roots=root_paths or None,
            include_default=include_default,
        )
        env = _envelope(
            True,
            {
                "index_path": str(index_path(index_profile)),
                "corpus": {
                    "config": resolved.get("config_path"),
                    "profile_requested": profile,
                    "profile_indexed": index_profile,
                    "description": resolved.get("description"),
                    "roots": [str(p) for p in root_paths],
                    "missing_roots": resolved.get("missing_roots"),
                    "use_builtin": use_builtin,
                },
                **stats,
            },
            tool="rag.index",
            entity_id="skill.rag-pipeline",
            started=started,
        )
    except Exception as exc:
        env = _envelope(False, error=f"{exc}\n{traceback.format_exc()}", tool="rag.index", started=started)
    audit.log_execution("rag.index", {"rebuild": rebuild, "profile": profile}, env)
    return env


def run_rag_query(query: str, k: int = 5, profile: str = "default") -> Dict[str, Any]:
    started = time.time()
    try:
        from packages.rag.simple_rag import search  # type: ignore
    except ImportError:
        sys.path.insert(0, str(PKG.parent))
        from packages.rag.simple_rag import search  # type: ignore
    try:
        hits = search(query, k=k, profile=profile)
        env = _envelope(
            True,
            {"query": query, "profile": profile, "hits": hits},
            tool="rag.query",
            entity_id="skill.rag-pipeline",
            started=started,
        )
    except Exception as exc:
        env = _envelope(False, error=f"{exc}\n{traceback.format_exc()}", tool="rag.query", started=started)
    audit.log_execution("rag.query", {"query": query, "k": k, "profile": profile}, env)
    return env


def run_rag_eval(profile: str = "real-corpus", k: int = 5, cases_path: Optional[str] = None) -> Dict[str, Any]:
    started = time.time()
    try:
        from packages.rag.simple_rag import evaluate, build_index  # type: ignore
    except ImportError:
        sys.path.insert(0, str(PKG.parent))
        from packages.rag.simple_rag import evaluate, build_index  # type: ignore
    try:
        # ensure index exists
        build_index(force=False, profile=profile)
        path = Path(cases_path) if cases_path else (RAG_DIR / "eval_cases_real.json")
        cases = json.loads(path.read_text(encoding="utf-8"))
        report = evaluate(cases, profile=profile, k=k)
        # write report to state
        out_dir = L7_DIR / "state" / "skill-runtime" / "rag"
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / f"eval_{profile}.json"
        out_path.write_text(json.dumps(report, indent=2))
        md_path = out_dir / f"eval_{profile}.md"
        lines = [
            f"# RAG Eval — profile `{profile}`",
            "",
            f"- cases: {report['cases']}",
            f"- **strict_hit_rate (primary):** {report.get('strict_hit_rate', report.get('hit_rate'))} ({report.get('strict_hits', report.get('hits'))}/{report['cases']})",
            f"- weak_hit_rate (legacy file-level): {report.get('weak_hit_rate', 'n/a')}",
            f"- top1_strict_rate: {report.get('top1_strict_rate', 'n/a')}",
            f"- k: {report['k']}",
            "",
            "| id | strict | top1 | rank | matched | top heading |",
            "|----|--------|------|------|---------|-------------|",
        ]
        for r in report["results"]:
            top_h = ""
            if r.get("top"):
                top_h = r["top"][0].get("heading") or r["top"][0].get("parent") or ""
            lines.append(
                f"| {r['id']} | {'✅' if r.get('strict_hit', r.get('hit')) else '❌'} | "
                f"{'✅' if r.get('top1_strict') else '❌'} | {r.get('strict_rank') or '-'} | "
                f"{r.get('matched_on') or ''} | `{top_h[:48]}` |"
            )
        md_path.write_text("\n".join(lines) + "\n")
        report["report_json"] = str(out_path)
        report["report_md"] = str(md_path)
        env = _envelope(True, report, tool="rag.eval", entity_id="skill.rag-pipeline", started=started)
    except Exception as exc:
        env = _envelope(False, error=f"{exc}\n{traceback.format_exc()}", tool="rag.eval", started=started)
    audit.log_execution("rag.eval", {"profile": profile, "k": k}, env)
    return env


def run_alchemy(
    stage: str,
    path: str,
    write: bool = True,
) -> Dict[str, Any]:
    """Run one alchemy stage or full transmute on a path/project."""
    started = time.time()
    stage_l = (stage or "transmute").lower().strip()
    tool = f"alchemy.{stage_l}"
    entity = "skill.alchemy-transmutation"
    if stage_l in ("nigredo", "decompose", "inventory"):
        entity = "skill.alchemy-nigredo"
    elif stage_l in ("albedo", "purify", "clean"):
        entity = "skill.alchemy-albedo"
    elif stage_l in ("citrinitas", "illuminate", "map"):
        entity = "skill.alchemy-citrinitas"
    elif stage_l in ("rubedo", "complete", "seal"):
        entity = "skill.alchemy-rubedo"
    try:
        if str(PKG) not in sys.path:
            sys.path.insert(0, str(PKG.parent))
        from packages.alchemy.transmuter import run_stage  # type: ignore

        result = run_stage(stage_l, path, write=write)
        env = _envelope(True, result, tool=tool, entity_id=entity, started=started)
    except Exception as exc:
        env = _envelope(
            False,
            error=f"{exc}\n{traceback.format_exc()}",
            tool=tool,
            entity_id=entity,
            started=started,
        )
    audit.log_execution(tool, {"stage": stage_l, "path": path, "write": write}, env)
    return env


def run_project_index(root: Optional[str] = None, limit: int = 40) -> Dict[str, Any]:
    """Inventory ~/Projects (or root) and light-nigredo each top-level entry."""
    started = time.time()
    home = Path.home()
    base = Path(root).expanduser() if root else home / "Projects"
    if not base.is_absolute():
        cand = home / "Projects" / root if root else base
        base = cand if cand.exists() else (home / root if root else base)
    base = base.resolve()
    try:
        if str(PKG) not in sys.path:
            sys.path.insert(0, str(PKG.parent))
        from packages.alchemy.transmuter import nigredo  # type: ignore

        if not base.exists():
            env = _envelope(
                False,
                error=f"root not found: {base}",
                tool="project.index",
                entity_id="skill.alchemy-transmutation",
                started=started,
            )
            audit.log_execution("project.index", {"root": str(base)}, env)
            return env

        entries = []
        if base.is_file():
            entries.append(base)
        else:
            kids = sorted(base.iterdir(), key=lambda p: p.name.lower())
            for p in kids:
                if p.name.startswith("."):
                    continue
                entries.append(p)
                if len(entries) >= limit:
                    break

        projects = []
        for p in entries:
            try:
                inv = nigredo(str(p))
                projects.append(
                    {
                        "name": p.name,
                        "path": str(p),
                        "kind": "file" if p.is_file() else "directory",
                        "files": (inv.get("inventory") or {}).get("files"),
                        "bytes": (inv.get("inventory") or {}).get("bytes"),
                        "bytes_human": (inv.get("inventory") or {}).get("bytes_human"),
                        "code_files": (inv.get("inventory") or {}).get("code_files"),
                        "junk_count": (inv.get("inventory") or {}).get("junk_count"),
                        "secret_count": (inv.get("inventory") or {}).get("secret_count"),
                        "git": inv.get("git"),
                    }
                )
            except Exception as exc:
                projects.append({"name": p.name, "path": str(p), "error": str(exc)})

        result = {
            "root": str(base),
            "count": len(projects),
            "projects": projects,
            "forge_hint": "alchemy_transmute with path=<project path or name>",
            "law": "XXV — inventory before forge",
        }
        env = _envelope(
            True,
            result,
            tool="project.index",
            entity_id="skill.alchemy-transmutation",
            started=started,
        )
    except Exception as exc:
        env = _envelope(
            False,
            error=f"{exc}\n{traceback.format_exc()}",
            tool="project.index",
            entity_id="skill.alchemy-transmutation",
            started=started,
        )
    audit.log_execution("project.index", {"root": str(base), "limit": limit}, env)
    return env


def dumps(env: Dict[str, Any]) -> str:
    return json.dumps(env, indent=2, default=str)
