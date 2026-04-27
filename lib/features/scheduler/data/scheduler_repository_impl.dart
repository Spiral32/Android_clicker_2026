import 'package:prog_set_touch/features/scheduler/data/schedule_storage.dart';
import 'package:prog_set_touch/features/scheduler/domain/schedule.dart';
import 'package:prog_set_touch/features/scheduler/domain/scheduler_repository.dart';

/// Реализация репозитория планировщика с использованием SharedPreferences
class SchedulerRepositoryImpl implements SchedulerRepository {
  final ScheduleStorage _storage;

  SchedulerRepositoryImpl(this._storage);

  @override
  Future<List<Schedule>> getAllSchedules() => _storage.getAllSchedules();

  @override
  Future<void> saveSchedule(Schedule schedule) =>
      _storage.saveSchedule(schedule);

  @override
  Future<void> deleteSchedule(String scheduleId) =>
      _storage.deleteSchedule(scheduleId);

  @override
  Future<void> clearAllSchedules() => _storage.clearAll();
}
