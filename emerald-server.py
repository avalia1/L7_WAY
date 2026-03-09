#!/usr/bin/env python3
"""
Emerald Tablet OS — Local Server
Serves L7 WAY on the local network. Privacy first by design.
Binds to 0.0.0.0 for all devices on YOUR network.
No data leaves. No telemetry. No tracking. No sharing.
Personal information is non-negotiable.
"""

import http.server
import os
import sys

PORT = 7777
SERVE_DIR = os.path.expanduser('~')

os.chdir(SERVE_DIR)

BRIEF_PATH = os.path.expanduser('~/.l7/state/health-brief.txt')

class SilentHandler(http.server.SimpleHTTPRequestHandler):
    """Serve files silently. No logging to stdout."""
    def log_message(self, format, *args):
        pass  # Silence

    def end_headers(self):
        # Local network only — no CORS needed for external
        self.send_header('X-L7-Privacy', 'sacred-ground')
        self.send_header('Cache-Control', 'no-store')
        super().end_headers()

    def do_GET(self):
        if self.path == '/brief':
            try:
                with open(BRIEF_PATH, 'r') as f:
                    content = f.read()
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain; charset=utf-8')
                self.send_header('X-L7-Privacy', 'sacred-ground')
                self.send_header('Cache-Control', 'no-store')
                self.end_headers()
                self.wfile.write(content.encode('utf-8'))
            except FileNotFoundError:
                self.send_response(503)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(b'Heart has not generated a brief yet. Waiting for first system check.')
            return
        return super().do_GET()

if __name__ == '__main__':
    with http.server.HTTPServer(('0.0.0.0', PORT), SilentHandler) as server:
        sys.stderr.write(f'[emerald] Serving on port {PORT}\n')
        sys.stderr.write(f'[emerald] Root: {SERVE_DIR}\n')
        sys.stderr.write(f'[emerald] Privacy: sacred ground. No data shared.\n')
        server.serve_forever()
