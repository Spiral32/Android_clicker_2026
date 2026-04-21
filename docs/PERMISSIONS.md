# Permissions

## Official Stage Context

Permissions are not the current active project stage.

Officially:
- Stage 2 (Permissions) is completed
- current active stage is Stage 5 (State Machine Hardening)
- permission behavior now acts as a prerequisite for later stages

## Planned

- Accessibility
- Overlay
- MediaProjection

## Stage 1

Permissions are intentionally deferred to Stage 2.

## Stage 2

- Main actions are blocked until all required permissions are granted.
- The UI shows only the next required permission instruction.
- Accessibility and overlay permissions open the corresponding system settings screens.
- MediaProjection is requested through the native Android activity flow.
- Permission state is refreshed when the app returns to foreground.

## Current Limitation

- MediaProjection approval is currently session-scoped in the native layer and is used only for Stage 2 gating.
- Persistent capture token handling is deferred to the screenshot and execution stages to avoid leaking invalid projection state across process restarts.

## Stage Mapping

- Stage 2 owns permission acquisition and permission gating
- Stage 5 consumes permission state as part of valid state transitions
- Stage 6 depends on permission validity before execution start
- Stage 7 depends on MediaProjection lifecycle correctness
