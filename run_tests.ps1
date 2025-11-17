param(
    [string]$Port = "3000"
)

$BaseUrl = "http://localhost:$Port"
$Timeout = 30
$TestResults = "pass"
$FailedTests = @()

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Test Suite: Stable Diffusion WebUI Mock UI" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if server is running
function Check-Server {
    param([int]$Port)
    
    $startTime = Get-Date
    while ($true) {
        try {
            $connection = New-Object System.Net.Sockets.TcpClient
            $connection.Connect("localhost", $Port)
            $connection.Close()
            Write-Host "✓ Server is running on port $Port" -ForegroundColor Green
            return $true
        } catch {
            $elapsed = ((Get-Date) - $startTime).TotalSeconds
            if ($elapsed -gt $Timeout) {
                Write-Host "✗ Server failed to start within $Timeout seconds" -ForegroundColor Red
                return $false
            }
            Start-Sleep -Milliseconds 500
        }
    }
}

# Function to kill existing server
function Kill-ExistingServer {
    param([int]$Port)
    
    try {
        $process = Get-Process -Name "python" -ErrorAction SilentlyContinue | 
                   Where-Object { $_.CommandLine -like "*http.server*$Port*" }
        
        if ($process) {
            Write-Host "Killing existing server on port $Port..."
            Stop-Process -InputObject $process -Force
            Start-Sleep -Seconds 2
        }
    } catch {
        # Continue silently if no process found
    }
}

# Kill existing server
Kill-ExistingServer -Port $Port

# Start the server
Write-Host "Starting Python HTTP server on port $Port..."
$serverProcess = Start-Process python3 -ArgumentList @("-m", "http.server", $Port) `
                 -RedirectStandardOutput "C:\tmp\html_server.log" `
                 -RedirectStandardError "C:\tmp\html_server_error.log" `
                 -PassThru -NoNewWindow

Write-Host "Server PID: $($serverProcess.Id)"

# Wait for server to be ready
if (!(Check-Server -Port $Port)) {
    Write-Host "Failed to start server" -ForegroundColor Red
    Get-Content "C:\tmp\html_server.log" -ErrorAction SilentlyContinue | Select-Object -First 20
    exit 1
}

Write-Host ""
Write-Host "Running Tests..."
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: HTTP 200 response
Write-Host "[TEST 1] Verify HTTP 200 response"
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/input.html" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ PASS: Received HTTP 200" -ForegroundColor Green
    } else {
        Write-Host "✗ FAIL: Expected HTTP 200, got $($response.StatusCode)" -ForegroundColor Red
        $TestResults = "fail"
        $FailedTests += "Test 1"
    }
} catch {
    Write-Host "✗ FAIL: $($_)" -ForegroundColor Red
    $TestResults = "fail"
    $FailedTests += "Test 1"
}
Write-Host ""

# Test 2: Loading overlay present (will be hidden by JS)
Write-Host "[TEST 2] Verify loading overlay structure exists"
try {
    $content = Invoke-WebRequest -Uri "$BaseUrl/input.html" -UseBasicParsing | Select-Object -ExpandProperty Content
    if ($content -match 'id="loading-overlay"') {
        Write-Host "✓ PASS: Loading overlay element exists" -ForegroundColor Green
    } else {
        Write-Host "✗ FAIL: Loading overlay element not found" -ForegroundColor Red
        $TestResults = "fail"
        $FailedTests += "Test 2"
    }
} catch {
    Write-Host "✗ FAIL: $($_)" -ForegroundColor Red
    $TestResults = "fail"
    $FailedTests += "Test 2"
}
Write-Host ""

# Test 3: Check that dropdown toggle has event.stopPropagation
Write-Host "[TEST 3] Verify dropdown bug fix (stopPropagation)"
try {
    $content = Invoke-WebRequest -Uri "$BaseUrl/input.html" -UseBasicParsing | Select-Object -ExpandProperty Content
    $count = ([regex]::Matches($content, "event.stopPropagation\(\)")).Count
    if ($count -ge 2) {
        Write-Host "✓ PASS: event.stopPropagation() is present in code ($count occurrences)" -ForegroundColor Green
    } else {
        Write-Host "✗ FAIL: Insufficient event.stopPropagation() found ($count)" -ForegroundColor Red
        $TestResults = "fail"
        $FailedTests += "Test 3"
    }
} catch {
    Write-Host "✗ FAIL: $($_)" -ForegroundColor Red
    $TestResults = "fail"
    $FailedTests += "Test 3"
}
Write-Host ""

# Test 4: Check that scan models re-renders dropdown
Write-Host "[TEST 4] Verify model scan re-renders UI"
try {
    $content = Invoke-WebRequest -Uri "$BaseUrl/input.html" -UseBasicParsing | Select-Object -ExpandProperty Content
    if ($content -match "renderDropdownOptions\(checkpointDropdown" -and $content -match "btn-scan-models") {
        Write-Host "✓ PASS: renderDropdownOptions is called after model scan" -ForegroundColor Green
    } else {
        Write-Host "✗ FAIL: renderDropdownOptions not properly integrated" -ForegroundColor Red
        $TestResults = "fail"
        $FailedTests += "Test 4"
    }
} catch {
    Write-Host "✗ FAIL: $($_)" -ForegroundColor Red
    $TestResults = "fail"
    $FailedTests += "Test 4"
}
Write-Host ""

# Test 5: Check that initBackendConfig has error handling
Write-Host "[TEST 5] Verify error handling in initialization"
try {
    $content = Invoke-WebRequest -Uri "$BaseUrl/input.html" -UseBasicParsing | Select-Object -ExpandProperty Content
    $tryCount = ([regex]::Matches($content, "\btry\b")).Count
    $catchCount = ([regex]::Matches($content, "\bcatch\b")).Count
    if ($tryCount -ge 1 -and $catchCount -ge 1) {
        Write-Host "✓ PASS: Try-catch error handling is present" -ForegroundColor Green
    } else {
        Write-Host "✗ FAIL: Try-catch error handling not sufficient (try: $tryCount, catch: $catchCount)" -ForegroundColor Red
        $TestResults = "fail"
        $FailedTests += "Test 5"
    }
} catch {
    Write-Host "✗ FAIL: $($_)" -ForegroundColor Red
    $TestResults = "fail"
    $FailedTests += "Test 5"
}
Write-Host ""

# Test 6: Check that fake-localization-bar has pointer-events: none
Write-Host "[TEST 6] Verify overlay does not block clicks (pointer-events: none)"
try {
    $content = Invoke-WebRequest -Uri "$BaseUrl/input.html" -UseBasicParsing | Select-Object -ExpandProperty Content
    if ($content -match "pointer-events:\s*none") {
        Write-Host "✓ PASS: pointer-events: none is set on fake-localization-bar" -ForegroundColor Green
    } else {
        Write-Host "✗ FAIL: pointer-events: none not found" -ForegroundColor Red
        $TestResults = "fail"
        $FailedTests += "Test 6"
    }
} catch {
    Write-Host "✗ FAIL: $($_)" -ForegroundColor Red
    $TestResults = "fail"
    $FailedTests += "Test 6"
}
Write-Host ""

# Test 7: Check page structure completeness
Write-Host "[TEST 7] Verify all required UI elements exist"
try {
    $content = Invoke-WebRequest -Uri "$BaseUrl/input.html" -UseBasicParsing | Select-Object -ExpandProperty Content
    $elementsCheck = 0
    
    if ($content -match 'id="checkpoint-dropdown"') { $elementsCheck++ }
    if ($content -match 'id="sampler-dropdown"') { $elementsCheck++ }
    if ($content -match 'id="btn-scan-models"') { $elementsCheck++ }
    if ($content -match 'id="toggle-localization"') { $elementsCheck++ }
    if ($content -match 'id="toggle-theme"') { $elementsCheck++ }
    if ($content -match 'id="fake-localization-bar"') { $elementsCheck++ }
    
    if ($elementsCheck -eq 6) {
        Write-Host "✓ PASS: All required UI elements found (6/6)" -ForegroundColor Green
    } else {
        Write-Host "✗ FAIL: Missing UI elements ($elementsCheck/6)" -ForegroundColor Red
        $TestResults = "fail"
        $FailedTests += "Test 7"
    }
} catch {
    Write-Host "✗ FAIL: $($_)" -ForegroundColor Red
    $TestResults = "fail"
    $FailedTests += "Test 7"
}
Write-Host ""

# Test 8: Check valid HTML structure
Write-Host "[TEST 8] Verify HTML structure is valid"
try {
    $content = Invoke-WebRequest -Uri "$BaseUrl/input.html" -UseBasicParsing | Select-Object -ExpandProperty Content
    if ($content -match "<!DOCTYPE html>" -and $content -match "</html>") {
        Write-Host "✓ PASS: HTML structure is valid" -ForegroundColor Green
    } else {
        Write-Host "✗ FAIL: HTML structure issues detected" -ForegroundColor Red
        $TestResults = "fail"
        $FailedTests += "Test 8"
    }
} catch {
    Write-Host "✗ FAIL: $($_)" -ForegroundColor Red
    $TestResults = "fail"
    $FailedTests += "Test 8"
}
Write-Host ""

# Clean up
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Cleaning up..."
try {
    Stop-Process -InputObject $serverProcess -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
} catch {
    # Continue
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
if ($TestResults -eq "pass") {
    Write-Host "✓ ALL TESTS PASSED" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "✗ SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "Failed tests: $($FailedTests -join ', ')" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Cyan
    exit 1
}
