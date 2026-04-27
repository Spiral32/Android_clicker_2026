# Notes

- Fixed app crash during settings/log export by using safe platform export flow without forcing a hardcoded storage path.
- Redesigned the main screen structure: platform status and scenario actions are now grouped into clearer cards.
- Rebuilt main screen navigation into two tabs (`Overview` / `Scenarios`) to prevent vertical overflow and keep scenario tools always reachable.
- Moved scenario import/export controls from main screen to the bottom of Settings for clearer workflow placement.
- Added visible selected scenario label in scheduler list items to avoid ambiguity.
- Localized new UI labels on main screen and scheduler (`ru`/`en`).
- Localized scheduler form scenario field and validation messages (`ru`/`en`) to remove remaining hardcoded strings.
- Fixed Android crash during scenario JSON export by using temporary file generation plus system share flow.
- Scenario import/export now includes native recorded actions, so imported scenarios remain executable.
- Stage 10 is closed; the next official active stage is Stage 11 (`Settings Persistence and Advanced Configuration`).
