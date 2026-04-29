import 'package:prog_set_touch/core/localization/app_locale.dart';
import 'package:prog_set_touch/features/settings/domain/app_settings.dart';
import 'package:prog_set_touch/features/settings/domain/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  SharedPrefsSettingsRepository(this._prefs);

  static const _localeKey = 'app_locale';
  static const _executionDelayMsKey = 'execution_delay_ms';
  static const _restoreAppAfterExecutionKey = 'restore_app_after_execution';
  static const _globalVerificationEnabledKey = 'global_verification_enabled';
  final SharedPreferences _prefs;

  @override
  AppSettings load() {
    final localeCode = _prefs.getString(_localeKey);
    final locale = localeCode == null
        ? AppSettings.defaultLocale
        : AppLocale.fromLanguageCode(localeCode);
    final executionDelayMs = _prefs.getInt(_executionDelayMsKey) ??
        AppSettings.initial().executionDelayMs;
    final restoreAppAfterExecution =
        _prefs.getBool(_restoreAppAfterExecutionKey) ??
            AppSettings.initial().restoreAppAfterExecution;
    final globalVerificationEnabled =
        _prefs.getBool(_globalVerificationEnabledKey) ??
            AppSettings.initial().globalVerificationEnabled;

    return AppSettings.normalized(
      locale: locale,
      executionDelayMs: executionDelayMs,
      restoreAppAfterExecution: restoreAppAfterExecution,
      globalVerificationEnabled: globalVerificationEnabled,
    );
  }

  @override
  Future<AppSettings> saveLocale(AppLocale locale) async {
    await _prefs.setString(_localeKey, locale.locale.languageCode);
    return load();
  }

  @override
  Future<AppSettings> saveExecutionDelayMs(int delayMs) async {
    final normalizedDelayMs = delayMs
        .clamp(
          AppSettings.minExecutionDelayMs,
          AppSettings.maxExecutionDelayMs,
        )
        .toInt();
    await _prefs.setInt(_executionDelayMsKey, normalizedDelayMs);
    return load();
  }

  @override
  Future<AppSettings> saveRestoreAppAfterExecution(bool restore) async {
    await _prefs.setBool(_restoreAppAfterExecutionKey, restore);
    return load();
  }

  @override
  Future<AppSettings> saveGlobalVerificationEnabled(bool enabled) async {
    await _prefs.setBool(_globalVerificationEnabledKey, enabled);
    return load();
  }
}
