part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({
    required this.locale,
  });

  final AppLocale locale;

  factory SettingsState.initial() {
    return const SettingsState(locale: AppLocale.ru);
  }

  factory SettingsState.fromSettings(AppSettings settings) {
    return SettingsState(locale: settings.locale);
  }

  SettingsState copyWith({
    AppLocale? locale,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [locale];
}
