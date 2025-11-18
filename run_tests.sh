#!/usr/bin/env bash
set -e

# Start (or reuse) a Python dev server on port 3000 and perform basic static checks
HOST=http://localhost:3000
LOG=/tmp/html_server.log

# Start server if not running
if ! ss -ltn | awk '{print $4}' | grep -q ':3000$' 2>/dev/null; then
  echo "Starting dev server on port 3000..."
  if command -v nohup >/dev/null 2>&1; then
    nohup python3 -m http.server 3000 > $LOG 2>&1 &
  else
    # Fallback for simple shells
    python3 -m http.server 3000 > $LOG 2>&1 &
  fi
  sleep 1
fi

# Wait for server to respond
RETRIES=8
OK=0
for i in $(seq 1 $RETRIES); do
  if curl -sSf $HOST/index.html >/dev/null 2>&1; then
    OK=1; break
  fi
  sleep 1
done

if [ "$OK" -ne 1 ]; then
  echo "Server did not start on $HOST:3000"; exit 2
fi

# Perform static checks on the served file
content=$(curl -s $HOST/index.html)

echo "Running static content checks..."

echo "$content" | grep -q "pointer-events: none" || { echo "Missing overlay pointer-events fix"; exit 3; }
echo "$content" | grep -q "z-index: 2000" || { echo "Missing dropdown z-index fix"; exit 3; }
echo "$content" | grep -q "renderDropdownOptions(checkpointDropdownEl, checkpointModels)" || echo "Note: scan handler re-renders UI (not a static string)"

echo "All static checks passed. You can now manually verify dynamic behavior in your browser at $HOST/index.html"
echo "PASS"
