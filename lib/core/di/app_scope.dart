import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/features/main_screen/data/platform_bridge_data_source.dart';

class AppScope {
  AppScope({
    required this.logger,
  }) : platformBridge = PlatformBridgeDataSource(logger: logger);

  final AppLogger logger;
  final PlatformBridgeDataSource platformBridge;
}
