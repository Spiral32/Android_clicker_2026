import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/features/main_screen/domain/app_state.dart';
import 'package:prog_set_touch/features/main_screen/domain/execution_summary.dart';
import 'package:prog_set_touch/features/main_screen/domain/overlay_status.dart';
import 'package:prog_set_touch/features/main_screen/domain/platform_bridge_repository.dart';
import 'package:prog_set_touch/features/main_screen/domain/platform_info.dart';
import 'package:prog_set_touch/features/main_screen/domain/permission_status.dart';
import 'package:prog_set_touch/features/main_screen/domain/permission_type.dart';
import 'package:prog_set_touch/features/main_screen/domain/recorder_summary.dart';
import 'package:prog_set_touch/features/settings/domain/app_settings.dart';
import 'package:prog_set_touch/features/settings/domain/settings_repository.dart';

part 'main_screen_event.dart';
part 'main_screen_state.dart';

class MainScreenBloc extends Bloc<MainScreenEvent, MainScreenState> {
  MainScreenBloc({
    required PlatformBridgeRepository platformBridgeRepository,
    required SettingsRepository settingsRepository,
    required AppLogger logger,
  })  : _platformBridgeRepository = platformBridgeRepository,
        _settingsRepository = settingsRepository,
        _logger = logger,
        super(
          MainScreenState(
            executionDelayMs: settingsRepository.load().executionDelayMs,
          ),
        ) {
    on<MainScreenRequested>(_onRequested);
    on<MainScreenPermissionActionPressed>(_onPermissionActionPressed);
    on<MainScreenOverlayToggleRequested>(_onOverlayToggleRequested);
    on<MainScreenRecorderStartRequested>(_onRecorderStartRequested);
    on<MainScreenRecorderStopRequested>(_onRecorderStopRequested);
    on<MainScreenRecorderClearRequested>(_onRecorderClearRequested);
    on<MainScreenStateRefreshRequested>(_onStateRefreshRequested);
    on<MainScreenStateResetRequested>(_onStateResetRequested);
    on<MainScreenExecutionStartRequested>(_onExecutionStartRequested);
    on<MainScreenExecutionStopRequested>(_onExecutionStopRequested);
    on<MainScreenExecutionPauseRequested>(_onExecutionPauseRequested);
    on<MainScreenExecutionResumeRequested>(_onExecutionResumeRequested);
    on<MainScreenExecutionDelayChanged>(_onExecutionDelayChanged);
    on<MainScreenExecutionUpdateReceived>(_onExecutionUpdateReceived);

    _executionSubscription = _platformBridgeRepository.executionUpdates.listen(
      (summary) => add(MainScreenExecutionUpdateReceived(summary)),
    );
  }

  final PlatformBridgeRepository _platformBridgeRepository;
  final SettingsRepository _settingsRepository;
  final AppLogger _logger;
  int _requestVersion = 0;
  StreamSubscription<ExecutionSummary>? _executionSubscription;

  @override
  Future<void> close() {
    _executionSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRequested(
    MainScreenRequested event,
    Emitter<MainScreenState> emit,
  ) async {
    final requestVersion = ++_requestVersion;
    emit(
      state.copyWith(
        status: MainScreenStatus.loading,
        clearError: true,
        clearPermissionAction: true,
      ),
    );

    try {
      final snapshot = await _loadSnapshot();
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }

      var overlayStatus = snapshot.overlayStatus;

      if (snapshot.permissionStatus.areAllGranted &&
          !overlayStatus.visible &&
          !snapshot.recorderSummary.isRecording) {
        overlayStatus = await _platformBridgeRepository.showOverlay();
        if (!_isRequestCurrent(requestVersion)) {
          return;
        }
      }

      emit(
        state.copyWith(
          status: MainScreenStatus.loaded,
          platformInfo: snapshot.platformInfo,
          permissionStatus: snapshot.permissionStatus,
          overlayStatus: overlayStatus,
          recorderSummary: snapshot.recorderSummary,
          executionSummary: snapshot.executionSummary,
          appState: snapshot.appState,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          status: MainScreenStatus.failure,
          errorKey: 'errorPlatformLoad',
        ),
      );
    }
  }

  Future<void> _onPermissionActionPressed(
    MainScreenPermissionActionPressed event,
    Emitter<MainScreenState> emit,
  ) async {
    final requestVersion = ++_requestVersion;
    emit(state.copyWith(isPermissionActionInProgress: true, clearError: true));

    try {
      switch (event.permissionType) {
        case PermissionType.accessibility:
          await _platformBridgeRepository.openAccessibilitySettings();
          break;
        case PermissionType.overlay:
          await _platformBridgeRepository.openOverlaySettings();
          break;
        case PermissionType.mediaProjection:
          final permissionStatus = await _platformBridgeRepository
              .requestMediaProjectionPermission();
          if (!_isRequestCurrent(requestVersion)) {
            return;
          }
          emit(
            state.copyWith(
              permissionStatus: permissionStatus,
              isPermissionActionInProgress: false,
              clearError: true,
            ),
          );
          return;
      }

      final permissionStatus =
          await _platformBridgeRepository.getPermissionStatus();
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }

      emit(
        state.copyWith(
          permissionStatus: permissionStatus,
          isPermissionActionInProgress: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_permission_action', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          isPermissionActionInProgress: false,
          errorKey: 'errorPermissionAction',
        ),
      );
    }
  }

  Future<void> _onOverlayToggleRequested(
    MainScreenOverlayToggleRequested event,
    Emitter<MainScreenState> emit,
  ) async {
    if (!state.permissionStatus.areAllGranted) {
      return;
    }

    final requestVersion = ++_requestVersion;
    emit(state.copyWith(isOverlayActionInProgress: true, clearError: true));

    try {
      final overlayStatus = state.overlayStatus.visible
          ? await _platformBridgeRepository.hideOverlay()
          : await _platformBridgeRepository.showOverlay();
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }

      emit(
        state.copyWith(
          overlayStatus: overlayStatus,
          isOverlayActionInProgress: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_overlay_action', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          isOverlayActionInProgress: false,
          errorKey: 'errorOverlayAction',
        ),
      );
    }
  }

  Future<void> _onRecorderStartRequested(
    MainScreenRecorderStartRequested event,
    Emitter<MainScreenState> emit,
  ) async {
    if (!state.permissionStatus.areAllGranted) {
      return;
    }

    if (!state.overlayStatus.visible) {
      emit(state.copyWith(errorKey: 'errorRecorderNeedsOverlay'));
      return;
    }

    final requestVersion = ++_requestVersion;
    emit(state.copyWith(isRecorderActionInProgress: true, clearError: true));

    try {
      final recorderSummary = await _platformBridgeRepository.startRecorder(
        mode: event.mode,
      );
      final appState = await _platformBridgeRepository.getCurrentState();
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          recorderSummary: recorderSummary,
          appState: appState,
          isRecorderActionInProgress: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_recorder_start', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          isRecorderActionInProgress: false,
          errorKey: 'errorRecorderAction',
        ),
      );
    }
  }

  Future<void> _onRecorderStopRequested(
    MainScreenRecorderStopRequested event,
    Emitter<MainScreenState> emit,
  ) async {
    final requestVersion = ++_requestVersion;
    emit(state.copyWith(isRecorderActionInProgress: true, clearError: true));

    try {
      final recorderSummary = await _platformBridgeRepository.stopRecorder();
      final results = await Future.wait<Object>([
        _platformBridgeRepository.getExecutionStatus(),
        _platformBridgeRepository.getCurrentState(),
      ]);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }

      emit(
        state.copyWith(
          recorderSummary: recorderSummary,
          executionSummary: results[0] as ExecutionSummary,
          appState: results[1] as AppState,
          isRecorderActionInProgress: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_recorder_stop', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          isRecorderActionInProgress: false,
          errorKey: 'errorRecorderAction',
        ),
      );
    }
  }

  Future<void> _onRecorderClearRequested(
    MainScreenRecorderClearRequested event,
    Emitter<MainScreenState> emit,
  ) async {
    final requestVersion = ++_requestVersion;
    emit(state.copyWith(isRecorderActionInProgress: true, clearError: true));

    try {
      final recorderSummary = await _platformBridgeRepository.clearRecorder();
      final results = await Future.wait<Object>([
        _platformBridgeRepository.getExecutionStatus(),
        _platformBridgeRepository.getCurrentState(),
      ]);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }

      emit(
        state.copyWith(
          recorderSummary: recorderSummary,
          executionSummary: results[0] as ExecutionSummary,
          appState: results[1] as AppState,
          isRecorderActionInProgress: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_recorder_clear', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          isRecorderActionInProgress: false,
          errorKey: 'errorRecorderAction',
        ),
      );
    }
  }

  Future<void> _onStateRefreshRequested(
    MainScreenStateRefreshRequested event,
    Emitter<MainScreenState> emit,
  ) async {
    final requestVersion = ++_requestVersion;
    emit(state.copyWith(isStateActionInProgress: true, clearError: true));

    try {
      final snapshot = await _loadSnapshot();
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          platformInfo: snapshot.platformInfo,
          permissionStatus: snapshot.permissionStatus,
          overlayStatus: snapshot.overlayStatus,
          appState: snapshot.appState,
          recorderSummary: snapshot.recorderSummary,
          executionSummary: snapshot.executionSummary,
          isStateActionInProgress: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_state_refresh', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          isStateActionInProgress: false,
          errorKey: 'errorStateRefresh',
        ),
      );
    }
  }

  Future<void> _onStateResetRequested(
    MainScreenStateResetRequested event,
    Emitter<MainScreenState> emit,
  ) async {
    if (!state.appState.isError) {
      return;
    }

    final requestVersion = ++_requestVersion;
    emit(state.copyWith(isStateActionInProgress: true, clearError: true));

    try {
      final success = await _platformBridgeRepository.resetState();
      if (success) {
        final appState = await _platformBridgeRepository.getCurrentState();
        if (!_isRequestCurrent(requestVersion)) {
          return;
        }
        emit(
          state.copyWith(
            appState: appState,
            isStateActionInProgress: false,
            clearError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isStateActionInProgress: false,
            errorKey: 'errorStateResetFailed',
          ),
        );
      }
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_state_reset', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          isStateActionInProgress: false,
          errorKey: 'errorStateReset',
        ),
      );
    }
  }

  Future<void> _onExecutionStartRequested(
    MainScreenExecutionStartRequested event,
    Emitter<MainScreenState> emit,
  ) async {
    if (!state.permissionStatus.areAllGranted) {
      return;
    }

    if (!state.appState.canExecute) {
      emit(state.copyWith(errorKey: 'errorExecutionNotAllowed'));
      return;
    }

    final requestVersion = ++_requestVersion;
    emit(state.copyWith(isExecutionActionInProgress: true, clearError: true));

    try {
      final executionSummary = await _platformBridgeRepository.startExecution(
        delayMs: state.executionDelayMs,
      );
      final appState = await _platformBridgeRepository.getCurrentState();
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          executionSummary: executionSummary,
          appState: appState,
          isExecutionActionInProgress: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_execution_start', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          isExecutionActionInProgress: false,
          errorKey: 'errorExecutionAction',
        ),
      );
    }
  }

  Future<void> _onExecutionStopRequested(
    MainScreenExecutionStopRequested event,
    Emitter<MainScreenState> emit,
  ) async {
    final requestVersion = ++_requestVersion;
    emit(state.copyWith(isExecutionActionInProgress: true, clearError: true));

    try {
      final executionSummary = await _platformBridgeRepository.stopExecution();
      final appState = await _platformBridgeRepository.getCurrentState();
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          executionSummary: executionSummary,
          appState: appState,
          isExecutionActionInProgress: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_execution_stop', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          isExecutionActionInProgress: false,
          errorKey: 'errorExecutionAction',
        ),
      );
    }
  }

  Future<void> _onExecutionPauseRequested(
    MainScreenExecutionPauseRequested event,
    Emitter<MainScreenState> emit,
  ) async {
    if (!state.appState.isExecuting) {
      return;
    }

    final requestVersion = ++_requestVersion;
    emit(state.copyWith(isExecutionActionInProgress: true, clearError: true));

    try {
      final paused = await _platformBridgeRepository.pauseExecution();
      if (paused) {
        final results = await Future.wait<Object>([
          _platformBridgeRepository.getCurrentState(),
          _platformBridgeRepository.getExecutionStatus(),
        ]);
        if (!_isRequestCurrent(requestVersion)) {
          return;
        }
        emit(
          state.copyWith(
            appState: results[0] as AppState,
            executionSummary: results[1] as ExecutionSummary,
            isExecutionActionInProgress: false,
            clearError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isExecutionActionInProgress: false,
            errorKey: 'errorExecutionPauseFailed',
          ),
        );
      }
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_execution_pause', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          isExecutionActionInProgress: false,
          errorKey: 'errorExecutionAction',
        ),
      );
    }
  }

  Future<void> _onExecutionResumeRequested(
    MainScreenExecutionResumeRequested event,
    Emitter<MainScreenState> emit,
  ) async {
    if (!state.appState.isPaused) {
      return;
    }

    final requestVersion = ++_requestVersion;
    emit(state.copyWith(isExecutionActionInProgress: true, clearError: true));

    try {
      final resumed = await _platformBridgeRepository.resumeExecution();
      if (resumed) {
        final results = await Future.wait<Object>([
          _platformBridgeRepository.getCurrentState(),
          _platformBridgeRepository.getExecutionStatus(),
        ]);
        if (!_isRequestCurrent(requestVersion)) {
          return;
        }
        emit(
          state.copyWith(
            appState: results[0] as AppState,
            executionSummary: results[1] as ExecutionSummary,
            isExecutionActionInProgress: false,
            clearError: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isExecutionActionInProgress: false,
            errorKey: 'errorExecutionResumeFailed',
          ),
        );
      }
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_execution_resume', error, stackTrace);
      if (!_isRequestCurrent(requestVersion)) {
        return;
      }
      emit(
        state.copyWith(
          isExecutionActionInProgress: false,
          errorKey: 'errorExecutionAction',
        ),
      );
    }
  }

  Future<void> _onExecutionDelayChanged(
    MainScreenExecutionDelayChanged event,
    Emitter<MainScreenState> emit,
  ) async {
    try {
      final settings = await _settingsRepository.saveExecutionDelayMs(event.delayMs);
      emit(state.copyWith(executionDelayMs: settings.executionDelayMs));
    } catch (error, stackTrace) {
      _logger.logError('main_screen_bloc_execution_delay', error, stackTrace);
      emit(
        state.copyWith(
          executionDelayMs: AppSettings.normalized(
            locale: AppSettings.defaultLocale,
            executionDelayMs: event.delayMs,
          ).executionDelayMs,
        ),
      );
    }
  }

  Future<void> _onExecutionUpdateReceived(
    MainScreenExecutionUpdateReceived event,
    Emitter<MainScreenState> emit,
  ) async {
    final appState = await _platformBridgeRepository.getCurrentState();
    emit(
      state.copyWith(
        executionSummary: event.executionSummary,
        appState: appState,
      ),
    );
  }

  Future<_MainScreenSnapshot> _loadSnapshot() async {
    final results = await Future.wait<Object>([
      _platformBridgeRepository.getPlatformInfo(),
      _platformBridgeRepository.getPermissionStatus(),
      _platformBridgeRepository.getRecorderStatus(),
      _platformBridgeRepository.getExecutionStatus(),
      _platformBridgeRepository.getCurrentState(),
      _platformBridgeRepository.getOverlayStatus(),
    ]);

    return _MainScreenSnapshot(
      platformInfo: results[0] as PlatformInfo,
      permissionStatus: results[1] as PermissionStatus,
      recorderSummary: results[2] as RecorderSummary,
      executionSummary: results[3] as ExecutionSummary,
      appState: results[4] as AppState,
      overlayStatus: results[5] as OverlayStatus,
    );
  }

  bool _isRequestCurrent(int requestVersion) =>
      !isClosed && requestVersion == _requestVersion;
}

class _MainScreenSnapshot {
  const _MainScreenSnapshot({
    required this.platformInfo,
    required this.permissionStatus,
    required this.recorderSummary,
    required this.executionSummary,
    required this.appState,
    required this.overlayStatus,
  });

  final PlatformInfo platformInfo;
  final PermissionStatus permissionStatus;
  final RecorderSummary recorderSummary;
  final ExecutionSummary executionSummary;
  final AppState appState;
  final OverlayStatus overlayStatus;
}
