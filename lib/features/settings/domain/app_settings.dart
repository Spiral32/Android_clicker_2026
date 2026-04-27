import 'package:equatable/equatable.dart';
import 'package:prog_set_touch/core/localization/app_locale.dart';

class AppSettings extends Equatable {
  const AppSettings({
    required this.locale,
    required this.executionDelayMs,
  });

  final AppLocale locale;
  final int executionDelayMs;

  factory AppSettings.initial() {
    return const AppSettings(
      locale: AppLocale.ru,
      executionDelayMs: 1000,
    );
  }

  AppSettings copyWith({
    AppLocale? locale,
    int? executionDelayMs,
  }) {
    return AppSettings(
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
