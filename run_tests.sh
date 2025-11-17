#!/usr/bin/env bash
set -e

BASE_URL=http://localhost:3000
LOGFILE=/tmp/html_server.log

# Determine the venv python
if [ -f ".venv/bin/python" ]; then
  VENV_PY=".venv/bin/python"
elif [ -f ".venv/Scripts/python.exe" ]; then
  VENV_PY=".venv/Scripts/python.exe"
else
  VENV_PY="python3"
fi

# Start server if not serving
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL || echo "000")
if [ "$HTTP_CODE" != "200" ]; then
  echo "Starting local server on port 3000..."
  nohup python3 -m http.server 3000 > $LOGFILE 2>&1 &
fi

# Wait for server to respond
echo -n "Waiting for server to be ready"
for i in {1..50}; do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL || echo "000")
  if [ "$HTTP_CODE" = "200" ]; then
    echo " - ready"
    break
  fi
  echo -n "."
  sleep 0.2
done

if [ "$HTTP_CODE" != "200" ]; then
  echo "Server did not start in time. Check $LOGFILE"
  tail -n 50 $LOGFILE || true
  exit 2
fi

# Run tests using venv python
$VENV_PY -m pytest -q tests/test_ui.py --disable-warnings

TEST_RC=$?

# Show tail of server log for debugging only
echo "--- Server log (last 20 lines) ---"
tail -n 20 $LOGFILE || true

if [ "$TEST_RC" -ne 0 ]; then
  echo "Some tests failed"
  exit $TEST_RC
fi

echo "All tests passed"
exit 0
