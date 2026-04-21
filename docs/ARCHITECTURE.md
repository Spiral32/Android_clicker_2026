# Architecture

## Official Project Stage

Current official stage:
- `Stage 5 — State Machine Hardening`

Stage rule:
- only one stage is active at a time
- later-stage code may exist in the repository, but it does not change the official stage
- Stage 6 starts only after Stage 5 exit criteria are satisfied
- Stage 7 starts only after Stage 6 exit criteria are satisfied

Stage sequence:
- Stage 1: Shell
- Stage 2: Permissions
- Stage 3: Overlay System
- Stage 4: Recorder
- Stage 5: State Machine Hardening
- Stage 6: Execution Engine Hardening
- Stage 7: Screenshot Verifier Integration
- Stage 8: Scheduler
- Stage 9: Autostart
- Stage 10: WebSocket Server
- Stage 11: Scenario Storage
- Stage 12: Settings

Stage 5 exit criteria:
- every recorder and execution entry point validates current state
- invalid transitions are blocked consistently
- reset from ERROR is deterministic
- Flutter receives synchronized state after critical native operations

## Layer Structure (Strict)

### Presentation (Flutter)

- Material 3 UI widgets
- BLoC state management
- Routing
- Localization (RU/EN)

### Domain

- **StateMachine** — Central state management (IDLE, RECORDING, EXECUTING, PAUSED, ERROR)
- **ExecutionEngine** — Gesture playback orchestration
- **ScenarioModel** — Scenario data structures and validation

### Infrastructure (Android/Kotlin)

- **AccessibilityController** — AccessibilityService integration
- **RecorderManager** — MotionEvent capture and classification
- **GestureActionClassifier** — Tap/Double-tap/Long-press/Swipe detection
- **ScreenshotVerifier** — Visual verification of executed actions
- **Scheduler** — Cyclic and one-shot timers
- **WebSocketServer** — Remote control interface (Ktor CIO)
- **Logger** — Ring buffer logging with export
- **OverlayManager** — Control overlay (floating button)

### Platform (Android)

- AccessibilityService implementation
- TYPE_ACCESSIBILITY_OVERLAY windows
- MotionEvent handling
- MediaProjection API
- AlarmManager for scheduling

---

## State Machine (Mandatory)

States:
- `IDLE` — Ready for recording or execution
- `RECORDING` — Capturing user gestures
- `EXECUTING` — Playing back scenario
- `PAUSED` — Execution paused
- `ERROR` — Error state, requires reset

Rules:
- Any operation validates current state
- Invalid state transitions are blocked
- ERROR state requires explicit reset

---

## Pipeline: Recording

```
MotionEvent → ActiveGesture → GestureActionClassifier → RecordedAction
```

**ActiveGesture:**
- startPoints: Map<pointerId, Pair<x, y>>
- endPoints: Map<pointerId, Pair<x, y>>
- startEventTimeMs / endEventTimeMs
- maxPointerCount

**Gesture Thresholds (dp):**
- Tap: distance < 32dp, duration < 450ms
- Long Press: duration ≥ 450ms
- Swipe: distance ≥ 72dp
- Double Tap: interval ≤ 280ms, distance ≤ 32dp

**RecordedAction:**
- type: tap | double_tap | long_press | swipe
- pointerCount: Int
- startX/Y, endX/Y: Double (screen coordinates)
- durationMs: Long

---

## Pipeline: Execution (Planned)

```
Scenario → ExecutionEngine → AccessibilityController → dispatchGesture()
                    ↓
            ScreenshotVerifier (verify action result)
```

**Features:**
- Sequential execution (v1)
- Configurable delays between actions
- Retry mechanism with limit
- Watchdog timer for hang detection
- Visual feedback during execution

---

## Overlay System (Separated)

### Control Overlay
- Always visible floating button
- Draggable
- Non-blocking (FLAG_NOT_TOUCH_MODAL)
- Functions: emergency stop, status, open app

### Recording Overlay
- Fullscreen (only during RECORDING state)
- Intercepts all MotionEvent
- Removed immediately after recording stops

---

## Implemented Stages

### Stage 1: Shell
- Material 3 app structure
- Localization
- BLoC architecture

### Stage 2: Permissions
- Accessibility service
- Overlay permission
- MediaProjection permission

### Stage 3: Overlay System
- Separated Control + Recording overlays
- OverlayManager lifecycle

### Stage 4: Recorder
- CONTINUOUS and POINT_CAPTURE modes
- Multi-touch support
- Gesture classification with configurable thresholds
- Visual feedback system
- Full platform bridge integration

---

## Planned Stages

### Stage 5: State Machine
- Central state management
- State validation layer

### Stage 6: Execution Engine
- Gesture playback via AccessibilityService
- Sequential execution
- Watchdog protection

### Stage 7: Screenshot Verifier
- Downscaled pixel diff (64x64 default)
- Region-based comparison
- FPS limiting (2-5 fps)
- FLAG_SECURE handling

### Stage 8: Scheduler
- Cyclic timer support
- One-shot timer support

### Stage 9: Autostart
- AlarmManager integration
- BOOT_COMPLETED receiver
- ForegroundService

### Stage 10: WebSocket Server
- Ktor CIO implementation
- WSS with TLS
- Token authentication
- Single connection limit

### Stage 11: Scenario Storage
- SQLite/Room database
- Scenario CRUD operations
- Import/export

### Stage 12: Settings
- Anti-detect (random delays, jitter)
- Screenshot parameters
- Retry configuration

---

## Stage Governance (Supersedes Ambiguity)

Official current stage:
- `Stage 5 — State Machine Hardening`

Mandatory rule:
- only one stage is active at a time
- later-stage code may exist in the repository as technical groundwork
- such groundwork does not mean the later stage has started officially

Execution order:
1. Stage 1 — Shell
2. Stage 2 — Permissions
3. Stage 3 — Overlay System
4. Stage 4 — Recorder
5. Stage 5 — State Machine Hardening
6. Stage 6 — Execution Engine Hardening
7. Stage 7 — Screenshot Verifier Integration
8. Stage 8 — Scheduler
9. Stage 9 — Autostart
10. Stage 10 — WebSocket Server
11. Stage 11 — Scenario Storage
12. Stage 12 — Settings

Stage 5 exit criteria:
- every recorder and execution entry point validates current state
- invalid transitions are blocked consistently
- reset from ERROR is deterministic
- Flutter receives synchronized state after critical native operations

Stage 6 may begin only after Stage 5 exit criteria are complete.
Stage 7 may begin only after Stage 6 exit criteria are complete.
