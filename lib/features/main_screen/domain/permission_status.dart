import 'package:equatable/equatable.dart';
import 'package:prog_set_touch/features/main_screen/domain/permission_type.dart';

class PermissionStatus extends Equatable {
  const PermissionStatus({
    required this.accessibilityGranted,
    required this.overlayGranted,
    required this.mediaProjectionGranted,
  });

  final bool accessibilityGranted;
  final bool overlayGranted;
  final bool mediaProjectionGranted;

  const PermissionStatus.initial()
      : accessibilityGranted = false,
        overlayGranted = false,
        mediaProjectionGranted = false;

  /// All permissions including optional MediaProjection
  bool get areAllGranted =>
      accessibilityGranted && overlayGranted && mediaProjectionGranted;

  /// Only required permissions for basic execution (without screen verification)
  bool get areExecutionPermissionsGranted =>
      accessibilityGranted && overlayGranted;

  PermissionType? get nextRequiredPermission {
    if (!accessibilityGranted) {
      return PermissionType.accessibility;
    }

    if (!overlayGranted) {
      return PermissionType.overlay;
    }

    return null;
  }

  /// Get next optional permission that could be requested
  PermissionType? get nextOptionalPermission {
    if (!mediaProjectionGranted) {
      return PermissionType.mediaProjection;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        accessibilityGranted,
        overlayGranted,
        mediaProjectionGranted,
      ];
}
