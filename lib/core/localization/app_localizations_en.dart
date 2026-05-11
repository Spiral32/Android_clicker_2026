import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prog Set Touch';

  @override
  String get mainScreenTitle => 'Prog Set Touch';

  @override
  String get mainScreenSubtitle => 'Automation base screen';

  @override
  String get mainPrimaryAction => 'Touch setup';

  @override
  String get mainRecordingStart => 'Start recording';

  @override
  String get mainRecordingStop => 'Stop recording';

  @override
  String get mainTestAction => 'Test';

  @override
  String get mainAutostartAction => 'Autostart';

  @override
  String get mainAutostartActionEnable => 'Enable floating button';

  @override
  String get mainAutostartActionDisable => 'Disable floating button';

  @override
  String get mainOpenSettings => 'Settings';

  @override
  String get mainRecorderTip => 'Recording works in a step-by-step non-blocking mode. After start, use the on-screen recorder panel to add taps, double taps, long presses, and swipes.';

  @override
  String get mainRecorderOpenPanel => 'Open recorder panel';

  @override
  String get mainRecorderStopPanel => 'Finish recording';

  @override
  String get mainPlatformSectionTitle => 'Platform status';

  @override
  String get mainPlatformUnavailable => 'Platform data unavailable';

  @override
  String get mainPlatformLabel => 'Platform';

  @override
  String get mainManufacturerLabel => 'Manufacturer';

  @override
  String get mainModelLabel => 'Model';

  @override
  String get mainSdkLabel => 'SDK';

  @override
  String get mainLocaleLabel => 'System locale';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose the app language.';

  @override
  String get settingsLanguageRussian => 'Russian';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsAutostartTitle => 'Autostart';

  @override
  String get settingsAutostartSubtitle => 'Control schedule restoration after device reboot.';

  @override
  String get settingsAutostartToggleTitle => 'Enable autostart after reboot';

  @override
  String get settingsAutostartToggleSubtitle => 'When disabled, BOOT_COMPLETED does not restore schedules automatically.';

  @override
  String get settingsAutostartEnabledMessage => 'Autostart after reboot is enabled.';

  @override
  String get settingsAutostartDisabledMessage => 'Autostart after reboot is disabled.';

  @override
  String get settingsAutostartChangeError => 'Failed to change autostart setting.';

  @override
  String get settingsMediaProjectionTitle => 'MediaProjection';

  @override
  String get settingsMediaProjectionSubtitle => 'This permission is required only for screen capture and screenshot verification.';

  @override
  String get settingsMediaProjectionStatusGranted => 'Status: permission granted';

  @override
  String get settingsMediaProjectionStatusMissing => 'Status: permission not granted';

  @override
  String get settingsMediaProjectionRequestAction => 'Request MediaProjection manually';

  @override
  String get settingsMediaProjectionGrantedMessage => 'MediaProjection permission granted.';

  @override
  String get settingsMediaProjectionDeniedMessage => 'MediaProjection permission not granted.';

  @override
  String get settingsMediaProjectionRequestError => 'Failed to request MediaProjection.';

  @override
  String get settingsExactAlarmTitle => 'Exact alarms';

  @override
  String get settingsExactAlarmSubtitle => 'For maximum schedule accuracy, allow exact alarms in Android system settings.';

  @override
  String get settingsExactAlarmStatusAllowed => 'Status: exact alarms allowed';

  @override
  String get settingsExactAlarmStatusLimited => 'Status: exact alarms limited, schedule may start with delay';

  @override
  String get settingsExactAlarmOpenAction => 'Open exact alarm settings';

  @override
  String get settingsExactAlarmOpenError => 'Failed to open exact alarm settings.';

  @override
  String get settingsDiagnosticsLoadError => 'Failed to load diagnostics.';

  @override
  String get settingsLogExportedMessage => 'Log exported to Download folder.';

  @override
  String get settingsLogExportError => 'Failed to export log.';

  @override
  String get settingsLogOpenLocationError => 'Failed to open log file location.';

  @override
  String get settingsLogClearedMessage => 'Log buffer cleared.';

  @override
  String get settingsLogClearError => 'Failed to clear log.';

  @override
  String get settingsWebSocketTitle => 'WebSocket';

  @override
  String get settingsWebSocketSubtitle => 'Control the built-in server for remote commands and diagnostics.';

  @override
  String get settingsWebSocketEnableTitle => 'Enable server';

  @override
  String get settingsWebSocketEnableSubtitle => 'Starts a single-client WebSocket server with token auth (Authorization: Bearer preferred).';

  @override
  String get settingsWebSocketEnableAction => 'Enable server';

  @override
  String get settingsWebSocketDisableAction => 'Disable server';

  @override
  String get settingsWebSocketRunningLabel => 'Server';

  @override
  String get settingsWebSocketStatusRunning => 'running';

  @override
  String get settingsWebSocketStatusStopped => 'stopped';

  @override
  String get settingsWebSocketClientLabel => 'Client';

  @override
  String get settingsWebSocketStatusClientConnected => 'connected';

  @override
  String get settingsWebSocketStatusNoClient => 'no client';

  @override
  String get settingsWebSocketTransportLabel => 'Transport';

  @override
  String get settingsWebSocketAuthLabel => 'Auth';

  @override
  String get settingsWebSocketAuthModeQueryToken => 'bearer token';

  @override
  String get settingsWebSocketPortLabel => 'Port';

  @override
  String get settingsWebSocketApplyPort => 'Apply';

  @override
  String get settingsWebSocketTokenLabel => 'Access token';

  @override
  String get settingsWebSocketRegenerateToken => 'Regenerate token';

  @override
  String get settingsWebSocketUrlsLabel => 'Connection URLs';

  @override
  String get settingsWebSocketRefreshAction => 'Refresh';

  @override
  String get settingsWebSocketUnavailableAddress => 'No local IPv4 address is available right now.';

  @override
  String get settingsWebSocketLoadError => 'Failed to load WebSocket status';

  @override
  String get settingsWebSocketTimeoutError => 'WebSocket status did not respond in time. Try refreshing again.';

  @override
  String get settingsWebSocketPortError => 'Port must be between 1024 and 65535.';

  @override
  String get settingsDiagnosticsTitle => 'Diagnostics & logs';

  @override
  String get settingsDiagnosticsSubtitle => 'Manage debug logging and quickly export log file.';

  @override
  String get settingsEnableLoggingTitle => 'Enable logging';

  @override
  String get settingsEnableLoggingSubtitle => 'Capture technical logs for diagnostics';

  @override
  String get settingsLogToFileTitle => 'Log to file';

  @override
  String get settingsNoLogFilePath => 'No file path available';

  @override
  String get settingsRefreshAction => 'Refresh';

  @override
  String get settingsClearAction => 'Clear';

  @override
  String get settingsExportAction => 'Export';

  @override
  String get settingsShareAction => 'Share';

  @override
  String get settingsNoLogsAvailable => 'No logs available';

  @override
  String get settingsErrorLoadingLogsPrefix => 'Error loading logs';

  @override
  String get settingsLogsCleared => 'Logs cleared';

  @override
  String get settingsErrorClearingLogsPrefix => 'Error clearing logs';

  @override
  String get settingsLogsExportedPrefix => 'Logs exported to';

  @override
  String get settingsFailedToExportLogs => 'Failed to export logs';

  @override
  String get settingsErrorExportingLogsPrefix => 'Error exporting logs';

  @override
  String get settingsNoExportedLogsToShare => 'No exported logs to share. Export first.';

  @override
  String get settingsGenericErrorPrefix => 'Error';

  @override
  String get settingsPermissionsAllGranted => 'All key permissions are granted.';

  @override
  String get settingsPermissionsMissingSummary => 'Some required permissions are missing. Open each missing permission directly from buttons below.';

  @override
  String get settingsPermissionAccessibilityLabel => 'Accessibility service';

  @override
  String get settingsPermissionOverlayLabel => 'Display over apps';

  @override
  String get settingsPermissionMediaProjectionLabel => 'MediaProjection';

  @override
  String get settingsPermissionGranted => 'granted';

  @override
  String get settingsPermissionMissing => 'not granted';

  @override
  String get settingsExecutionPermissionsRequired => 'To run scenarios, first grant required permissions: Accessibility service and Display over apps.';

  @override
  String get settingsLogSourceLabel => 'Source';

  @override
  String get settingsLogSourceBuffer => 'Buffer';

  @override
  String get settingsLogSourceFileFallback => 'File fallback';

  @override
  String get languageSwitcherTooltip => 'Change language';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get permissionsAllGranted => 'All required permissions are granted. Primary actions are unlocked.';

  @override
  String get permissionsAccessibilityDescription => 'First, enable the accessibility service for Prog Set Touch. Touch automation cannot run without it.';

  @override
  String get permissionsAccessibilityAction => 'Open accessibility settings';

  @override
  String get permissionsOverlayDescription => 'Then allow drawing over other apps. This is required for the background UI and later floating overlay button.';

  @override
  String get permissionsOverlayAction => 'Open overlay settings';

  @override
  String get permissionsMediaProjectionDescription => 'Screen capture permission is requested separately, only for screenshots and screen verification features.';

  @override
  String get permissionsMediaProjectionAction => 'Request MediaProjection';

  @override
  String get overlayStatusTitle => 'Floating overlay';

  @override
  String get overlayStatusVisible => 'Visible and draggable';

  @override
  String get overlayStatusHidden => 'Hidden';

  @override
  String get recorderTitle => 'Recorder';

  @override
  String get recorderStatusRecording => 'Recording is active';

  @override
  String get recorderStatusStopped => 'Recording is stopped';

  @override
  String get recorderTotalActions => 'Total actions';

  @override
  String get recorderTapCount => 'Taps';

  @override
  String get recorderDoubleTapCount => 'Double taps';

  @override
  String get recorderLongPressCount => 'Long presses';

  @override
  String get recorderSwipeCount => 'Swipes';

  @override
  String get recorderMaxPointers => 'Max touch points';

  @override
  String get recorderClear => 'Clear recording';

  @override
  String get recorderClearConfirmTitle => 'Confirmation';

  @override
  String get recorderClearConfirmMessage => 'Are you sure you want to clear the current recording?';

  @override
  String get commonConfirm => 'Yes';

  @override
  String get commonCancel => 'No';

  @override
  String get executionTitle => 'Execution';

  @override
  String get executionStatusExecuting => 'Executing';

  @override
  String get executionStatusPaused => 'Paused';

  @override
  String get executionStatusIdle => 'Idle';

  @override
  String get executionStart => 'Test';

  @override
  String get executionStop => 'Stop';

  @override
  String executionProgress(Object completed, Object total) {
    return '$completed of $total';
  }

  @override
  String get settingsExecutionTitle => 'Execution Settings';

  @override
  String get settingsExecutionDelay => 'Delay between actions';

  @override
  String settingsExecutionDelayUnit(Object seconds) {
    return '$seconds sec.';
  }

  @override
  String get settingsRestoreAppTitle => 'Restore app';

  @override
  String get settingsRestoreAppSubtitle => 'Open the app after finishing scenario execution';

  @override
  String get settingsVisualVerificationTitle => 'Visual Verification';

  @override
  String get settingsVisualVerificationSubtitle => 'Global toggle for screenshot verification during execution';

  @override
  String get settingsRestoreAppChangeError => 'Failed to change restore app setting';

  @override
  String get statusUnavailable => 'Unavailable';

  @override
  String get errorPlatformLoad => 'Failed to load platform data';

  @override
  String get errorPermissionAction => 'Failed to perform permission action';

  @override
  String get errorOverlayAction => 'Failed to change overlay state';

  @override
  String get errorRecorderAction => 'Failed to change recorder state';

  @override
  String get errorRecorderNeedsOverlay => 'Enable the floating button before starting recording';

  @override
  String get errorExecutionAction => 'Failed to execute scenario';

  @override
  String get errorExecutionNotAllowed => 'Execution not allowed in current state';

  @override
  String get errorExecutionPauseFailed => 'Failed to pause execution';

  @override
  String get errorExecutionResumeFailed => 'Failed to resume execution';

  @override
  String get schedulerTitle => 'Scheduler';

  @override
  String get noSchedulesMessage => 'No schedules yet';

  @override
  String get noSchedulesDescription => 'Create your first schedule to automate scenario execution';

  @override
  String get deleteScheduleTitle => 'Delete Schedule';

  @override
  String deleteScheduleMessage(Object name) {
    return 'Are you sure you want to delete \'$name\'?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get addScheduleTitle => 'Add Schedule';

  @override
  String get editScheduleTitle => 'Edit Schedule';

  @override
  String get scheduleNameLabel => 'Name';

  @override
  String get scheduleNameRequired => 'Name is required';

  @override
  String get scheduleTypeLabel => 'Type';

  @override
  String get scheduleTypeOneTime => 'One time';

  @override
  String get scheduleTypeDaily => 'Daily';

  @override
  String get scheduleTypeWeekly => 'Weekly';

  @override
  String get hourLabel => 'Hour';

  @override
  String get minuteLabel => 'Minute';

  @override
  String get invalidHour => 'Hour must be 0-23';

  @override
  String get invalidMinute => 'Minute must be 0-59';

  @override
  String get daysOfWeekLabel => 'Days of week';

  @override
  String get scheduleScenarioLabel => 'Scenario';

  @override
  String get scheduleScenarioRequired => 'Select a scenario';

  @override
  String get scheduleScenarioRequiredToCreate => 'Create at least one scenario first';

  @override
  String get scheduleScenarioMissing => 'Missing scenario';

  @override
  String get save => 'Save';

  @override
  String get settingsAboutTitle => 'About';

  @override
  String get settingsAboutSubtitle => 'How to use Prog Set Touch';

  @override
  String get settingsAboutDescriptionTitle => 'App Description';

  @override
  String get settingsAboutSectionBasics => 'Basics';

  @override
  String get settingsAboutBasicsContent => 'Prog Set Touch is a smart auto-clicker endowed with \"vision\". Unlike regular clickers, it can verify screen changes using visual verification (screenshots).';

  @override
  String get settingsAboutSectionRecording => 'Recording and Editor';

  @override
  String get settingsAboutRecordingContent => 'Record gestures (taps, swipes) using the floating widget over other apps. The built-in step editor allows you to change coordinates, delays, and configure verification thresholds.';

  @override
  String get settingsAboutSectionExecution => 'Visual Control';

  @override
  String get settingsAboutExecutionContent => 'If screen verification is enabled for a step, the clicker takes a screenshot before and after the gesture. By tuning Timeout, Sensitivity Threshold (%), and \'Continue on Failure\', you can create reliable macros resistant to lag.';

  @override
  String get settingsAboutSectionOverlay => 'Execution & Management';

  @override
  String get settingsAboutOverlayContent => 'Run scenarios in batches via Quick Launch. For stable operation, we recommend setting a global delay between steps in Settings.';

  @override
  String get settingsAboutSectionPermissions => 'Permissions & Security';

  @override
  String get settingsAboutPermissionsContent => 'Requires Accessibility service (simulating touches), Display over apps (floating recorder), and MediaProjection (only for visual verification) permissions.';

  @override
  String get scenarioEditWhileExecutingRejected => 'Cannot edit steps while execution is active';

  @override
  String get scenarioStepEditorAddStep => 'Add Step';

  @override
  String get scenarioStepEditorVerificationLabel => 'Verify screen changes';

  @override
  String get scenarioStepEditorVerificationSubtitle => 'Verify if the screen content changed after executing this step';

  @override
  String get scenarioStepEditorThresholdLabel => 'Sensitivity threshold (%)';

  @override
  String scenarioStepEditorThresholdCurrent(Object value) {
    return 'Current: $value%';
  }

  @override
  String get scenarioStepEditorTimeoutLabel => 'Timeout (sec)';

  @override
  String get scenarioStepEditorTimeoutHelper => 'From 1 to 300 seconds (5 min)';

  @override
  String get scenarioStepEditorContinueOnFailure => 'Stop current and continue next scenario on failure';

  @override
  String get scenarioScreenTitle => 'Scenarios';

  @override
  String get scenarioCreate => 'Create Scenario';

  @override
  String get scenarioCreateCompact => 'Create';

  @override
  String get scenarioRunAll => 'Run All Scenarios';

  @override
  String get scenarioRunAllCompact => 'Run All';

  @override
  String get scenarioQuickLaunch => 'Quick Launch';

  @override
  String get scenarioNameHint => 'Scenario name';

  @override
  String get scenarioColumnName => 'Name';

  @override
  String get scenarioColumnSteps => 'Steps';

  @override
  String get scenarioEmptyNotAllowed => 'You cannot save an empty scenario. Record at least one action first.';

  @override
  String get scenarioLimitReached => 'Maximum 50 scenarios allowed.';

  @override
  String get scenarioNameMustBeUnique => 'Scenario name must be unique.';

  @override
  String get scenarioQuickLaunchEmpty => 'No scenarios selected for Quick Launch.';

  @override
  String get scenarioRunAllEmpty => 'No enabled scenarios for Run All.';

  @override
  String get scenarioExecutionBusy => 'Execution is already in progress.';

  @override
  String get scenarioBatchDone => 'Scenario batch execution finished.';

  @override
  String get scenarioRename => 'Rename';

  @override
  String get scenarioDelete => 'Delete';

  @override
  String get scenarioDeleteConfirmTitle => 'Delete Scenario';

  @override
  String scenarioDeleteConfirmMessage(Object name) {
    return 'Are you sure you want to delete scenario \'$name\'?';
  }

  @override
  String get scenarioRenameTitle => 'Rename Scenario';

  @override
  String get scenarioExport => 'Export Scenarios';

  @override
  String get scenarioImport => 'Import Scenarios';

  @override
  String get scenarioExportEmpty => 'No scenarios to export.';

  @override
  String get scenarioExportDone => 'Scenarios exported successfully.';

  @override
  String get scenarioExportFailed => 'Failed to export scenarios.';

  @override
  String get scenarioImportDone => 'Scenarios imported successfully.';

  @override
  String get scenarioImportInvalidJson => 'Import file contains invalid JSON.';

  @override
  String get scenarioImportNoItems => 'No valid scenarios found in import file.';

  @override
  String get mainScenarioSectionTitle => 'Scenarios';

  @override
  String get mainOverviewTabTitle => 'Overview';

  @override
  String get mainStatusPermissions => 'Permissions';

  @override
  String get mainStatusOverlay => 'Overlay';

  @override
  String get mainStatusRecorder => 'Recorder';

  @override
  String get mainStatusActions => 'Actions';

  @override
  String get mainStatusOk => 'OK';

  @override
  String get mainStatusOff => 'OFF';

  @override
  String get schedulerScenarioPrefix => 'Scenario';

  @override
  String get notesLatestChangesTitle => 'Latest changes';

  @override
  String get notesExportCrashFix => 'Fixed app crash during settings/log export.';

  @override
  String get notesMainScreenRedesign => 'Main screen redesigned for clearer status and action blocks.';

  @override
  String get notesSchedulerScenarioVisible => 'Scheduler cards now show the selected scenario.';

  @override
  String get scenarioStepEditorOpen => 'Edit Steps';

  @override
  String get scenarioStepEditorSaved => 'Scenario steps saved.';

  @override
  String get scenarioStepEditorSaveFailed => 'Failed to save scenario steps.';

  @override
  String get scenarioStepEditorLoadFailed => 'Failed to load scenario steps';

  @override
  String scenarioStepEditorTitle(Object name) {
    return 'Edit Steps: $name';
  }

  @override
  String get scenarioStepEditorSubtitle => 'Adjust step order, gesture parameters, and per-step delay.';

  @override
  String scenarioStepEditorCount(Object count) {
    return '$count steps';
  }

  @override
  String scenarioStepEditorStepLabel(Object index) {
    return 'Step $index';
  }

  @override
  String get scenarioStepEditorEditTitle => 'Edit Step';

  @override
  String get scenarioStepEditorTypeLabel => 'Action Type';

  @override
  String get scenarioStepEditorPointerCountLabel => 'Pointer Count';

  @override
  String get scenarioStepEditorDurationLabel => 'Gesture Duration (ms)';

  @override
  String get scenarioStepEditorDelayLabel => 'Delay After Step (ms)';

  @override
  String get scenarioStepEditorStartXLabel => 'Start X';

  @override
  String get scenarioStepEditorStartYLabel => 'Start Y';

  @override
  String get scenarioStepEditorEndXLabel => 'End X';

  @override
  String get scenarioStepEditorEndYLabel => 'End Y';

  @override
  String get scenarioStepEditorInvalidValues => 'Please enter valid numeric values for the step.';

  @override
  String scenarioStepEditorPointerCount(Object count) {
    return 'Pointers: $count';
  }

  @override
  String scenarioStepEditorDuration(Object durationMs) {
    return 'Duration: $durationMs ms';
  }

  @override
  String scenarioStepEditorDelay(Object delayMs) {
    return 'Delay: $delayMs ms';
  }

  @override
  String scenarioStepEditorStart(Object x, Object y) {
    return 'Start: $x, $y';
  }

  @override
  String scenarioStepEditorEnd(Object x, Object y) {
    return 'End: $x, $y';
  }

  @override
  String get scenarioStepTypeTap => 'Tap';

  @override
  String get scenarioStepTypeDoubleTap => 'Double Tap';

  @override
  String get scenarioStepTypeLongPress => 'Long Press';

  @override
  String get scenarioStepTypeSwipe => 'Swipe';

  @override
  String get scenarioEditBlockedWhileExecuting => 'Cannot edit scenario steps while execution is in progress.';

  @override
  String get scenarioDeleteBlockedWhileExecuting => 'Cannot delete a scenario while execution is in progress.';

  @override
  String get scenarioImportBlockedWhileExecuting => 'Cannot import scenarios while execution is in progress.';

  @override
  String get scenarioReorderBlockedWhileExecuting => 'Cannot reorder scenarios while execution is in progress.';
}
