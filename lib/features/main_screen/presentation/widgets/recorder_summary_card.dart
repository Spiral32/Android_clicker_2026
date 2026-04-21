import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prog_set_touch/features/main_screen/domain/recorder_summary.dart';

class RecorderSummaryCard extends StatelessWidget {
  const RecorderSummaryCard({
    super.key,
    required this.recorderSummary,
  });

  final RecorderSummary recorderSummary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recorderTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              recorderSummary.isRecording
                  ? l10n.recorderStatusRecording
                  : l10n.recorderStatusStopped,
            ),
            const SizedBox(height: 4),
            Text(
              'Mode: ${recorderSummary.mode.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            _RecorderRow(
              label: l10n.recorderTotalActions,
              value: recorderSummary.totalActions.toString(),
            ),
            _RecorderRow(
              label: l10n.recorderTapCount,
              value: recorderSummary.tapCount.toString(),
            ),
            _RecorderRow(
              label: l10n.recorderDoubleTapCount,
              value: recorderSummary.doubleTapCount.toString(),
            ),
            _RecorderRow(
              label: l10n.recorderLongPressCount,
              value: recorderSummary.longPressCount.toString(),
            ),
            _RecorderRow(
              label: l10n.recorderSwipeCount,
              value: recorderSummary.swipeCount.toString(),
            ),
            _RecorderRow(
              label: l10n.recorderMaxPointers,
              value: recorderSummary.maxPointerCount.toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecorderRow extends StatelessWidget {
  const _RecorderRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text(value),
        ],
      ),
    );
  }
}
