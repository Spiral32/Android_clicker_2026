part of 'main_screen_bloc.dart';

sealed class MainScreenEvent extends Equatable {
  const MainScreenEvent();

  @override
  List<Object?> get props => [];
}

final class MainScreenRequested extends MainScreenEvent {
  const MainScreenRequested();
}

final class MainScreenPermissionActionPressed extends MainScreenEvent {
  const MainScreenPermissionActionPressed(this.permissionType);

  final PermissionType permissionType;

  @override
  List<Object?> get props => [permissionType];
}

final class MainScreenOverlayToggleRequested extends MainScreenEvent {
  const MainScreenOverlayToggleRequested();
}

final class MainScreenRecorderStartRequested extends MainScreenEvent {
  const MainScreenRecorderStartRequested({this.mode = RecorderMode.pointCapture});

  final RecorderMode mode;

  @override
  List<Object?> get props => [mode];
}

final class MainScreenRecorderStopRequested extends MainScreenEvent {
  const MainScreenRecorderStopRequested();
}

final class MainScreenRecorderClearRequested extends MainScreenEvent {
  const MainScreenRecorderClearRequested();
}

final class MainScreenStateRefreshRequested extends MainScreenEvent {
  const MainScreenStateRefreshRequested();
}

final class MainScreenStateResetRequested extends MainScreenEvent {
  const MainScreenStateResetRequested();
}

final class MainScreenExecutionStartRequested extends MainScreenEvent {
  const MainScreenExecutionStartRequested();
}

final class MainScreenExecutionStopRequested extends MainScreenEvent {
  const MainScreenExecutionStopRequested();
}

final class MainScreenExecutionPauseRequested extends MainScreenEvent {
  const MainScreenExecutionPauseRequested();
}

final class MainScreenExecutionResumeRequested extends MainScreenEvent {
  const MainScreenExecutionResumeRequested();
}

final class MainScreenExecutionDelayChanged extends MainScreenEvent {
  const MainScreenExecutionDelayChanged(this.delayMs);

  final int delayMs;

  @override
  List<Object?> get props => [delayMs];
}

final class MainScreenExecutionUpdateReceived extends MainScreenEvent {
  const MainScreenExecutionUpdateReceived(this.executionSummary);

  final ExecutionSummary executionSummary;

  @override
  List<Object?> get props => [executionSummary];
}
