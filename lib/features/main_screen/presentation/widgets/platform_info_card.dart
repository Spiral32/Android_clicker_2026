import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prog_set_touch/features/main_screen/domain/platform_info.dart';

class PlatformInfoCard extends StatelessWidget {
  const PlatformInfoCard({
    super.key,
    required this.platformInfo,
  });

  final PlatformInfo? platformInfo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final info = platformInfo;

    if (info == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.mainPlatformUnavailable),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.mainPlatformSectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _InfoRow(label: l10n.mainPlatformLabel, value: info.platform),
            _InfoRow(
              label: l10n.mainManufacturerLabel,
              value: info.manufacturer,
            ),
            _InfoRow(label: l10n.mainModelLabel, value: info.model),
            _InfoRow(label: l10n.mainSdkLabel, value: info.sdkInt.toString()),
            _InfoRow(label: l10n.mainLocaleLabel, value: info.localeTag),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isEmpty ? l10n.statusUnavailable : value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
