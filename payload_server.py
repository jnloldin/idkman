# language: Python 3, file: payload_server.py
import os
import hmac
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs

SECRET = os.environ.get("PL_SECRET", "changeme").encode()
PAYLOAD_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "current.lua")
PORT = int(os.environ.get("PORT", "8080"))


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path != "/pl":
            self.send_response(404)
            self.end_headers()
            return
        q = parse_qs(parsed.query)
        supplied = (q.get("k") or [""])[0].encode()
        if not hmac.compare_digest(supplied, SECRET):
            self.send_response(403)
            self.end_headers()
            return
        try:
            with open(PAYLOAD_PATH, "rb") as f:
                body = f.read()
        except OSError:
            self.send_response(404)
            self.end_headers()
            return
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", PORT), Handler)
    print(f"listening on 0.0.0.0:{PORT}", flush=True)
    server.serve_forever()
