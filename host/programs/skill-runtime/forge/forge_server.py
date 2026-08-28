#!/usr/bin/env python3
"""
L7 Forge HTTP surface for skill-runtime.

Law I / XXV — tools execute through the forge, not ad-hoc MCP.

Endpoints:
  GET  /health
  GET  /tools
  POST /execute     { "tool": "financial_ratios", "params": {...} }
  POST /api/call    same (empire compatibility)
  POST /api/execute same when body has "tool" (not flow)

Default port: 7378 (empire dashboard often 7377)
"""

from __future__ import annotations

import json
import os
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

FORGE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(FORGE_DIR))

from skill_bridge import can_execute, execute_tool, list_skill_tools  # noqa: E402

HOST = os.environ.get("L7_FORGE_HOST", "127.0.0.1")
PORT = int(os.environ.get("L7_FORGE_PORT", "7378"))
GATEWAY_PORT = os.environ.get("L7_PORT", "18789")


def _parse_origins(value: str) -> list[str]:
    return [item.strip() for item in (value or "").split(",") if item.strip()]


def allowed_origins() -> set[str]:
    origins = {
        f"http://127.0.0.1:{GATEWAY_PORT}",
        f"http://localhost:{GATEWAY_PORT}",
        f"http://[::1]:{GATEWAY_PORT}",
        f"http://127.0.0.1:{PORT}",
        f"http://localhost:{PORT}",
    }
    origins.update(_parse_origins(os.environ.get("L7_CORS_ORIGINS", "")))
    return origins


def origin_allowed(origin: str | None) -> bool:
    if not origin:
        return True
    if origin in allowed_origins():
        return True
    return False


def cors_headers(origin: str | None) -> dict[str, str]:
    headers = {
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization, X-L7-Token, X-L7-Request-Id",
        "Access-Control-Max-Age": "600",
        "Vary": "Origin",
    }
    if origin and origin_allowed(origin):
        headers["Access-Control-Allow-Origin"] = origin
    return headers


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        sys.stderr.write("[forge] " + (fmt % args) + "\n")

    def _send(self, code: int, obj: dict):
        body = json.dumps(obj, indent=2, default=str).encode("utf-8")
        origin = self.headers.get("Origin")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        for name, value in cors_headers(origin).items():
            self.send_header(name, value)
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        origin = self.headers.get("Origin")
        if origin and not origin_allowed(origin):
            self._send(403, {"success": False, "error": "Origin not allowed"})
            return
        self.send_response(204)
        for name, value in cors_headers(origin).items():
            self.send_header(name, value)
        self.end_headers()

    def do_GET(self):
        path = urlparse(self.path).path
        if path in ("/health", "/api/health"):
            self._send(
                200,
                {
                    "ok": True,
                    "gateway": True,
                    "mode": "skill-runtime",
                    "tools": len(list_skill_tools()),
                    "port": PORT,
                },
            )
            return
        if path in ("/tools", "/api/tools"):
            self._send(200, {"tools": list_skill_tools()})
            return
        self._send(404, {"error": "not found", "path": path})

    def do_POST(self):
        path = urlparse(self.path).path
        length = int(self.headers.get("Content-Length") or 0)
        raw = self.rfile.read(length) if length else b"{}"
        try:
            body = json.loads(raw.decode("utf-8") or "{}")
        except json.JSONDecodeError:
            self._send(400, {"success": False, "error": "Invalid JSON body"})
            return

        if path in ("/execute", "/api/execute", "/api/call", "/call"):
            # Support both {tool, params} and {tool, arguments}
            tool = body.get("tool") or body.get("name")
            params = body.get("params") or body.get("arguments") or body.get("args") or {}
            if not tool:
                # flow-style body is not handled here
                if body.get("flow"):
                    self._send(
                        400,
                        {
                            "success": False,
                            "error": "This forge executes tools only. Use empire /api/execute for flows.",
                        },
                    )
                    return
                self._send(400, {"success": False, "error": "tool required"})
                return
            if not can_execute(tool):
                self._send(
                    404,
                    {
                        "success": False,
                        "ok": False,
                        "error": f"Unknown or unmapped forge tool: {tool}",
                        "hint": "GET /tools for executable skill tools",
                    },
                )
                return
            who = self.headers.get("X-L7-Who") or body.get("who") or "forge-http"
            result = execute_tool(tool, params, who=who)
            code = 200 if result.get("success") else 422
            self._send(code, result)
            return

        self._send(404, {"error": "not found", "path": path})


def main():
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"L7 Forge (skill-runtime) on http://{HOST}:{PORT}", flush=True)
    print("  GET  /health  /tools", flush=True)
    print("  POST /execute  {\"tool\":\"financial_ratios\",\"params\":{...}}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nforge stop", flush=True)
        server.server_close()


if __name__ == "__main__":
    main()
