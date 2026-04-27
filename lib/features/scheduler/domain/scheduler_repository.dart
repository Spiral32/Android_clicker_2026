import 'package:prog_set_touch/features/scheduler/domain/schedule.dart';

/// Репозиторий для управления расписаниями
abstract class SchedulerRepository {
  /// Получить все расписания
  Future<List<Schedule>> getAllSchedules();

  /// Сохранить расписание
  Future<void> saveSchedule(Schedule schedule);

  /// Удалить расписание
  Future<void> deleteSchedule(String scheduleId);

  /// Очистить все расписания
  Future<void> clearAllSchedules();
}
