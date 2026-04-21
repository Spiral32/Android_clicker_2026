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
  String get settingsLanguageRussian => 'Russian';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsWebSocketTitle => 'WebSocket';

  @override
  String get settingsWebSocketPlaceholder => 'WSS settings will be available in stage 10';

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
  String get permissionsMediaProjectionDescription => 'The final step is screen capture approval. This permission will be checked before every scenario launch.';

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
}
