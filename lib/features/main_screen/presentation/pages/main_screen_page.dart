import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/core/localization/app_localizations.dart';
import 'package:prog_set_touch/features/main_screen/data/platform_bridge_data_source.dart';
import 'package:prog_set_touch/features/main_screen/domain/recorder_summary.dart';
import 'package:prog_set_touch/features/main_screen/presentation/bloc/main_screen_bloc.dart';
import 'package:prog_set_touch/features/main_screen/presentation/widgets/permission_gate_card.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_item.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_repository.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_service.dart';
import 'package:prog_set_touch/features/scenario/presentation/bloc/scenario_bloc.dart';
import 'package:prog_set_touch/features/scenario/presentation/widgets/scenario_step_editor_dialog.dart';
import 'package:prog_set_touch/features/settings/domain/settings_repository.dart';
import 'package:prog_set_touch/features/scheduler/presentation/pages/scheduler_screen.dart';
import 'package:prog_set_touch/features/settings/presentation/pages/settings_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:prog_set_touch/shared/widgets/app_language_switcher.dart';

class MainScreenPage extends StatelessWidget {
  const MainScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MainScreenBloc(
            platformBridgeRepository: context.read<PlatformBridgeDataSource>(),
            settingsRepository: context.read<SettingsRepository>(),
            logger: context.read<AppLogger>(),
          )..add(const MainScreenRequested()),
        ),
        BlocProvider(
          create: (context) => ScenarioBloc(
            repository: context.read<ScenarioRepository>(),
            service: context.read<ScenarioService>(),
            platformBridgeRepository: context.read<PlatformBridgeDataSource>(),
            settingsRepository: context.read<SettingsRepository>(),
            logger: context.read<AppLogger>(),
          )..add(const ScenarioLoadRequested()),
        ),
      ],
      child: const _MainScreenView(),
    );
  }
}

class _ControlIconButton extends StatelessWidget {
  const _ControlIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    required this.color,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor: isDisabled ? Colors.grey : color,
        backgroundColor: (isDisabled ? Colors.grey : color).withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _MainScreenView extends StatefulWidget {
  const _MainScreenView();

  @override
  State<_MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<_MainScreenView>
    with WidgetsBindingObserver {
  String? _pendingScenarioName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<MainScreenBloc>().add(const MainScreenRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<MainScreenBloc, MainScreenState>(
          listenWhen: (previous, current) =>
              previous.errorKey != current.errorKey && current.errorKey != null,
          listener: (context, state) {
            final errorText = _formatMainError(context, state.errorKey);
            if (errorText == null) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(errorText)));
          },
        ),
        BlocListener<ScenarioBloc, ScenarioState>(
          listenWhen: (previous, current) =>
              previous.messageKey != current.messageKey &&
              current.messageKey != null,
          listener: (context, state) {
            final message = _formatScenarioMessage(context, state.messageKey);
            if (message == null) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          },
        ),
        BlocListener<MainScreenBloc, MainScreenState>(
          listenWhen: (previous, current) =>
              previous.recorderSummary.isRecording &&
              !current.recorderSummary.isRecording,
          listener: (context, state) {
            if (_pendingScenarioName != null) {
              _stopAndSavePendingScenario(context);
            }
          },
        ),
      ],
      child: BlocBuilder<MainScreenBloc, MainScreenState>(
        builder: (context, mainState) {
          return BlocBuilder<ScenarioBloc, ScenarioState>(
            builder: (context, scenarioState) {
              final actionsEnabled = mainState.permissionStatus.areAllGranted;

              return Scaffold(
                appBar: AppBar(
                  title: Text(l10n.mainScreenTitle),
                  actions: [
                    const AppLanguageMenuButton(),
                    IconButton(
                      tooltip: l10n.schedulerTitle,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SchedulerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.schedule),
                    ),
                  ],
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      // Modern Control Panel
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              _ControlIconButton(
                                tooltip: l10n.scenarioCreate,
                                onPressed: () {
                                  if (_pendingScenarioName != null) {
                                    _stopAndSavePendingScenario(context);
                                    return;
                                  }
                                  _showCreateDialog(context);
                                },
                                icon: _pendingScenarioName != null
                                    ? Icons.stop_circle
                                    : Icons.add_rounded,
                                color: _pendingScenarioName != null
                                    ? Colors.orange
                                    : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              _ControlIconButton(
                                tooltip: l10n.scenarioRunAll,
                                onPressed: scenarioState.isExecuting
                                    ? null
                                    : () => context
                                        .read<ScenarioBloc>()
                                        .add(const ScenarioRunAllRequested()),
                                icon: Icons.play_arrow_rounded,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 8),
                              _ControlIconButton(
                                tooltip: mainState.overlayStatus.visible
                                    ? l10n.mainAutostartActionDisable
                                    : l10n.mainAutostartActionEnable,
                                onPressed: (mainState
                                            .permissionStatus.areAllGranted &&
                                        !mainState
                                            .recorderSummary.isRecording &&
                                        !mainState.isOverlayActionInProgress)
                                    ? () {
                                        context.read<MainScreenBloc>().add(
                                              const MainScreenOverlayToggleRequested(),
                                            );
                                      }
                                    : null,
                                icon: mainState.overlayStatus.visible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: mainState.overlayStatus.visible
                                    ? theme.colorScheme.primary
                                    : Colors.blueGrey,
                              ),
                              const Spacer(),
                              _ControlIconButton(
                                tooltip: l10n.mainOpenSettings,
                                onPressed: () {
                                  final mainScreenBloc =
                                      context.read<MainScreenBloc>();
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider.value(
                                              value: mainScreenBloc),
                                          BlocProvider.value(
                                            value: context.read<ScenarioBloc>(),
                                          ),
                                        ],
                                        child: const SettingsPage(),
                                      ),
                                    ),
                                  );
                                },
                                icon: Icons.settings_outlined,
                                color: Colors.blueGrey.shade700,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!mainState.permissionStatus.areAllGranted)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: PermissionGateCard(
                            permissionStatus: mainState.permissionStatus,
                            isLoading: mainState.isPermissionActionInProgress,
                            onActionPressed: (permissionType) {
                              context.read<MainScreenBloc>().add(
                                    MainScreenPermissionActionPressed(
                                        permissionType),
                                  );
                            },
                          ),
                        ),

                      // Scenario List Section
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _ScenarioTableHeader(
                                allSelected:
                                    scenarioState.isAllQuickLaunchSelected,
                                partialSelected:
                                    scenarioState.isAnyQuickLaunchSelected &&
                                        !scenarioState.isAllQuickLaunchSelected,
                                onSelectAll: () =>
                                    context.read<ScenarioBloc>().add(
                                          const ScenarioSelectAllQuickLaunchToggled(),
                                        ),
                              ),
                              const Divider(height: 1),
                              if (scenarioState.isExecuting)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                  child: Column(
                                    children: [
                                      LinearProgressIndicator(
                                        value: scenarioState.totalInBatch > 0
                                            ? scenarioState.completedInBatch /
                                                scenarioState.totalInBatch
                                            : null,
                                      ),
                                      const SizedBox(height: 4),
                                      if (scenarioState
                                          .executionSummary.isExecuting)
                                        Text(
                                          l10n.executionProgress(
                                            scenarioState.executionSummary
                                                .completedActions,
                                            scenarioState
                                                .executionSummary.totalActions,
                                          ),
                                          style: theme.textTheme.bodySmall,
                                        ),
                                    ],
                                  ),
                                ),
                              scenarioState.isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    )
                                  : ReorderableListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: scenarioState.scenarios.length,
                                      onReorder: (oldIndex, newIndex) {
                                        var adjusted = newIndex;
                                        if (newIndex > oldIndex) {
                                          adjusted = newIndex - 1;
                                        }
                                        context.read<ScenarioBloc>().add(
                                              ScenarioReordered(
                                                  oldIndex: oldIndex,
                                                  newIndex: adjusted),
                                            );
                                      },
                                      itemBuilder: (context, index) {
                                        final item =
                                            scenarioState.scenarios[index];
                                        return _ScenarioTableRow(
                                          key: ValueKey(item.id),
                                          index: index,
                                          scenario: item,
                                          isActive:
                                              scenarioState.activeScenarioId ==
                                                  item.id,
                                          onQuickLaunchToggled: () => context
                                              .read<ScenarioBloc>()
                                              .add(ScenarioQuickLaunchToggled(
                                                  item.id)),
                                          onEnabledToggled: () => context
                                              .read<ScenarioBloc>()
                                              .add(ScenarioEnabledToggled(
                                                  item.id)),
                                          onRunSingle: scenarioState.isExecuting
                                              ? null
                                              : () => context
                                                  .read<ScenarioBloc>()
                                                  .add(
                                                      ScenarioSingleRunRequested(
                                                          item.id)),
                                          onLongPress: () =>
                                              _showScenarioActions(
                                                  context, item),
                                        );
                                      },
                                    ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButton: scenarioState.isExecuting
                    ? FloatingActionButton(
                        onPressed: () => context
                            .read<ScenarioBloc>()
                            .add(const ScenarioStopRequested()),
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.stop),
                      )
                    : (scenarioState.isAnyQuickLaunchSelected
                        ? FloatingActionButton(
                            onPressed: () => context
                                .read<ScenarioBloc>()
                                .add(const ScenarioQuickLaunchRunRequested()),
                            child: const Icon(Icons.flash_on),
                          )
                        : null),
              );
            },
          );
        },
      ),
    );
  }

  String? _formatMainError(BuildContext context, String? errorKey) {
    if (errorKey == null) return null;
    final l10n = AppLocalizations.of(context)!;
    return switch (errorKey) {
      'errorPermissionAction' => l10n.errorPermissionAction,
      'errorOverlayAction' => l10n.errorOverlayAction,
      'errorRecorderAction' => l10n.errorRecorderAction,
      'errorRecorderNeedsOverlay' => l10n.errorRecorderNeedsOverlay,
      'errorExecutionAction' => l10n.errorExecutionAction,
      'errorExecutionNotAllowed' => l10n.errorExecutionNotAllowed,
      'errorExecutionPauseFailed' => l10n.errorExecutionPauseFailed,
      'errorExecutionResumeFailed' => l10n.errorExecutionResumeFailed,
      _ => null,
    };
  }

  String? _formatScenarioMessage(BuildContext context, String? messageKey) {
    if (messageKey == null) return null;
    final l10n = AppLocalizations.of(context)!;
    return switch (messageKey) {
      'scenarioEmptyNotAllowed' => l10n.scenarioEmptyNotAllowed,
      'scenarioLimitReached' => l10n.scenarioLimitReached,
      'scenarioNameMustBeUnique' => l10n.scenarioNameMustBeUnique,
      'scenarioQuickLaunchEmpty' => l10n.scenarioQuickLaunchEmpty,
      'scenarioRunAllEmpty' => l10n.scenarioRunAllEmpty,
      'scenarioExecutionBusy' => l10n.scenarioExecutionBusy,
      'scenarioBatchDone' => l10n.scenarioBatchDone,
      'scenarioImportDone' => l10n.scenarioImportDone,
      'scenarioImportInvalidJson' => l10n.scenarioImportInvalidJson,
      'scenarioImportNoItems' => l10n.scenarioImportNoItems,
      'scenarioStepEditorSaved' => l10n.scenarioStepEditorSaved,
      'scenarioStepEditorSaveFailed' => l10n.scenarioStepEditorSaveFailed,
      'scenarioEditBlockedWhileExecuting' =>
        l10n.scenarioEditBlockedWhileExecuting,
      'scenarioDeleteBlockedWhileExecuting' =>
        l10n.scenarioDeleteBlockedWhileExecuting,
      'scenarioImportBlockedWhileExecuting' =>
        l10n.scenarioImportBlockedWhileExecuting,
      'scenarioReorderBlockedWhileExecuting' =>
        l10n.scenarioReorderBlockedWhileExecuting,
      'scenarioBatchStoppedOnVerificationFailure' =>
        l10n.errorExecutionAction,
      _ => null,
    };
  }

  AppLogger _logger(BuildContext context) => context.read<AppLogger>();

  Future<void> _exportScenarios(
    BuildContext context,
    ScenarioState state,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (state.scenarios.isEmpty) {
      _logger(context).logInfo(
        'main_screen_page',
        'Scenario export skipped',
        payload: {'action': 'scenario_export_skip_empty'},
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.scenarioExportEmpty)),
      );
      return;
    }

    try {
      final fileName =
          'scenarios_${DateTime.now().millisecondsSinceEpoch}.json';
      final platformBridge = context.read<PlatformBridgeDataSource>();
      final scenariosPayload = <Map<String, dynamic>>[];
      for (final entry in state.scenarios) {
        final actions = await platformBridge.exportScenarioActions(entry.id);
        scenariosPayload.add({
          ...entry.toMap(),
          'actions': actions,
        });
      }

      final payload = jsonEncode({
        'version': 1,
        'scenarios': scenariosPayload,
      });

      String? path;
      if (Platform.isAndroid) {
        final tempDir = await getTemporaryDirectory();
        final exportFile = File('${tempDir.path}/$fileName');
        await exportFile.writeAsString(payload);
        path = exportFile.path;
        await Share.shareXFiles(
          [XFile(exportFile.path)],
          subject: 'ProgSet Touch Scenarios',
        );
      } else {
        path = await FilePicker.platform.saveFile(
          dialogTitle: l10n.scenarioExport,
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: const ['json'],
        );
        if (path != null) {
          await File(path).writeAsString(payload);
        }
      }

      _logger(context).logInfo(
        'main_screen_page',
        'Scenario export completed',
        payload: {
          'action': 'scenario_export_done',
          'count': state.scenarios.length,
          'withActions': true,
          'path': path,
        },
      );
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.scenarioExportDone)),
        );
      }
    } catch (error, stackTrace) {
      _logger(context).logError(
        'main_screen_page',
        error,
        stackTrace,
        context: 'Scenario export failed | action=scenario_export_failed',
      );
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.scenarioExportFailed)),
        );
      }
    }
  }

  Future<void> _importScenarios(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      _logger(context).logInfo(
        'main_screen_page',
        'Scenario import cancelled by user',
        payload: {'action': 'scenario_import_cancel'},
      );
      return;
    }

    final file = result.files.first;
    String? content;
    if (file.bytes != null) {
      content = utf8.decode(file.bytes!);
    } else if (file.path != null) {
      content = await File(file.path!).readAsString();
    }
    if (content == null || content.trim().isEmpty) {
      _logger(context).logInfo(
        'main_screen_page',
        'Scenario import rejected: empty content',
        payload: {'action': 'scenario_import_empty_payload'},
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.scenarioImportInvalidJson)),
        );
      }
      return;
    }
    if (context.mounted) {
      _logger(context).logInfo(
        'main_screen_page',
        'Scenario import requested',
        payload: {
          'action': 'scenario_import_requested',
          'bytes': content.length,
          'file': file.name,
        },
      );
      context.read<ScenarioBloc>().add(ScenarioImportRequested(content));
    }
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final mainState = context.read<MainScreenBloc>().state;
    final scenarioState = context.read<ScenarioBloc>().state;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.scenarioCreate),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.scenarioNameHint),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    if (name == null || name.trim().isEmpty) {
      _logger(context).logInfo(
        'main_screen_page',
        'Scenario create cancelled or empty',
        payload: {'action': 'scenario_create_cancel_or_empty'},
      );
      return;
    }

    final trimmedName = name.trim();

    if (!context.mounted) return;
    if (_pendingScenarioName != null ||
        mainState.recorderSummary.isRecording ||
        scenarioState.isExecuting) {
      return;
    }

    if (!mainState.overlayStatus.visible) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.errorRecorderNeedsOverlay)),
        );
      return;
    }

    setState(() => _pendingScenarioName = trimmedName);
    _logger(context).logInfo(
      'main_screen_page',
      'Scenario recording flow started',
      payload: {
        'action': 'scenario_recording_flow_started',
        'name': trimmedName
      },
    );

    try {
      await context.read<PlatformBridgeDataSource>().startRecorder(
            mode: RecorderMode.pointCapture,
          );
      if (!context.mounted) return;
      context.read<MainScreenBloc>().add(const MainScreenRequested());
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.mainRecorderTip)),
        );
    } catch (error) {
      if (!context.mounted) return;
      setState(() => _pendingScenarioName = null);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${l10n.settingsGenericErrorPrefix}: $error')),
        );
    }
  }

  Future<void> _stopAndSavePendingScenario(BuildContext context) async {
    final pendingName = _pendingScenarioName;
    if (pendingName == null) return;
    final l10n = AppLocalizations.of(context)!;

    try {
      final summary =
          await context.read<PlatformBridgeDataSource>().stopRecorder();
      if (!context.mounted) return;

      if (summary.totalActions <= 0) {
        setState(() => _pendingScenarioName = null);
        context.read<MainScreenBloc>().add(const MainScreenRequested());
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(l10n.scenarioEmptyNotAllowed)),
          );
        return;
      }

      context.read<ScenarioBloc>().add(
            ScenarioCreateRequested(
              name: pendingName,
              stepCount: summary.totalActions,
            ),
          );
      setState(() => _pendingScenarioName = null);
      context.read<MainScreenBloc>().add(const MainScreenRequested());
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${l10n.settingsGenericErrorPrefix}: $error')),
        );
    }
  }

  void _showScenarioActions(BuildContext context, ScenarioItem scenario) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_note_outlined),
                title: Text(l10n.scenarioStepEditorOpen),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _showStepEditor(context, scenario);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.scenarioRename),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _showRenameDialog(context, scenario);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(l10n.scenarioDelete,
                    style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _showDeleteConfirmation(context, scenario);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRenameDialog(
      BuildContext context, ScenarioItem scenario) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: scenario.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.scenarioRenameTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.scenarioNameHint),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (newName != null &&
        newName.trim().isNotEmpty &&
        newName.trim() != scenario.name) {
      if (context.mounted) {
        context.read<ScenarioBloc>().add(
              ScenarioRenameRequested(
                scenarioId: scenario.id,
                newName: newName.trim(),
              ),
            );
      }
    }
  }

  Future<void> _showStepEditor(
    BuildContext context,
    ScenarioItem scenario,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ScenarioBloc>(),
        child: ScenarioStepEditorDialog(scenario: scenario),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, ScenarioItem scenario) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.scenarioDeleteConfirmTitle),
          content: Text(l10n.scenarioDeleteConfirmMessage(scenario.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (context.mounted) {
        context.read<ScenarioBloc>().add(ScenarioDeleteRequested(scenario.id));
      }
    }
  }
}

class _ScenarioTableHeader extends StatelessWidget {
  const _ScenarioTableHeader({
    required this.allSelected,
    required this.partialSelected,
    required this.onSelectAll,
  });

  final bool allSelected;
  final bool partialSelected;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Checkbox(
              tristate: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              value: allSelected ? true : (partialSelected ? null : false),
              onChanged: (_) => onSelectAll(),
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 32,
            child: Icon(Icons.flash_on, size: 18, color: Colors.amber),
          ),
          const SizedBox(
            width: 48,
            child: Text(
              'ON',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.scenarioColumnName.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.5,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              l10n.scenarioColumnSteps.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(
            width: 40,
            child: Icon(Icons.play_arrow_rounded, size: 20, color: Colors.grey),
          ),
          const SizedBox(
            width: 32,
            child: Icon(Icons.swap_vert_rounded, size: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isOk,
  });

  final String label;
  final bool isOk;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isOk ? const Color(0xFFEAF9EE) : const Color(0xFFFFF5E8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isOk ? const Color(0xFFB6E0C2) : const Color(0xFFF1D3A5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '$label: ${isOk ? l10n.mainStatusOk : l10n.mainStatusOff}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isOk ? const Color(0xFF2E7D32) : const Color(0xFFC77800),
          ),
        ),
      ),
    );
  }
}

class _ScenarioTableRow extends StatelessWidget {
  const _ScenarioTableRow({
    super.key,
    required this.index,
    required this.scenario,
    required this.isActive,
    required this.onQuickLaunchToggled,
    required this.onEnabledToggled,
    required this.onRunSingle,
    required this.onLongPress,
  });

  final int index;
  final ScenarioItem scenario;
  final bool isActive;
  final VoidCallback onQuickLaunchToggled;
  final VoidCallback onEnabledToggled;
  final VoidCallback? onRunSingle;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onLongPress: onLongPress,
      child: Container(
        key: key,
        color: isActive ? theme.colorScheme.primaryContainer : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            // Select (Quick Launch)
            SizedBox(
              width: 32,
              child: Checkbox(
                value: scenario.quickLaunchEnabled,
                onChanged: (_) => onQuickLaunchToggled(),
              ),
            ),
            const SizedBox(width: 8),
            // Quick Launch Icon
            SizedBox(
              width: 32,
              child: Icon(
                Icons.flash_on,
                color: scenario.quickLaunchEnabled
                    ? Colors.amber
                    : Colors.grey[300],
                size: 20,
              ),
            ),
            // ON/OFF Switch
            SizedBox(
              width: 48,
              child: Switch(
                value: scenario.isEnabled,
                onChanged: (_) => onEnabledToggled(),
              ),
            ),
            const SizedBox(width: 8),
            // Name
            Expanded(
              child: Text(
                scenario.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Steps
            SizedBox(
              width: 50,
              child: Text(
                '${scenario.stepCount}',
                textAlign: TextAlign.center,
              ),
            ),
            // Run Single
            SizedBox(
              width: 40,
              child: IconButton(
                icon: const Icon(Icons.play_arrow, size: 20),
                onPressed: onRunSingle,
              ),
            ),
            // Reorder Handle
            SizedBox(
              width: 32,
              child: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.swap_vert, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
