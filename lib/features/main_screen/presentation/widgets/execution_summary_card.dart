import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prog_set_touch/features/main_screen/domain/execution_summary.dart';

class ExecutionSummaryCard extends StatelessWidget {
  const ExecutionSummaryCard({
    super.key,
    required this.executionSummary,
  });

  final ExecutionSummary executionSummary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final statusText = executionSummary.isExecuting
        ? l10n.executionStatusExecuting
        : executionSummary.isPaused
            ? l10n.executionStatusPaused
            : l10n.executionStatusIdle;

    final statusColor = executionSummary.isExecuting
        ? Colors.blue
        : executionSummary.isPaused
            ? Colors.orange
            : Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  executionSummary.isExecuting
                      ? Icons.play_circle_filled
                      : executionSummary.isPaused
                          ? Icons.pause_circle_filled
                          : Icons.circle_outlined,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.executionTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              statusText,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (executionSummary.totalActions > 0) ...[
              const SizedBox(height: 8),
              Text(
                l10n.executionProgress(
                  executionSummary.completedActions,
                  executionSummary.totalActions,
                ),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: executionSummary.totalActions > 0
                    ? executionSummary.completedActions /
                        executionSummary.totalActions
                    : 0,
              ),
            ] else if (!executionSummary.isExecuting && !executionSummary.isPaused) ...[
              // Hint when actions available from recorder but not loaded for execution yet
              const SizedBox(height: 8),
              Text(
                'Нажмите "Тест" для запуска',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (executionSummary.hasError) ...[
              const SizedBox(height: 8),
              Text(
                executionSummary.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
