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

  const ScenarioStep({
    required this.type,
    required this.pointerCount,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.durationMs,
    required this.stepDelayMs,
  });

  final ScenarioStepType type;
  final int pointerCount;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final int durationMs;
  final int stepDelayMs;

  factory ScenarioStep.fromMap(Map<String, dynamic> map) {
    final rawType = (map['type']?.toString() ?? '').trim();
    final rawPointerCount = map['pointerCount'];
    final rawDurationMs = map['durationMs'];
    final rawStepDelayMs = map['stepDelayMs'];

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
      ];

  static int _toInt(Object? value, {required int fallback}) {
    return switch (value) {
      int() => value,
      num() => value.toInt(),
      String() => int.tryParse(value) ?? fallback,
      _ => fallback,
    };
  }

  static double _toDouble(Object? value) {
    return switch (value) {
      double() => value,
      num() => value.toDouble(),
      String() => double.tryParse(value) ?? 0,
      _ => 0,
    };
  }
}
