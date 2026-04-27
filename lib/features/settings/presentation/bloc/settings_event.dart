part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class SettingsLocaleChanged extends SettingsEvent {
  const SettingsLocaleChanged(this.locale);

  final AppLocale locale;

  @override
  List<Object?> get props => [locale];
}

final class SettingsNativeStatusRequested extends SettingsEvent {
  const SettingsNativeStatusRequested();
}

final class SettingsAutostartToggled extends SettingsEvent {
  const SettingsAutostartToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

final class SettingsLoggingToggled extends SettingsEvent {
  const SettingsLoggingToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

final class SettingsLogToFileToggled extends SettingsEvent {
  const SettingsLogToFileToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}
