[2026-04-12]
Checkpoint:
stage4_blocking_recorder

Purpose:
Rollback point before replacing the blocking fullscreen recorder with a non-blocking guided recorder flow.

Rollback instruction:
Restore the `*.bak` files from this folder back to their original paths.

Saved files:
- android/app/src/main/kotlin/com/progsettouch/app/MainActivity.kt
- android/app/src/main/kotlin/com/progsettouch/app/ProgSetAccessibilityService.kt
- android/app/src/main/kotlin/com/progsettouch/app/RecorderManager.kt
- lib/features/main_screen/presentation/bloc/main_screen_bloc.dart
- lib/features/main_screen/presentation/pages/main_screen_page.dart
- lib/core/localization/app_ru.arb
- lib/core/localization/app_en.arb
- ai/DECISIONS.md
