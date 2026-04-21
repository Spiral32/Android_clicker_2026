part of 'main_screen_bloc.dart';

enum MainScreenStatus {
  initial,
  loading,
  loaded,
  failure,
}

class MainScreenState extends Equatable {
  const MainScreenState({
    this.status = MainScreenStatus.initial,
    this.platformInfo,
    this.permissionStatus = const PermissionStatus.initial(),
    this.overlayStatus = const OverlayStatus.initial(),
    this.recorderSummary = const RecorderSummary.initial(),
    this.executionSummary = const ExecutionSummary.initial(),
    this.appState = const AppState.initial(),
    this.errorKey,
    this.isPermissionActionInProgress = false,
    this.isOverlayActionInProgress = false,
    this.isRecorderActionInProgress = false,
    this.isExecutionActionInProgress = false,
    this.isStateActionInProgress = false,
    this.executionDelayMs = 1000,
  });

  final MainScreenStatus status;
  final PlatformInfo? platformInfo;
  final PermissionStatus permissionStatus;
  final OverlayStatus overlayStatus;
  final RecorderSummary recorderSummary;
  final ExecutionSummary executionSummary;
  final AppState appState;
  final String? errorKey;
  final bool isPermissionActionInProgress;
  final bool isOverlayActionInProgress;
  final bool isRecorderActionInProgress;
  final bool isExecutionActionInProgress;
  final bool isStateActionInProgress;
  final int executionDelayMs;

  MainScreenState copyWith({
    MainScreenStatus? status,
    PlatformInfo? platformInfo,
    PermissionStatus? permissionStatus,
    OverlayStatus? overlayStatus,
    RecorderSummary? recorderSummary,
    ExecutionSummary? executionSummary,
    AppState? appState,
    String? errorKey,
    bool clearError = false,
    bool? isPermissionActionInProgress,
    bool? isOverlayActionInProgress,
    bool? isRecorderActionInProgress,
    bool? isExecutionActionInProgress,
    bool? isStateActionInProgress,
    bool clearPermissionAction = false,
    int? executionDelayMs,
  }) {
    return MainScreenState(
      status: status ?? this.status,
      platformInfo: platformInfo ?? this.platformInfo,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      overlayStatus: overlayStatus ?? this.overlayStatus,
      recorderSummary: recorderSummary ?? this.recorderSummary,
      executionSummary: executionSummary ?? this.executionSummary,
      appState: appState ?? this.appState,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
      isPermissionActionInProgress:
          clearPermissionAction ? false : (isPermissionActionInProgress ?? this.isPermissionActionInProgress),
      isOverlayActionInProgress:
          isOverlayActionInProgress ?? this.isOverlayActionInProgress,
      isRecorderActionInProgress:
          isRecorderActionInProgress ?? this.isRecorderActionInProgress,
      isExecutionActionInProgress:
          isExecutionActionInProgress ?? this.isExecutionActionInProgress,
      isStateActionInProgress:
          isStateActionInProgress ?? this.isStateActionInProgress,
      executionDelayMs: executionDelayMs ?? this.executionDelayMs,
    );
  }

  @override
  List<Object?> get props => [
        status,
        platformInfo,
        permissionStatus,
        overlayStatus,
        recorderSummary,
        executionSummary,
        appState,
        errorKey,
        isPermissionActionInProgress,
        isOverlayActionInProgress,
        isRecorderActionInProgress,
        isExecutionActionInProgress,
        isStateActionInProgress,
        executionDelayMs,
      ];
}
