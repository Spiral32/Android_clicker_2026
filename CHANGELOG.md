# Changelog

## 2026-04-27

- Fixed scenario queue reordering persistence by correcting order normalization logic.
- Fixed potential app crash during settings/log export by removing hardcoded export path usage and making platform export arguments safe.
- Fixed Android crash during scenario JSON export by switching export to temporary-file generation plus system share flow.
- Extended scenario JSON import/export to include native recorded actions so transferred scenarios remain executable.
- Cleared native scenario action storage on scenario delete and blocked metadata-only scenario creation when native binding fails.
- Confirmed Stage 10 scenario export works on real device and moved official project memory to Stage 11.
- Added critical-path logging for log export calls and scheduler scenario-name loading errors/success.
- Expanded structured logging (`action` + `payload`) for scheduler CRUD flows and scenario import/export/create entry points.
- Redesigned main screen layout into clearer status and action cards to improve readability.
- Rebuilt the main screen into tabbed navigation (`Overview` / `Scenarios`) to eliminate large bottom overflow and restore clear scenario workspace.
- Moved scenario import/export controls into the bottom of Settings and removed duplicate access from the main screen.
- Added scenario selection in scheduler form and displayed selected scenario name directly in scheduler list items.
- Added localization keys for new main-screen status labels and scheduler scenario prefix (`ru`/`en`).
- Localized scheduler-form scenario picker labels and validation messages (`ru`/`en`).
