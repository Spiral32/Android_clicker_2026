part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.locale,
    this.autostartEnabled = true,
    this.loggingEnabled = true,
    this.logToFileEnabled = true,
    this.isNativeSettingsLoading = true,
    this.isAutostartBusy = false,
    this.isLoggingBusy = false,
    this.errorKey,
  });

  final AppLocale locale;
  final bool autostartEnabled;
  final bool loggingEnabled;
  final bool logToFileEnabled;
  final bool isNativeSettingsLoading;
  final bool isAutostartBusy;
  final bool isLoggingBusy;
  final String? errorKey;

  factory SettingsState.initial() {
    return const SettingsState(locale: AppLocale.ru);
  }

  factory SettingsState.fromSettings(AppSettings settings) {
    return SettingsState(locale: settings.locale);
  }

  SettingsState copyWith({
    AppLocale? locale,
    bool? autostartEnabled,
    bool? loggingEnabled,
    bool? logToFileEnabled,
    bool? isNativeSettingsLoading,
    bool? isAutostartBusy,
    bool? isLoggingBusy,
    String? errorKey,
    bool clearError = false,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      autostartEnabled: autostartEnabled ?? this.autostartEnabled,
      loggingEnabled: loggingEnabled ?? this.loggingEnabled,
      logToFileEnabled: logToFileEnabled ?? this.logToFileEnabled,
      isNativeSettingsLoading:
          isNativeSettingsLoading ?? this.isNativeSettingsLoading,
      isAutostartBusy: isAutostartBusy ?? this.isAutostartBusy,
      isLoggingBusy: isLoggingBusy ?? this.isLoggingBusy,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
    );
  }

  @override
  List<Object?> get props => [
        locale,
        autostartEnabled,
        loggingEnabled,
        logToFileEnabled,
        isNativeSettingsLoading,
        isAutostartBusy,
        isLoggingBusy,
        errorKey,
      ];
}
