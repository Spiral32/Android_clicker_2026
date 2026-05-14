import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Prog Set Touch'**
  String get appTitle;

  /// No description provided for @mainScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Prog Set Touch'**
  String get mainScreenTitle;

  /// No description provided for @mainScreenSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Базовый экран автоматизации'**
  String get mainScreenSubtitle;

  /// No description provided for @mainPrimaryAction.
  ///
  /// In ru, this message translates to:
  /// **'Настройка нажатий'**
  String get mainPrimaryAction;

  /// No description provided for @mainRecordingStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать запись'**
  String get mainRecordingStart;

  /// No description provided for @mainRecordingStop.
  ///
  /// In ru, this message translates to:
  /// **'Остановить запись'**
  String get mainRecordingStop;

  /// No description provided for @mainTestAction.
  ///
  /// In ru, this message translates to:
  /// **'Тест'**
  String get mainTestAction;

  /// No description provided for @mainAutostartAction.
  ///
  /// In ru, this message translates to:
  /// **'Автозапуск'**
  String get mainAutostartAction;

  /// No description provided for @mainAutostartActionEnable.
  ///
  /// In ru, this message translates to:
  /// **'Включить плавающую кнопку'**
  String get mainAutostartActionEnable;

  /// No description provided for @mainAutostartActionDisable.
  ///
  /// In ru, this message translates to:
  /// **'Выключить плавающую кнопку'**
  String get mainAutostartActionDisable;

  /// No description provided for @mainOpenSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get mainOpenSettings;

  /// No description provided for @mainRecorderTip.
  ///
  /// In ru, this message translates to:
  /// **'Запись работает в пошаговом неблокирующем режиме. После старта используйте панель записи поверх экрана, чтобы добавлять тапы, двойные тапы, долгие нажатия и свайпы.'**
  String get mainRecorderTip;

  /// No description provided for @mainRecorderOpenPanel.
  ///
  /// In ru, this message translates to:
  /// **'Открыть панель записи'**
  String get mainRecorderOpenPanel;

  /// No description provided for @mainRecorderStopPanel.
  ///
  /// In ru, this message translates to:
  /// **'Завершить запись'**
  String get mainRecorderStopPanel;

  /// No description provided for @mainPlatformSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Состояние платформы'**
  String get mainPlatformSectionTitle;

  /// No description provided for @mainPlatformUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Данные платформы недоступны'**
  String get mainPlatformUnavailable;

  /// No description provided for @mainPlatformLabel.
  ///
  /// In ru, this message translates to:
  /// **'Платформа'**
  String get mainPlatformLabel;

  /// No description provided for @mainManufacturerLabel.
  ///
  /// In ru, this message translates to:
  /// **'Производитель'**
  String get mainManufacturerLabel;

  /// No description provided for @mainModelLabel.
  ///
  /// In ru, this message translates to:
  /// **'Модель'**
  String get mainModelLabel;

  /// No description provided for @mainSdkLabel.
  ///
  /// In ru, this message translates to:
  /// **'SDK'**
  String get mainSdkLabel;

  /// No description provided for @mainLocaleLabel.
  ///
  /// In ru, this message translates to:
  /// **'Системный язык'**
  String get mainLocaleLabel;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Выберите язык приложения.'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRussian;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsAutostartTitle.
  ///
  /// In ru, this message translates to:
  /// **'Автозапуск'**
  String get settingsAutostartTitle;

  /// No description provided for @settingsAutostartSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Управляйте восстановлением расписаний после перезагрузки устройства.'**
  String get settingsAutostartSubtitle;

  /// No description provided for @settingsAutostartToggleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Включить автозапуск после перезагрузки'**
  String get settingsAutostartToggleTitle;

  /// No description provided for @settingsAutostartToggleSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Если выключено, BOOT_COMPLETED не восстанавливает расписания автоматически.'**
  String get settingsAutostartToggleSubtitle;

  /// No description provided for @settingsAutostartEnabledMessage.
  ///
  /// In ru, this message translates to:
  /// **'Автозапуск после перезагрузки включен.'**
  String get settingsAutostartEnabledMessage;

  /// No description provided for @settingsAutostartDisabledMessage.
  ///
  /// In ru, this message translates to:
  /// **'Автозапуск после перезагрузки отключен.'**
  String get settingsAutostartDisabledMessage;

  /// No description provided for @settingsAutostartChangeError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось изменить автозапуск.'**
  String get settingsAutostartChangeError;

  /// No description provided for @settingsMediaProjectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'MediaProjection'**
  String get settingsMediaProjectionTitle;

  /// No description provided for @settingsMediaProjectionSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Разрешение нужно только для функций захвата экрана и проверки скриншотов.'**
  String get settingsMediaProjectionSubtitle;

  /// No description provided for @settingsMediaProjectionStatusGranted.
  ///
  /// In ru, this message translates to:
  /// **'Статус: разрешение выдано'**
  String get settingsMediaProjectionStatusGranted;

  /// No description provided for @settingsMediaProjectionStatusMissing.
  ///
  /// In ru, this message translates to:
  /// **'Статус: разрешение не выдано'**
  String get settingsMediaProjectionStatusMissing;

  /// No description provided for @settingsMediaProjectionRequestAction.
  ///
  /// In ru, this message translates to:
  /// **'Запросить MediaProjection вручную'**
  String get settingsMediaProjectionRequestAction;

  /// No description provided for @settingsMediaProjectionGrantedMessage.
  ///
  /// In ru, this message translates to:
  /// **'MediaProjection разрешение получено.'**
  String get settingsMediaProjectionGrantedMessage;

  /// No description provided for @settingsMediaProjectionDeniedMessage.
  ///
  /// In ru, this message translates to:
  /// **'MediaProjection разрешение не получено.'**
  String get settingsMediaProjectionDeniedMessage;

  /// No description provided for @settingsMediaProjectionRequestError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось запросить MediaProjection.'**
  String get settingsMediaProjectionRequestError;

  /// No description provided for @settingsExactAlarmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Точные будильники'**
  String get settingsExactAlarmTitle;

  /// No description provided for @settingsExactAlarmSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Для максимально точного срабатывания расписания разрешите точные будильники в системных настройках Android.'**
  String get settingsExactAlarmSubtitle;

  /// No description provided for @settingsExactAlarmStatusAllowed.
  ///
  /// In ru, this message translates to:
  /// **'Статус: точные будильники разрешены'**
  String get settingsExactAlarmStatusAllowed;

  /// No description provided for @settingsExactAlarmStatusLimited.
  ///
  /// In ru, this message translates to:
  /// **'Статус: точные будильники ограничены, возможна задержка запуска'**
  String get settingsExactAlarmStatusLimited;

  /// No description provided for @settingsExactAlarmOpenAction.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки точных будильников'**
  String get settingsExactAlarmOpenAction;

  /// No description provided for @settingsExactAlarmOpenError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть настройки точных будильников.'**
  String get settingsExactAlarmOpenError;

  /// No description provided for @settingsDiagnosticsLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить диагностику.'**
  String get settingsDiagnosticsLoadError;

  /// No description provided for @settingsLogExportedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Лог экспортирован в папку Download.'**
  String get settingsLogExportedMessage;

  /// No description provided for @settingsLogExportError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось экспортировать лог.'**
  String get settingsLogExportError;

  /// No description provided for @settingsLogOpenLocationError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть расположение лог-файла.'**
  String get settingsLogOpenLocationError;

  /// No description provided for @settingsLogClearedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Буфер логов очищен.'**
  String get settingsLogClearedMessage;

  /// No description provided for @settingsLogClearError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось очистить лог.'**
  String get settingsLogClearError;

  /// No description provided for @settingsWebSocketTitle.
  ///
  /// In ru, this message translates to:
  /// **'WebSocket'**
  String get settingsWebSocketTitle;

  /// No description provided for @settingsWebSocketSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Управляйте встроенным сервером для удалённых команд и диагностики.'**
  String get settingsWebSocketSubtitle;

  /// No description provided for @settingsWebSocketEnableTitle.
  ///
  /// In ru, this message translates to:
  /// **'Включить сервер'**
  String get settingsWebSocketEnableTitle;

  /// No description provided for @settingsWebSocketEnableSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Запускает WebSocket-сервер с одним клиентом и токен-авторизацией (предпочтительно через Authorization: Bearer).'**
  String get settingsWebSocketEnableSubtitle;

  /// No description provided for @settingsWebSocketEnableAction.
  ///
  /// In ru, this message translates to:
  /// **'Включить сервер'**
  String get settingsWebSocketEnableAction;

  /// No description provided for @settingsWebSocketDisableAction.
  ///
  /// In ru, this message translates to:
  /// **'Выключить сервер'**
  String get settingsWebSocketDisableAction;

  /// No description provided for @settingsWebSocketRunningLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сервер'**
  String get settingsWebSocketRunningLabel;

  /// No description provided for @settingsWebSocketStatusRunning.
  ///
  /// In ru, this message translates to:
  /// **'запущен'**
  String get settingsWebSocketStatusRunning;

  /// No description provided for @settingsWebSocketStatusStopped.
  ///
  /// In ru, this message translates to:
  /// **'остановлен'**
  String get settingsWebSocketStatusStopped;

  /// No description provided for @settingsWebSocketClientLabel.
  ///
  /// In ru, this message translates to:
  /// **'Клиент'**
  String get settingsWebSocketClientLabel;

  /// No description provided for @settingsWebSocketStatusClientConnected.
  ///
  /// In ru, this message translates to:
  /// **'подключен'**
  String get settingsWebSocketStatusClientConnected;

  /// No description provided for @settingsWebSocketStatusNoClient.
  ///
  /// In ru, this message translates to:
  /// **'нет клиента'**
  String get settingsWebSocketStatusNoClient;

  /// No description provided for @settingsWebSocketTransportLabel.
  ///
  /// In ru, this message translates to:
  /// **'Транспорт'**
  String get settingsWebSocketTransportLabel;

  /// No description provided for @settingsWebSocketAuthLabel.
  ///
  /// In ru, this message translates to:
  /// **'Защита'**
  String get settingsWebSocketAuthLabel;

  /// No description provided for @settingsWebSocketAuthModeQueryToken.
  ///
  /// In ru, this message translates to:
  /// **'bearer token'**
  String get settingsWebSocketAuthModeQueryToken;

  /// No description provided for @settingsWebSocketPortLabel.
  ///
  /// In ru, this message translates to:
  /// **'Порт'**
  String get settingsWebSocketPortLabel;

  /// No description provided for @settingsWebSocketApplyPort.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get settingsWebSocketApplyPort;

  /// No description provided for @settingsWebSocketTokenLabel.
  ///
  /// In ru, this message translates to:
  /// **'Токен доступа'**
  String get settingsWebSocketTokenLabel;

  /// No description provided for @settingsWebSocketRegenerateToken.
  ///
  /// In ru, this message translates to:
  /// **'Пересоздать токен'**
  String get settingsWebSocketRegenerateToken;

  /// No description provided for @settingsWebSocketUrlsLabel.
  ///
  /// In ru, this message translates to:
  /// **'URL подключения'**
  String get settingsWebSocketUrlsLabel;

  /// No description provided for @settingsWebSocketRefreshAction.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get settingsWebSocketRefreshAction;

  /// No description provided for @settingsWebSocketUnavailableAddress.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас нет доступного локального IPv4-адреса.'**
  String get settingsWebSocketUnavailableAddress;

  /// No description provided for @settingsWebSocketLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить статус WebSocket'**
  String get settingsWebSocketLoadError;

  /// No description provided for @settingsWebSocketTimeoutError.
  ///
  /// In ru, this message translates to:
  /// **'Статус WebSocket не ответил вовремя. Попробуйте обновить ещё раз.'**
  String get settingsWebSocketTimeoutError;

  /// No description provided for @settingsWebSocketPortError.
  ///
  /// In ru, this message translates to:
  /// **'Порт должен быть в диапазоне 1024-65535.'**
  String get settingsWebSocketPortError;

  /// No description provided for @settingsDiagnosticsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Диагностика и логи'**
  String get settingsDiagnosticsTitle;

  /// No description provided for @settingsDiagnosticsSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Управляйте режимом логирования и быстро экспортируйте лог-файл.'**
  String get settingsDiagnosticsSubtitle;

  /// No description provided for @settingsEnableLoggingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Включить логирование'**
  String get settingsEnableLoggingTitle;

  /// No description provided for @settingsEnableLoggingSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Собирать технические логи для диагностики'**
  String get settingsEnableLoggingSubtitle;

  /// No description provided for @settingsLogToFileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Запись лога в файл'**
  String get settingsLogToFileTitle;

  /// No description provided for @settingsNoLogFilePath.
  ///
  /// In ru, this message translates to:
  /// **'Путь к файлу недоступен'**
  String get settingsNoLogFilePath;

  /// No description provided for @settingsRefreshAction.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get settingsRefreshAction;

  /// No description provided for @settingsClearAction.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get settingsClearAction;

  /// No description provided for @settingsExportAction.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт'**
  String get settingsExportAction;

  /// No description provided for @settingsShareAction.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться'**
  String get settingsShareAction;

  /// No description provided for @settingsNoLogsAvailable.
  ///
  /// In ru, this message translates to:
  /// **'Логи отсутствуют'**
  String get settingsNoLogsAvailable;

  /// No description provided for @settingsErrorLoadingLogsPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки логов'**
  String get settingsErrorLoadingLogsPrefix;

  /// No description provided for @settingsLogsCleared.
  ///
  /// In ru, this message translates to:
  /// **'Логи очищены'**
  String get settingsLogsCleared;

  /// No description provided for @settingsErrorClearingLogsPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка очистки логов'**
  String get settingsErrorClearingLogsPrefix;

  /// No description provided for @settingsLogsExportedPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Логи экспортированы в'**
  String get settingsLogsExportedPrefix;

  /// No description provided for @settingsFailedToExportLogs.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось экспортировать логи'**
  String get settingsFailedToExportLogs;

  /// No description provided for @settingsErrorExportingLogsPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка экспорта логов'**
  String get settingsErrorExportingLogsPrefix;

  /// No description provided for @settingsNoExportedLogsToShare.
  ///
  /// In ru, this message translates to:
  /// **'Нет экспортированных логов для отправки. Сначала выполните экспорт.'**
  String get settingsNoExportedLogsToShare;

  /// No description provided for @settingsGenericErrorPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get settingsGenericErrorPrefix;

  /// No description provided for @settingsPermissionsAllGranted.
  ///
  /// In ru, this message translates to:
  /// **'Все ключевые разрешения выданы.'**
  String get settingsPermissionsAllGranted;

  /// No description provided for @settingsPermissionsMissingSummary.
  ///
  /// In ru, this message translates to:
  /// **'Не все необходимые права выданы.'**
  String get settingsPermissionsMissingSummary;

  /// No description provided for @settingsPermissionAccessibilityLabel.
  ///
  /// In ru, this message translates to:
  /// **'Служба специальных возможностей'**
  String get settingsPermissionAccessibilityLabel;

  /// No description provided for @settingsPermissionOverlayLabel.
  ///
  /// In ru, this message translates to:
  /// **'Отображение поверх окон'**
  String get settingsPermissionOverlayLabel;

  /// No description provided for @settingsPermissionMediaProjectionLabel.
  ///
  /// In ru, this message translates to:
  /// **'MediaProjection'**
  String get settingsPermissionMediaProjectionLabel;

  /// No description provided for @settingsPermissionGranted.
  ///
  /// In ru, this message translates to:
  /// **'выдано'**
  String get settingsPermissionGranted;

  /// No description provided for @settingsPermissionMissing.
  ///
  /// In ru, this message translates to:
  /// **'не выдано'**
  String get settingsPermissionMissing;

  /// No description provided for @settingsExecutionPermissionsRequired.
  ///
  /// In ru, this message translates to:
  /// **'Для выполнения сценариев сначала выдайте обязательные разрешения. '**
  String get settingsExecutionPermissionsRequired;

  /// No description provided for @settingsLogSourceLabel.
  ///
  /// In ru, this message translates to:
  /// **'Источник'**
  String get settingsLogSourceLabel;

  /// No description provided for @settingsLogSourceBuffer.
  ///
  /// In ru, this message translates to:
  /// **'Buffer'**
  String get settingsLogSourceBuffer;

  /// No description provided for @settingsLogSourceFileFallback.
  ///
  /// In ru, this message translates to:
  /// **'File fallback'**
  String get settingsLogSourceFileFallback;

  /// No description provided for @languageSwitcherTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Сменить язык'**
  String get languageSwitcherTooltip;

  /// No description provided for @permissionsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Разрешения'**
  String get permissionsTitle;

  /// No description provided for @permissionsAllGranted.
  ///
  /// In ru, this message translates to:
  /// **'Все обязательные разрешения выданы. Основные действия разблокированы.'**
  String get permissionsAllGranted;

  /// No description provided for @permissionsAccessibilityDescription.
  ///
  /// In ru, this message translates to:
  /// **'Сначала включите сервис специальных возможностей для Prog Set Touch. Без него автоматизация нажатий не может быть запущена.'**
  String get permissionsAccessibilityDescription;

  /// No description provided for @permissionsAccessibilityAction.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки специальных возможностей'**
  String get permissionsAccessibilityAction;

  /// No description provided for @permissionsOverlayDescription.
  ///
  /// In ru, this message translates to:
  /// **'Затем разрешите отображение поверх других окон. Это нужно для фонового интерфейса и последующей overlay-кнопки.'**
  String get permissionsOverlayDescription;

  /// No description provided for @permissionsOverlayAction.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки overlay'**
  String get permissionsOverlayAction;

  /// No description provided for @permissionsMediaProjectionDescription.
  ///
  /// In ru, this message translates to:
  /// **'Разрешение на захват экрана запрашивается отдельно, только для функций скриншотов и экранной верификации.'**
  String get permissionsMediaProjectionDescription;

  /// No description provided for @permissionsMediaProjectionAction.
  ///
  /// In ru, this message translates to:
  /// **'Запросить MediaProjection'**
  String get permissionsMediaProjectionAction;

  /// No description provided for @overlayStatusTitle.
  ///
  /// In ru, this message translates to:
  /// **'Плавающая overlay-кнопка'**
  String get overlayStatusTitle;

  /// No description provided for @overlayStatusVisible.
  ///
  /// In ru, this message translates to:
  /// **'Отображается и перетаскивается'**
  String get overlayStatusVisible;

  /// No description provided for @overlayStatusHidden.
  ///
  /// In ru, this message translates to:
  /// **'Скрыта'**
  String get overlayStatusHidden;

  /// No description provided for @recorderTitle.
  ///
  /// In ru, this message translates to:
  /// **'Рекордер'**
  String get recorderTitle;

  /// No description provided for @recorderStatusRecording.
  ///
  /// In ru, this message translates to:
  /// **'Запись активна'**
  String get recorderStatusRecording;

  /// No description provided for @recorderStatusStopped.
  ///
  /// In ru, this message translates to:
  /// **'Запись остановлена'**
  String get recorderStatusStopped;

  /// No description provided for @recorderTotalActions.
  ///
  /// In ru, this message translates to:
  /// **'Всего действий'**
  String get recorderTotalActions;

  /// No description provided for @recorderTapCount.
  ///
  /// In ru, this message translates to:
  /// **'Тапы'**
  String get recorderTapCount;

  /// No description provided for @recorderDoubleTapCount.
  ///
  /// In ru, this message translates to:
  /// **'Двойные тапы'**
  String get recorderDoubleTapCount;

  /// No description provided for @recorderLongPressCount.
  ///
  /// In ru, this message translates to:
  /// **'Долгие нажатия'**
  String get recorderLongPressCount;

  /// No description provided for @recorderSwipeCount.
  ///
  /// In ru, this message translates to:
  /// **'Свайпы'**
  String get recorderSwipeCount;

  /// No description provided for @recorderMaxPointers.
  ///
  /// In ru, this message translates to:
  /// **'Максимум точек касания'**
  String get recorderMaxPointers;

  /// No description provided for @recorderClear.
  ///
  /// In ru, this message translates to:
  /// **'Стереть запись'**
  String get recorderClear;

  /// No description provided for @recorderClearConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение'**
  String get recorderClearConfirmTitle;

  /// No description provided for @recorderClearConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите стереть текущую запись?'**
  String get recorderClearConfirmMessage;

  /// No description provided for @commonConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get commonConfirm;

  /// No description provided for @commonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get commonCancel;

  /// No description provided for @executionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выполнение'**
  String get executionTitle;

  /// No description provided for @executionStatusExecuting.
  ///
  /// In ru, this message translates to:
  /// **'Выполняется'**
  String get executionStatusExecuting;

  /// No description provided for @executionStatusPaused.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get executionStatusPaused;

  /// No description provided for @executionStatusIdle.
  ///
  /// In ru, this message translates to:
  /// **'Ожидание'**
  String get executionStatusIdle;

  /// No description provided for @executionStart.
  ///
  /// In ru, this message translates to:
  /// **'Тэст'**
  String get executionStart;

  /// No description provided for @executionStop.
  ///
  /// In ru, this message translates to:
  /// **'Стоп'**
  String get executionStop;

  /// No description provided for @executionProgress.
  ///
  /// In ru, this message translates to:
  /// **'{completed} из {total}'**
  String executionProgress(Object completed, Object total);

  /// No description provided for @settingsExecutionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки выполнения'**
  String get settingsExecutionTitle;

  /// No description provided for @settingsExecutionDelay.
  ///
  /// In ru, this message translates to:
  /// **'Задержка между действиями'**
  String get settingsExecutionDelay;

  /// No description provided for @settingsExecutionDelayUnit.
  ///
  /// In ru, this message translates to:
  /// **'{seconds} сек.'**
  String settingsExecutionDelayUnit(Object seconds);

  /// No description provided for @settingsRestoreAppTitle.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить приложение'**
  String get settingsRestoreAppTitle;

  /// No description provided for @settingsRestoreAppSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Открыть приложение после завершения выполнения сценария'**
  String get settingsRestoreAppSubtitle;

  /// No description provided for @settingsVisualVerificationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Визуальная верификация'**
  String get settingsVisualVerificationTitle;

  /// No description provided for @settingsVisualVerificationSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Глобальный переключатель проверки скриншотов во время выполнения'**
  String get settingsVisualVerificationSubtitle;

  /// No description provided for @settingsRestoreAppChangeError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось изменить настройку восстановления приложения'**
  String get settingsRestoreAppChangeError;

  /// No description provided for @statusUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Недоступно'**
  String get statusUnavailable;

  /// No description provided for @errorPlatformLoad.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить данные платформы'**
  String get errorPlatformLoad;

  /// No description provided for @errorPermissionAction.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выполнить действие для разрешения'**
  String get errorPermissionAction;

  /// No description provided for @errorOverlayAction.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось изменить состояние overlay'**
  String get errorOverlayAction;

  /// No description provided for @errorRecorderAction.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось изменить состояние рекордера'**
  String get errorRecorderAction;

  /// No description provided for @errorRecorderNeedsOverlay.
  ///
  /// In ru, this message translates to:
  /// **'Перед началом записи включите плавающую кнопку'**
  String get errorRecorderNeedsOverlay;

  /// No description provided for @errorExecutionAction.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выполнить сценарий'**
  String get errorExecutionAction;

  /// No description provided for @errorExecutionNotAllowed.
  ///
  /// In ru, this message translates to:
  /// **'Выполнение недоступно в текущем состоянии'**
  String get errorExecutionNotAllowed;

  /// No description provided for @errorExecutionPauseFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось приостановить выполнение'**
  String get errorExecutionPauseFailed;

  /// No description provided for @errorExecutionResumeFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось возобновить выполнение'**
  String get errorExecutionResumeFailed;

  /// No description provided for @schedulerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Планировщик'**
  String get schedulerTitle;

  /// No description provided for @noSchedulesMessage.
  ///
  /// In ru, this message translates to:
  /// **'Расписаний пока нет'**
  String get noSchedulesMessage;

  /// No description provided for @noSchedulesDescription.
  ///
  /// In ru, this message translates to:
  /// **'Создайте первое расписание для автоматизации выполнения сценариев'**
  String get noSchedulesDescription;

  /// No description provided for @deleteScheduleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить расписание'**
  String get deleteScheduleTitle;

  /// No description provided for @deleteScheduleMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить \'{name}\'?'**
  String deleteScheduleMessage(Object name);

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @addScheduleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить расписание'**
  String get addScheduleTitle;

  /// No description provided for @editScheduleTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать расписание'**
  String get editScheduleTitle;

  /// No description provided for @scheduleNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get scheduleNameLabel;

  /// No description provided for @scheduleNameRequired.
  ///
  /// In ru, this message translates to:
  /// **'Название обязательно'**
  String get scheduleNameRequired;

  /// No description provided for @scheduleTypeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get scheduleTypeLabel;

  /// No description provided for @scheduleTypeOneTime.
  ///
  /// In ru, this message translates to:
  /// **'Одноразовое'**
  String get scheduleTypeOneTime;

  /// No description provided for @scheduleTypeDaily.
  ///
  /// In ru, this message translates to:
  /// **'Ежедневно'**
  String get scheduleTypeDaily;

  /// No description provided for @scheduleTypeWeekly.
  ///
  /// In ru, this message translates to:
  /// **'Еженедельно'**
  String get scheduleTypeWeekly;

  /// No description provided for @hourLabel.
  ///
  /// In ru, this message translates to:
  /// **'Часы'**
  String get hourLabel;

  /// No description provided for @minuteLabel.
  ///
  /// In ru, this message translates to:
  /// **'Минуты'**
  String get minuteLabel;

  /// No description provided for @invalidHour.
  ///
  /// In ru, this message translates to:
  /// **'Часы должны быть 0-23'**
  String get invalidHour;

  /// No description provided for @invalidMinute.
  ///
  /// In ru, this message translates to:
  /// **'Минуты должны быть 0-59'**
  String get invalidMinute;

  /// No description provided for @daysOfWeekLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дни недели'**
  String get daysOfWeekLabel;

  /// No description provided for @scheduleScenarioLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сценарий'**
  String get scheduleScenarioLabel;

  /// No description provided for @scheduleScenarioRequired.
  ///
  /// In ru, this message translates to:
  /// **'Выберите сценарий'**
  String get scheduleScenarioRequired;

  /// No description provided for @scheduleScenarioRequiredToCreate.
  ///
  /// In ru, this message translates to:
  /// **'Сначала создайте хотя бы один сценарий'**
  String get scheduleScenarioRequiredToCreate;

  /// No description provided for @scheduleScenarioMissing.
  ///
  /// In ru, this message translates to:
  /// **'Сценарий не найден'**
  String get scheduleScenarioMissing;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @scenarioStartRecording.
  ///
  /// In ru, this message translates to:
  /// **'Начать запись'**
  String get scenarioStartRecording;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In ru, this message translates to:
  /// **'О программе'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Как пользоваться Prog Set Touch'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsAboutDescriptionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Описание работы'**
  String get settingsAboutDescriptionTitle;

  /// No description provided for @settingsAboutSectionBasics.
  ///
  /// In ru, this message translates to:
  /// **'Основы работы'**
  String get settingsAboutSectionBasics;

  /// No description provided for @settingsAboutBasicsContent.
  ///
  /// In ru, this message translates to:
  /// **'Prog Set Touch — это умный автокликер, наделенный «зрением». В отличие от обычных кликеров, он может проверять изменения на экране с помощью визуальной верификации (скриншотов).'**
  String get settingsAboutBasicsContent;

  /// No description provided for @settingsAboutSectionRecording.
  ///
  /// In ru, this message translates to:
  /// **'Запись и редактор'**
  String get settingsAboutSectionRecording;

  /// No description provided for @settingsAboutRecordingContent.
  ///
  /// In ru, this message translates to:
  /// **'Записывайте жесты (тапы, свайпы) с помощью плавающего виджета поверх других окон. Встроенный пошаговый редактор позволяет менять координаты, задержки и настраивать пороги проверок.'**
  String get settingsAboutRecordingContent;

  /// No description provided for @settingsAboutSectionExecution.
  ///
  /// In ru, this message translates to:
  /// **'Визуальный контроль'**
  String get settingsAboutSectionExecution;

  /// No description provided for @settingsAboutExecutionContent.
  ///
  /// In ru, this message translates to:
  /// **'Если для шага включена проверка экрана, кликер сделает снимок до и после жеста. Настраивая Таймаут, Порог чувствительности (%) и опцию «Продолжить при ошибке», вы можете создавать надежные макросы, устойчивые к лагам и долгой загрузке.'**
  String get settingsAboutExecutionContent;

  /// No description provided for @settingsAboutSectionOverlay.
  ///
  /// In ru, this message translates to:
  /// **'Запуск и управление'**
  String get settingsAboutSectionOverlay;

  /// No description provided for @settingsAboutOverlayContent.
  ///
  /// In ru, this message translates to:
  /// **'Запускайте сценарии пакетами через Быстрый Запуск. Для стабильной работы рекомендуем настроить глобальную задержку между шагами в Настройках.'**
  String get settingsAboutOverlayContent;

  /// No description provided for @settingsAboutSectionPermissions.
  ///
  /// In ru, this message translates to:
  /// **'Безопасность и разрешения'**
  String get settingsAboutSectionPermissions;

  /// No description provided for @settingsAboutPermissionsContent.
  ///
  /// In ru, this message translates to:
  /// **'Для работы требуются разрешения на Спец. возможности (имитация нажатий), Отображение поверх окон (запись) и MediaProjection (только для визуальной верификации).'**
  String get settingsAboutPermissionsContent;

  /// No description provided for @scenarioEditWhileExecutingRejected.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя редактировать шаги во время выполнения'**
  String get scenarioEditWhileExecutingRejected;

  /// No description provided for @scenarioStepEditorAddStep.
  ///
  /// In ru, this message translates to:
  /// **'Добавить шаг'**
  String get scenarioStepEditorAddStep;

  /// No description provided for @scenarioStepEditorVerificationLabel.
  ///
  /// In ru, this message translates to:
  /// **'Проверка изменений экрана'**
  String get scenarioStepEditorVerificationLabel;

  /// No description provided for @scenarioStepEditorVerificationSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверять, изменилось ли содержимое экрана после выполнения этого шага'**
  String get scenarioStepEditorVerificationSubtitle;

  /// No description provided for @scenarioStepEditorThresholdLabel.
  ///
  /// In ru, this message translates to:
  /// **'Порог чувствительности (%)'**
  String get scenarioStepEditorThresholdLabel;

  /// No description provided for @scenarioStepEditorThresholdCurrent.
  ///
  /// In ru, this message translates to:
  /// **'Текущее: {value}%'**
  String scenarioStepEditorThresholdCurrent(Object value);

  /// No description provided for @scenarioStepEditorTimeoutLabel.
  ///
  /// In ru, this message translates to:
  /// **'Время ожидания (сек)'**
  String get scenarioStepEditorTimeoutLabel;

  /// No description provided for @scenarioStepEditorTimeoutHelper.
  ///
  /// In ru, this message translates to:
  /// **'От 1 до 300 секунд (5 мин)'**
  String get scenarioStepEditorTimeoutHelper;

  /// No description provided for @scenarioStepEditorContinueOnFailure.
  ///
  /// In ru, this message translates to:
  /// **'Остановить текущий и продолжить следующий сценарий при ошибке'**
  String get scenarioStepEditorContinueOnFailure;

  /// No description provided for @scenarioScreenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сценарии'**
  String get scenarioScreenTitle;

  /// No description provided for @scenarioCreate.
  ///
  /// In ru, this message translates to:
  /// **'Создать сценарий'**
  String get scenarioCreate;

  /// No description provided for @scenarioCreateCompact.
  ///
  /// In ru, this message translates to:
  /// **'Создать'**
  String get scenarioCreateCompact;

  /// No description provided for @scenarioRunAll.
  ///
  /// In ru, this message translates to:
  /// **'Запустить все сценарии'**
  String get scenarioRunAll;

  /// No description provided for @scenarioRunAllCompact.
  ///
  /// In ru, this message translates to:
  /// **'Запустить все'**
  String get scenarioRunAllCompact;

  /// No description provided for @scenarioQuickLaunch.
  ///
  /// In ru, this message translates to:
  /// **'Быстрый запуск'**
  String get scenarioQuickLaunch;

  /// No description provided for @scenarioNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Название сценария'**
  String get scenarioNameHint;

  /// No description provided for @scenarioColumnName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get scenarioColumnName;

  /// No description provided for @scenarioColumnSteps.
  ///
  /// In ru, this message translates to:
  /// **'Шаги'**
  String get scenarioColumnSteps;

  /// No description provided for @scenarioEmptyNotAllowed.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя сохранить пустой сценарий. Сначала запишите хотя бы одно действие.'**
  String get scenarioEmptyNotAllowed;

  /// No description provided for @scenarioLimitReached.
  ///
  /// In ru, this message translates to:
  /// **'Допустимо максимум 50 сценариев.'**
  String get scenarioLimitReached;

  /// No description provided for @scenarioNameMustBeUnique.
  ///
  /// In ru, this message translates to:
  /// **'Название сценария должно быть уникальным.'**
  String get scenarioNameMustBeUnique;

  /// No description provided for @scenarioQuickLaunchEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Не выбраны сценарии для быстрого запуска.'**
  String get scenarioQuickLaunchEmpty;

  /// No description provided for @scenarioRunAllEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет включенных сценариев для запуска.'**
  String get scenarioRunAllEmpty;

  /// No description provided for @scenarioExecutionBusy.
  ///
  /// In ru, this message translates to:
  /// **'Выполнение уже идет.'**
  String get scenarioExecutionBusy;

  /// No description provided for @scenarioBatchDone.
  ///
  /// In ru, this message translates to:
  /// **'Пакетное выполнение сценариев завершено.'**
  String get scenarioBatchDone;

  /// No description provided for @scenarioRename.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать'**
  String get scenarioRename;

  /// No description provided for @scenarioDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get scenarioDelete;

  /// No description provided for @scenarioDeleteConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить сценарий'**
  String get scenarioDeleteConfirmTitle;

  /// No description provided for @scenarioDeleteConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить сценарий «{name}»?'**
  String scenarioDeleteConfirmMessage(Object name);

  /// No description provided for @scenarioRenameTitle.
  ///
  /// In ru, this message translates to:
  /// **'Переименовать сценарий'**
  String get scenarioRenameTitle;

  /// No description provided for @scenarioExport.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт сценариев'**
  String get scenarioExport;

  /// No description provided for @scenarioImport.
  ///
  /// In ru, this message translates to:
  /// **'Импорт сценариев'**
  String get scenarioImport;

  /// No description provided for @scenarioExportEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет сценариев для экспорта.'**
  String get scenarioExportEmpty;

  /// No description provided for @scenarioExportDone.
  ///
  /// In ru, this message translates to:
  /// **'Сценарии успешно экспортированы.'**
  String get scenarioExportDone;

  /// No description provided for @scenarioExportFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось экспортировать сценарии.'**
  String get scenarioExportFailed;

  /// No description provided for @scenarioImportDone.
  ///
  /// In ru, this message translates to:
  /// **'Сценарии успешно импортированы.'**
  String get scenarioImportDone;

  /// No description provided for @scenarioImportInvalidJson.
  ///
  /// In ru, this message translates to:
  /// **'Некорректный JSON файла импорта.'**
  String get scenarioImportInvalidJson;

  /// No description provided for @scenarioImportNoItems.
  ///
  /// In ru, this message translates to:
  /// **'В файле импорта нет валидных сценариев.'**
  String get scenarioImportNoItems;

  /// No description provided for @mainScenarioSectionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сценарии'**
  String get mainScenarioSectionTitle;

  /// No description provided for @mainOverviewTabTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обзор'**
  String get mainOverviewTabTitle;

  /// No description provided for @mainStatusPermissions.
  ///
  /// In ru, this message translates to:
  /// **'Разрешения'**
  String get mainStatusPermissions;

  /// No description provided for @mainStatusOverlay.
  ///
  /// In ru, this message translates to:
  /// **'Overlay'**
  String get mainStatusOverlay;

  /// No description provided for @mainStatusRecorder.
  ///
  /// In ru, this message translates to:
  /// **'Рекордер'**
  String get mainStatusRecorder;

  /// No description provided for @mainStatusActions.
  ///
  /// In ru, this message translates to:
  /// **'Действия'**
  String get mainStatusActions;

  /// No description provided for @mainStatusOk.
  ///
  /// In ru, this message translates to:
  /// **'OK'**
  String get mainStatusOk;

  /// No description provided for @mainStatusOff.
  ///
  /// In ru, this message translates to:
  /// **'OFF'**
  String get mainStatusOff;

  /// No description provided for @schedulerScenarioPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Сценарий'**
  String get schedulerScenarioPrefix;

  /// No description provided for @notesLatestChangesTitle.
  ///
  /// In ru, this message translates to:
  /// **'Последние изменения'**
  String get notesLatestChangesTitle;

  /// No description provided for @notesExportCrashFix.
  ///
  /// In ru, this message translates to:
  /// **'Исправлен вылет при экспорте настроек/логов.'**
  String get notesExportCrashFix;

  /// No description provided for @notesMainScreenRedesign.
  ///
  /// In ru, this message translates to:
  /// **'Главный экран переработан: улучшена читаемость статусов и блоков действий.'**
  String get notesMainScreenRedesign;

  /// No description provided for @notesSchedulerScenarioVisible.
  ///
  /// In ru, this message translates to:
  /// **'В карточке планировщика теперь видно выбранный сценарий.'**
  String get notesSchedulerScenarioVisible;

  /// No description provided for @scenarioStepEditorOpen.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать шаги'**
  String get scenarioStepEditorOpen;

  /// No description provided for @scenarioStepEditorSaved.
  ///
  /// In ru, this message translates to:
  /// **'Шаги сценария сохранены.'**
  String get scenarioStepEditorSaved;

  /// No description provided for @scenarioStepEditorSaveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить шаги сценария.'**
  String get scenarioStepEditorSaveFailed;

  /// No description provided for @scenarioStepEditorLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить шаги сценария'**
  String get scenarioStepEditorLoadFailed;

  /// No description provided for @scenarioStepEditorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать шаги: {name}'**
  String scenarioStepEditorTitle(Object name);

  /// No description provided for @scenarioStepEditorSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Изменяйте порядок шагов, параметры жестов и задержку после каждого шага.'**
  String get scenarioStepEditorSubtitle;

  /// No description provided for @scenarioStepEditorCount.
  ///
  /// In ru, this message translates to:
  /// **'Шагов: {count}'**
  String scenarioStepEditorCount(Object count);

  /// No description provided for @scenarioStepEditorStepLabel.
  ///
  /// In ru, this message translates to:
  /// **'Шаг {index}'**
  String scenarioStepEditorStepLabel(Object index);

  /// No description provided for @scenarioStepEditorEditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать шаг'**
  String get scenarioStepEditorEditTitle;

  /// No description provided for @scenarioStepEditorTypeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тип действия'**
  String get scenarioStepEditorTypeLabel;

  /// No description provided for @scenarioStepEditorPointerCountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Число касаний'**
  String get scenarioStepEditorPointerCountLabel;

  /// No description provided for @scenarioStepEditorDurationLabel.
  ///
  /// In ru, this message translates to:
  /// **'Длительность жеста (мс)'**
  String get scenarioStepEditorDurationLabel;

  /// No description provided for @scenarioStepEditorDelayLabel.
  ///
  /// In ru, this message translates to:
  /// **'Задержка после шага (мс)'**
  String get scenarioStepEditorDelayLabel;

  /// No description provided for @scenarioStepEditorStartXLabel.
  ///
  /// In ru, this message translates to:
  /// **'Start X'**
  String get scenarioStepEditorStartXLabel;

  /// No description provided for @scenarioStepEditorStartYLabel.
  ///
  /// In ru, this message translates to:
  /// **'Start Y'**
  String get scenarioStepEditorStartYLabel;

  /// No description provided for @scenarioStepEditorEndXLabel.
  ///
  /// In ru, this message translates to:
  /// **'End X'**
  String get scenarioStepEditorEndXLabel;

  /// No description provided for @scenarioStepEditorEndYLabel.
  ///
  /// In ru, this message translates to:
  /// **'End Y'**
  String get scenarioStepEditorEndYLabel;

  /// No description provided for @scenarioStepEditorInvalidValues.
  ///
  /// In ru, this message translates to:
  /// **'Введите корректные числовые значения для шага.'**
  String get scenarioStepEditorInvalidValues;

  /// No description provided for @scenarioStepEditorPointerCount.
  ///
  /// In ru, this message translates to:
  /// **'Касаний: {count}'**
  String scenarioStepEditorPointerCount(Object count);

  /// No description provided for @scenarioStepEditorDuration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность: {durationMs} мс'**
  String scenarioStepEditorDuration(Object durationMs);

  /// No description provided for @scenarioStepEditorDelay.
  ///
  /// In ru, this message translates to:
  /// **'Задержка: {delayMs} мс'**
  String scenarioStepEditorDelay(Object delayMs);

  /// No description provided for @scenarioStepEditorStart.
  ///
  /// In ru, this message translates to:
  /// **'Начало: {x}, {y}'**
  String scenarioStepEditorStart(Object x, Object y);

  /// No description provided for @scenarioStepEditorEnd.
  ///
  /// In ru, this message translates to:
  /// **'Конец: {x}, {y}'**
  String scenarioStepEditorEnd(Object x, Object y);

  /// No description provided for @scenarioStepTypeTap.
  ///
  /// In ru, this message translates to:
  /// **'Тап'**
  String get scenarioStepTypeTap;

  /// No description provided for @scenarioStepTypeDoubleTap.
  ///
  /// In ru, this message translates to:
  /// **'Двойной тап'**
  String get scenarioStepTypeDoubleTap;

  /// No description provided for @scenarioStepTypeLongPress.
  ///
  /// In ru, this message translates to:
  /// **'Долгое нажатие'**
  String get scenarioStepTypeLongPress;

  /// No description provided for @scenarioStepTypeSwipe.
  ///
  /// In ru, this message translates to:
  /// **'Свайп'**
  String get scenarioStepTypeSwipe;

  /// No description provided for @scenarioEditBlockedWhileExecuting.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя редактировать шаги сценария во время выполнения.'**
  String get scenarioEditBlockedWhileExecuting;

  /// No description provided for @scenarioDeleteBlockedWhileExecuting.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя удалить сценарий во время выполнения.'**
  String get scenarioDeleteBlockedWhileExecuting;

  /// No description provided for @scenarioImportBlockedWhileExecuting.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя импортировать сценарии во время выполнения.'**
  String get scenarioImportBlockedWhileExecuting;

  /// No description provided for @scenarioReorderBlockedWhileExecuting.
  ///
  /// In ru, this message translates to:
  /// **'Нельзя менять порядок сценариев во время выполнения.'**
  String get scenarioReorderBlockedWhileExecuting;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
