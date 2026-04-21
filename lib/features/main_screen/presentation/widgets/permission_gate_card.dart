import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prog_set_touch/features/main_screen/domain/permission_status.dart';
import 'package:prog_set_touch/features/main_screen/domain/permission_type.dart';

class PermissionGateCard extends StatelessWidget {
  const PermissionGateCard({
    super.key,
    required this.permissionStatus,
    required this.isLoading,
    required this.onActionPressed,
  });

  final PermissionStatus permissionStatus;
  final bool isLoading;
  final ValueChanged<PermissionType> onActionPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (permissionStatus.areAllGranted) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.permissionsAllGranted),
        ),
      );
    }

    final nextPermission = permissionStatus.nextRequiredPermission!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.permissionsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(_description(context, nextPermission)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isLoading ? null : () => onActionPressed(nextPermission),
              child: Text(_actionLabel(context, nextPermission)),
            ),
          ],
        ),
      ),
    );
  }

  String _description(BuildContext context, PermissionType type) {
    final l10n = AppLocalizations.of(context)!;

    switch (type) {
      case PermissionType.accessibility:
        return l10n.permissionsAccessibilityDescription;
      case PermissionType.overlay:
        return l10n.permissionsOverlayDescription;
      case PermissionType.mediaProjection:
        return l10n.permissionsMediaProjectionDescription;
    }
  }

  String _actionLabel(BuildContext context, PermissionType type) {
    final l10n = AppLocalizations.of(context)!;

    switch (type) {
      case PermissionType.accessibility:
        return l10n.permissionsAccessibilityAction;
      case PermissionType.overlay:
        return l10n.permissionsOverlayAction;
      case PermissionType.mediaProjection:
        return l10n.permissionsMediaProjectionAction;
    }
  }
}
