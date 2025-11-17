#!/bin/bash

# Setup script for Stable Diffusion WebUI Mock UI
# This script prepares the reproducible environment for running the app

set -e

echo "=========================================="
echo "Setting up Stable Diffusion WebUI Mock UI"
echo "=========================================="

# Check for Python 3
if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 is not installed"
    exit 1
fi

echo "✓ Python 3 is available: $(python3 --version)"

# Verify we are in the correct directory
if [ ! -f "input.html" ]; then
    echo "ERROR: input.html not found in current directory"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "✓ Found input.html"

# Create a temporary directory for server logs if it doesn't exist
mkdir -p /tmp

echo "✓ Environment ready"
echo ""
echo "Setup complete! To start the server, run:"
echo "  nohup python3 -m http.server 3000 > /tmp/html_server.log 2>&1 &"
echo ""
echo "To verify the server is running:"
echo "  curl -s http://localhost:3000 | head -20"
echo ""
echo "To run tests:"
echo "  bash run_tests.sh"
echo ""
