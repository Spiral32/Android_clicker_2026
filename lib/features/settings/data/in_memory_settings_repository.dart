import 'package:prog_set_touch/core/localization/app_locale.dart';
import 'package:prog_set_touch/features/settings/domain/app_settings.dart';

class InMemorySettingsRepository {
  AppSettings _settings = AppSettings.initial();

  AppSettings current() => _settings;

  AppSettings updateLocale(AppLocale locale) {
    _settings = _settings.copyWith(locale: locale);
    return _settings;
  }
}
