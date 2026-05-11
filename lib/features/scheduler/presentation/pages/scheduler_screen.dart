import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/core/localization/localization_extensions.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_repository.dart';
import 'package:prog_set_touch/features/scheduler/domain/schedule.dart'
    as domain;
import 'package:prog_set_touch/features/scheduler/presentation/bloc/scheduler_bloc.dart';
import 'package:prog_set_touch/features/scheduler/presentation/widgets/schedule_form.dart';
import 'package:prog_set_touch/features/scheduler/presentation/widgets/schedule_list_item.dart';

class SchedulerScreen extends StatelessWidget {
  const SchedulerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.schedulerTitle),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: const _SchedulerView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context) async {
    final schedule = await showDialog<domain.Schedule>(
      context: context,
      builder: (context) => const ScheduleForm(),
    );

    if (schedule != null) {
      context.read<SchedulerBloc>().add(SchedulerScheduleAdded(schedule));
    }
  }
}

class _SchedulerView extends StatefulWidget {
  const _SchedulerView();

  @override
  State<_SchedulerView> createState() => _SchedulerViewState();
}

class _SchedulerViewState extends State<_SchedulerView> {
  late final Future<Map<String, String>> _scenarioNamesFuture;

  @override
  void initState() {
    super.initState();
    _scenarioNamesFuture = _loadScenarioNames();
  }

  Future<Map<String, String>> _loadScenarioNames() async {
    final logger = context.read<AppLogger>();
    try {
      final scenarios = await context.read<ScenarioRepository>().getAll();
      final mapped = {
        for (final scenario in scenarios) scenario.id: scenario.name,
      };
      logger.logInfo(
        'scheduler_screen',
        'Scenario names loaded for scheduler',
        payload: {'count': mapped.length},
      );
      return mapped;
    } catch (error, stackTrace) {
      logger.logError(
        'scheduler_screen',
        error,
        stackTrace,
        context: 'Failed to load scenario names for scheduler list',
      );
      return const <String, String>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _scenarioNamesFuture,
      builder: (context, scenarioSnapshot) {
        final scenarioNames = scenarioSnapshot.data ?? const <String, String>{};
        return BlocBuilder<SchedulerBloc, SchedulerState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.error}'),
                    ElevatedButton(
                      onPressed: () => context
                          .read<SchedulerBloc>()
                          .add(const SchedulerSchedulesLoaded()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.schedules.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.noSchedulesMessage,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.noSchedulesDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.schedules.length,
              itemBuilder: (context, index) {
                final schedule = state.schedules[index];
                return ScheduleListItem(
                  schedule: schedule,
                  scenarioName: scenarioNames[schedule.scenarioId],
                  onTap: () => _showEditScheduleDialog(context, schedule),
                  onToggle: (isActive) =>
                      _toggleSchedule(context, schedule, isActive),
                  onDelete: () => _showDeleteConfirmation(context, schedule),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showEditScheduleDialog(
      BuildContext context, domain.Schedule schedule) async {
    final updatedSchedule = await showDialog<domain.Schedule>(
      context: context,
      builder: (context) => ScheduleForm(schedule: schedule),
    );

    if (updatedSchedule != null) {
      context
          .read<SchedulerBloc>()
          .add(SchedulerScheduleUpdated(updatedSchedule));
    }
  }

  void _toggleSchedule(
      BuildContext context, domain.Schedule schedule, bool isActive) {
    final updatedSchedule = schedule.copyWith(isActive: isActive);
    context
        .read<SchedulerBloc>()
        .add(SchedulerScheduleUpdated(updatedSchedule));
  }

  void _showDeleteConfirmation(BuildContext context, domain.Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteScheduleTitle),
        content: Text(context.l10n.deleteScheduleMessage(schedule.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<SchedulerBloc>()
                  .add(SchedulerScheduleDeleted(schedule.id));
              Navigator.of(context).pop();
            },
            child: Text(context.l10n.delete),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
