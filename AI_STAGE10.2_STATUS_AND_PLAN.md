# AI_STAGE10.2 Status And Plan

Source brief:
- [AI_STAGE10.2.md](/d:/_Other/_MyProject/Android/Clicker/new3/AI_STAGE10.2.md)

Note:
- This document is an implementation analysis of the newly added Stage 10 master brief.
- Official AI memory currently records Stage 10 and Stage 11 as completed.
- This file is treated as a follow-up product gap checklist, not as the official active stage marker by itself.

## Current Status

Legend:
- [x] implemented in code and already confirmed earlier
- [~] implemented or partially implemented, but needs targeted QA or product alignment
- [ ] not implemented yet

### Global Rules
- [x] No parallel execution
- [x] StateMachine mandatory
- [x] Confirm destructive actions
- [x] No hardcoded strings in the active flows

### UI
- [~] "Scenarios" table exists with `[Select All] | quick launch | ON | Name | Steps | Run | Reorder`
- [ ] Only "Scenarios" remains in UI
- [ ] "Execution" and "Recorder" flows removed from the main screen

Why not complete:
- `MainScreenPage` still has an `Overview` tab with recorder/overlay/runtime controls.

### Quick Launch
- [x] Runs selected scenarios
- [x] Order follows `orderIndex`
- [x] Empty selection shows fallback message

### Settings
- [~] Global delay exists and is persisted
- [~] App restore after execution exists as runtime behavior
- [ ] "Open app after execution" as an explicit user setting
- [ ] Per-step delay editing with default `1s`

Why not complete:
- restore-after-execution is implemented natively, but not exposed as a configurable settings toggle
- per-step delay cannot be edited because editable step models do not exist in Flutter yet

### Stage 10.1 Data
- [x] Max 50 scenarios enforced
- [x] Unique names enforced

### Stage 10.2 Repository
- [x] Validation enforced

### Stage 10.3 Domain
- [x] Empty scenario rejected

### Stage 10.4 Execution
- [x] Batch order implemented
- [x] Parallel execution blocked

### Stage 10.5 UI
- [~] Reorder logic implemented and persisted in storage
- [~] Restart persistence was previously tracked as QA-sensitive, not explicitly re-confirmed against this new brief

### Stage 10.5.1 Step Editor
- [ ] Full step editor
- [ ] Per-step editing
- [ ] Per-step delay support

Architectural gap:
- Flutter currently stores `ScenarioItem` metadata only
- native recorded actions are stored in `ScenarioActionStore`
- there is no Flutter-side editable `ScenarioStep` model or update API yet

### Stage 10.6 Quick Launch
- [x] Multi-run behavior implemented

### Stage 10.7 Scheduler
- [x] Skip stale implemented

### Stage 10.8 Import/Export
- [x] JSON import/export implemented
- [x] Native actions included in transferred payload

### Stage 10.9 WebSocket
- [x] Reject while executing implemented

### Stage 10.10 Logging
- [x] Scenario logs exist

### Stage 10.11 Settings
- [~] Applied correctly for current global settings
- [ ] Applied correctly for the new product asks from this brief

### Edge Cases
- [ ] Delete during execution explicitly guarded
- [ ] Reorder during execution explicitly guarded
- [ ] Import during execution explicitly guarded
- [~] App kill behavior is partially covered by existing persistence, but not closed against this brief

## Priority Order

### Priority 1
- Step editor architecture and editable step contract
- Execution-time guards for delete/reorder/import

### Priority 2
- Step editor UI
- Per-step delay support
- Product decision for "Open app after execution" toggle vs fixed behavior

### Priority 3
- UI cleanup to align with "Only Scenarios"
- Final QA sweep for restart/app-kill behavior

## Implementation Plan

### Phase 1: Lock Product Contract
- [x] Decide whether `AI_STAGE10.2.md` should reopen official Scenario work or be treated as a Stage 12/12.x backlog item
- [ ] Decide whether "Open app after execution" stays always-on or becomes a persisted toggle
- [x] Define editable step model fields

Output:
- one agreed contract document
- no ambiguity before code changes begin

### Phase 2: Step Model And Bridge
- [x] Add Flutter-side `ScenarioStep` domain model
- [x] Add typed bridge methods to read scenario actions from native storage
- [x] Add typed bridge methods to replace scenario actions after edit
- [x] Extend import/export compatibility to preserve per-step delay
- [ ] Keep backward compatibility with older action payloads that do not contain per-step delay

Verification:
- [ ] Can load existing scenario actions into Flutter editor state
- [ ] Can save modified actions back to native store
- [ ] Old imported JSON still works

### Phase 3: Scenario Editor UI
- [x] Add scenario editor screen/dialog
- [x] Show step list for a scenario
- [x] Support step edit/delete/reorder
- [x] Support per-step delay with default `1000 ms`
- [x] Update scenario `stepCount` after edits

Verification:
- [ ] Step count updates correctly
- [ ] Edited scenario still executes
- [ ] Reordered steps execute in edited order

### Phase 4: Execution Safety Guards
- [x] Block scenario delete during execution
- [x] Block scenario reorder during execution
- [x] Block scenario import during execution
- [x] Surface localized messages for blocked actions

Verification:
- [ ] Delete is rejected while a batch is active
- [ ] Reorder is rejected while a batch is active
- [ ] Import is rejected while a batch is active

### Phase 5: Settings/Product Alignment
- [ ] Implement explicit "Open app after execution" toggle if the product decision requires it
- [ ] Otherwise document fixed restore behavior as intentional and mark the brief accordingly
- [ ] Ensure global delay and per-step delay semantics are clearly separated in UI

Verification:
- [ ] Global delay still affects execution
- [ ] Per-step delay is applied per edited step
- [ ] Restart persistence works for new settings if a new toggle is introduced

### Phase 6: UI Alignment Cleanup
- [ ] Decide whether to remove the Overview tab or reinterpret the brief for the current architecture
- [ ] If required, move remaining needed recorder/runtime actions into Settings or scenario-focused flows
- [ ] Keep permissions/runtime support usable after the cleanup

Verification:
- [ ] Main screen matches final approved information architecture
- [ ] Scenario flows remain usable on device

### Phase 7: QA And Closure
- [ ] Reorder persists after restart
- [ ] Delete/reorder/import guards behave correctly during execution
- [ ] App kill / restart behavior documented
- [ ] Import/export with edited steps confirmed
- [ ] Update AI memory and changelog after each completed phase

## Suggested Work Log Format

Use this format while implementing:

- Date:
- Phase:
- Change:
- Result:
- Verification:
- Memory updated:

## First Recommended Slice

Start with Phase 1 plus Phase 2 contract groundwork.

Reason:
- the biggest unresolved gap is not UI polish, but the missing editable step model
- without that contract, any Step Editor UI would be a throwaway layer
- execution guards are smaller and can be implemented immediately after the contract is stable
