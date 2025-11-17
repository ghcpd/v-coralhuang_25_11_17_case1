#!/usr/bin/env bash
set -euo pipefail

PORT=3000
LOG_FILE=/tmp/html_server.log
SERVER_READY=0

if ! lsof -iTCP:${PORT} -sTCP:LISTEN >/dev/null 2>&1; then
    nohup python3 -m http.server ${PORT} > "${LOG_FILE}" 2>&1 &
    SERVER_READY=1
    sleep 1
fi

curl -fsS "http://localhost:${PORT}/" > /tmp/index_snapshot.html

python3 - <<'PY'
import pathlib
import sys

html = pathlib.Path('/tmp/index_snapshot.html').read_text()

tests = [
    ("served main html", "Broken Stable Diffusion WebUI Mock" in html),
    ("dropdowns stop closing immediately", "closeDropdownMenus" in html and "event.stopPropagation" in html),
    ("backend init guarded", "nonExistingConfig" not in html and "backendConfig" in html),
    ("scan models rerenders", "renderDropdownOptions(dropdownElement, checkpointModels)" in html),
    ("fake localization bar non blocking", "pointer-events: none" in html)
]

failed = [name for name, result in tests if not result]

if failed:
    for name in failed:
        print(f"FAIL: {name}")
    sys.exit(1)

print("All tests passed:")
for name, _ in tests:
    print(f" - {name}")
PY
