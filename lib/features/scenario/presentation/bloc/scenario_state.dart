part of 'scenario_bloc.dart';

class ScenarioState extends Equatable {
  const ScenarioState({
    this.isLoading = false,
    this.isExecuting = false,
    this.scenarios = const <ScenarioItem>[],
    this.messageKey,
    this.lastSnapshot = const <ScenarioItem>[],
    this.activeScenarioId,
    this.completedInBatch = 0,
    this.totalInBatch = 0,
    this.executionSummary = const ExecutionSummary.initial(),
  });

  final bool isLoading;
  final bool isExecuting;
  final List<ScenarioItem> scenarios;
  final String? messageKey;
  final List<ScenarioItem> lastSnapshot;
  final String? activeScenarioId;
  final int completedInBatch;
  final int totalInBatch;
  final ExecutionSummary executionSummary;

  bool get isAllQuickLaunchSelected =>
      scenarios.isNotEmpty &&
      scenarios.every((item) => item.quickLaunchEnabled);

  bool get isAnyQuickLaunchSelected =>
      scenarios.any((item) => item.quickLaunchEnabled);

  ScenarioState copyWith({
    bool? isLoading,
    bool? isExecuting,
    List<ScenarioItem>? scenarios,
    String? messageKey,
    List<ScenarioItem>? lastSnapshot,
    String? activeScenarioId,
    int? completedInBatch,
    int? totalInBatch,
    ExecutionSummary? executionSummary,
    bool clearMessage = false,
    bool clearActiveScenario = false,
  }) {
    return ScenarioState(
      isLoading: isLoading ?? this.isLoading,
      isExecuting: isExecuting ?? this.isExecuting,
      scenarios: scenarios ?? this.scenarios,
      messageKey: clearMessage ? null : (messageKey ?? this.messageKey),
      lastSnapshot: lastSnapshot ?? this.lastSnapshot,
      activeScenarioId: clearActiveScenario
          ? null
          : (activeScenarioId ?? this.activeScenarioId),
      completedInBatch: completedInBatch ?? this.completedInBatch,
      totalInBatch: totalInBatch ?? this.totalInBatch,
      executionSummary: executionSummary ?? this.executionSummary,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isExecuting,
        scenarios,
        messageKey,
        lastSnapshot,
        activeScenarioId,
        completedInBatch,
        totalInBatch,
        executionSummary,
      ];
}
