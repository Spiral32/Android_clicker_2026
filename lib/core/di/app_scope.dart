import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/features/main_screen/data/platform_bridge_data_source.dart';
import 'package:prog_set_touch/features/scenario/data/scenario_repository_impl.dart';
import 'package:prog_set_touch/features/scenario/data/scenario_storage.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_repository.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_service.dart';
import 'package:prog_set_touch/features/settings/data/shared_prefs_settings_repository.dart';
import 'package:prog_set_touch/features/settings/domain/settings_repository.dart';
import 'package:prog_set_touch/features/scheduler/data/schedule_storage.dart';
import 'package:prog_set_touch/features/scheduler/data/scheduler_platform_bridge.dart';
import 'package:prog_set_touch/features/scheduler/data/scheduler_repository_impl.dart';
import 'package:prog_set_touch/features/scheduler/domain/scheduler_repository.dart';
import 'package:prog_set_touch/features/scheduler/domain/scheduler_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScope {
  AppScope({
    required this.logger,
    required SharedPreferences prefs,
  })  : platformBridge = PlatformBridgeDataSource(logger: logger),
        scenarioRepository = ScenarioRepositoryImpl(ScenarioStorage(prefs)),
        scenarioService = ScenarioService(),
        settingsRepository = SharedPrefsSettingsRepository(prefs),
        schedulerRepository = SchedulerRepositoryImpl(ScheduleStorage(prefs)),
        schedulerService = SchedulerService(
          platformBridge: SchedulerPlatformBridge(
              logger: (message) => logger.logInfo('Scheduler', message)),
        );

  final AppLogger logger;
  final PlatformBridgeDataSource platformBridge;
  final ScenarioRepository scenarioRepository;
  final ScenarioService scenarioService;
  final SettingsRepository settingsRepository;
  final SchedulerRepository schedulerRepository;
  final SchedulerService schedulerService;
}
