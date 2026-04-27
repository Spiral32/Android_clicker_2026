AI STAGE 10 IMPLEMENTATION PLAN WITH QA CHECKLISTS
Legend:
- [x] implemented in code
- [ ] requires full runtime/device validation

Stage 10.1 Data Layer QA:
- [x] Create scenario -> persisted in storage
- [ ] Restart app -> scenario exists
- [x] Create 50 -> success; 51 -> rejected
- [x] Duplicate name -> rejected
- [x] orderIndex persists in saved model

Stage 10.2 Repository QA:
- [x] No direct DB access from UI
- [x] Validation works (unique, limit)

Stage 10.3 Domain QA:
- [x] Empty scenario not allowed
- [x] Invalid scenario rejected

Stage 10.4 Execution QA:
- [x] SINGLE works
- [x] BATCH works in order
- [x] Error in one -> continues
- [x] Parallel execution blocked

Stage 10.5 UI QA:
- [x] List loads correctly
- [ ] Reorder persists after restart
- [x] Select All works (3 states)

Stage 10.6 Quick Launch QA:
- [x] Selected scenarios run
- [x] None selected -> message
- [x] Ignores ON/OFF

Stage 10.7 Scheduler QA:
- [x] Skip if executing
- [x] Skip stale triggers
- [x] No retry

Stage 10.8 Import/Export QA:
- [x] Export JSON valid
- [x] Import validates limit and uniqueness
- [x] Android real-device JSON export no longer crashes after share-flow fix

Stage 10.9 WebSocket QA:
- [x] start_single works
- [x] start_batch works
- [x] Reject if executing

Stage 10.10 Logging QA:
- [x] Logs exist for core Scenario actions (create/update/reorder/import/run/stop)
- [x] Errors logged properly for Scenario flow (validation + platform/storage failures)
