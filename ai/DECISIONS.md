[2026-04-12]
Decision:
Manual project scaffolding is used instead of CLI generation.
Reason:
The execution environment explicitly forbids Flutter, Dart, Gradle, Java, ADB, and batch commands because they may hang indefinitely.

[2026-04-12]
Decision:
Localization ARB files are stored in `lib/core/localization` and locale switching is controlled by a dedicated BLoC.
Reason:
This satisfies the requirement for zero hardcoded UI strings and runtime language switching without application restart.

[2026-04-12]
Decision:
Platform interaction is isolated behind a Flutter repository contract and an Android `MethodChannel` bridge.
Reason:
This preserves architectural boundaries and keeps the presentation layer independent from Android implementation details.

[2026-04-12]
Decision:
The Android Gradle wrapper is aligned to Gradle 8.7.
Reason:
The selected Android Gradle Plugin version requires at least Gradle 8.7, and the build was failing with wrapper version 8.0.

[2026-04-12]
Decision:
The manual Android scaffold now includes local Flutter SDK binding and explicit debug signing.
Reason:
The Flutter tool expects a standard Android app packaging pipeline and predictable debug APK output for `assembleDebug`.

[2026-04-12]
Decision:
Android subproject build directories are redirected to the workspace root `build/` directory.
Reason:
Flutter tooling expects APK artifacts under the root build output layout used by the standard Flutter Android template.

[2026-04-12]
Decision:
Android build tooling was downgraded from AGP 8.5.2 / Gradle 8.7 to a more Flutter-template-compatible combination.
Reason:
The previous tooling version was too aggressive for the manual scaffold and likely prevented Flutter from locating the expected debug APK artifact even when `assembleDebug` completed.

[2026-04-12]
Decision:
The Android app module now copies the generated debug APK into `build/app/outputs/flutter-apk/app-debug.apk`.
Reason:
`assembleDebug` completes, but Flutter tooling still cannot find the artifact; this aligns the output path with Flutter's expected APK discovery location.

[2026-04-12]
Decision:
Android Gradle configuration is switched from Kotlin DSL files to Groovy `*.gradle` files.
Reason:
Flutter tooling compatibility is stronger with the standard Groovy Android template, and Flutter issue reports indicate some tool versions still mis-detect or mishandle `build.gradle.kts` during APK discovery.

[2026-04-12]
Decision:
Stage 2 permission gating is implemented in strict order: Accessibility -> Overlay -> MediaProjection.
Reason:
The product requirement says to show only the next relevant instruction and block action flows until mandatory permissions are complete.

[2026-04-12]
Decision:
MediaProjection permission state is treated as session-scoped for now.
Reason:
Persisting projection readiness without a valid runtime capture token would create false-positive permission state and increase failure risk in later execution stages.

[2026-04-12]
Decision:
`SYSTEM_ALERT_WINDOW` is declared in the Android manifest during Stage 2.
Reason:
Without this manifest permission, the app may not appear in the Android "Display over other apps" settings list, making the overlay permission flow unusable for the user.

[2026-04-12]
Decision:
Stage 3 overlay is hosted by the accessibility service and rendered with `TYPE_ACCESSIBILITY_OVERLAY`.
Reason:
This matches the platform requirement, avoids overlay logic inside Flutter UI, and keeps the floating control available when the app is backgrounded.

[2026-04-12]
Decision:
The overlay view handles only drag and tap-to-open behavior.
Reason:
Heavy logic inside the overlay is explicitly forbidden; execution control and automation runtime remain in later stages.

[2026-04-12]
Decision:
Overlay readiness now requires a live connected accessibility service instance, not only the enabled system setting.
Reason:
The overlay is rendered from `AccessibilityService`; a checked toggle in settings is insufficient if the system has not actually bound the service yet.

[2026-04-12]
Decision:
Stage 4 recorder is implemented as a fullscreen accessibility overlay owned by the accessibility service.
Reason:
This keeps recording in the Android infrastructure layer, allows `MotionEvent` capture with multi-touch metadata, and avoids putting recorder logic into Flutter UI.

[2026-04-12]
Decision:
Gesture classification is summary-oriented in Stage 4: tap, double tap, long press, swipe, plus max pointer count.
Reason:
This gives a stable foundation for later scenario modeling without prematurely introducing execution or storage complexity in the recorder stage.

[2026-04-12]
Decision:
Recorder start now requires an active floating overlay, and the app auto-activates the floating overlay after all permissions are granted.
Reason:
This matches the desired operator flow: overlay is the stable foreground control surface, while recorder start should minimize the app and keep a visible stop path for the user.
[2026-04-15]
Decision:
Maintain persistent AI project memory inside repository docs during ongoing work.

Why:
- the project already spans multiple stages and native/Flutter interactions
- fixes often depend on earlier architectural choices and debugging history
- future AI sessions must be able to understand what was changed, why it was changed, and what remains risky without rediscovering context

Rule:
- every meaningful fix or architectural correction should be reflected in project memory docs
- implementation progress and active stage rules go to `ai/TASKS.md` and `ROADMAP.md`
- important technical decisions and chosen solution directions go to `ai/DECISIONS.md`
- discovered defects, regressions, and unresolved blockers go to `ai/BUGS.md`
- change summaries affecting project history go to `CHANGELOG_AI.md`

Reading order for future AI sessions:
1. `ROADMAP.md`
2. `ai/TASKS.md`
3. `ai/DECISIONS.md`
4. `ai/BUGS.md`
5. `CHANGELOG_AI.md`
6. relevant code files for the current bug/feature

Operator command for future sessions:
- "Прочитай AI-память проекта и продолжай работу"

Expected behavior on that command:
- read the files listed in the reading order
- determine the official active stage
- account for known bugs, previous fixes, and chosen directions
- only then continue implementation

[2026-04-15]
Decision:
Project files must not be deleted during normal AI work.

Rule:
- do not delete files
- if a file is obsolete, rewrite its content or mark it as `DEPRECATED`
- prefer preserving project history and context inside the repository

[2026-04-15]
Decision:
Stage 4 recording is officially moving to non-blocking step-by-step capture UX.

Why:
- fullscreen CONTINUOUS recording through accessibility overlay blocks underlying touch interaction
- attempted pass-through injection is not stable enough to be treated as a production solution
- Android input model makes simultaneous raw overlay capture and normal app interaction unreliable in this architecture

Applied direction:
- `CONTINUOUS` must no longer be treated as the production recording path
- official recording UX is `POINT_CAPTURE` / step-by-step non-blocking capture
- if old code still requests `CONTINUOUS`, native layer should remap it to non-blocking capture
- recorder UI wording should explicitly describe step-by-step actions instead of generic Tap/Swipe labels

Implication for future AI sessions:
- do not try to restore fullscreen blocking recorder as the main UX
- continue hardening the non-blocking recorder flow instead

[2026-04-15]
Decision:
Recorder stop from overlay control must always bring native app state back to `IDLE`.

Why:
- the recorder panel can be closed directly from overlay controls
- if overlay stop does not also restore state machine from `RECORDING` to `IDLE`, the next recorder start is rejected by state validation
- this creates the visible bug where "Open recording panel" no longer reopens the panel after a previous stop

Applied direction:
- overlay-driven recorder stop is treated as a state-changing action, not only a UI cleanup action
- stop callbacks from recorder UI must restore the state machine when current state is `RECORDING`
- repeated recorder sessions must be supported without app restart

[2026-04-15]
Decision:
The point-capture recorder panel must be draggable and old overlay status messaging stays hidden.

Why:
- the recording panel can cover important parts of the target app during capture
- drag must be obvious and reliable, not hidden behind a tiny touch target
- a separate "Floating overlay" status card adds redundant noise once overlay state is already represented by the main action buttons

Applied direction:
- the point-capture panel uses a visible drag handle in its header and updates its `WindowManager` position while moving
- the deprecated overlay status card should remain a no-op widget instead of being shown on the main screen
- future recorder UX changes should preserve movable overlay controls

[2026-04-15]
Decision:
The application must minimize during "Test" execution and restore itself upon completion.

Why:
- execution happens on the target application's UI
- the automation app should not block the view of the target app during playback
- restoration provides a clear feedback loop to the operator that the task is finished

Applied direction:
- `startExecution` triggers a home screen intent
- `onExecutionComplete` triggers a launch intent back to the app

[2026-04-15]
Decision:
The floating control overlay must provide a visible "Stop" path during execution.

Why:
- the app is minimized during execution
- the user must have an immediate way to abort a runaway or incorrect scenario without reopening the main app

Applied direction:
- overlay changes its icon to `ic_media_pause` and color to red when state is `EXECUTING`
- clicking the overlay in `EXECUTING` state triggers `stopExecution` instead of opening the app
- state machine transitions are used as the trigger for overlay UI updates

[2026-04-15]
Decision:
Destructive actions like clearing a recording must be guarded by confirmation.

Why:
- accidental clicks can lead to loss of complex recorded scenarios
- confirmation adds a safety layer for the operator

Applied direction:
- "Clear recording" button shows a localized `AlertDialog`
- action is performed only on explicit "Yes/Confirm" result

