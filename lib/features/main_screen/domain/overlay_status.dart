import 'package:equatable/equatable.dart';

class OverlayStatus extends Equatable {
  const OverlayStatus({
    required this.visible,
  });

  final bool visible;

  const OverlayStatus.initial() : visible = false;

  @override
  List<Object?> get props => [visible];
}
