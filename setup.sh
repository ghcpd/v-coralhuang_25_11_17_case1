#!/usr/bin/env bash
set -e

# Simple idempotent setup: ensure index.html exists
echo "Preparing workspace..."
if [ -f index.html ]; then
  echo "index.html already present"
else
  if [ -f input.html ]; then
    cp input.html index.html
    echo "Copied input.html to index.html"
  else
    echo "No input.html found; nothing to do"
  fi
fi

echo "Setup complete."