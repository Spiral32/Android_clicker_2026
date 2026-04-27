# AI_STAGE10_MASTER_PLAN.md

## 🎯 Goal
Full Scenario Storage + Execution system with:
- CRUD (max 50, unique names)
- Step editor (full edit + per-step delay default 1s)
- Execution (SINGLE / BATCH)
- Scheduler (skip stale, no catch-up)
- Quick Launch (floating button)
- Import/Export (JSON)
- RU/EN localization
- Logging (DEBUG/INFO/ERROR)

---

# 🧠 GLOBAL RULES
- No parallel execution
- StateMachine mandatory
- Confirm destructive actions
- No hardcoded strings (ARB only)

---

# 🖥️ UI
- Only "Scenarios"
- Removed: "Execution", "Recorder"
- Table:
[Select All] | ⚡ | ON | Name | Steps | ▶ | ↑↓

---

# ⚡ QUICK LAUNCH
- Runs selected scenarios (checkbox)
- Order = orderIndex
- Fallback → message

---

# ⚙️ SETTINGS
- Open app after execution
- Global / per-step delay

---

# STAGES

## 10.1 Data
- Entities
QA:
- 50 max
- unique names

## 10.2 Repository
QA:
- validation enforced

## 10.3 Domain
QA:
- empty rejected

## 10.4 Execution
QA:
- batch order
- no parallel

## 10.5 UI
QA:
- reorder persists

## 10.5.1 Step Editor
QA:
- edit works

## 10.6 Quick Launch
QA:
- multi run correct

## 10.7 Scheduler
QA:
- skip stale

## 10.8 Import/Export
QA:
- JSON valid

## 10.9 WebSocket
QA:
- reject executing

## 10.10 Logging
QA:
- logs exist

## 10.11 Settings
QA:
- applied correctly

---

# EDGE CASES
- delete during execution
- reorder during execution
- import during execution
- app kill

---

# RESULT
- stable execution
- safe scheduler
- correct quick launch
