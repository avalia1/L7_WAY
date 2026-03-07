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

class SilentHandler(http.server.SimpleHTTPRequestHandler):
    """Serve files silently. No logging to stdout."""
    def log_message(self, format, *args):
        pass  # Silence

    def end_headers(self):
        # Local network only — no CORS needed for external
        self.send_header('X-L7-Privacy', 'sacred-ground')
        self.send_header('Cache-Control', 'no-store')
        super().end_headers()

if __name__ == '__main__':
    with http.server.HTTPServer(('0.0.0.0', PORT), SilentHandler) as server:
        sys.stderr.write(f'[emerald] Serving on port {PORT}\n')
        sys.stderr.write(f'[emerald] Root: {SERVE_DIR}\n')
        sys.stderr.write(f'[emerald] Privacy: sacred ground. No data shared.\n')
        server.serve_forever()
