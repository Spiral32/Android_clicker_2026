# Settings Storage Contract

## Stage 11 Scope

This document defines which settings are persisted, where they live, and which layer owns them.

## Flutter-Owned Settings

Storage:
- `SharedPreferences` file managed by Flutter plugin (`FlutterSharedPreferences`)

Keys:
- `app_locale`
- `execution_delay_ms`

Contract:
- `app_locale` stores the Flutter locale language code (`ru`, `en`)
- `execution_delay_ms` stores execution delay in milliseconds
- `execution_delay_ms` is normalized to the safe UI/runtime range `1000..120000`
- invalid or missing values fall back to `AppSettings.initial()`

Owner:
- `SharedPrefsSettingsRepository`

Consumers:
- `SettingsBloc` for locale
- `MainScreenBloc` for execution delay

## Native-Owned Settings

Storage:
- Android `SharedPreferences`

Keys and owners:
- `flutter.autostart_enabled` in `FlutterSharedPreferences`
  - owner: `MainActivity`
- `flutter.websocket_enabled` in `FlutterSharedPreferences`
  - owner: `WebSocketServerManager`
- `flutter.websocket_port` in `FlutterSharedPreferences`
  - owner: `WebSocketServerManager`
- `flutter.websocket_token` in `FlutterSharedPreferences`
  - owner: `WebSocketServerManager`
- `logging_enabled` in `progset_logging`
  - owner: `LogManager`
- `log_to_file_enabled` in `progset_logging`
  - owner: `LogManager`

Contract:
- Flutter reads/writes native-owned settings only through typed `PlatformBridgeRepository` methods
- Flutter `AppSettings` must not mirror native runtime-only settings
- WebSocket status in Flutter is a typed runtime snapshot (`WebSocketStatus`), not persisted Flutter settings state

## Hardening Rules

- Keep one owner per persisted key
- Normalize persisted values at repository boundary before exposing them to UI
- Add new user-facing settings to this document when Stage 11 expands
