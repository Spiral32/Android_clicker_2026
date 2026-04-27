import 'package:prog_set_touch/core/localization/app_locale.dart';
import 'package:prog_set_touch/features/settings/domain/app_settings.dart';

abstract class SettingsRepository {
  AppSettings load();

  Future<AppSettings> saveLocale(AppLocale locale);

  Future<AppSettings> saveExecutionDelayMs(int delayMs);
}
