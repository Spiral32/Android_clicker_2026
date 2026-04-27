# Architecture

## Official Project Stage

Current official stage:
- `Stage 10 — Scenario Storage`

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
- Stage 7: Scheduler ✅
- Stage 8: Autostart ✅
- Stage 9: WebSocket Server ✅
- Stage 10: Scenario Storage
- Stage 11: Settings Persistence and Advanced Configuration
- Stage 12: Screenshot Verifier Integration

Stage 10 status:
- active implementation stage after Stage 9 closure
- storage architecture is the current delivery focus

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
- **Scheduler** — Schedule management and execution (oneTime, daily, weekly schedules)

### Infrastructure (Android/Kotlin)

- **AccessibilityController** — AccessibilityService integration
- **RecorderManager** — MotionEvent capture and classification
- **GestureActionClassifier** — Tap/Double-tap/Long-press/Swipe detection
- **ScreenshotVerifier** — Visual verification of executed actions
- **Scheduler** — Cyclic and one-shot timers
- **WebSocketServer** — Remote control interface (native Kotlin foundation, single client, bearer-first token auth, strict handshake)
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

### Stage 8: Autostart
- AlarmManager integration
- BOOT_COMPLETED receiver
- Settings control and boot restoration

### Stage 9: WebSocket Server
- Native Kotlin WebSocket server foundation
- Bearer-first token authentication with legacy query-token fallback
- Single connection limit
- Settings diagnostics and server control
- Transport/parsing hardening (strict handshake, masked frames, frame size cap)

### Stage 10: Scenario Storage
- SQLite/Room database
- Scenario CRUD operations
- Import/export
### Stage 11: Settings
- Anti-detect (random delays, jitter)
- Screenshot parameters
- Retry configuration

---

## Stage Governance (Supersedes Ambiguity)

Official current stage:
- `Stage 10 — Scenario Storage`

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
7. Stage 7 — Scheduler
8. Stage 8 — Autostart
9. Stage 9 — WebSocket Server
10. Stage 10 — Scenario Storage
11. Stage 11 — Settings Persistence and Advanced Configuration
12. Stage 12 — Screenshot Verifier Integration
