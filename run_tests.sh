#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

PORT=3000
LOG=/tmp/html_server.log

server_running=false
if command -v lsof >/dev/null 2>&1; then
  if lsof -i "TCP:${PORT}" -sTCP:LISTEN >/dev/null 2>&1; then
    server_running=true
  fi
fi

if [ "$server_running" = false ]; then
  echo "Starting HTTP server on port ${PORT}..."
  nohup python3 -m http.server ${PORT} > "${LOG}" 2>&1 &
  sleep 1
  echo "Server started with PID $!"
else
  echo "Server already listening on port ${PORT}."
fi

echo "Checking HTTP response..."
curl -sSf "http://localhost:${PORT}" >/dev/null

echo "Fetching index.html for verification..."
page_file=$(mktemp)
trap 'rm -f "$page_file"' EXIT
curl -sSf "http://localhost:${PORT}/index.html" -o "$page_file"

python3 - "$page_file" <<'PY'
import sys
path = sys.argv[1]
with open(path, encoding="utf-8") as file:
    html = file.read()

requirements = [
    ("renderDropdownOptions(", "dropdown re-render logic"),
    ("menu.classList.toggle(\"hidden\")", "dropdown toggle handler"),
    ("loading.classList.add(\"hidden\")", "loading overlay hides"),
    ("pointer-events: none", "overlay pointer passthrough"),
    ("body.classList.add(\"overlay-visible\")", "overlay-aware layout")
]
for token, description in requirements:
    if token not in html:
        sys.exit(f"Missing {description} check ({token})")
print("Static content validation passed")
PY
echo "All tests passed."
