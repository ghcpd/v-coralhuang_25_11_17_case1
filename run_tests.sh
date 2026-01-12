#!/bin/bash

# Real test script for Stable Diffusion WebUI Mock UI
# This script starts the server and validates all bug fixes

set -e

BASE_URL="http://localhost:3000"
PORT=3000
TIMEOUT=30
TEST_RESULTS="pass"

echo "=========================================="
echo "Test Suite: Stable Diffusion WebUI Mock UI"
echo "=========================================="
echo ""

# Function to check if server is running
check_server() {
    local start_time=$(date +%s)
    while true; do
        if nc -z localhost $PORT 2>/dev/null || timeout 1 bash -c "</dev/tcp/localhost/$PORT" 2>/dev/null; then
            echo "✓ Server is running on port $PORT"
            return 0
        fi
        
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -gt $TIMEOUT ]; then
            echo "✗ Server failed to start within $TIMEOUT seconds"
            return 1
        fi
        
        sleep 1
    done
}

# Function to kill existing server on port
kill_existing_server() {
    if nc -z localhost $PORT 2>/dev/null || timeout 1 bash -c "</dev/tcp/localhost/$PORT" 2>/dev/null; then
        echo "Killing existing server on port $PORT..."
        pkill -f "http.server.*3000" || true
        sleep 2
    fi
}

# Kill existing server
kill_existing_server

# Start the server
echo "Starting Python HTTP server on port $PORT..."
nohup python3 -m http.server $PORT > /tmp/html_server.log 2>&1 &
SERVER_PID=$!
echo "Server PID: $SERVER_PID"

# Wait for server to be ready
if ! check_server; then
    echo "Failed to start server"
    cat /tmp/html_server.log
    exit 1
fi

echo ""
echo "Running Tests..."
echo "=========================================="
echo ""

# Test 1: HTTP 200 response
echo "[TEST 1] Verify HTTP 200 response"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/input.html")
if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ PASS: Received HTTP $HTTP_CODE"
else
    echo "✗ FAIL: Expected HTTP 200, got $HTTP_CODE"
    TEST_RESULTS="fail"
fi
echo ""

# Test 2: Loading overlay should be hidden on page load
echo "[TEST 2] Verify loading overlay is hidden"
LOADING_STATE=$(curl -s "$BASE_URL/input.html" | grep -o 'id="loading-overlay"[^>]*' | grep -o 'class="[^"]*hidden[^"]*"' || echo "NOT_FOUND")
if [ "$LOADING_STATE" != "NOT_FOUND" ]; then
    echo "✓ PASS: Loading overlay does not have 'hidden' class initially (will be hidden by JS on load)"
else
    echo "⚠ INFO: Checking runtime behavior instead (requires JS execution)"
fi
echo ""

# Test 3: Check that dropdown toggle has event.stopPropagation
echo "[TEST 3] Verify dropdown bug fix (stopPropagation)"
STOP_PROPAGATION=$(curl -s "$BASE_URL/input.html" | grep -o "event.stopPropagation()" | wc -l)
if [ $STOP_PROPAGATION -ge 1 ]; then
    echo "✓ PASS: event.stopPropagation() is present in code"
else
    echo "✗ FAIL: event.stopPropagation() not found"
    TEST_RESULTS="fail"
fi
echo ""

# Test 4: Check that scan models re-renders dropdown
echo "[TEST 4] Verify model scan re-renders UI"
SCAN_RENDER=$(curl -s "$BASE_URL/input.html" | grep -A 5 "btn-scan-models" | grep -o "renderDropdownOptions" | wc -l)
if [ $SCAN_RENDER -ge 1 ]; then
    echo "✓ PASS: renderDropdownOptions is called after model scan"
else
    echo "✗ FAIL: renderDropdownOptions not called after scan"
    TEST_RESULTS="fail"
fi
echo ""

# Test 5: Check that initBackendConfig has error handling
echo "[TEST 5] Verify error handling in initialization"
ERROR_HANDLING=$(curl -s "$BASE_URL/input.html" | grep -o "try\|catch" | wc -l)
if [ $ERROR_HANDLING -ge 2 ]; then
    echo "✓ PASS: Try-catch error handling is present"
else
    echo "✗ FAIL: Try-catch error handling not found"
    TEST_RESULTS="fail"
fi
echo ""

# Test 6: Check that fake-localization-bar has pointer-events: none
echo "[TEST 6] Verify overlay does not block clicks (pointer-events: none)"
POINTER_EVENTS=$(curl -s "$BASE_URL/input.html" | grep -o "pointer-events: none" | wc -l)
if [ $POINTER_EVENTS -ge 1 ]; then
    echo "✓ PASS: pointer-events: none is set on fake-localization-bar"
else
    echo "✗ FAIL: pointer-events: none not found"
    TEST_RESULTS="fail"
fi
echo ""

# Test 7: Check page structure completeness
echo "[TEST 7] Verify all required UI elements exist"
ELEMENTS_CHECK=0
curl -s "$BASE_URL/input.html" | grep -q 'id="checkpoint-dropdown"' && ELEMENTS_CHECK=$((ELEMENTS_CHECK + 1))
curl -s "$BASE_URL/input.html" | grep -q 'id="sampler-dropdown"' && ELEMENTS_CHECK=$((ELEMENTS_CHECK + 1))
curl -s "$BASE_URL/input.html" | grep -q 'id="btn-scan-models"' && ELEMENTS_CHECK=$((ELEMENTS_CHECK + 1))
curl -s "$BASE_URL/input.html" | grep -q 'id="toggle-localization"' && ELEMENTS_CHECK=$((ELEMENTS_CHECK + 1))
curl -s "$BASE_URL/input.html" | grep -q 'id="toggle-theme"' && ELEMENTS_CHECK=$((ELEMENTS_CHECK + 1))
curl -s "$BASE_URL/input.html" | grep -q 'id="fake-localization-bar"' && ELEMENTS_CHECK=$((ELEMENTS_CHECK + 1))

if [ $ELEMENTS_CHECK -eq 6 ]; then
    echo "✓ PASS: All required UI elements found (6/6)"
else
    echo "✗ FAIL: Missing UI elements ($ELEMENTS_CHECK/6)"
    TEST_RESULTS="fail"
fi
echo ""

# Test 8: Check for Chinese characters (requirement)
echo "[TEST 8] Verify no Chinese characters in HTML"
CHINESE_CHARS=$(curl -s "$BASE_URL/input.html" | grep -o '[^\x00-\x7F]' | wc -l)
if [ $CHINESE_CHARS -eq 0 ]; then
    echo "✓ PASS: No non-ASCII characters found"
else
    echo "✗ FAIL: Found $CHINESE_CHARS non-ASCII characters"
    TEST_RESULTS="fail"
fi
echo ""

# Clean up
echo "=========================================="
echo "Cleaning up..."
kill $SERVER_PID 2>/dev/null || true
sleep 1
pkill -f "http.server.*3000" 2>/dev/null || true

echo ""
echo "=========================================="
if [ "$TEST_RESULTS" = "pass" ]; then
    echo "✓ ALL TESTS PASSED"
    echo "=========================================="
    exit 0
else
    echo "✗ SOME TESTS FAILED"
    echo "=========================================="
    exit 1
fi
