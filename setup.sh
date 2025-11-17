#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required to run the web server."
  exit 1
fi

chmod +x run_tests.sh

cat <<'MSG'
Setup complete. You can start the dev server with:
nohup python3 -m http.server 3000 > /tmp/html_server.log 2>&1 &
MSG
