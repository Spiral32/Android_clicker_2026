# WebSocket API

## Planned Transport

- WSS only
- TLS mandatory
- One active client connection

## Planned Commands

- start
- stop
- status
- upload_script
- get_log
- ping

## Stage 1

Runtime WebSocket server is not implemented yet.
# Stage Status

WebSocket API is not part of the active implementation stage.

Official stage mapping:
- current active stage: `Stage 5 — State Machine Hardening`
- WebSocket belongs to `Stage 10 — WebSocket Server`
- any mentions of WebSocket in code or docs are planning notes until Stage 10 becomes active

# Activation Rule

Stage 10 may begin only after completion of:
- Stage 5 — State Machine Hardening
- Stage 6 — Execution Engine Hardening
- Stage 7 — Screenshot Verifier Integration
- Stage 8 — Scheduler
- Stage 9 — Autostart

Until then, this document defines a planned interface only and must not be treated as production-ready scope.
