import 'package:prog_set_touch/features/scheduler/data/scheduler_platform_bridge.dart';
import 'package:prog_set_touch/features/scheduler/domain/schedule.dart';

/// Сервис для управления планированием расписаний
class SchedulerService {
  SchedulerService({
    required this.platformBridge,
  });

  final SchedulerPlatformBridge platformBridge;

  /// Запланировать выполнение расписания
  Future<bool> scheduleExecution(Schedule schedule) {
    return platformBridge.scheduleExecution(schedule);
  }

  /// Отменить расписание
  Future<bool> cancelSchedule(String scheduleId) {
    return platformBridge.cancelSchedule(scheduleId);
  }

  /// Отменить все расписания
  Future<bool> cancelAllSchedules() {
    return platformBridge.cancelAllSchedules();
  }
}
