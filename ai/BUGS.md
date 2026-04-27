[2026-04-12]
Issue:
Real Flutter/Android build verification was not executed.
Reason:
The environment constraints explicitly forbid CLI commands required for build and runtime validation.

[2026-04-12]
Issue:
Manual scaffolding may still require generated Flutter platform files before device deployment.
Reason:
`flutter create` could not be used under the anti-hang restrictions.
[2026-04-15]
Issue:
Fullscreen CONTINUOUS recorder blocks underlying app interaction.

Status:
Architecture-level limitation identified. No longer treated as the target production UX.

Resolution path:
- move Stage 4 to non-blocking step-by-step capture
- remap legacy `CONTINUOUS` requests to the non-blocking recording mode
- continue refining point capture UX instead of fullscreen raw pass-through recording

[2026-04-15]
Issue:
After stopping recorder from overlay controls, pressing "Open recording panel" again may fail to reopen the recorder.

Cause:
- recorder UI cleanup completed successfully
- but state machine could remain in `RECORDING`
- next start request was then blocked by state validation

Resolution:
- propagate overlay stop back into service-level state transition
- ensure `RECORDING -> IDLE` happens when stop is requested from recorder overlay

[2026-04-15]
Issue:
The point-capture recorder panel can obstruct target UI while choosing actions.

Status:
Resolved in current direction.

Resolution:
- keep the panel floating
- add a visible drag handle so the operator can move the panel away before selecting capture points
- keep the deprecated overlay status card hidden to avoid duplicate status messaging on the main screen

[2026-04-21]
Issue:
Opening Settings screen could freeze/crash after localization refactor.

Cause:
- async diagnostics loader used localization API variant unavailable in current generated localization class
- malformed method braces around diagnostics handlers after incremental edits

Resolution:
- switched Settings async handlers to use compatible localization access
- fixed method boundaries in `diagnostics_settings_page.dart`
- re-generated l10n and validated diagnostics screen compile path

[2026-04-21]
Issue:
Settings log viewer displayed "Логи отсутствуют" even when logging had worked before app restart.

Cause:
- UI requested only in-memory log buffer
- buffer is process-lifetime state and can be empty after restart
- existing log file still contained valid records, but was not used for display fallback

Resolution:
- added `LogManager.getLogsForDisplay()` to return buffer first and fallback to current log file tail
- switched `MainActivity` `getLogs` method channel handler to use display fallback API
- validated Android compile path after fix

[2026-04-23]
Issue:
WebSocket section in Settings could stay in loading state for too long on some devices.

Cause:
- `getWebSocketStatus` built local URLs by scanning network interfaces synchronously
- network interface enumeration can stall and delay MethodChannel response

Resolution:
- moved local IPv4 resolution to background cache refresh in `WebSocketServerManager`
- `getWebSocketStatus` now returns cached addresses immediately (non-blocking)
- trigger address refresh on init and server start

[2026-04-23]
Issue:
WebSocket Settings section could remain in endless loading state.

Cause:
- `_loadStatus()` was called from `initState()`
- localization lookup was executed before `try/catch` in that method, so early context-dependent failure could abort the flow before `_isLoading` reset

Resolution:
- moved localization lookup out of pre-`try` path
- hardened `_formatWebSocketError()` with safe fallback text even when localization is temporarily unavailable
- kept timeout/error path deterministic so loader always exits
