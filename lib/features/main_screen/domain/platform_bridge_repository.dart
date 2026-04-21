import 'package:prog_set_touch/features/main_screen/domain/app_state.dart';
import 'package:prog_set_touch/features/main_screen/domain/execution_summary.dart';
import 'package:prog_set_touch/features/main_screen/domain/platform_info.dart';
import 'package:prog_set_touch/features/main_screen/domain/overlay_status.dart';
import 'package:prog_set_touch/features/main_screen/domain/permission_status.dart';
import 'package:prog_set_touch/features/main_screen/domain/recorder_summary.dart';
export 'package:prog_set_touch/features/main_screen/domain/recorder_summary.dart' show RecorderMode;

abstract class PlatformBridgeRepository {
  Future<PlatformInfo> getPlatformInfo();

  Future<PermissionStatus> getPermissionStatus();

  Future<void> openAccessibilitySettings();

  Future<void> openOverlaySettings();

  Future<PermissionStatus> requestMediaProjectionPermission();

  Future<OverlayStatus> getOverlayStatus();

  Future<OverlayStatus> showOverlay();

  Future<OverlayStatus> hideOverlay();

  Future<RecorderSummary> getRecorderStatus();

  Future<RecorderSummary> startRecorder({RecorderMode mode});

  Future<RecorderSummary> stopRecorder();

  Future<AppState> getCurrentState();

  Future<bool> resetState();

  Future<ExecutionSummary> startExecution({int? delayMs});

  Future<ExecutionSummary> stopExecution();

  Future<bool> pauseExecution();

  Future<bool> resumeExecution();

  Future<ExecutionSummary> getExecutionStatus();

  Future<String> getLogs();

  Future<void> clearLogs();

  Future<String?> getLogFilePath();

  Future<String?> exportLogs({String? path});

  Future<void> setLoggingEnabled(bool enabled);

  Future<void> setLogToFileEnabled(bool enabled);

  Stream<ExecutionSummary> get executionUpdates;
}
