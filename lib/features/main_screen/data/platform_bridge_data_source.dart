import 'dart:async';

import 'package:flutter/services.dart';
import 'package:prog_set_touch/core/constants/platform_constants.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/core/utils/platform_result_parser.dart';
import 'package:prog_set_touch/features/main_screen/domain/app_state.dart';
import 'package:prog_set_touch/features/main_screen/domain/execution_summary.dart';
import 'package:prog_set_touch/features/main_screen/domain/overlay_status.dart';
import 'package:prog_set_touch/features/main_screen/domain/platform_bridge_repository.dart';
import 'package:prog_set_touch/features/main_screen/domain/platform_info.dart';
import 'package:prog_set_touch/features/main_screen/domain/permission_status.dart';
import 'package:prog_set_touch/features/main_screen/domain/recorder_summary.dart';

class PlatformBridgeDataSource implements PlatformBridgeRepository {
  PlatformBridgeDataSource({
    required AppLogger logger,
  })  : _logger = logger,
        _channel = const MethodChannel(PlatformConstants.platformChannel) {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  final AppLogger _logger;
  final MethodChannel _channel;
  final _executionUpdatesController = StreamController<ExecutionSummary>.broadcast();

  @override
  Stream<ExecutionSummary> get executionUpdates => _executionUpdatesController.stream;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onExecutionUpdate':
        final map = PlatformResultParser.parseMap(call.arguments);
        _executionUpdatesController.add(ExecutionSummary.fromMap(map));
        break;
      default:
        _logger.logInfo('platform_bridge_data_source', 'Unknown method from platform: ${call.method}');
    }
  }

  @override
  Future<PlatformInfo> getPlatformInfo() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getPlatformInfo');
      final map = PlatformResultParser.parseMap(result);

      return PlatformInfo(
        platform: map['platform'] as String? ?? '',
        manufacturer: map['manufacturer'] as String? ?? '',
        model: map['model'] as String? ?? '',
        sdkInt: map['sdkInt'] as int? ?? 0,
        localeTag: map['locale'] as String? ?? '',
      );
    } on PlatformException catch (error, stackTrace) {
      _logger.logError(
        'platform_bridge_data_source',
        error,
        stackTrace,
        context: 'PlatformException while loading platform info',
      );
      rethrow;
    } catch (error, stackTrace) {
      _logger.logError(
        'platform_bridge_data_source',
        error,
        stackTrace,
        context: 'Unexpected error while loading platform info',
      );
      rethrow;
    }
  }

  @override
  Future<PermissionStatus> getPermissionStatus() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('getPermissionStatus');
      return _mapPermissionStatus(result);
    } on PlatformException catch (error, stackTrace) {
      _logger.logError(
        'platform_bridge_data_source',
        error,
        stackTrace,
        context: 'PlatformException while loading permission status',
      );
      rethrow;
    } catch (error, stackTrace) {
      _logger.logError(
        'platform_bridge_data_source',
        error,
        stackTrace,
        context: 'Unexpected error while loading permission status',
      );
      rethrow;
    }
  }

  @override
  Future<void> openAccessibilitySettings() async {
    await _invokeVoid('openAccessibilitySettings');
  }

  @override
  Future<void> openOverlaySettings() async {
    await _invokeVoid('openOverlaySettings');
  }

  @override
  Future<PermissionStatus> requestMediaProjectionPermission() async {
    try {
      final result =
          await _channel.invokeMethod<dynamic>('requestMediaProjectionPermission');
      return _mapPermissionStatus(result);
    } on PlatformException catch (error, stackTrace) {
      _logger.logError(
        'platform_bridge_data_source',
        error,
        stackTrace,
        context: 'PlatformException while requesting media projection permission',
      );
      rethrow;
    } catch (error, stackTrace) {
      _logger.logError(
        'platform_bridge_data_source',
        error,
        stackTrace,
        context: 'Unexpected error while requesting media projection permission',
      );
      rethrow;
    }
  }

  @override
  Future<OverlayStatus> getOverlayStatus() async {
    return _mapOverlayStatus(await _invokeMap('getOverlayStatus'));
  }

  @override
  Future<OverlayStatus> showOverlay() async {
    return _mapOverlayStatus(await _invokeMap('showOverlay'));
  }

  @override
  Future<OverlayStatus> hideOverlay() async {
    return _mapOverlayStatus(await _invokeMap('hideOverlay'));
  }

  @override
  Future<RecorderSummary> getRecorderStatus() async {
    return _mapRecorderSummary(await _invokeMap('getRecorderStatus'));
  }

  @override
  Future<RecorderSummary> startRecorder({RecorderMode mode = RecorderMode.continuous}) async {
    final modeString = mode == RecorderMode.pointCapture ? 'POINT_CAPTURE' : 'CONTINUOUS';
    final result = await _channel.invokeMethod<dynamic>('startRecorder', {'mode': modeString});
    return _mapRecorderSummary(PlatformResultParser.parseMap(result));
  }

  @override
  Future<RecorderSummary> stopRecorder() async {
    return _mapRecorderSummary(await _invokeMap('stopRecorder'));
  }

  @override
  Future<AppState> getCurrentState() async {
    final map = await _invokeMap('getCurrentState');
    return AppState.fromMap(map);
  }

  @override
  Future<bool> resetState() async {
    final map = await _invokeMap('resetState');
    return map['success'] as bool? ?? false;
  }

  @override
  Future<ExecutionSummary> startExecution({int? delayMs}) async {
    final result = await _channel.invokeMethod<dynamic>(
      'startExecution',
      {'delayMs': delayMs},
    );
    return ExecutionSummary.fromMap(PlatformResultParser.parseMap(result));
  }

  @override
  Future<ExecutionSummary> stopExecution() async {
    final result = await _channel.invokeMethod<dynamic>('stopExecution');
    return ExecutionSummary.fromMap(PlatformResultParser.parseMap(result));
  }

  @override
  Future<bool> pauseExecution() async {
    final result = await _channel.invokeMethod<dynamic>('pauseExecution');
    final map = PlatformResultParser.parseMap(result);
    return map['paused'] as bool? ?? false;
  }

  @override
  Future<bool> resumeExecution() async {
    final result = await _channel.invokeMethod<dynamic>('resumeExecution');
    final map = PlatformResultParser.parseMap(result);
    return map['resumed'] as bool? ?? false;
  }

  @override
  Future<ExecutionSummary> getExecutionStatus() async {
    final result = await _channel.invokeMethod<dynamic>('getExecutionStatus');
    return ExecutionSummary.fromMap(PlatformResultParser.parseMap(result));
  }

  @override
  Future<String> getLogs() async {
    final result = await _channel.invokeMethod<String>('getLogs');
    return result ?? '';
  }

  @override
  Future<void> clearLogs() async {
    await _channel.invokeMethod<void>('clearLogs');
  }

  @override
  Future<String?> getLogFilePath() async {
    return await _channel.invokeMethod<String>('getLogFilePath');
  }

  @override
  Future<String?> exportLogs({String? path}) async {
    final result = await _channel.invokeMethod<String>('exportLogs', {'path': path});
    return result;
  }

  @override
  Future<void> setLoggingEnabled(bool enabled) async {
    await _channel.invokeMethod<void>('setLoggingEnabled', {'enabled': enabled});
  }

  @override
  Future<void> setLogToFileEnabled(bool enabled) async {
    await _channel.invokeMethod<void>('setLogToFileEnabled', {'enabled': enabled});
  }

  Future<void> _invokeVoid(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on PlatformException catch (error, stackTrace) {
      _logger.logError(
        'platform_bridge_data_source',
        error,
        stackTrace,
        context: 'PlatformException while invoking $method',
      );
      rethrow;
    } catch (error, stackTrace) {
      _logger.logError(
        'platform_bridge_data_source',
        error,
        stackTrace,
        context: 'Unexpected error while invoking $method',
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _invokeMap(String method) async {
    try {
      final result = await _channel.invokeMethod<dynamic>(method);
      return PlatformResultParser.parseMap(result);
    } on PlatformException catch (error, stackTrace) {
      _logger.logError(
        'platform_bridge_data_source',
        error,
        stackTrace,
        context: 'PlatformException while invoking $method',
      );
      rethrow;
    } catch (error, stackTrace) {
      _logger.logError(
        'platform_bridge_data_source',
        error,
        stackTrace,
        context: 'Unexpected error while invoking $method',
      );
      rethrow;
    }
  }

  PermissionStatus _mapPermissionStatus(dynamic result) {
    final map = PlatformResultParser.parseMap(result);

    return PermissionStatus(
      accessibilityGranted: map['accessibilityGranted'] as bool? ?? false,
      overlayGranted: map['overlayGranted'] as bool? ?? false,
      mediaProjectionGranted: map['mediaProjectionGranted'] as bool? ?? false,
    );
  }

  OverlayStatus _mapOverlayStatus(Map<String, dynamic> map) {
    return OverlayStatus(
      visible: map['visible'] as bool? ?? false,
    );
  }

  Future<RecorderSummary> clearRecorder() async {
    final result =
        await _channel.invokeMapMethod<String, dynamic>('clearRecorder');
    return _mapRecorderSummary(result ?? const <String, dynamic>{});
  }

  RecorderSummary _mapRecorderSummary(Map<String, dynamic> map) {
    final modeString = map['mode'] as String? ?? 'CONTINUOUS';
    final mode = modeString == 'POINT_CAPTURE' ? RecorderMode.pointCapture : RecorderMode.continuous;

    return RecorderSummary(
      isRecording: map['isRecording'] as bool? ?? false,
      totalActions: map['totalActions'] as int? ?? 0,
      tapCount: map['tapCount'] as int? ?? 0,
      doubleTapCount: map['doubleTapCount'] as int? ?? 0,
      longPressCount: map['longPressCount'] as int? ?? 0,
      swipeCount: map['swipeCount'] as int? ?? 0,
      maxPointerCount: map['maxPointerCount'] as int? ?? 0,
      sessionDurationMs: map['sessionDurationMs'] as int? ?? 0,
      mode: mode,
      error: map['error'] as String?,
    );
  }
}
