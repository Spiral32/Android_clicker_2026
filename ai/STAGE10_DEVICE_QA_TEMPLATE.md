# Stage 10 Device QA Template

Date:
Device:
Build/Branch:
Tester:

Legend:
- PASS = works as expected on real device
- FAIL = does not meet expected behavior
- N/A = not applicable for this run

## 10.1 Data Layer

- [ ] PASS / [ ] FAIL / [ ] N/A - Create scenario -> persists in storage.
- [ ] PASS / [ ] FAIL / [ ] N/A - Restart app -> created scenario still exists.
- [ ] PASS / [ ] FAIL / [ ] N/A - Create up to 50 scenarios allowed, 51st rejected.
- [ ] PASS / [ ] FAIL / [ ] N/A - Duplicate name rejected.
- [ ] PASS / [ ] FAIL / [ ] N/A - Reorder persists after restart.

Notes:

## 10.2 Repository + 10.3 Domain

- [ ] PASS / [ ] FAIL / [ ] N/A - Empty scenario rejected.
- [ ] PASS / [ ] FAIL / [ ] N/A - Invalid import items rejected.
- [ ] PASS / [ ] FAIL / [ ] N/A - Name uniqueness/limit validation works.

Notes:

## 10.4 Execution

- [ ] PASS / [ ] FAIL / [ ] N/A - SINGLE run starts correct scenario.
- [ ] PASS / [ ] FAIL / [ ] N/A - BATCH runs in expected order.
- [ ] PASS / [ ] FAIL / [ ] N/A - If one scenario fails, batch continues.
- [ ] PASS / [ ] FAIL / [ ] N/A - Parallel execution is blocked.

Notes:

## 10.5 UI

- [ ] PASS / [ ] FAIL / [ ] N/A - Scenario list renders correctly.
- [ ] PASS / [ ] FAIL / [ ] N/A - Reorder UI works and persists.
- [ ] PASS / [ ] FAIL / [ ] N/A - Select All tri-state works.
- [ ] PASS / [ ] FAIL / [ ] N/A - Main screen controls do not overlap on small screen.

Notes:

## 10.6 Quick Launch

- [ ] PASS / [ ] FAIL / [ ] N/A - Quick Launch runs selected scenarios only.
- [ ] PASS / [ ] FAIL / [ ] N/A - No selection -> user message shown.
- [ ] PASS / [ ] FAIL / [ ] N/A - Ignores ON/OFF switch as designed.

Notes:

## 10.7 Scheduler

- [ ] PASS / [ ] FAIL / [ ] N/A - Scheduler trigger skipped while EXECUTING.
- [ ] PASS / [ ] FAIL / [ ] N/A - Stale triggers skipped.
- [ ] PASS / [ ] FAIL / [ ] N/A - No unintended retry loop.

Notes:

## 10.8 Import/Export

- [ ] PASS / [ ] FAIL / [ ] N/A - Export creates valid JSON file.
- [ ] PASS / [ ] FAIL / [ ] N/A - Import validates max count and unique names.
- [ ] PASS / [ ] FAIL / [ ] N/A - Invalid JSON import rejected with message.

Notes:

## 10.9 WebSocket

- [ ] PASS / [ ] FAIL / [ ] N/A - `start_single` works.
- [ ] PASS / [ ] FAIL / [ ] N/A - `start_batch` works.
- [ ] PASS / [ ] FAIL / [ ] N/A - Commands rejected if execution already running.
- [ ] PASS / [ ] FAIL / [ ] N/A - `get_scenarios` returns expected list.

Notes:

## 10.10 Logging

- [ ] PASS / [ ] FAIL / [ ] N/A - Action logs visible with `[SCENARIO]`.
- [ ] PASS / [ ] FAIL / [ ] N/A - Error logs visible with `[ERROR][SCENARIO]`.
- [ ] PASS / [ ] FAIL / [ ] N/A - Logs include useful action context.

Notes:

## Final Result

- [ ] Stage 10 accepted on this device run
- [ ] Stage 10 has blocking issues

Blocking issues:
