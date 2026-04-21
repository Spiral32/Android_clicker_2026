# AI Changelog

## 2026-04-12 — Stage 1-4 Complete

- Stage 1: Application scaffold with Material 3, BLoC, RU/EN localization
- Stage 2: Permission gate (Accessibility, Overlay, MediaProjection)
- Stage 3: Separated Overlay System (Control + Recording overlays)
- Stage 4: RecorderManager with CONTINUOUS/POINT_CAPTURE modes, GestureActionClassifier, multi-touch support, visual feedback

## 2026-04-13 — ТЗ Updated

- Aligned with FINAL PRODUCTION ТЗ
- Updated README with full specification
- Updated ARCHITECTURE with State Machine and layer structure
- Next: Stage 5 State Machine → Stage 6 Execution Engine

---

## Roadmap

### ✅ Implemented
- [x] Stage 1: Shell (Material 3, BLoC, Localization)
- [x] Stage 2: Permission System
- [x] Stage 3: Overlay System (Control + Recording)
- [x] Stage 4: Recorder (CONTINUOUS, POINT_CAPTURE, multi-touch, visual feedback)

### 🚧 Planned (per ТЗ)
- [ ] Stage 5: State Machine (IDLE, RECORDING, EXECUTING, PAUSED, ERROR)
- [ ] Stage 6: Execution Engine (gesture playback, watchdog)
- [ ] Stage 7: Screenshot Verifier (downscaled diff, FPS limit)
- [ ] Stage 8: Scheduler (cyclic, one-shot timers)
- [ ] Stage 9: Autostart (AlarmManager, BOOT_COMPLETED)
- [ ] Stage 10: WebSocket Server (Ktor CIO, WSS, token auth)
- [ ] Stage 11: Scenario Storage (SQLite/Room)
- [ ] Stage 12: Settings (anti-detect, retry config)
- [ ] Stage 13: Additional (DPI scaling, Dry Run)
## 2026-04-15

- Documentation stage model normalized to a strict single-active-stage flow
- Official current project stage fixed as `Stage 5 — State Machine Hardening`
- `ai/TASKS.md` updated with stage policy, entry/exit criteria, and explicit next-stage order
- `README.md` translated and aligned to the official stage model
- `docs/ARCHITECTURE.md` updated with stage governance and official sequencing
- `docs/PERMISSIONS.md` updated to clarify its role as completed Stage 2 scope
- `docs/API_WEBSOCKET.md` updated to clarify that WebSocket is planned Stage 10 scope only
- AI memory workflow documented in `ai/DECISIONS.md` with required reading order for future sessions
- Stage 4 recording direction updated: production path is now non-blocking step-by-step capture instead of fullscreen blocking continuous recorder
- Stage 4 recorder control labels clarified to explicit step-by-step action wording in the native panel
- Fixed project memory for recorder reopen bug: overlay stop must transition state machine back to `IDLE`
- Added repository rule: AI should not delete files; obsolete files must be rewritten or marked `DEPRECATED`
- Point-capture recorder panel made explicitly draggable through a visible header handle
- Overlay-stop flow hardened with a guard to avoid duplicate recorder shutdown on state transition
- `overlay_status_card.dart` marked `DEPRECATED` and reduced to a no-op widget to keep redundant overlay messaging off the main screen
- Application automatically minimizes to home screen when "Test" execution starts and restores to foreground on completion
- Floating control overlay transforms into a red "Stop" button during execution; clicking it stops the current scenario
- "Clear recording" button now requires explicit user confirmation via a localized dialog
- Added execution delay setting (1-10s) in the Settings page, integrated with the Android execution engine
- Performed full project cleanup and build (`flutter clean`, `flutter pub get`, `flutter build apk --debug`) to verify all Stage 5 changes
- Corrected "Test" button label to "Тэст" in Russian localization per user request
