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

  bool get areAllGranted => accessibilityGranted && overlayGranted;

  PermissionType? get nextRequiredPermission {
    if (!accessibilityGranted) {
      return PermissionType.accessibility;
    }

    if (!overlayGranted) {
      return PermissionType.overlay;
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
