Changelog - v-coralhuang_25_11_17_case1

Files created/edited:
- index.html (created/edited) - fixed UI issues described below
- setup.sh (created) - environment setup (virtualenv, pip installs, Playwright)
- run_tests.sh (created) - starts server, runs tests
- requirements.txt (edited) - includes pytest, requests and playwright
- tests/test_ui.py (created) - Playwright-based UI test (fallback to basic checks if browsers are not available)

Fixed bugs:
1) Dropdown interaction bug: global click handler now hides menus only on outside clicks and toggles stop propagation; clicking a dropdown no longer closes it immediately.
2) Loading overlay never disappears: backend config initialization is guarded; errors logged instead of stopping init, ensuring the loading overlay hides when ready.
3) Model scan does not refresh dropdown options: Scan button re-renders dropdown after updating the internal array to show new models.
4) Theme/localization overlay blocks controls: fake overlay uses pointer-events: none and a reduced z-index; layout adjustment uses `body.locale-zh .main-panel` so it doesn't interfere with controls.

How to run:
- ./setup.sh  # prepares the virtualenv and installs dependencies
- ./run_tests.sh  # starts server and runs automated tests
- Open http://localhost:3000 in a browser to manually verify UI interactions.

Notes:
- The automated tests use Playwright if present in the environment; otherwise they run a fallback static server check.
- The page references mock data and intentionally simulates the WebUI-like UI for demonstration and testing purposes.
