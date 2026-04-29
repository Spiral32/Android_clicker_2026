import 'package:equatable/equatable.dart';
import 'package:prog_set_touch/core/localization/app_locale.dart';

class AppSettings extends Equatable {
  static const int minExecutionDelayMs = 1000;
  static const int maxExecutionDelayMs = 120000;
  static const AppLocale defaultLocale = AppLocale.ru;

  const AppSettings({
    required this.locale,
    required this.executionDelayMs,
    required this.restoreAppAfterExecution,
    required this.globalVerificationEnabled,
  });

  final AppLocale locale;
  final int executionDelayMs;
  final bool restoreAppAfterExecution;
  final bool globalVerificationEnabled;

  factory AppSettings.initial() {
    return const AppSettings(
      locale: defaultLocale,
      executionDelayMs: minExecutionDelayMs,
      restoreAppAfterExecution: true,
      globalVerificationEnabled: true,
    );
  }

  factory AppSettings.normalized({
    required AppLocale locale,
    required int executionDelayMs,
    required bool restoreAppAfterExecution,
    required bool globalVerificationEnabled,
  }) {
    return AppSettings(
      locale: locale,
      executionDelayMs: executionDelayMs
          .clamp(
            minExecutionDelayMs,
            maxExecutionDelayMs,
          )
          .toInt(),
      restoreAppAfterExecution: restoreAppAfterExecution,
      globalVerificationEnabled: globalVerificationEnabled,
    );
  }

  AppSettings copyWith({
    AppLocale? locale,
    int? executionDelayMs,
    bool? restoreAppAfterExecution,
    bool? globalVerificationEnabled,
  }) {
    return AppSettings.normalized(
      locale: locale ?? this.locale,
      executionDelayMs: executionDelayMs ?? this.executionDelayMs,
      restoreAppAfterExecution:
          restoreAppAfterExecution ?? this.restoreAppAfterExecution,
      globalVerificationEnabled:
          globalVerificationEnabled ?? this.globalVerificationEnabled,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        executionDelayMs,
        restoreAppAfterExecution,
        globalVerificationEnabled,
      ];
}
