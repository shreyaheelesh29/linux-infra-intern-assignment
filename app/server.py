#!/usr/bin/env python3
import json
import os
from datetime import datetime, timezone
from http.server import BaseHTTPRequestHandler, HTTPServer


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/health":
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"not found")
            return

        payload = json.dumps({"status": "healthy"}, separators=(",", ":")).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format, *args):
        message = "%s - - %s" % (self.address_string(), format % args)
        print(message, flush=True)

        log_dir = os.environ.get("LOG_DIR")
        if not log_dir:
            return

        try:
            os.makedirs(log_dir, exist_ok=True)
            timestamp = datetime.now(timezone.utc).isoformat()
            with open(os.path.join(log_dir, "infra-demo.log"), "a", encoding="utf-8") as log_file:
                log_file.write(f"{timestamp} {message}\n")
        except OSError as exc:
            print(f"could not write application log: {exc}", flush=True)


def main():
    port = int(os.environ.get("PORT", "8080"))
    server = HTTPServer(("0.0.0.0", port), Handler)
    print(f"infra-demo service listening on 0.0.0.0:{port}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
