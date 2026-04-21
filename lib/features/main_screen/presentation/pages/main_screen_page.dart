import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/features/main_screen/data/platform_bridge_data_source.dart';
import 'package:prog_set_touch/features/main_screen/domain/recorder_summary.dart';
import 'package:prog_set_touch/features/main_screen/presentation/bloc/main_screen_bloc.dart';
import 'package:prog_set_touch/features/main_screen/presentation/widgets/execution_summary_card.dart';
import 'package:prog_set_touch/features/main_screen/presentation/widgets/main_action_card.dart';
import 'package:prog_set_touch/features/main_screen/presentation/widgets/permission_gate_card.dart';
import 'package:prog_set_touch/features/main_screen/presentation/widgets/platform_info_card.dart';
import 'package:prog_set_touch/features/main_screen/presentation/widgets/recorder_summary_card.dart';
import 'package:prog_set_touch/features/settings/presentation/pages/diagnostics_settings_page.dart';

class MainScreenPage extends StatelessWidget {
  const MainScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainScreenBloc(
        platformBridgeRepository: context.read<PlatformBridgeDataSource>(),
        logger: context.read<AppLogger>(),
      )..add(const MainScreenRequested()),
      child: const _MainScreenView(),
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

    return BlocConsumer<MainScreenBloc, MainScreenState>(
      listenWhen: (previous, current) =>
          previous.errorKey != current.errorKey && current.errorKey != null,
      listener: (context, state) {
        final errorText = switch (state.errorKey) {
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

        if (errorText == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorText)));
      },
      builder: (context, state) {
        final actionsEnabled = state.permissionStatus.areAllGranted;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.mainScreenTitle),
            actions: [
              IconButton(
                tooltip: l10n.mainOpenSettings,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider.value(
                        value: context.read<MainScreenBloc>(),
                        child: const SettingsPage(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<MainScreenBloc>().add(const MainScreenRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Text(
                    l10n.mainScreenSubtitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  if (state.status == MainScreenStatus.loaded ||
                      state.status == MainScreenStatus.failure)
                    PermissionGateCard(
                      permissionStatus: state.permissionStatus,
                      isLoading: state.isPermissionActionInProgress,
                      onActionPressed: (permissionType) {
                        context.read<MainScreenBloc>().add(
                              MainScreenPermissionActionPressed(permissionType),
                            );
                      },
                    ),

                  if (!state.recorderSummary.isRecording)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F9FC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFD8E3EE)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.tips_and_updates_outlined),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Запись работает в пошаговом неблокирующем режиме. После старта используйте панель записи поверх экрана, чтобы добавлять тапы, двойные тапы, долгие нажатия и свайпы.',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // ==================== Зелёная кнопка записи ====================
                  MainActionCard(
                    title: state.recorderSummary.isRecording
                        ? 'Завершить запись'
                        : 'Открыть панель записи',
                    icon: Icons.touch_app_outlined,
                    backgroundColor: state.recorderSummary.isRecording
                        ? const Color(0xFFB42318) // красный при записи
                        : const Color(
                            0xFF34C759), // зелёный в обычном состоянии
                    foregroundColor: Colors.white,
                    enabled: actionsEnabled &&
                        state.overlayStatus.visible &&
                        !state.isRecorderActionInProgress,
                    onTap: () {
                      context.read<MainScreenBloc>().add(
                            state.recorderSummary.isRecording
                                ? const MainScreenRecorderStopRequested()
                                : const MainScreenRecorderStartRequested(
                                    mode: RecorderMode.pointCapture,
                                  ),
                          );
                    },
                  ),

                  // Кнопка выполнения (оставил как было, можно тоже сделать зелёной при необходимости)
                  MainActionCard(
                    title: state.executionSummary.isExecuting
                        ? l10n.executionStop
                        : l10n.executionStart,
                    icon: state.executionSummary.isExecuting
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_outline,
                    backgroundColor: state.executionSummary.isExecuting
                        ? const Color(0xFFB42318)
                        : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    enabled: actionsEnabled &&
                        (state.executionSummary.isExecuting ||
                            (state.appState.canExecute &&
                                state.recorderSummary.totalActions > 0 &&
                                !state.isExecutionActionInProgress)),
                    onTap: () {
                      if (state.executionSummary.isExecuting) {
                        context.read<MainScreenBloc>().add(
                              const MainScreenExecutionStopRequested(),
                            );
                      } else {
                        context.read<MainScreenBloc>().add(
                              const MainScreenExecutionStartRequested(),
                            );
                      }
                    },
                  ),

                  if (state.executionSummary.isExecuting ||
                      state.executionSummary.isPaused)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: LinearProgressIndicator(
                        value: state.executionSummary.totalActions > 0
                            ? state.executionSummary.completedActions /
                                state.executionSummary.totalActions
                            : 0,
                      ),
                    ),

                  // Кнопка оверлея
                  MainActionCard(
                    title: state.overlayStatus.visible
                        ? l10n.mainAutostartActionDisable
                        : l10n.mainAutostartActionEnable,
                    icon: Icons.power_settings_new_outlined,
                    backgroundColor: state.overlayStatus.visible
                        ? Colors.orangeAccent
                        : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    enabled: actionsEnabled &&
                        !state.recorderSummary.isRecording &&
                        !state.isOverlayActionInProgress,
                    onTap: () {
                      context.read<MainScreenBloc>().add(
                            const MainScreenOverlayToggleRequested(),
                          );
                    },
                  ),

                  if (!state.recorderSummary.isRecording &&
                      state.recorderSummary.totalActions > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: state.isRecorderActionInProgress
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title:
                                          Text(l10n.recorderClearConfirmTitle),
                                      content: Text(
                                          l10n.recorderClearConfirmMessage),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text(l10n.commonCancel),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text(l10n.commonConfirm),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true && context.mounted) {
                                    context.read<MainScreenBloc>().add(
                                          const MainScreenRecorderClearRequested(),
                                        );
                                  }
                                },
                          icon: const Icon(Icons.delete_outline),
                          label: Text(l10n.recorderClear),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                  if (state.status == MainScreenStatus.initial ||
                      state.status == MainScreenStatus.loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (state.status == MainScreenStatus.failure)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Text(l10n.errorPlatformLoad),
                      ),
                    )
                  else ...[
                    if (state.executionSummary.isExecuting ||
                        state.executionSummary.isPaused ||
                        state.recorderSummary.totalActions > 0)
                      ExecutionSummaryCard(
                        executionSummary: state.executionSummary,
                      ),
                    RecorderSummaryCard(
                      recorderSummary: state.recorderSummary,
                    ),
                    PlatformInfoCard(
                      platformInfo: state.platformInfo,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
