import 'package:equatable/equatable.dart';

class PlatformInfo extends Equatable {
  const PlatformInfo({
    required this.platform,
    required this.manufacturer,
    required this.model,
    required this.sdkInt,
    required this.localeTag,
  });

  final String platform;
  final String manufacturer;
  final String model;
  final int sdkInt;
  final String localeTag;

  @override
  List<Object?> get props => [
        platform,
        manufacturer,
        model,
        sdkInt,
        localeTag,
      ];
}
