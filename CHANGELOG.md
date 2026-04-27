# Changelog

## 2026-04-27

- Finalized the Stage 11 settings storage contract in `docs/SETTINGS_STORAGE_CONTRACT.md`.
- Hardened settings persistence by normalizing restored/saved execution delay values to the supported range.
- Synced `MainScreenBloc` execution-delay state with the normalized repository result instead of trusting raw input.
- Restored the exact-alarm settings section in the main Settings page and grouped it with runtime/scheduler controls.
- Confirmed Stage 11 settings flow works on device, including restart persistence validation.
- Fixed scenario queue reordering persistence by correcting order normalization logic.
- Fixed potential app crash during settings/log export by removing hardcoded export path usage and making platform export arguments safe.
- Fixed Android crash during scenario JSON export by switching export to temporary-file generation plus system share flow.
- Extended scenario JSON import/export to include native recorded actions so transferred scenarios remain executable.
- Cleared native scenario action storage on scenario delete and blocked metadata-only scenario creation when native binding fails.
- Confirmed Stage 10 scenario export works on real device and moved official project memory to Stage 11.
- Added critical-path logging for log export calls and scheduler scenario-name loading errors/success.
- Expanded structured logging (`action` + `payload`) for scheduler CRUD flows and scenario import/export/create entry points.
- Moved WebSocket settings orchestration into `SettingsBloc` and replaced raw Flutter map handling with a typed `WebSocketStatus` model.
- Redesigned main screen layout into clearer status and action cards to improve readability.
- Rebuilt the main screen into tabbed navigation (`Overview` / `Scenarios`) to eliminate large bottom overflow and restore clear scenario workspace.
- Moved scenario import/export controls into the bottom of Settings and removed duplicate access from the main screen.
- Added scenario selection in scheduler form and displayed selected scenario name directly in scheduler list items.
- Added localization keys for new main-screen status labels and scheduler scenario prefix (`ru`/`en`).
- Localized scheduler-form scenario picker labels and validation messages (`ru`/`en`).
