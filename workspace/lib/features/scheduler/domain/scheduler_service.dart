import 'package:prog_set_touch/features/scheduler/data/scheduler_platform_bridge.dart';
import 'package:prog_set_touch/features/scheduler/domain/schedule.dart';

/// Сервис для управления планированием расписаний
class SchedulerService {
  SchedulerService({
    required this.platformBridge,
  });

  final SchedulerPlatformBridge platformBridge;

  /// Запланировать выполнение расписания
  Future<bool> scheduleExecution(Schedule schedule) async {
    final bool result = await platformBridge.scheduleExecution(schedule);
    // Добавляем маркер завершения выполнения расписания
    _logScheduleExecuteResult(schedule, result);
    return result;
  }

  /// Отменить расписание
  Future<bool> cancelSchedule(String scheduleId) {
    return platformBridge.cancelSchedule(scheduleId);
  }

  /// Отменить все расписания
  Future<bool> cancelAllSchedules() {
    return platformBridge.cancelAllSchedules();
  }

  void _logScheduleExecuteResult(Schedule schedule, bool success) {
    const String result = success ? 'success' : 'error';
    platformBridge.logger('schedule_execute_result: schedule_id=${schedule.id}, result=$result');
  }
}