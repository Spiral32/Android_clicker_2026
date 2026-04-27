[2026-04-27]
Task:
Officially close Stage 10 and move project memory to Stage 11 after Scenario Storage validation, including working real-device JSON export/import flow.

Program essence:
- Android automation engine with Flutter UI and Kotlin platform layer
- Records touch gestures and executes action scenarios
- Works through Accessibility, overlay windows, and MediaProjection-dependent flows

Stage policy:
- Only one stage can be active at a time
- The next stage starts only after the current one satisfies its exit criteria
- Experimental/prototype code does not define official stage completion
- Official status is defined by project memory docs

Official current stage:
- Stage 11 - Settings Persistence and Advanced Configuration

Completed stages:
- Stage 1: Application shell
- Stage 2: Permission system
- Stage 3: Overlay system
- Stage 4: Recorder system
- Stage 5: State Machine Hardening
- Stage 6: Execution Engine Hardening
- Stage 7: Scheduler
- Stage 8: Autostart
- Stage 9: WebSocket Server
- Stage 10: Scenario Storage

Active stage details:
- Stage 11: Settings Persistence and Advanced Configuration
  - Scope:
    - persist user-facing settings across restart
    - harden advanced configuration flows and storage contracts
    - consolidate Flutter/native settings integration paths
    - keep settings UI localized and stable for production use
  - Entry criteria:
    - Stage 10 completed
  - Exit criteria:
    - settings data is persistently stored and restored after app restart
    - advanced configuration contract is documented
    - UI provides stable settings management flow
    - integration with native settings/runtime path is validated
    - stage results are documented in memory docs/changelog

Stage 11 implementation progress:
- [ ] Settings storage contract finalized
- [ ] Persistent settings backend audited and hardened
- [ ] Advanced configuration flows prioritized
- [ ] Real-device restart persistence verification recorded in AI memory

Stage 10 completion note (2026-04-27):
- [x] WebSocket Stage 10 commands implemented (`start_single`, `start_batch`, `get_scenarios`)
- [x] Scenario import/export implemented in UI + BLoC validation path
- [x] Added structured Scenario action logging path in Flutter (`[SCENARIO]` tag)
- [x] Added structured Scenario error logging path in Flutter (`[ERROR][SCENARIO]` tag)
- [x] Added real-device QA template for Stage 10 run (`ai/STAGE10_DEVICE_QA_TEMPLATE.md`)
- [x] Improved Main screen adaptive layout for Scenario action controls on small widths
- [x] Fixed Kotlin nullable compile issue in WebSocket Stage 10 command path
- [x] Scenario import/export now transfers native recorded actions, not only scenario metadata
- [x] Scenario deletion now clears native action storage for the removed scenario
- [x] Scenario creation now rejects metadata-only save if native action binding fails
- [x] Android JSON export crash fixed
- [x] Real-device scenario JSON export confirmed working by user on 2026-04-27
- [x] Stage 10 officially closed in AI memory

Stage 9 completion evidence:
- [x] Native Kotlin WebSocket server foundation added without external networking libraries
- [x] Single-client connection guard implemented
- [x] Token-based protected access implemented (bearer-first with legacy query fallback)
- [x] Basic JSON command protocol implemented (`ping`, `status`, `get_log`, `start`, `stop`)
- [x] MethodChannel bridge added for WebSocket settings/status control
- [x] Settings UI now exposes server toggle, port, token rotation, and connection URLs
- [x] Real-device connection verification recorded in AI memory
- [x] TLS / `WSS` hardening decision finalized for production direction

Stage 8 completion evidence:
- [x] Android permission and receiver registration (`RECEIVE_BOOT_COMPLETED`, `BootReceiver` in manifest)
- [x] Native boot handler created (`BootReceiver` restores active schedules)
- [x] Kotlin compile issues in autostart/scheduler flow resolved
- [x] Dedicated autostart setting in Flutter UI (toggle + persisted value)
- [x] Autostart control moved to active `settings_page.dart` (not only legacy diagnostics screen)
- [x] Bridge autostart setting to native layer and gate boot behavior by setting
- [x] Manual MediaProjection request path in Settings (without startup auto-prompt)
- [x] Scheduler fallback to inexact alarms when exact alarms are unavailable
- [x] Localization added for new Settings blocks/messages (autostart + MediaProjection + diagnostics)
- [x] Exact alarm controls in Settings (status + open system settings action)
- [x] Scheduler logging enhanced with `schedule_set` and `schedule_trigger` structured fields (planned/trigger/drift)
- [x] Settings open freeze regression fixed after localization update
- [x] Settings screen UI polished and diagnostics/logging section fully localized (RU/EN)
- [x] Real-device reboot verification documented (at least one successful run)
- [x] Real-device scheduled execution verified from exported logs on 2026-04-23 (`schedule_trigger`, `EXECUTING -> IDLE`, 10/10 actions completed)
- [x] Stage 8 completion progress entry added to `CHANGELOG_AI.md`

Next stages:
- Stage 11: Settings Persistence and Advanced Configuration
- Stage 12: Screenshot Verifier Integration
