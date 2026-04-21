# ROADMAP

## Назначение проекта

**Prog Set Touch** — Android automation engine с Flutter UI и Kotlin platform layer.

Основная задача программы:
- записывать touch-жесты
- исполнять сценарии действий
- работать через Accessibility, overlay и MediaProjection

---

### Stage 5 — State Machine Hardening
- все recorder/execution entry points проверяют state перед выполнением
- invalid transitions блокируются везде одинаково
- `ERROR -> IDLE` reset работает детерминированно
- после start/stop/pause/resume Flutter всегда получает актуальное native state
- lifecycle edge cases не оставляют приложение в неконсистентном состоянии
- логи можно включить, просмотреть и экспортировать из UI
- результаты проверки Stage 2-4 зафиксированы в документации и задачах

---

## Текущий официальный этап

### Stage 6 — Execution Engine Hardening
- гарантирована жёсткая последовательность выполнения жестов
- реализована надёжная остановка (stop) и пауза (pause)
- Watchdog: защита от зависаний жестов и тайм-аут всего сценария
- детальный статус выполнения во Flutter (индекс текущего действия)
- защита от "разъезда" состояния выполнения
- сохранение сценариев в постоянную память устройства
- защита от пустой перезаписи (backup/restore пустых записей)

---

## Что будет следующим

### Stage 7 — Scheduler

Начинается только после полного завершения `Stage 6`.

В него входит:
- планировщик задач для автоматизации
- управление расписанием выполнения сценариев
- интеграция с системными событиями для запуска автоматизации

---

## Дальнейшие этапы

### Stage 8 — Autostart
### Stage 9 — WebSocket Server
### Stage 10 — Scenario Storage
### Stage 11 — Settings Persistence and Advanced Configuration
### Stage 12 — Screenshot Verifier Integration

---

## Правило проекта

У проекта всегда только **один активный stage**.

Следующий stage нельзя начинать официально, пока не выполнены критерии завершения текущего stage.
