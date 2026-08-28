#!/usr/bin/env python3
"""
L7 Skills CLI — discover, route, validate, and execute AI Playground skills.

Usage:
  l7 skills list
  l7 skills show <name>
  l7 skills route "<task>"
  l7 skills validate
  l7 skills ratios [--period Q4_2024] [--industry technology]
  l7 skills dcf [--company Name]
  l7 skills brand
  l7 skills rag-index [--rebuild]
  l7 skills rag-query "<question>"
  l7 skills doctor
  l7 skills alchemy transmute <path>
  l7 skills alchemy nigredo|albedo|citrinitas|rubedo <path>
  l7 skills project-index [--root ~/Projects]
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from runtime.execute import (  # noqa: E402
    dumps,
    list_skills,
    show_skill,
    route,
    run_financial_ratios,
    run_dcf,
    run_brand_palette,
    run_rag_index,
    run_rag_query,
    run_rag_eval,
    run_alchemy,
    run_project_index,
)
from runtime.validator import validate_cross_links, format_report  # noqa: E402
from runtime.loader import load_all_tools, load_all_citizens, L7_DIR, PLAYGROUND  # noqa: E402


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(prog="l7 skills", description="L7 Skill Runtime")
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("list", help="List installed skills")
    p_show = sub.add_parser("show", help="Show skill body")
    p_show.add_argument("name")
    p_show.add_argument("--meta-only", action="store_true")

    p_route = sub.add_parser("route", help="Route a task to skills")
    p_route.add_argument("query")
    p_route.add_argument("-k", type=int, default=5)

    sub.add_parser("validate", help="Validate skills/tools/citizens")
    sub.add_parser("doctor", help="Health check")

    p_ratios = sub.add_parser("ratios", help="Run financial ratio analysis")
    p_ratios.add_argument("--period", default="Q4_2024")
    p_ratios.add_argument("--industry", default="technology")
    p_ratios.add_argument("--data", default=None)

    p_dcf = sub.add_parser("dcf", help="Run DCF valuation (demo or --data JSON)")
    p_dcf.add_argument("--company", default="SampleCo")
    p_dcf.add_argument("--data", default=None, help="Path to dcf_case.v1 JSON (real mode)")

    sub.add_parser("brand", help="Show brand guideline package")
    sub.add_parser("corpus", help="Show corpus.json profiles")

    p_ri = sub.add_parser("rag-index", help="Build TF-IDF index over skills+READMEs")
    p_ri.add_argument("--rebuild", action="store_true")
    p_ri.add_argument("--profile", default="default", help="Index profile (default|real-corpus|custom)")
    p_ri.add_argument(
        "--root",
        action="append",
        default=[],
        help="Extra corpus root (repeatable). With --profile real-corpus, used as extras.",
    )

    p_rq = sub.add_parser("rag-query", help="Query local RAG index")
    p_rq.add_argument("query")
    p_rq.add_argument("-k", type=int, default=5)
    p_rq.add_argument("--profile", default="default")

    p_re = sub.add_parser("rag-eval", help="Evaluate RAG profile against golden questions")
    p_re.add_argument("--profile", default="real-corpus")
    p_re.add_argument("-k", type=int, default=5)
    p_re.add_argument("--cases", default=None, help="Path to eval cases JSON")

    p_al = sub.add_parser("alchemy", help="Alchemy stages / full transmute (Law XXV)")
    p_al.add_argument(
        "stage",
        choices=[
            "transmute",
            "nigredo",
            "albedo",
            "citrinitas",
            "rubedo",
            "decompose",
            "purify",
            "illuminate",
            "complete",
            "full",
        ],
        help="Stage or full transmute",
    )
    p_al.add_argument("path", help="Path, or short name under ~/Projects|~/L7_WAY")
    p_al.add_argument(
        "--no-write",
        action="store_true",
        help="Do not seal work JSON under state/alchemy (transmute only)",
    )

    p_pi = sub.add_parser("project-index", help="Inventory Projects tree (nigredo light)")
    p_pi.add_argument("--root", default=None, help="Root to index (default ~/Projects)")
    p_pi.add_argument("--limit", type=int, default=40, help="Max top-level entries")

    sub.add_parser("e2e", help="Run offline end-to-end subprocess suite")

    args = parser.parse_args(argv)

    if args.cmd == "list":
        print(dumps(list_skills()))
        return 0
    if args.cmd == "show":
        print(dumps(show_skill(args.name, include_body=not args.meta_only)))
        return 0
    if args.cmd == "route":
        print(dumps(route(args.query, limit=args.k)))
        return 0
    if args.cmd == "validate":
        report = validate_cross_links()
        print(format_report(report))
        return 0 if report.ok() else 1
    if args.cmd == "doctor":
        import time
        from datetime import datetime, timezone

        t0 = time.time()
        skills = list_skills()["result"]
        tools = load_all_tools()
        citizens = load_all_citizens()
        report = validate_cross_links()
        out = {
            "success": report.ok(),
            "result": {
                "l7_dir": str(L7_DIR),
                "playground_exists": PLAYGROUND.exists(),
                "playground": str(PLAYGROUND),
                "skills": skills.get("count"),
                "tools_total": len(tools),
                "citizens_total": len(citizens),
                "validation_errors": len(report.errors),
                "validation_warns": len(report.warns),
                "validation_info": len([f for f in report.findings if f.level == "info"]),
                "runtime": str(ROOT),
            },
            "error": "" if report.ok() else f"{len(report.errors)} validation errors",
            "meta": {
                "execution_time_ms": int((time.time() - t0) * 1000),
                "timestamp": datetime.now(timezone.utc).isoformat(),
                "entity_id": "skill.l7-empire",
                "tool": "skill.doctor",
            },
        }
        print(json.dumps(out, indent=2))
        return 0 if report.ok() else 1
    if args.cmd == "ratios":
        print(dumps(run_financial_ratios(period=args.period, industry=args.industry, data_path=args.data)))
        return 0
    if args.cmd == "dcf":
        print(dumps(run_dcf(company=args.company, data_path=args.data)))
        return 0
    if args.cmd == "brand":
        print(dumps(run_brand_palette()))
        return 0
    if args.cmd == "corpus":
        from runtime.corpus_config import load_corpus_config, resolve_profile_roots

        cfg = load_corpus_config()
        profiles = {}
        for name in (cfg.get("profiles") or {}):
            profiles[name] = resolve_profile_roots(name)
            profiles[name]["roots"] = [str(p) for p in profiles[name]["roots"]]
        print(
            dumps(
                {
                    "success": True,
                    "result": {"config": cfg, "resolved": profiles},
                    "error": "",
                    "meta": {"tool": "skill.corpus"},
                }
            )
        )
        return 0
    if args.cmd == "rag-index":
        print(dumps(run_rag_index(rebuild=args.rebuild, profile=args.profile, roots=args.root)))
        return 0
    if args.cmd == "rag-query":
        print(dumps(run_rag_query(args.query, k=args.k, profile=args.profile)))
        return 0
    if args.cmd == "rag-eval":
        print(dumps(run_rag_eval(profile=args.profile, k=args.k, cases_path=args.cases)))
        return 0
    if args.cmd == "alchemy":
        print(
            dumps(
                run_alchemy(
                    stage=args.stage,
                    path=args.path,
                    write=not args.no_write,
                )
            )
        )
        return 0
    if args.cmd == "project-index":
        print(dumps(run_project_index(root=args.root, limit=args.limit)))
        return 0
    if args.cmd == "e2e":
        import subprocess

        script = ROOT / "scripts" / "e2e_offline.sh"
        proc = subprocess.run(["bash", str(script)], check=False)
        return proc.returncode
    return 2


if __name__ == "__main__":
    sys.exit(main())
