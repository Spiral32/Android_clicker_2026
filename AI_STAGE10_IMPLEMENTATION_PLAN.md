# AI_STAGE10_IMPLEMENTATION_PLAN.md

## 🎯 Goal
Implement full Scenario Storage system with:
- Scenario CRUD
- Execution integration
- Scheduler integration
- Quick Launch (floating button)
- Import / Export
- Full RU/EN localization
- Strict StateMachine compliance

---

# 🧩 STAGE BREAKDOWN

## Stage 10.1 — Data Layer (Room)
Tasks:
- ScenarioEntity, StepEntity, ScheduleEntity
Requirements:
- max 50 scenarios, unique name, quickLaunchEnabled, orderIndex
Exit:
- persistence after restart
Tests:
- 50 ok, 51 fail; duplicate reject

## Stage 10.2 — Repository
- CRUD + validation
Exit:
- no direct DB from UI

## Stage 10.3 — Domain
- ScenarioModel + validation
Rule:
- empty scenario rejected

## Stage 10.4 — Execution
- SINGLE / BATCH
Rules:
- one execution only
- batch snapshot
- continue on error
Conflict:
IF EXECUTING:
- Scheduler SKIP
- WebSocket REJECT
- UI BLOCK
- Floating STOP

## Stage 10.5 — UI
- ListView.builder
Table:
[Select All] | ⚡ | ON | Name | Steps | ▶ | ↑↓

## Stage 10.6 — Quick Launch
- runs quickLaunchEnabled ordered
Fallback:
- none → message

## Stage 10.7 — Scheduler
- skip EXECUTING
- skip stale
- no retry

## Stage 10.8 — Import/Export
- JSON
- validate max + unique

## Stage 10.9 — WebSocket
Commands:
- start_single, start_batch, get_scenarios
Rule:
- reject if EXECUTING

## Stage 10.10 — Logging & QA
Logs:
[SCENARIO], [EXECUTION], [SCHEDULER], [ERROR]
Tests:
- reorder persists
- quick launch correct
- scheduler skip
- batch order

---

# GLOBAL RULES
- RU/EN only via ARB
- no parallel execution
- state machine mandatory
- confirm destructive actions
