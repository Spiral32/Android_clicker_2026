# WebSocket API

## Stage Status

Current official stage:
- `Stage 10 — Scenario Storage`

Current implementation status:
- Stage 9 implementation completed and carried into Stage 10 as available subsystem
- transport: `ws://` (plain WebSocket)
- auth: bearer-first token model (legacy query fallback)
- one active client connection

Notes:
- current in-app server transport is `ws://` only
- production exposure must use external TLS termination and publish `wss://` endpoint to clients
- token rotation is supported from Settings UI
- the protocol is intentionally small and operational

## Connection

Path:
- `/ws`

Authentication:
- preferred: `Authorization: Bearer <token>` header
- compatibility fallback: `?token=<token>` in query string (legacy clients)

Example:
- URL: `ws://192.168.1.10:8787/ws`
- Header: `Authorization: Bearer <token>`

## Request Format

All client messages are JSON text frames.

```json
{
  "id": "1",
  "command": "status",
  "args": {}
}
```

Fields:
- `id` — optional request identifier echoed back in response
- `command` — command name
- `args` — optional command arguments object

## Response Format

Success:

```json
{
  "id": "1",
  "ok": true,
  "result": {}
}
```

Error:

```json
{
  "id": "1",
  "ok": false,
  "error": {
    "code": "unknown_command",
    "message": "Unsupported command: foo"
  }
}
```

## Implemented Commands

### `ping`

Returns:
- `message = "pong"`
- `serverTimeMs`

### `status`

Returns:
- server status (`enabled`, `running`, `port`, `transport`, `authMode`, `clientConnected`, `urls`)
- app snapshot (`serviceConnected`, `appState`, `execution`, `recorder`, `overlayVisible`, `mediaProjectionReady`)

### `get_log`

Arguments:
- `maxChars` optional, clamped to a safe range

Returns:
- log text
- log source (`buffer` or `file_fallback`)

### `start`

Arguments:
- `delayMs` optional

Behavior:
- starts execution through the existing accessibility execution pipeline

Returns:
- execution summary on success
- structured error if execution cannot start

### `stop`

Behavior:
- stops active execution

Returns:
- execution summary

### `start_single`

Arguments:
- `scenarioId` required
- `delayMs` optional

Behavior:
- starts one stored scenario by id
- rejects when execution is already active

Returns:
- execution summary with `mode = "single"` and `scenarioId`

### `start_batch`

Arguments:
- `scenarioIds` required (array of scenario ids)
- `delayMs` optional

Behavior:
- starts sequential batch execution in the provided order
- continues to next scenario when one scenario fails to start or ends with errors
- rejects when execution is already active
- `stop` requests graceful batch stop before the next scenario

Returns:
- immediate acceptance with `mode = "batch"`, `accepted`, `total`, `scenarioIds`

### `get_scenarios`

Behavior:
- returns stored scenarios from Flutter persistence (`scenario_items_v1`)
- enriches each entry with native action info (`hasActions`, `actionCount`)
- falls back to native action-store ids when Flutter list is unavailable

Returns:
- `total`
- `scenarios` array

## Not Yet Implemented

### `upload_script`

Current status:
- explicitly returns `not_implemented`

Reason:
- scenario storage and remote upload workflow belong to later stages
