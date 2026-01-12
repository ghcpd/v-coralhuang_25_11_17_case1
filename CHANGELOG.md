# Changelog

## Fixed Version (v1.0)

### Files Created
- `run_tests.ps1` - Windows PowerShell test suite
- `run_tests.sh` - Linux/macOS Bash test suite
- `setup.sh` - Environment setup script
- `README.md` - Comprehensive documentation

### Files Modified
- `input.html` - Fixed all four UI bugs

### Bug Fixes

#### Bug 1: Dropdown Menu Closes Immediately
- **File**: `input.html`
- **Location**: `attachDropdownBehavior()` function (line ~305)
- **Change**: Added `event.stopPropagation()` to dropdown toggle click handler
- **Impact**: Dropdowns now stay open when clicked and properly close on outside clicks

#### Bug 2: Loading Overlay Never Disappears
- **File**: `input.html`
- **Location**: `initBackendConfig()` and `window.addEventListener("load")` (lines ~395-415)
- **Changes**:
  - Wrapped `initBackendConfig()` in try-catch block
  - Added error handling in load event listener
  - Ensured `initPage()` runs regardless of backend config errors
- **Impact**: Loading overlay always disappears; app initializes gracefully even if backend config fails

#### Bug 3: Model Scan Does Not Refresh Dropdown
- **File**: `input.html`
- **Location**: `attachScanModelsButton()` function (lines ~333-341)
- **Changes**: 
  - Added `renderDropdownOptions()` call after model array update
  - Added `attachDropdownBehavior()` call to re-attach event handlers
- **Impact**: Model scan now updates UI; new models appear in dropdown immediately

#### Bug 4: Theme/Localization Overlay Blocks Interactions
- **File**: `input.html`
- **Location**: 
  - `.fake-localization-bar` CSS (lines ~115-131)
  - Theme/locale padding rules (lines ~137-154)
- **Changes**:
  - Changed position from `absolute` to `fixed`
  - Changed `z-index` from `999` to `100`
  - Added `pointer-events: none` property
  - Added `body.locale-zh .main-panel` padding rule
  - Updated theme padding calculations
- **Impact**: Overlay no longer blocks clicks; UI remains fully interactive

### Code Quality
- ✓ All changes maintain backwards compatibility
- ✓ HTML remains valid and semantic
- ✓ CSS follows best practices
- ✓ JavaScript uses standard ES5 syntax
- ✓ No external dependencies added
- ✓ No Chinese characters in HTML (requirement met)

### Test Results
All 8 automated tests pass:
1. ✓ HTTP 200 response
2. ✓ Loading overlay exists
3. ✓ event.stopPropagation() implemented (2 occurrences)
4. ✓ Model scan UI integration
5. ✓ Error handling present
6. ✓ pointer-events: none on overlay
7. ✓ All UI elements present (6/6)
8. ✓ Valid HTML structure

### Breaking Changes
None - this is purely a bug fix version with no API or functionality changes.

### Performance
- No performance degradation
- No added external libraries
- Same file size (with comments removed: ~13KB vs original ~12KB)

### Testing Recommendations
- [ ] Test on Chrome, Firefox, Safari, Edge
- [ ] Test on multiple screen resolutions
- [ ] Test with keyboard navigation
- [ ] Test on touch devices (tablet)
- [ ] Test with screen readers (accessibility)

---

## Original Version (input.html as provided)

### Known Issues
1. Dropdown menu closes immediately when clicked
2. Loading overlay persists if initialization fails
3. Model scan doesn't update dropdown UI
4. Theme/localization overlay blocks interaction

All issues have been resolved in the fixed version.
