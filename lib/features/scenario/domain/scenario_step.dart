import 'package:equatable/equatable.dart';

enum ScenarioStepType {
  tap('tap'),
  doubleTap('double_tap'),
  longPress('long_press'),
  swipe('swipe');

  const ScenarioStepType(this.value);

  final String value;

  static ScenarioStepType fromValue(String raw) {
    return ScenarioStepType.values.firstWhere(
      (item) => item.value == raw,
      orElse: () => ScenarioStepType.tap,
    );
  }
}

class ScenarioStep extends Equatable {
  static const int defaultStepDelayMs = 1000;
  static const int minGestureDurationMs = 50;
  static const int minStepDelayMs = 0;
  static const double minThresholdPercent = 1.0;
  static const double maxThresholdPercent = 100.0;
  static const double defaultThresholdPercent = 90.0;
  static const int minTimeoutMs = 1000; // 1 second
  static const int maxTimeoutMs = 300000; // 5 minutes
  static const int defaultTimeoutMs = 10000; // 10 seconds

  const ScenarioStep({
    required this.type,
    required this.pointerCount,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.durationMs,
    required this.stepDelayMs,
    this.verificationEnabled = false,
    this.thresholdPercent = defaultThresholdPercent,
    this.timeoutMs = defaultTimeoutMs,
    this.continueOnFailure = false,
    this.resultImageFileName,
  });

  final ScenarioStepType type;
  final int pointerCount;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final int durationMs;
  final int stepDelayMs;
  final bool verificationEnabled;
  final double thresholdPercent;
  final int timeoutMs;
  final bool continueOnFailure;
  final String? resultImageFileName;

  factory ScenarioStep.initial() {
    return const ScenarioStep(
      type: ScenarioStepType.tap,
      pointerCount: 1,
      startX: 500,
      startY: 1000,
      endX: 500,
      endY: 1000,
      durationMs: 100,
      stepDelayMs: defaultStepDelayMs,
      verificationEnabled: false,
      thresholdPercent: defaultThresholdPercent,
      timeoutMs: defaultTimeoutMs,
      continueOnFailure: false,
      resultImageFileName: null,
    );
  }

  factory ScenarioStep.fromMap(Map<String, dynamic> map) {
    final rawType = (map['type']?.toString() ?? '').trim();
    final rawPointerCount = map['pointerCount'];
    final rawDurationMs = map['durationMs'];
    final rawStepDelayMs = map['stepDelayMs'];
    final rawVerificationEnabled = map['verificationEnabled'];
    final rawThresholdPercent = map['thresholdPercent'];
    final rawTimeoutMs = map['timeoutMs'];
    final rawContinueOnFailure = map['continueOnFailure'];
    final resultImageFileName = map['resultImageFileName'] as String?;

    return ScenarioStep(
      type: ScenarioStepType.fromValue(rawType),
      pointerCount: _toInt(rawPointerCount, fallback: 1).clamp(1, 10),
      startX: _toDouble(map['startX']),
      startY: _toDouble(map['startY']),
      endX: _toDouble(map['endX']),
      endY: _toDouble(map['endY']),
      durationMs: _toInt(
        rawDurationMs,
        fallback: minGestureDurationMs,
      ).clamp(minGestureDurationMs, 60000),
      stepDelayMs: _toInt(
        rawStepDelayMs,
        fallback: defaultStepDelayMs,
      ).clamp(minStepDelayMs, 600000),
      verificationEnabled: _toBool(rawVerificationEnabled),
      thresholdPercent: _toDouble(
        rawThresholdPercent,
        fallback: defaultThresholdPercent,
      ).clamp(minThresholdPercent, maxThresholdPercent),
      timeoutMs: _toInt(
        rawTimeoutMs,
        fallback: defaultTimeoutMs,
      ).clamp(minTimeoutMs, maxTimeoutMs),
      continueOnFailure: _toBool(rawContinueOnFailure),
      resultImageFileName: resultImageFileName,
    );
  }

  ScenarioStep copyWith({
    ScenarioStepType? type,
    int? pointerCount,
    double? startX,
    double? startY,
    double? endX,
    double? endY,
    int? durationMs,
    int? stepDelayMs,
    bool? verificationEnabled,
    double? thresholdPercent,
    int? timeoutMs,
    bool? continueOnFailure,
    String? resultImageFileName,
  }) {
    return ScenarioStep(
      type: type ?? this.type,
      pointerCount: pointerCount ?? this.pointerCount,
      startX: startX ?? this.startX,
      startY: startY ?? this.startY,
      endX: endX ?? this.endX,
      endY: endY ?? this.endY,
      durationMs: durationMs ?? this.durationMs,
      stepDelayMs: stepDelayMs ?? this.stepDelayMs,
      verificationEnabled: verificationEnabled ?? this.verificationEnabled,
      thresholdPercent: thresholdPercent ?? this.thresholdPercent,
      timeoutMs: timeoutMs ?? this.timeoutMs,
      continueOnFailure: continueOnFailure ?? this.continueOnFailure,
      resultImageFileName: resultImageFileName ?? this.resultImageFileName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.value,
      'pointerCount': pointerCount,
      'startX': startX,
      'startY': startY,
      'endX': endX,
      'endY': endY,
      'durationMs': durationMs,
      'stepDelayMs': stepDelayMs,
      'verificationEnabled': verificationEnabled,
      'thresholdPercent': thresholdPercent,
      'timeoutMs': timeoutMs,
      'continueOnFailure': continueOnFailure,
      if (resultImageFileName != null)
        'resultImageFileName': resultImageFileName,
    };
  }

  @override
  List<Object?> get props => [
        type,
        pointerCount,
        startX,
        startY,
        endX,
        endY,
        durationMs,
        stepDelayMs,
        verificationEnabled,
        thresholdPercent,
        timeoutMs,
        continueOnFailure,
        resultImageFileName,
      ];

  static int _toInt(Object? value, {required int fallback}) {
    return switch (value) {
      int() => value,
      num() => value.toInt(),
      String() => int.tryParse(value) ?? fallback,
      _ => fallback,
    };
  }

  static double _toDouble(Object? value, {double fallback = 0}) {
    return switch (value) {
      double() => value,
      num() => value.toDouble(),
      String() => double.tryParse(value) ?? fallback,
      _ => fallback,
    };
  }

  static bool _toBool(Object? value) {
    return switch (value) {
      bool() => value,
      int() => value != 0,
      String() => value.toLowerCase() == 'true',
      _ => false,
    };
  }
}
