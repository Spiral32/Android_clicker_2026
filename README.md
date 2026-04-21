# Prog Set Touch

Production-grade Android automation engine with Flutter UI and Kotlin platform integration.
The application records touch gestures, executes scenarios, works through Accessibility, overlay windows and MediaProjection-based flows.

**Target:** Android 9+ (API 28+)  
**Architecture:** Flutter + BLoC + Kotlin platform layer + state machine

---

## Текущее состояние проекта

Проект ведётся по строгой линейной этапности: в каждый момент времени активен только один stage.

Официально завершённые этапы:
- Stage 1 — оболочка приложения
- Stage 2 — система разрешений
- Stage 3 — overlay system
- Stage 4 — recorder system

## Текущий этап

**Текущий официальный этап: Stage 5 — State Machine Hardening**

Это означает:
- Stage 6 и выше ещё не считаются активными этапами
- Даже если часть кода для execution или screenshot verifier уже существует, это пока задел, а не завершённый этап
- Вся текущая разработка должна подчиняться целям Stage 5

Критерии завершения текущего этапа:
- все recorder/execution операции обязаны проходить через корректные state checks
- все критические переходы состояния должны быть детерминированными
- Flutter UI должен получать актуальное native state после ключевых действий
- lifecycle-сбои не должны оставлять приложение в невалидном состоянии

---

## Что уже реализовано

### Stage 1 — Оболочка приложения
- Material 3 UI
- BLoC state management
- RU/EN локализация
- Android MethodChannel bridge
- Главный экран и экран настроек

### Stage 2 — Разрешения
- Проверка Accessibility Service
- Проверка overlay permission
- Запрос MediaProjection
- Обновление permission state при возврате приложения в foreground

### Stage 3 — Overlay system
- Управление overlay через AccessibilityService
- Синхронизация статуса overlay между Kotlin и Flutter
- Защита от запуска рекордера без активного overlay

### Stage 4 — Recorder system
- Запуск и остановка записи
- Передача recorder summary в Flutter
- Подсчёт tap / double tap / long press / swipe
- Поддержка `CONTINUOUS` и `POINT_CAPTURE`
- Базовая подготовка под multi-touch сценарии

### Stage 5 — State machine (частично)
Состояния:
- `IDLE`
- `RECORDING`
- `EXECUTING`
- `PAUSED`
- `ERROR`

Что уже есть:
- базовая модель состояний
- валидация переходов
- reset / error flow
- bridge состояния в Flutter

Что ещё нужно:
- жёсткое применение state checks ко всем операциям платформенного слоя
- дополнительная защита от race conditions

### Stage 6 — Execution engine
Что уже есть:
- start / stop / pause / resume execution
- execution summary в Flutter
- связка execution flow с текущим состоянием приложения

Статус этапа:
- ещё не активен официально

Что будет входить в этап:
- production-hardening последовательности выполнения
- watchdog
- дополнительная защита от зависаний и неконсистентного state

### Stage 7 — Screenshot verifier
Что уже есть:
- native verifier module
- вызов screenshot verification через bridge

Статус этапа:
- ещё не активен официально

Что будет входить в этап:
- оптимизация CPU-нагрузки
- безопасная lifecycle-интеграция
- более плотная интеграция в execution pipeline

---

## Текущий технический фокус

- Устранение race conditions между Flutter и native слоем
- Усиление state machine enforcement
- Защита lifecycle вокруг MediaProjection
- Удаление debug-поведения из production UI
- Выравнивание bridge-контрактов между Flutter и Kotlin
- Стабилизация recorder/execution flow только в пределах целей Stage 5
- Максимально подробное логирование для диагностики
- Просмотр и экспорт логов в `Download`
- Аудит корректности Stage 2-4

---

## Что ещё не доведено до production

- Scheduler / autostart
- WebSocket server
- Persistent scenario storage
- Полноценная persistence для настроек
- Расширенные execution safeguards

---

## Структура проекта

```text
lib/
  features/
    main_screen/          # Основной UI, permissions, recorder/execution state
    settings/             # Настройки приложения
  core/
    constants/
    di/
    error/
    localization/
    utils/

android/app/src/main/kotlin/com/progsettouch/app/
  MainActivity.kt
  ProgSetAccessibilityService.kt
  OverlayManager.kt
  RecorderManager.kt
  PointCaptureManager.kt
  StateMachine.kt
  ExecutionEngine.kt
  ScreenshotVerifier.kt

docs/
  ARCHITECTURE.md
  PERMISSIONS.md
  API_WEBSOCKET.md
```
