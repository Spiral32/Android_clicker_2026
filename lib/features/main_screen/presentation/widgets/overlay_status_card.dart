import 'package:flutter/material.dart';
import 'package:prog_set_touch/features/main_screen/domain/overlay_status.dart';

/// DEPRECATED: the main screen no longer shows a separate overlay status card.
/// The floating button state is communicated through the main actions only.
class OverlayStatusCard extends StatelessWidget {
  const OverlayStatusCard({
    super.key,
    required this.overlayStatus,
  });

  final OverlayStatus overlayStatus;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
