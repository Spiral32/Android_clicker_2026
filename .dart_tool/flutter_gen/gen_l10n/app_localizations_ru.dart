import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Prog Set Touch';

  @override
  String get mainScreenTitle => 'Prog Set Touch';

  @override
  String get mainScreenSubtitle => 'Базовый экран автоматизации';

  @override
  String get mainPrimaryAction => 'Настройка нажатий';

  @override
  String get mainRecordingStart => 'Начать запись';

  @override
  String get mainRecordingStop => 'Остановить запись';

  @override
  String get mainTestAction => 'Тест';

  @override
  String get mainAutostartAction => 'Автозапуск';

  @override
  String get mainAutostartActionEnable => 'Включить плавающую кнопку';

  @override
  String get mainAutostartActionDisable => 'Выключить плавающую кнопку';

  @override
  String get mainOpenSettings => 'Настройки';

  @override
  String get mainPlatformSectionTitle => 'Состояние платформы';

  @override
  String get mainPlatformUnavailable => 'Данные платформы недоступны';

  @override
  String get mainPlatformLabel => 'Платформа';

  @override
  String get mainManufacturerLabel => 'Производитель';

  @override
  String get mainModelLabel => 'Модель';

  @override
  String get mainSdkLabel => 'SDK';

  @override
  String get mainLocaleLabel => 'Системный язык';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguageTitle => 'Язык';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsWebSocketTitle => 'WebSocket';

  @override
  String get settingsWebSocketPlaceholder => 'Настройки WSS будут доступны на этапе 10';

  @override
  String get languageSwitcherTooltip => 'Сменить язык';

  @override
  String get permissionsTitle => 'Разрешения';

  @override
  String get permissionsAllGranted => 'Все обязательные разрешения выданы. Основные действия разблокированы.';

  @override
  String get permissionsAccessibilityDescription => 'Сначала включите сервис специальных возможностей для Prog Set Touch. Без него автоматизация нажатий не может быть запущена.';

  @override
  String get permissionsAccessibilityAction => 'Открыть настройки специальных возможностей';

  @override
  String get permissionsOverlayDescription => 'Затем разрешите отображение поверх других окон. Это нужно для фонового интерфейса и последующей overlay-кнопки.';

  @override
  String get permissionsOverlayAction => 'Открыть настройки overlay';

  @override
  String get permissionsMediaProjectionDescription => 'Последний шаг — подтвердить доступ к захвату экрана. Это разрешение будет проверяться перед каждым запуском сценария.';

  @override
  String get permissionsMediaProjectionAction => 'Запросить MediaProjection';

  @override
  String get overlayStatusTitle => 'Плавающая overlay-кнопка';

  @override
  String get overlayStatusVisible => 'Отображается и перетаскивается';

  @override
  String get overlayStatusHidden => 'Скрыта';

  @override
  String get recorderTitle => 'Рекордер';

  @override
  String get recorderStatusRecording => 'Запись активна';

  @override
  String get recorderStatusStopped => 'Запись остановлена';

  @override
  String get recorderTotalActions => 'Всего действий';

  @override
  String get recorderTapCount => 'Тапы';

  @override
  String get recorderDoubleTapCount => 'Двойные тапы';

  @override
  String get recorderLongPressCount => 'Долгие нажатия';

  @override
  String get recorderSwipeCount => 'Свайпы';

  @override
  String get recorderMaxPointers => 'Максимум точек касания';

  @override
  String get recorderClear => 'Стереть запись';

  @override
  String get recorderClearConfirmTitle => 'Подтверждение';

  @override
  String get recorderClearConfirmMessage => 'Вы уверены, что хотите стереть текущую запись?';

  @override
  String get commonConfirm => 'Да';

  @override
  String get commonCancel => 'Нет';

  @override
  String get executionTitle => 'Выполнение';

  @override
  String get executionStatusExecuting => 'Выполняется';

  @override
  String get executionStatusPaused => 'Пауза';

  @override
  String get executionStatusIdle => 'Ожидание';

  @override
  String get executionStart => 'Тэст';

  @override
  String get executionStop => 'Стоп';

  @override
  String executionProgress(Object completed, Object total) {
    return '$completed из $total';
  }

  @override
  String get settingsExecutionTitle => 'Настройки выполнения';

  @override
  String get settingsExecutionDelay => 'Задержка между действиями';

  @override
  String settingsExecutionDelayUnit(Object seconds) {
    return '$seconds сек.';
  }

  @override
  String get statusUnavailable => 'Недоступно';

  @override
  String get errorPlatformLoad => 'Не удалось загрузить данные платформы';

  @override
  String get errorPermissionAction => 'Не удалось выполнить действие для разрешения';

  @override
  String get errorOverlayAction => 'Не удалось изменить состояние overlay';

  @override
  String get errorRecorderAction => 'Не удалось изменить состояние рекордера';

  @override
  String get errorRecorderNeedsOverlay => 'Перед началом записи включите плавающую кнопку';

  @override
  String get errorExecutionAction => 'Не удалось выполнить сценарий';

  @override
  String get errorExecutionNotAllowed => 'Выполнение недоступно в текущем состоянии';

  @override
  String get errorExecutionPauseFailed => 'Не удалось приостановить выполнение';

  @override
  String get errorExecutionResumeFailed => 'Не удалось возобновить выполнение';
}
