part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.locale,
    this.autostartEnabled = true,
    this.loggingEnabled = true,
    this.logToFileEnabled = true,
    this.restoreAppAfterExecution = true,
    this.globalVerificationEnabled = true,
    this.isNativeSettingsLoading = true,
    this.isAutostartBusy = false,
    this.isLoggingBusy = false,
    this.isRestoreAppBusy = false,
    this.isGlobalVerificationBusy = false,
    this.webSocketStatus = const WebSocketStatus(),
    this.isWebSocketLoading = true,
    this.isWebSocketBusy = false,
    this.webSocketError,
    this.errorKey,
  });

  final AppLocale locale;
  final bool autostartEnabled;
  final bool loggingEnabled;
  final bool logToFileEnabled;
  final bool restoreAppAfterExecution;
  final bool globalVerificationEnabled;
  final bool isNativeSettingsLoading;
  final bool isAutostartBusy;
  final bool isLoggingBusy;
  final bool isRestoreAppBusy;
  final bool isGlobalVerificationBusy;
  final WebSocketStatus webSocketStatus;
  final bool isWebSocketLoading;
  final bool isWebSocketBusy;
  final String? webSocketError;
  final String? errorKey;

  factory SettingsState.initial() {
    return const SettingsState(locale: AppLocale.ru);
  }

  factory SettingsState.fromSettings(AppSettings settings) {
    return SettingsState(
      locale: settings.locale,
      restoreAppAfterExecution: settings.restoreAppAfterExecution,
      globalVerificationEnabled: settings.globalVerificationEnabled,
    );
  }

  SettingsState copyWith({
    AppLocale? locale,
    bool? autostartEnabled,
    bool? loggingEnabled,
    bool? logToFileEnabled,
    bool? restoreAppAfterExecution,
    bool? globalVerificationEnabled,
    bool? isNativeSettingsLoading,
    bool? isAutostartBusy,
    bool? isLoggingBusy,
    bool? isRestoreAppBusy,
    bool? isGlobalVerificationBusy,
    WebSocketStatus? webSocketStatus,
    bool? isWebSocketLoading,
    bool? isWebSocketBusy,
    String? webSocketError,
    bool clearWebSocketError = false,
    String? errorKey,
    bool clearError = false,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      autostartEnabled: autostartEnabled ?? this.autostartEnabled,
      loggingEnabled: loggingEnabled ?? this.loggingEnabled,
      logToFileEnabled: logToFileEnabled ?? this.logToFileEnabled,
      restoreAppAfterExecution:
          restoreAppAfterExecution ?? this.restoreAppAfterExecution,
      globalVerificationEnabled:
          globalVerificationEnabled ?? this.globalVerificationEnabled,
      isNativeSettingsLoading:
          isNativeSettingsLoading ?? this.isNativeSettingsLoading,
      isAutostartBusy: isAutostartBusy ?? this.isAutostartBusy,
      isLoggingBusy: isLoggingBusy ?? this.isLoggingBusy,
      isRestoreAppBusy: isRestoreAppBusy ?? this.isRestoreAppBusy,
      isGlobalVerificationBusy:
          isGlobalVerificationBusy ?? this.isGlobalVerificationBusy,
      webSocketStatus: webSocketStatus ?? this.webSocketStatus,
      isWebSocketLoading: isWebSocketLoading ?? this.isWebSocketLoading,
      isWebSocketBusy: isWebSocketBusy ?? this.isWebSocketBusy,
      webSocketError:
          clearWebSocketError ? null : (webSocketError ?? this.webSocketError),
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
    );
  }

  @override
  List<Object?> get props => [
        locale,
        autostartEnabled,
        loggingEnabled,
        logToFileEnabled,
        restoreAppAfterExecution,
        globalVerificationEnabled,
        isNativeSettingsLoading,
        isAutostartBusy,
        isLoggingBusy,
        isRestoreAppBusy,
        isGlobalVerificationBusy,
        webSocketStatus,
        isWebSocketLoading,
        isWebSocketBusy,
        webSocketError,
        errorKey,
      ];
}
