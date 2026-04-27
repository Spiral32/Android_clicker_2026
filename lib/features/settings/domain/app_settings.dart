import 'package:equatable/equatable.dart';
import 'package:prog_set_touch/core/localization/app_locale.dart';

class AppSettings extends Equatable {
  static const int minExecutionDelayMs = 1000;
  static const int maxExecutionDelayMs = 120000;
  static const AppLocale defaultLocale = AppLocale.ru;

  const AppSettings({
    required this.locale,
    required this.executionDelayMs,
  });

  final AppLocale locale;
  final int executionDelayMs;

  factory AppSettings.initial() {
    return const AppSettings(
      locale: defaultLocale,
      executionDelayMs: minExecutionDelayMs,
    );
  }

  factory AppSettings.normalized({
    required AppLocale locale,
    required int executionDelayMs,
  }) {
    return AppSettings(
      locale: locale,
      executionDelayMs: executionDelayMs
          .clamp(
            minExecutionDelayMs,
            maxExecutionDelayMs,
          )
          .toInt(),
    );
  }

  AppSettings copyWith({
    AppLocale? locale,
    int? executionDelayMs,
  }) {
    return AppSettings.normalized(
      locale: locale ?? this.locale,
      executionDelayMs: executionDelayMs ?? this.executionDelayMs,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        executionDelayMs,
      ];
}
