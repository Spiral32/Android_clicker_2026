import 'package:flutter/material.dart';
import 'package:prog_set_touch/core/localization/app_localizations.dart';
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
    final theme = Theme.of(context);

    // All required and optional permissions granted
    if (permissionStatus.areAllGranted) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.permissionsAllGranted),
        ),
      );
    }

    final nextRequired = permissionStatus.nextRequiredPermission;
    final nextOptional = permissionStatus.nextOptionalPermission;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.permissionsTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            // Required permissions section
            if (nextRequired != null) ...[
              Text(
                _description(context, nextRequired),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: isLoading ? null : () => onActionPressed(nextRequired),
                child: Text(_actionLabel(context, nextRequired)),
              ),
            ],
            
            // Optional permissions section (shown only when required are done)
            if (nextRequired == null && nextOptional != null) ...[
              const Divider(height: 24),
              Text(
                'Optional: ${_description(context, nextOptional)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: isLoading ? null : () => onActionPressed(nextOptional),
                child: Text(_actionLabel(context, nextOptional)),
              ),
              const SizedBox(height: 8),
              Text(
                'You can skip this and use the app without screen verification.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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
