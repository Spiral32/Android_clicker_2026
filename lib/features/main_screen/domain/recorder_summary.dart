import 'package:equatable/equatable.dart';

enum RecorderMode {
  continuous,
  pointCapture,
}

class RecorderSummary extends Equatable {
  const RecorderSummary({
    required this.isRecording,
    required this.totalActions,
    required this.tapCount,
    required this.doubleTapCount,
    required this.longPressCount,
    required this.swipeCount,
    required this.maxPointerCount,
    required this.sessionDurationMs,
    this.mode = RecorderMode.continuous,
    this.error,
  });

  const RecorderSummary.initial()
      : isRecording = false,
        totalActions = 0,
        tapCount = 0,
        doubleTapCount = 0,
        longPressCount = 0,
        swipeCount = 0,
        maxPointerCount = 0,
        sessionDurationMs = 0,
        mode = RecorderMode.continuous,
        error = null;

  final bool isRecording;
  final int totalActions;
  final int tapCount;
  final int doubleTapCount;
  final int longPressCount;
  final int swipeCount;
  final int maxPointerCount;
  final int sessionDurationMs;
  final RecorderMode mode;
  final String? error;

  bool get hasError => error != null && error!.isNotEmpty;

  @override
  List<Object?> get props => [
        isRecording,
        totalActions,
        tapCount,
        doubleTapCount,
        longPressCount,
        swipeCount,
        maxPointerCount,
        sessionDurationMs,
        mode,
        error,
      ];
}
