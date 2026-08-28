#!/usr/bin/env python3
"""Smoke tests for L7 skill runtime."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from runtime.loader import load_all_skills, route_task  # noqa: E402
from runtime.validator import validate_cross_links  # noqa: E402
from runtime.execute import (  # noqa: E402
    run_financial_ratios,
    run_dcf,
    run_brand_palette,
    run_rag_index,
    run_rag_query,
    list_skills,
    route,
)

FIN = ROOT / "packages" / "financial" / "fixtures"


class TestRuntime(unittest.TestCase):
    def test_skills_loaded(self):
        skills = load_all_skills()
        names = {s.name for s in skills}
        self.assertGreaterEqual(len(skills), 16)
        self.assertIn("ai-playground-index", names)
        self.assertIn("rag-pipeline", names)

    def test_route_rag(self):
        ranked = route_task("build a rag pipeline with chroma vectors")
        self.assertTrue(ranked)
        top = {r["name"] for r in ranked[:5]}
        self.assertTrue(top & {"rag-pipeline", "vector-chroma", "llamaindex-rag"})

    def test_validate(self):
        report = validate_cross_links()
        # allow warns; errors must be zero for core pack
        self.assertEqual(report.errors, [], msg=[e.message for e in report.errors])

    def test_ratios(self):
        env = run_financial_ratios(period="Q4_2024", industry="technology")
        self.assertTrue(env["success"], env.get("error"))
        ratios = env["result"]["ratios"]
        self.assertIn("profitability", ratios)
        self.assertGreater(ratios["profitability"]["roe"], 0)
        self.assertEqual(env["result"].get("mode"), "demo")
        self.assertIn("data_quality", env["result"])

    def test_ratios_real_json(self):
        path = FIN / "statements_complete.json"
        env = run_financial_ratios(data_path=str(path), industry="technology")
        self.assertTrue(env["success"], env.get("error"))
        self.assertEqual(env["result"]["mode"], "real")
        self.assertGreater(env["result"]["ratios"]["profitability"]["roe"], 0)
        self.assertEqual(env["result"]["data_quality"]["status"], "ok")
        self.assertEqual(env["result"]["data_quality"]["proxies_used"], [])

    def test_ratios_incomplete_fails(self):
        path = FIN / "statements_incomplete.json"
        env = run_financial_ratios(data_path=str(path))
        self.assertFalse(env["success"])
        self.assertIn("incomplete", env["error"].lower())

    def test_dcf(self):
        env = run_dcf(company="UnitTestCo")
        self.assertTrue(env["success"], env.get("error"))
        self.assertGreater(env["result"]["valuation"]["enterprise_value"], 0)
        self.assertEqual(env["result"].get("mode"), "demo")

    def test_dcf_real_json(self):
        path = FIN / "dcf_case_complete.json"
        env = run_dcf(data_path=str(path))
        self.assertTrue(env["success"], env.get("error"))
        self.assertEqual(env["result"]["mode"], "real")
        self.assertGreater(env["result"]["valuation"]["enterprise_value"], 0)
        self.assertIn("data_quality", env["result"])

    def test_brand(self):
        env = run_brand_palette()
        self.assertTrue(env["success"], env.get("error"))
        self.assertIn("colors", env["result"])

    def test_rag(self):
        idx = run_rag_index(rebuild=True)
        self.assertTrue(idx["success"], idx.get("error"))
        self.assertGreater(idx["result"]["chunks"], 10)
        q = run_rag_query("orchestrator workers agent pattern", k=3)
        self.assertTrue(q["success"], q.get("error"))
        self.assertTrue(q["result"]["hits"])

    def test_list_envelope(self):
        env = list_skills()
        self.assertTrue(env["success"])
        self.assertIn("meta", env)
        self.assertIn("execution_time_ms", env["meta"])

    def test_route_envelope(self):
        env = route("prompt engineering few shot")
        self.assertTrue(env["success"])
        self.assertTrue(env["result"]["matches"])


if __name__ == "__main__":
    unittest.main()
