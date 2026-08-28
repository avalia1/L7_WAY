#!/usr/bin/env python3
"""Contract tests for skill-runtime forge bridge."""

from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

FORGE = Path(__file__).resolve().parent
sys.path.insert(0, str(FORGE))

from skill_bridge import can_execute, execute_tool, list_skill_tools  # noqa: E402

FIX = FORGE.parent / "packages" / "financial" / "fixtures"


class TestForge(unittest.TestCase):
    def test_can_and_list(self):
        tools = list_skill_tools()
        names = {t["name"] for t in tools}
        self.assertIn("financial_ratios", names)
        self.assertIn("dcf_valuation", names)
        self.assertIn("rag_pipeline", names)
        self.assertTrue(can_execute("financial_ratios"))
        self.assertFalse(can_execute("no_such_tool_xyz"))

    def test_execute_ratios_demo(self):
        env = execute_tool("financial_ratios", {"period": "Q4_2024", "industry": "technology"}, who="test")
        self.assertTrue(env.get("success"), env.get("error"))
        self.assertTrue(env.get("ok"))
        self.assertEqual(env["meta"]["who"], "test")
        self.assertEqual(env["meta"]["source"], "skill-runtime-forge")
        self.assertGreater(env["result"]["ratios"]["profitability"]["roe"], 0)

    def test_execute_ratios_real(self):
        env = execute_tool(
            "financial_ratios",
            {"data": str(FIX / "statements_complete.json")},
            who="test",
        )
        self.assertTrue(env.get("success"), env.get("error"))
        self.assertEqual(env["result"]["mode"], "real")

    def test_execute_ratios_incomplete(self):
        env = execute_tool(
            "financial_ratios",
            {"data": str(FIX / "statements_incomplete.json")},
            who="test",
        )
        self.assertFalse(env.get("success"))

    def test_execute_dcf(self):
        env = execute_tool(
            "dcf_valuation",
            {"data": str(FIX / "dcf_case_complete.json")},
            who="test",
        )
        self.assertTrue(env.get("success"), env.get("error"))
        self.assertGreater(env["result"]["valuation"]["enterprise_value"], 0)

    def test_execute_rag_query(self):
        env = execute_tool(
            "rag_pipeline",
            {"action": "query", "query": "What is Law XV?", "profile": "real-corpus", "k": 3},
            who="test",
        )
        self.assertTrue(env.get("success"), env.get("error"))
        self.assertTrue(env["result"].get("hits"))

    def test_execute_doctor_via_l7_empire(self):
        env = execute_tool("l7_empire", {}, who="test")
        self.assertTrue(env.get("success"), env.get("error"))
        self.assertGreaterEqual(env["result"].get("skills", 0), 1)

    def test_unknown_tool(self):
        env = execute_tool("not_a_real_tool", {}, who="test")
        self.assertFalse(env.get("success"))

    def test_alchemy_nigredo_and_transmute(self):
        self.assertTrue(can_execute("alchemy_transmute"))
        self.assertTrue(can_execute("alchemy_nigredo"))
        self.assertTrue(can_execute("project_index"))
        # self skill-runtime path (small, always present)
        rt = str(FORGE.parent)
        env = execute_tool("alchemy_nigredo", {"path": rt}, who="test")
        self.assertTrue(env.get("success"), env.get("error"))
        self.assertEqual(env["result"].get("stage"), "nigredo")
        self.assertGreater(env["result"]["inventory"]["files"], 0)

        env2 = execute_tool(
            "alchemy_transmute",
            {"path": rt, "no_write": True},
            who="test",
            timeout=180.0,
        )
        self.assertTrue(env2.get("success"), env2.get("error"))
        self.assertIn("stages", env2["result"])
        self.assertIn("nigredo", env2["result"]["stages"])
        self.assertIn("rubedo", env2["result"]["stages"])
        self.assertIn("manifest", env2["result"])

    def test_project_index(self):
        env = execute_tool(
            "project_index",
            {"root": str(FORGE.parent), "limit": 5},
            who="test",
            timeout=180.0,
        )
        self.assertTrue(env.get("success"), env.get("error"))
        self.assertGreaterEqual(env["result"].get("count", 0), 1)

    def test_cors_allowlist_rejects_wildcard(self):
        from forge_server import cors_headers, origin_allowed

        self.assertTrue(origin_allowed(None))
        self.assertTrue(origin_allowed("http://127.0.0.1:18789"))
        self.assertFalse(origin_allowed("https://evil.example"))
        headers = cors_headers("http://127.0.0.1:18789")
        self.assertEqual(headers["Access-Control-Allow-Origin"], "http://127.0.0.1:18789")
        self.assertNotEqual(headers.get("Access-Control-Allow-Origin"), "*")
        denied = cors_headers("https://evil.example")
        self.assertNotIn("Access-Control-Allow-Origin", denied)


if __name__ == "__main__":
    unittest.main()
