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
/// import 'gen_l10n/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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

  /// No description provided for @settingsWebSocketTitle.
  ///
  /// In ru, this message translates to:
  /// **'WebSocket'**
  String get settingsWebSocketTitle;

  /// No description provided for @settingsWebSocketPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Настройки WSS будут доступны на этапе 10'**
  String get settingsWebSocketPlaceholder;

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
  /// **'Последний шаг — подтвердить доступ к захвату экрана. Это разрешение будет проверяться перед каждым запуском сценария.'**
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
