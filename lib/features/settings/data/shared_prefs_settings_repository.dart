import 'package:prog_set_touch/core/localization/app_locale.dart';
import 'package:prog_set_touch/features/settings/domain/app_settings.dart';
import 'package:prog_set_touch/features/settings/domain/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._prefs);

  static const _localeKey = 'app_locale';
  static const _executionDelayMsKey = 'execution_delay_ms';
  final SharedPreferences _prefs;

  @override
  AppSettings load() {
    final localeCode = _prefs.getString(_localeKey);
    final executionDelayMs =
        _prefs.getInt(_executionDelayMsKey) ?? AppSettings.initial().executionDelayMs;
    return AppSettings.initial().copyWith(
      locale: localeCode == null
          ? AppLocale.ru
          : AppLocale.fromLanguageCode(localeCode),
      executionDelayMs: executionDelayMs,
    );
  }

  @override
  Future<AppSettings> saveLocale(AppLocale locale) async {
    await _prefs.setString(_localeKey, locale.locale.languageCode);
    return load();
  }

  @override
  Future<AppSettings> saveExecutionDelayMs(int delayMs) async {
    await _prefs.setInt(_executionDelayMsKey, delayMs);
    return load();
  }
}
