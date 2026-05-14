// ignore: unused_import
import 'package:intl/intl.dart' as intl;
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
  String get mainRecorderTip =>
      'Запись работает в пошаговом неблокирующем режиме. После старта используйте панель записи поверх экрана, чтобы добавлять тапы, двойные тапы, долгие нажатия и свайпы.';

  @override
  String get mainRecorderOpenPanel => 'Открыть панель записи';

  @override
  String get mainRecorderStopPanel => 'Завершить запись';

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
  String get settingsLanguageSubtitle => 'Выберите язык приложения.';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAutostartTitle => 'Автозапуск';

  @override
  String get settingsAutostartSubtitle =>
      'Управляйте восстановлением расписаний после перезагрузки устройства.';

  @override
  String get settingsAutostartToggleTitle =>
      'Включить автозапуск после перезагрузки';

  @override
  String get settingsAutostartToggleSubtitle =>
      'Если выключено, BOOT_COMPLETED не восстанавливает расписания автоматически.';

  @override
  String get settingsAutostartEnabledMessage =>
      'Автозапуск после перезагрузки включен.';

  @override
  String get settingsAutostartDisabledMessage =>
      'Автозапуск после перезагрузки отключен.';

  @override
  String get settingsAutostartChangeError => 'Не удалось изменить автозапуск.';

  @override
  String get settingsMediaProjectionTitle => 'MediaProjection';

  @override
  String get settingsMediaProjectionSubtitle =>
      'Разрешение нужно только для функций захвата экрана и проверки скриншотов.';

  @override
  String get settingsMediaProjectionStatusGranted =>
      'Статус: разрешение выдано';

  @override
  String get settingsMediaProjectionStatusMissing =>
      'Статус: разрешение не выдано';

  @override
  String get settingsMediaProjectionRequestAction =>
      'Запросить MediaProjection вручную';

  @override
  String get settingsMediaProjectionGrantedMessage =>
      'MediaProjection разрешение получено.';

  @override
  String get settingsMediaProjectionDeniedMessage =>
      'MediaProjection разрешение не получено.';

  @override
  String get settingsMediaProjectionRequestError =>
      'Не удалось запросить MediaProjection.';

  @override
  String get settingsExactAlarmTitle => 'Точные будильники';

  @override
  String get settingsExactAlarmSubtitle =>
      'Для максимально точного срабатывания расписания разрешите точные будильники в системных настройках Android.';

  @override
  String get settingsExactAlarmStatusAllowed =>
      'Статус: точные будильники разрешены';

  @override
  String get settingsExactAlarmStatusLimited =>
      'Статус: точные будильники ограничены, возможна задержка запуска';

  @override
  String get settingsExactAlarmOpenAction =>
      'Открыть настройки точных будильников';

  @override
  String get settingsExactAlarmOpenError =>
      'Не удалось открыть настройки точных будильников.';

  @override
  String get settingsDiagnosticsLoadError =>
      'Не удалось загрузить диагностику.';

  @override
  String get settingsLogExportedMessage =>
      'Лог экспортирован в папку Download.';

  @override
  String get settingsLogExportError => 'Не удалось экспортировать лог.';

  @override
  String get settingsLogOpenLocationError =>
      'Не удалось открыть расположение лог-файла.';

  @override
  String get settingsLogClearedMessage => 'Буфер логов очищен.';

  @override
  String get settingsLogClearError => 'Не удалось очистить лог.';

  @override
  String get settingsWebSocketTitle => 'WebSocket';

  @override
  String get settingsWebSocketSubtitle =>
      'Управляйте встроенным сервером для удалённых команд и диагностики.';

  @override
  String get settingsWebSocketEnableTitle => 'Включить сервер';

  @override
  String get settingsWebSocketEnableSubtitle =>
      'Запускает WebSocket-сервер с одним клиентом и токен-авторизацией (предпочтительно через Authorization: Bearer).';

  @override
  String get settingsWebSocketEnableAction => 'Включить сервер';

  @override
  String get settingsWebSocketDisableAction => 'Выключить сервер';

  @override
  String get settingsWebSocketRunningLabel => 'Сервер';

  @override
  String get settingsWebSocketStatusRunning => 'запущен';

  @override
  String get settingsWebSocketStatusStopped => 'остановлен';

  @override
  String get settingsWebSocketClientLabel => 'Клиент';

  @override
  String get settingsWebSocketStatusClientConnected => 'подключен';

  @override
  String get settingsWebSocketStatusNoClient => 'нет клиента';

  @override
  String get settingsWebSocketTransportLabel => 'Транспорт';

  @override
  String get settingsWebSocketAuthLabel => 'Защита';

  @override
  String get settingsWebSocketAuthModeQueryToken => 'bearer token';

  @override
  String get settingsWebSocketPortLabel => 'Порт';

  @override
  String get settingsWebSocketApplyPort => 'Применить';

  @override
  String get settingsWebSocketTokenLabel => 'Токен доступа';

  @override
  String get settingsWebSocketRegenerateToken => 'Пересоздать токен';

  @override
  String get settingsWebSocketUrlsLabel => 'URL подключения';

  @override
  String get settingsWebSocketRefreshAction => 'Обновить';

  @override
  String get settingsWebSocketUnavailableAddress =>
      'Сейчас нет доступного локального IPv4-адреса.';

  @override
  String get settingsWebSocketLoadError =>
      'Не удалось загрузить статус WebSocket';

  @override
  String get settingsWebSocketTimeoutError =>
      'Статус WebSocket не ответил вовремя. Попробуйте обновить ещё раз.';

  @override
  String get settingsWebSocketPortError =>
      'Порт должен быть в диапазоне 1024-65535.';

  @override
  String get settingsDiagnosticsTitle => 'Диагностика и логи';

  @override
  String get settingsDiagnosticsSubtitle =>
      'Управляйте режимом логирования и быстро экспортируйте лог-файл.';

  @override
  String get settingsEnableLoggingTitle => 'Включить логирование';

  @override
  String get settingsEnableLoggingSubtitle =>
      'Собирать технические логи для диагностики';

  @override
  String get settingsLogToFileTitle => 'Запись лога в файл';

  @override
  String get settingsNoLogFilePath => 'Путь к файлу недоступен';

  @override
  String get settingsRefreshAction => 'Обновить';

  @override
  String get settingsClearAction => 'Очистить';

  @override
  String get settingsExportAction => 'Экспорт';

  @override
  String get settingsShareAction => 'Поделиться';

  @override
  String get settingsNoLogsAvailable => 'Логи отсутствуют';

  @override
  String get settingsErrorLoadingLogsPrefix => 'Ошибка загрузки логов';

  @override
  String get settingsLogsCleared => 'Логи очищены';

  @override
  String get settingsErrorClearingLogsPrefix => 'Ошибка очистки логов';

  @override
  String get settingsLogsExportedPrefix => 'Логи экспортированы в';

  @override
  String get settingsFailedToExportLogs => 'Не удалось экспортировать логи';

  @override
  String get settingsErrorExportingLogsPrefix => 'Ошибка экспорта логов';

  @override
  String get settingsNoExportedLogsToShare =>
      'Нет экспортированных логов для отправки. Сначала выполните экспорт.';

  @override
  String get settingsGenericErrorPrefix => 'Ошибка';

  @override
  String get settingsPermissionsAllGranted => 'Все ключевые разрешения выданы.';

  @override
  String get settingsPermissionsMissingSummary =>
      'Не все необходимые права выданы.';

  @override
  String get settingsPermissionAccessibilityLabel =>
      'Служба специальных возможностей';

  @override
  String get settingsPermissionOverlayLabel => 'Отображение поверх окон';

  @override
  String get settingsPermissionMediaProjectionLabel => 'MediaProjection';

  @override
  String get settingsPermissionGranted => 'выдано';

  @override
  String get settingsPermissionMissing => 'не выдано';

  @override
  String get settingsExecutionPermissionsRequired =>
      'Для выполнения сценариев сначала выдайте обязательные разрешения. ';

  @override
  String get settingsLogSourceLabel => 'Источник';

  @override
  String get settingsLogSourceBuffer => 'Buffer';

  @override
  String get settingsLogSourceFileFallback => 'File fallback';

  @override
  String get languageSwitcherTooltip => 'Сменить язык';

  @override
  String get permissionsTitle => 'Разрешения';

  @override
  String get permissionsAllGranted =>
      'Все обязательные разрешения выданы. Основные действия разблокированы.';

  @override
  String get permissionsAccessibilityDescription =>
      'Сначала включите сервис специальных возможностей для Prog Set Touch. Без него автоматизация нажатий не может быть запущена.';

  @override
  String get permissionsAccessibilityAction =>
      'Открыть настройки специальных возможностей';

  @override
  String get permissionsOverlayDescription =>
      'Затем разрешите отображение поверх других окон. Это нужно для фонового интерфейса и последующей overlay-кнопки.';

  @override
  String get permissionsOverlayAction => 'Открыть настройки overlay';

  @override
  String get permissionsMediaProjectionDescription =>
      'Разрешение на захват экрана запрашивается отдельно, только для функций скриншотов и экранной верификации.';

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
  String get recorderClearConfirmMessage =>
      'Вы уверены, что хотите стереть текущую запись?';

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
  String get settingsRestoreAppTitle => 'Восстановить приложение';

  @override
  String get settingsRestoreAppSubtitle =>
      'Открыть приложение после завершения выполнения сценария';

  @override
  String get settingsVisualVerificationTitle => 'Визуальная верификация';

  @override
  String get settingsVisualVerificationSubtitle =>
      'Глобальный переключатель проверки скриншотов во время выполнения';

  @override
  String get settingsRestoreAppChangeError =>
      'Не удалось изменить настройку восстановления приложения';

  @override
  String get statusUnavailable => 'Недоступно';

  @override
  String get errorPlatformLoad => 'Не удалось загрузить данные платформы';

  @override
  String get errorPermissionAction =>
      'Не удалось выполнить действие для разрешения';

  @override
  String get errorOverlayAction => 'Не удалось изменить состояние overlay';

  @override
  String get errorRecorderAction => 'Не удалось изменить состояние рекордера';

  @override
  String get errorRecorderNeedsOverlay =>
      'Перед началом записи включите плавающую кнопку';

  @override
  String get errorExecutionAction => 'Не удалось выполнить сценарий';

  @override
  String get errorExecutionNotAllowed =>
      'Выполнение недоступно в текущем состоянии';

  @override
  String get errorExecutionPauseFailed => 'Не удалось приостановить выполнение';

  @override
  String get errorExecutionResumeFailed => 'Не удалось возобновить выполнение';

  @override
  String get schedulerTitle => 'Планировщик';

  @override
  String get noSchedulesMessage => 'Расписаний пока нет';

  @override
  String get noSchedulesDescription =>
      'Создайте первое расписание для автоматизации выполнения сценариев';

  @override
  String get deleteScheduleTitle => 'Удалить расписание';

  @override
  String deleteScheduleMessage(Object name) {
    return 'Вы уверены, что хотите удалить \'$name\'?';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get addScheduleTitle => 'Добавить расписание';

  @override
  String get editScheduleTitle => 'Редактировать расписание';

  @override
  String get scheduleNameLabel => 'Название';

  @override
  String get scheduleNameRequired => 'Название обязательно';

  @override
  String get scheduleTypeLabel => 'Тип';

  @override
  String get scheduleTypeOneTime => 'Одноразовое';

  @override
  String get scheduleTypeDaily => 'Ежедневно';

  @override
  String get scheduleTypeWeekly => 'Еженедельно';

  @override
  String get hourLabel => 'Часы';

  @override
  String get minuteLabel => 'Минуты';

  @override
  String get invalidHour => 'Часы должны быть 0-23';

  @override
  String get invalidMinute => 'Минуты должны быть 0-59';

  @override
  String get daysOfWeekLabel => 'Дни недели';

  @override
  String get scheduleScenarioLabel => 'Сценарий';

  @override
  String get scheduleScenarioRequired => 'Выберите сценарий';

  @override
  String get scheduleScenarioRequiredToCreate =>
      'Сначала создайте хотя бы один сценарий';

  @override
  String get scheduleScenarioMissing => 'Сценарий не найден';

  @override
  String get save => 'Сохранить';

  @override
  String get scenarioStartRecording => 'Начать запись';

  @override
  String get settingsAboutTitle => 'О программе';

  @override
  String get settingsAboutSubtitle => 'Как пользоваться Prog Set Touch';

  @override
  String get settingsAboutDescriptionTitle => 'Описание работы';

  @override
  String get settingsAboutSectionBasics => 'Основы работы';

  @override
  String get settingsAboutBasicsContent =>
      'Prog Set Touch — это умный автокликер, наделенный «зрением». В отличие от обычных кликеров, он может проверять изменения на экране с помощью визуальной верификации (скриншотов).';

  @override
  String get settingsAboutSectionRecording => 'Запись и редактор';

  @override
  String get settingsAboutRecordingContent =>
      'Записывайте жесты (тапы, свайпы) с помощью плавающего виджета поверх других окон. Встроенный пошаговый редактор позволяет менять координаты, задержки и настраивать пороги проверок.';

  @override
  String get settingsAboutSectionExecution => 'Визуальный контроль';

  @override
  String get settingsAboutExecutionContent =>
      'Если для шага включена проверка экрана, кликер сделает снимок до и после жеста. Настраивая Таймаут, Порог чувствительности (%) и опцию «Продолжить при ошибке», вы можете создавать надежные макросы, устойчивые к лагам и долгой загрузке.';

  @override
  String get settingsAboutSectionOverlay => 'Запуск и управление';

  @override
  String get settingsAboutOverlayContent =>
      'Запускайте сценарии пакетами через Быстрый Запуск. Для стабильной работы рекомендуем настроить глобальную задержку между шагами в Настройках.';

  @override
  String get settingsAboutSectionPermissions => 'Безопасность и разрешения';

  @override
  String get settingsAboutPermissionsContent =>
      'Для работы требуются разрешения на Спец. возможности (имитация нажатий), Отображение поверх окон (запись) и MediaProjection (только для визуальной верификации).';

  @override
  String get scenarioEditWhileExecutingRejected =>
      'Нельзя редактировать шаги во время выполнения';

  @override
  String get scenarioStepEditorAddStep => 'Добавить шаг';

  @override
  String get scenarioStepEditorVerificationLabel => 'Проверка изменений экрана';

  @override
  String get scenarioStepEditorVerificationSubtitle =>
      'Проверять, изменилось ли содержимое экрана после выполнения этого шага';

  @override
  String get scenarioStepEditorThresholdLabel => 'Порог чувствительности (%)';

  @override
  String scenarioStepEditorThresholdCurrent(Object value) {
    return 'Текущее: $value%';
  }

  @override
  String get scenarioStepEditorTimeoutLabel => 'Время ожидания (сек)';

  @override
  String get scenarioStepEditorTimeoutHelper => 'От 1 до 300 секунд (5 мин)';

  @override
  String get scenarioStepEditorContinueOnFailure =>
      'Остановить текущий и продолжить следующий сценарий при ошибке';

  @override
  String get scenarioScreenTitle => 'Сценарии';

  @override
  String get scenarioCreate => 'Создать сценарий';

  @override
  String get scenarioCreateCompact => 'Создать';

  @override
  String get scenarioRunAll => 'Запустить все сценарии';

  @override
  String get scenarioRunAllCompact => 'Запустить все';

  @override
  String get scenarioQuickLaunch => 'Быстрый запуск';

  @override
  String get scenarioNameHint => 'Название сценария';

  @override
  String get scenarioColumnName => 'Название';

  @override
  String get scenarioColumnSteps => 'Шаги';

  @override
  String get scenarioEmptyNotAllowed =>
      'Нельзя сохранить пустой сценарий. Сначала запишите хотя бы одно действие.';

  @override
  String get scenarioLimitReached => 'Допустимо максимум 50 сценариев.';

  @override
  String get scenarioNameMustBeUnique =>
      'Название сценария должно быть уникальным.';

  @override
  String get scenarioQuickLaunchEmpty =>
      'Не выбраны сценарии для быстрого запуска.';

  @override
  String get scenarioRunAllEmpty => 'Нет включенных сценариев для запуска.';

  @override
  String get scenarioExecutionBusy => 'Выполнение уже идет.';

  @override
  String get scenarioBatchDone => 'Пакетное выполнение сценариев завершено.';

  @override
  String get scenarioRename => 'Переименовать';

  @override
  String get scenarioDelete => 'Удалить';

  @override
  String get scenarioDeleteConfirmTitle => 'Удалить сценарий';

  @override
  String scenarioDeleteConfirmMessage(Object name) {
    return 'Вы уверены, что хотите удалить сценарий «$name»?';
  }

  @override
  String get scenarioRenameTitle => 'Переименовать сценарий';

  @override
  String get scenarioExport => 'Экспорт сценариев';

  @override
  String get scenarioImport => 'Импорт сценариев';

  @override
  String get scenarioExportEmpty => 'Нет сценариев для экспорта.';

  @override
  String get scenarioExportDone => 'Сценарии успешно экспортированы.';

  @override
  String get scenarioExportFailed => 'Не удалось экспортировать сценарии.';

  @override
  String get scenarioImportDone => 'Сценарии успешно импортированы.';

  @override
  String get scenarioImportInvalidJson => 'Некорректный JSON файла импорта.';

  @override
  String get scenarioImportNoItems => 'В файле импорта нет валидных сценариев.';

  @override
  String get mainScenarioSectionTitle => 'Сценарии';

  @override
  String get mainOverviewTabTitle => 'Обзор';

  @override
  String get mainStatusPermissions => 'Разрешения';

  @override
  String get mainStatusOverlay => 'Overlay';

  @override
  String get mainStatusRecorder => 'Рекордер';

  @override
  String get mainStatusActions => 'Действия';

  @override
  String get mainStatusOk => 'OK';

  @override
  String get mainStatusOff => 'OFF';

  @override
  String get schedulerScenarioPrefix => 'Сценарий';

  @override
  String get notesLatestChangesTitle => 'Последние изменения';

  @override
  String get notesExportCrashFix =>
      'Исправлен вылет при экспорте настроек/логов.';

  @override
  String get notesMainScreenRedesign =>
      'Главный экран переработан: улучшена читаемость статусов и блоков действий.';

  @override
  String get notesSchedulerScenarioVisible =>
      'В карточке планировщика теперь видно выбранный сценарий.';

  @override
  String get scenarioStepEditorOpen => 'Редактировать шаги';

  @override
  String get scenarioStepEditorSaved => 'Шаги сценария сохранены.';

  @override
  String get scenarioStepEditorSaveFailed =>
      'Не удалось сохранить шаги сценария.';

  @override
  String get scenarioStepEditorLoadFailed =>
      'Не удалось загрузить шаги сценария';

  @override
  String scenarioStepEditorTitle(Object name) {
    return 'Редактировать шаги: $name';
  }

  @override
  String get scenarioStepEditorSubtitle =>
      'Изменяйте порядок шагов, параметры жестов и задержку после каждого шага.';

  @override
  String scenarioStepEditorCount(Object count) {
    return 'Шагов: $count';
  }

  @override
  String scenarioStepEditorStepLabel(Object index) {
    return 'Шаг $index';
  }

  @override
  String get scenarioStepEditorEditTitle => 'Редактировать шаг';

  @override
  String get scenarioStepEditorTypeLabel => 'Тип действия';

  @override
  String get scenarioStepEditorPointerCountLabel => 'Число касаний';

  @override
  String get scenarioStepEditorDurationLabel => 'Длительность жеста (мс)';

  @override
  String get scenarioStepEditorDelayLabel => 'Задержка после шага (мс)';

  @override
  String get scenarioStepEditorStartXLabel => 'Start X';

  @override
  String get scenarioStepEditorStartYLabel => 'Start Y';

  @override
  String get scenarioStepEditorEndXLabel => 'End X';

  @override
  String get scenarioStepEditorEndYLabel => 'End Y';

  @override
  String get scenarioStepEditorInvalidValues =>
      'Введите корректные числовые значения для шага.';

  @override
  String scenarioStepEditorPointerCount(Object count) {
    return 'Касаний: $count';
  }

  @override
  String scenarioStepEditorDuration(Object durationMs) {
    return 'Длительность: $durationMs мс';
  }

  @override
  String scenarioStepEditorDelay(Object delayMs) {
    return 'Задержка: $delayMs мс';
  }

  @override
  String scenarioStepEditorStart(Object x, Object y) {
    return 'Начало: $x, $y';
  }

  @override
  String scenarioStepEditorEnd(Object x, Object y) {
    return 'Конец: $x, $y';
  }

  @override
  String get scenarioStepTypeTap => 'Тап';

  @override
  String get scenarioStepTypeDoubleTap => 'Двойной тап';

  @override
  String get scenarioStepTypeLongPress => 'Долгое нажатие';

  @override
  String get scenarioStepTypeSwipe => 'Свайп';

  @override
  String get scenarioEditBlockedWhileExecuting =>
      'Нельзя редактировать шаги сценария во время выполнения.';

  @override
  String get scenarioDeleteBlockedWhileExecuting =>
      'Нельзя удалить сценарий во время выполнения.';

  @override
  String get scenarioImportBlockedWhileExecuting =>
      'Нельзя импортировать сценарии во время выполнения.';

  @override
  String get scenarioReorderBlockedWhileExecuting =>
      'Нельзя менять порядок сценариев во время выполнения.';
}
