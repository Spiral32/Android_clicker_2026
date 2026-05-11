import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prog_set_touch/core/localization/localization_extensions.dart';
import 'package:prog_set_touch/features/scheduler/domain/schedule.dart';

class ScheduleListItem extends StatelessWidget {
  const ScheduleListItem({
    super.key,
    required this.schedule,
    this.scenarioName,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final Schedule schedule;
  final String? scenarioName;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          _getScheduleIcon(schedule.type),
          color: schedule.isActive ? Colors.green : Colors.grey,
        ),
        title: Text(schedule.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getScheduleDescription(schedule)),
            const SizedBox(height: 2),
            Text(
              '${l10n.schedulerScenarioPrefix}: ${scenarioName ?? schedule.scenarioId}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: schedule.isActive,
              onChanged: onToggle,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getScheduleIcon(ScheduleType type) {
    return switch (type) {
      ScheduleType.oneTime => Icons.schedule,
      ScheduleType.daily => Icons.repeat,
      ScheduleType.weekly => Icons.calendar_view_week,
    };
  }

  String _getScheduleDescription(Schedule schedule) {
    final time =
        '${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')}';

    return switch (schedule.type) {
      ScheduleType.oneTime => schedule.dateTimestamp != null
          ? 'Once at $time on ${DateFormat.yMd().format(DateTime.fromMillisecondsSinceEpoch(schedule.dateTimestamp!))}'
          : 'Once at $time',
      ScheduleType.daily => 'Daily at $time',
      ScheduleType.weekly =>
        schedule.daysOfWeek != null && schedule.daysOfWeek!.isNotEmpty
            ? 'Weekly at $time on ${_formatDays(schedule.daysOfWeek!)}'
            : 'Weekly at $time',
    };
  }

  String _formatDays(List<int> days) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((day) => dayNames[day]).join(', ');
  }
}
