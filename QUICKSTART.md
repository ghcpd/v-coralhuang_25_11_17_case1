# Quick Start Guide

## For Windows Users

### Step 1: Verify Python Installation
```powershell
python3 --version
```
Should show Python 3.6 or higher.

### Step 2: Navigate to Project Directory
```powershell
cd c:\Bug_Bash\25_11_17\v-coralhuang_25_11_17_case1
```

### Step 3: Start the Development Server
```powershell
python3 -m http.server 3000
```
You should see:
```
Serving HTTP on 0.0.0.0 port 3000 (http://0.0.0.0:3000/) ...
```

### Step 4: Open in Browser
Open your browser and navigate to:
```
http://localhost:3000/input.html
```

### Step 5: Run Automated Tests (Optional - New Terminal)
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File run_tests.ps1 -Port 3000
```

---

## For Linux/macOS Users

### Step 1: Verify Python Installation
```bash
python3 --version
```
Should show Python 3.6 or higher.

### Step 2: Navigate to Project Directory
```bash
cd c:\Bug_Bash\25_11_17\v-coralhuang_25_11_17_case1
```

### Step 3: Start the Development Server
```bash
python3 -m http.server 3000
```

### Step 4: Open in Browser
Open your browser and navigate to:
```
http://localhost:3000/input.html
```

### Step 5: Run Automated Tests (Optional - New Terminal)
```bash
bash run_tests.sh
```

---

## Manual Testing Checklist

After starting the server, verify the following:

### Loading Overlay
- [ ] Page loads and displays the WebUI
- [ ] Loading overlay disappears after ~1 second
- [ ] If it doesn't disappear, check browser console for errors

### Dropdown Menu (Bug 1 Fix)
1. Click on "Checkpoint" dropdown (says "Select checkpoint")
2. [ ] Menu appears with options
3. [ ] Menu stays open
4. [ ] Select an option (e.g., "v1-5-pruned-emaonly.safetensors")
5. [ ] Selected text appears in button
6. [ ] Menu closes after selection
7. [ ] Click elsewhere on page - menu stays closed

### Model Scan (Bug 3 Fix)
1. Click "Scan for models (mock)" button
2. [ ] Dropdown items increase from 1 to 3
3. [ ] New models "majicmixRealistic_v7.safetensors" and "someNewModel_v2.safetensors" appear
4. [ ] Can select any model

### Theme & Localization (Bug 4 Fix)
1. Toggle "Enable dark theme extension"
   - [ ] Theme changes to dark
   - [ ] All buttons and dropdowns remain clickable
   
2. Toggle "Enable localization extension"
   - [ ] Orange bar appears at top with localization text
   - [ ] Bar does NOT block clicks on UI elements
   - [ ] Can still use dropdowns and buttons

3. Toggle both ON
   - [ ] Both theme and localization active
   - [ ] "Generate" button is fully clickable
   - [ ] Dropdowns work properly
   - [ ] No elements are obscured

---

## Troubleshooting

### Server Won't Start on Port 3000
**Solution**: Port may be in use. Kill existing process:
```powershell
# Windows
Get-Process | Where-Object {$_.ProcessName -like "*python*"} | Stop-Process -Force

# Linux/macOS
pkill -f "http.server"
```
Then try starting again.

### "File not found" error
**Solution**: Make sure you're in the correct directory:
```powershell
cd c:\Bug_Bash\25_11_17\v-coralhuang_25_11_17_case1
ls  # or 'dir' on Windows - should show input.html
```

### Tests Won't Run
**Solution**: Ensure Python3 is in PATH:
```powershell
where python3  # Windows
which python3  # Linux/macOS
```

### Browser Shows Blank Page
**Solution**: 
1. Verify server is running (check terminal)
2. Check browser console for JavaScript errors (F12)
3. Verify URL is exactly: `http://localhost:3000/input.html`

---

## What Was Fixed

### Bug 1: Dropdown Closes Immediately ✓ FIXED
- Dropdown menu now opens and stays open
- Can select items
- Closes properly on outside click

### Bug 2: Loading Overlay Never Disappears ✓ FIXED
- Initialization error is caught gracefully
- Loading overlay always disappears
- App always initializes

### Bug 3: Model Scan Doesn't Update UI ✓ FIXED
- Scan button properly updates dropdown
- New models appear immediately
- UI re-renders after scan

### Bug 4: Theme Overlay Blocks Clicks ✓ FIXED
- Overlay uses `pointer-events: none`
- All buttons and dropdowns remain clickable
- Layout adjusts properly for visibility

---

## File Descriptions

| File | Purpose |
|------|---------|
| `input.html` | Fixed web application |
| `run_tests.ps1` | Windows automated test suite |
| `run_tests.sh` | Linux/macOS automated test suite |
| `setup.sh` | Environment setup script |
| `README.md` | Comprehensive documentation |
| `CHANGELOG.md` | Detailed change log |
| `QUICKSTART.md` | This file |

---

## Support

For detailed technical information, see `README.md`.
For a list of all changes, see `CHANGELOG.md`.

All bugs are fixed and tested. Enjoy the working WebUI mock!
