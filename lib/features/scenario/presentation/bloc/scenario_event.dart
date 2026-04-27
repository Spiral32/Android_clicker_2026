part of 'scenario_bloc.dart';

sealed class ScenarioEvent extends Equatable {
  const ScenarioEvent();

  @override
  List<Object?> get props => [];
}

final class ScenarioLoadRequested extends ScenarioEvent {
  const ScenarioLoadRequested();
}

final class ScenarioCreateRequested extends ScenarioEvent {
  const ScenarioCreateRequested({
    required this.name,
    this.stepCount = 0,
  });

  final String name;
  final int stepCount;

  @override
  List<Object?> get props => [name, stepCount];
}

final class ScenarioQuickLaunchToggled extends ScenarioEvent {
  const ScenarioQuickLaunchToggled(this.scenarioId);

  final String scenarioId;

  @override
  List<Object?> get props => [scenarioId];
}

final class ScenarioRenameRequested extends ScenarioEvent {
  const ScenarioRenameRequested({
    required this.scenarioId,
    required this.newName,
  });

  final String scenarioId;
  final String newName;

  @override
  List<Object?> get props => [scenarioId, newName];
}

final class ScenarioDeleteRequested extends ScenarioEvent {
  const ScenarioDeleteRequested(this.scenarioId);

  final String scenarioId;

  @override
  List<Object?> get props => [scenarioId];
}

final class ScenarioEnabledToggled extends ScenarioEvent {
  const ScenarioEnabledToggled(this.scenarioId);

  final String scenarioId;

  @override
  List<Object?> get props => [scenarioId];
}

final class ScenarioReordered extends ScenarioEvent {
  const ScenarioReordered({
    required this.oldIndex,
    required this.newIndex,
  });

  final int oldIndex;
  final int newIndex;

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

final class ScenarioSelectAllQuickLaunchToggled extends ScenarioEvent {
  const ScenarioSelectAllQuickLaunchToggled();
}

final class ScenarioQuickLaunchRunRequested extends ScenarioEvent {
  const ScenarioQuickLaunchRunRequested();
}

final class ScenarioRunAllRequested extends ScenarioEvent {
  const ScenarioRunAllRequested();
}

final class ScenarioSingleRunRequested extends ScenarioEvent {
  const ScenarioSingleRunRequested(this.scenarioId);

  final String scenarioId;

  @override
  List<Object?> get props => [scenarioId];
}

final class ScenarioStopRequested extends ScenarioEvent {
  const ScenarioStopRequested();
}

final class ScenarioImportRequested extends ScenarioEvent {
  const ScenarioImportRequested(this.jsonContent);

  final String jsonContent;

  @override
  List<Object?> get props => [jsonContent];
}
