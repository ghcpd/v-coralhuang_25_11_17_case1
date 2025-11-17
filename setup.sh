#!/usr/bin/env bash
set -e
# Idempotent setup: create python venv and install dependencies
if [ ! -d ".venv" ]; then
  python3 -m venv .venv || python -m venv .venv
fi
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
# Install Playwright browsers
python -m playwright install

# Ensure server log location exists for UNIX-like systems
mkdir -p /tmp

echo "Setup done. Use ./run_tests.sh to run tests."
