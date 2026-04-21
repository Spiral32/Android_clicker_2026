[2026-04-15]
Task:
Define the project plan for Prog Set Touch as a strict stage-based roadmap with one active stage at a time.

Program essence:
- Android automation engine with Flutter UI and Kotlin platform layer
- Records touch gestures and executes action scenarios
- Works through Accessibility, overlay windows, and MediaProjection-dependent flows

Current architecture:
- Presentation: Flutter + BLoC + localization
- Domain: app state, execution status, recorder status, permission models
- Infrastructure/Platform: Android MethodChannel bridge, AccessibilityService, overlay manager, recorder, state machine, execution engine, screenshot verifier

Stage policy:
- Only one stage can be active at a time
- The next stage starts only after the current one satisfies its exit criteria
- Technical prototypes may exist ahead of the active stage, but they are not considered complete implementation
- The official project status is defined by documentation, not by the presence of experimental code

Official current stage:
- Stage 7 — Screenshot Verifier Integration

Completed stages:
- Stage 1: Application shell
- Stage 2: Permission system
- Stage 3: Overlay system
- Stage 4: Recorder system
- Stage 5: State Machine Hardening
- Stage 6: Execution Engine Hardening

Active stage details:
- Stage 7: Screenshot Verifier Integration
  - Scope:
    - optimize screenshot verification cost
    - integrate verification into execution safety flow
    - harden MediaProjection lifecycle handling
  - Entry criteria:
    - Stage 6 completed
  - Exit criteria:
    - Verifier runs stably without memory leaks
    - Verifier integrated with execution engine
    - UI supports configuring verification parameters


Next stages:
- Stage 6: Execution Engine Hardening
  - Scope:
    - finalize execution sequencing
    - add watchdog and stop guarantees
    - guarantee stable pause/resume/stop behavior
  - Starts only after Stage 5 exit criteria are complete

- Stage 7: Screenshot Verifier Integration
  - Scope:
    - optimize screenshot verification cost
    - integrate verification into execution safety flow
    - harden MediaProjection lifecycle handling
  - Starts only after Stage 6 exit criteria are complete

- Stage 8: Scheduler
- Stage 9: Autostart
- Stage 10: WebSocket control
- Stage 11: Scenario storage
- Stage 12: Settings persistence and advanced configuration

Not in the active stage yet:
- Scheduler/autostart production flow
- WebSocket server production flow
- Persistent scenario storage
- Full settings persistence and advanced configuration
