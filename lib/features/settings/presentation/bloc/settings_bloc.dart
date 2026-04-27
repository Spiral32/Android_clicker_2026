import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/core/localization/app_locale.dart';
import 'package:prog_set_touch/features/main_screen/domain/platform_bridge_repository.dart';
import 'package:prog_set_touch/features/settings/domain/app_settings.dart';
import 'package:prog_set_touch/features/settings/domain/settings_repository.dart';
import 'package:prog_set_touch/features/settings/domain/web_socket_status.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required AppLogger logger,
    required SettingsRepository repository,
    required PlatformBridgeRepository platformBridgeRepository,
  })  : _logger = logger,
        _repository = repository,
        _platformBridgeRepository = platformBridgeRepository,
        super(SettingsState.fromSettings(repository.load())) {
    on<SettingsLocaleChanged>(_onLocaleChanged);
    on<SettingsNativeStatusRequested>(_onNativeStatusRequested);
    on<SettingsAutostartToggled>(_onAutostartToggled);
    on<SettingsLoggingToggled>(_onLoggingToggled);
    on<SettingsLogToFileToggled>(_onLogToFileToggled);
    on<SettingsWebSocketStatusRequested>(_onWebSocketStatusRequested);
    on<SettingsWebSocketEnabledToggled>(_onWebSocketEnabledToggled);
    on<SettingsWebSocketPortSubmitted>(_onWebSocketPortSubmitted);
    on<SettingsWebSocketTokenRegenerated>(_onWebSocketTokenRegenerated);
  }

  final AppLogger _logger;
  final SettingsRepository _repository;
  final PlatformBridgeRepository _platformBridgeRepository;

  Future<void> _onLocaleChanged(
    SettingsLocaleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final settings = await _repository.saveLocale(event.locale);
      emit(state.copyWith(locale: settings.locale));
    } catch (error, stackTrace) {
      _logger.logError('settings_bloc', error, stackTrace);
    }
  }

  Future<void> _onNativeStatusRequested(
    SettingsNativeStatusRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isNativeSettingsLoading: true, clearError: true));
      final results = await Future.wait<Object>([
        _platformBridgeRepository.getAutostartEnabled(),
        _platformBridgeRepository.getLoggingEnabled(),
        _platformBridgeRepository.getLogToFileEnabled(),
      ]);
      emit(
        state.copyWith(
          autostartEnabled: results[0] as bool,
          loggingEnabled: results[1] as bool,
          logToFileEnabled: results[2] as bool,
          isNativeSettingsLoading: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('settings_bloc_native_status', error, stackTrace);
      emit(
        state.copyWith(
          isNativeSettingsLoading: false,
          errorKey: 'settingsNativeStatusLoadError',
        ),
      );
    }
  }

  Future<void> _onAutostartToggled(
    SettingsAutostartToggled event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isAutostartBusy: true, clearError: true));
      await _platformBridgeRepository.setAutostartEnabled(event.enabled);
      emit(
        state.copyWith(
          autostartEnabled: event.enabled,
          isAutostartBusy: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('settings_bloc_autostart', error, stackTrace);
      emit(
        state.copyWith(
          isAutostartBusy: false,
          errorKey: 'settingsAutostartChangeError',
        ),
      );
    }
  }

  Future<void> _onLoggingToggled(
    SettingsLoggingToggled event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoggingBusy: true, clearError: true));
      await _platformBridgeRepository.setLoggingEnabled(event.enabled);
      emit(
        state.copyWith(
          loggingEnabled: event.enabled,
          isLoggingBusy: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('settings_bloc_logging', error, stackTrace);
      emit(
        state.copyWith(
          isLoggingBusy: false,
          errorKey: 'settingsLoggingChangeError',
        ),
      );
    }
  }

  Future<void> _onLogToFileToggled(
    SettingsLogToFileToggled event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoggingBusy: true, clearError: true));
      await _platformBridgeRepository.setLogToFileEnabled(event.enabled);
      emit(
        state.copyWith(
          logToFileEnabled: event.enabled,
          isLoggingBusy: false,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('settings_bloc_log_to_file', error, stackTrace);
      emit(
        state.copyWith(
          isLoggingBusy: false,
          errorKey: 'settingsLogToFileChangeError',
        ),
      );
    }
  }

  Future<void> _onWebSocketStatusRequested(
    SettingsWebSocketStatusRequested event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isWebSocketLoading: true,
          clearWebSocketError: true,
        ),
      );
      final status = await _platformBridgeRepository.getWebSocketStatus();
      emit(
        state.copyWith(
          webSocketStatus: status,
          isWebSocketLoading: false,
          clearWebSocketError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('settings_bloc_websocket_status', error, stackTrace);
      emit(
        state.copyWith(
          isWebSocketLoading: false,
          webSocketError: _formatWebSocketError(error),
        ),
      );
    }
  }

  Future<void> _onWebSocketEnabledToggled(
    SettingsWebSocketEnabledToggled event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isWebSocketBusy: true, clearWebSocketError: true));
      final status =
          await _platformBridgeRepository.setWebSocketEnabled(event.enabled);
      emit(
        state.copyWith(
          webSocketStatus: status,
          isWebSocketBusy: false,
          clearWebSocketError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('settings_bloc_websocket_toggle', error, stackTrace);
      emit(
        state.copyWith(
          isWebSocketBusy: false,
          webSocketError: _formatWebSocketError(error),
        ),
      );
    }
  }

  Future<void> _onWebSocketPortSubmitted(
    SettingsWebSocketPortSubmitted event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isWebSocketBusy: true, clearWebSocketError: true));
      final status = await _platformBridgeRepository.setWebSocketPort(event.port);
      emit(
        state.copyWith(
          webSocketStatus: status,
          isWebSocketBusy: false,
          clearWebSocketError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('settings_bloc_websocket_port', error, stackTrace);
      emit(
        state.copyWith(
          isWebSocketBusy: false,
          webSocketError: _formatWebSocketError(error),
        ),
      );
    }
  }

  Future<void> _onWebSocketTokenRegenerated(
    SettingsWebSocketTokenRegenerated event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isWebSocketBusy: true, clearWebSocketError: true));
      final status = await _platformBridgeRepository.regenerateWebSocketToken();
      emit(
        state.copyWith(
          webSocketStatus: status,
          isWebSocketBusy: false,
          clearWebSocketError: true,
        ),
      );
    } catch (error, stackTrace) {
      _logger.logError('settings_bloc_websocket_token', error, stackTrace);
      emit(
        state.copyWith(
          isWebSocketBusy: false,
          webSocketError: _formatWebSocketError(error),
        ),
      );
    }
  }

  String _formatWebSocketError(Object error) {
    if (error is TimeoutException) {
      return 'websocket_timeout';
    }
    return 'websocket_error:$error';
  }
}
