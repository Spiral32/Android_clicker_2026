import 'package:equatable/equatable.dart';

class ExecutionSummary extends Equatable {
  const ExecutionSummary({
    required this.isExecuting,
    this.isPaused = false,
    required this.totalActions,
    required this.completedActions,
    required this.failedActions,
    this.currentActionIndex = -1,
    this.error,
  });

  const ExecutionSummary.initial()
      : isExecuting = false,
        isPaused = false,
        totalActions = 0,
        completedActions = 0,
        failedActions = 0,
        currentActionIndex = -1,
        error = null;

  factory ExecutionSummary.fromMap(Map<String, dynamic> map) {
    return ExecutionSummary(
      isExecuting: map['isExecuting'] as bool? ?? false,
      isPaused: map['isPaused'] as bool? ?? false,
      totalActions: map['totalActions'] as int? ?? 0,
      completedActions: map['completedActions'] as int? ?? 0,
      failedActions: map['failedActions'] as int? ?? 0,
      currentActionIndex: map['currentActionIndex'] as int? ?? -1,
      error: map['error'] as String?,
    );
  }

  final bool isExecuting;
  final bool isPaused;
  final int totalActions;
  final int completedActions;
  final int failedActions;
  final int currentActionIndex;
  final String? error;

  bool get hasError => error != null && error!.isNotEmpty;

  double get progressPercent =>
      totalActions > 0 ? (completedActions / totalActions * 100) : 0;

  @override
  List<Object?> get props => [
        isExecuting,
        isPaused,
        totalActions,
        completedActions,
        failedActions,
        currentActionIndex,
        error,
      ];
}
