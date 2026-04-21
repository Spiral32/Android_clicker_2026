import 'package:equatable/equatable.dart';
import 'package:prog_set_touch/core/localization/app_locale.dart';

class AppSettings extends Equatable {
  const AppSettings({
    required this.locale,
    required this.websocketHost,
    required this.websocketPort,
  });

  final AppLocale locale;
  final String websocketHost;
  final int websocketPort;

  factory AppSettings.initial() {
    return const AppSettings(
      locale: AppLocale.ru,
      websocketHost: '',
      websocketPort: 443,
    );
  }

  AppSettings copyWith({
    AppLocale? locale,
    String? websocketHost,
    int? websocketPort,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      websocketHost: websocketHost ?? this.websocketHost,
      websocketPort: websocketPort ?? this.websocketPort,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        websocketHost,
        websocketPort,
      ];
}
