import 'dart:convert';

import 'package:prog_set_touch/features/scheduler/domain/schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Репозиторий для хранения расписаний в persistent storage
class ScheduleStorage {
  static const String _schedulesKey = 'scheduler_schedules';

  final SharedPreferences _prefs;

  ScheduleStorage(this._prefs);

  /// Получить все сохраненные расписания
  Future<List<Schedule>> getAllSchedules() async {
    final schedulesJson = _prefs.getStringList(_schedulesKey) ?? [];
    return schedulesJson.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return Schedule.fromMap(map);
    }).toList();
  }

  /// Сохранить расписание
  Future<void> saveSchedule(Schedule schedule) async {
    final schedules = await getAllSchedules();
    final existingIndex = schedules.indexWhere((s) => s.id == schedule.id);

    if (existingIndex >= 0) {
      schedules[existingIndex] = schedule;
    } else {
      schedules.add(schedule);
    }

    await _saveSchedules(schedules);
  }

  /// Удалить расписание по ID
  Future<void> deleteSchedule(String scheduleId) async {
    final schedules = await getAllSchedules();
    schedules.removeWhere((s) => s.id == scheduleId);
    await _saveSchedules(schedules);
  }

  /// Сохранить все расписания
  Future<void> _saveSchedules(List<Schedule> schedules) async {
    final schedulesJson = schedules.map((s) => jsonEncode(s.toMap())).toList();
    await _prefs.setStringList(_schedulesKey, schedulesJson);
  }

  /// Очистить все расписания
  Future<void> clearAll() async {
    await _prefs.remove(_schedulesKey);
  }
}

/// Расширение для сериализации Schedule
extension ScheduleSerialization on Schedule {
  /// Преобразовать в Map для JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'hour': hour,
      'minute': minute,
      'daysOfWeek': daysOfWeek,
      'dateTimestamp': dateTimestamp,
      'scenarioId': scenarioId,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Создать из Map
  static Schedule fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      type: ScheduleType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ScheduleType.oneTime,
      ),
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      daysOfWeek: (map['daysOfWeek'] as List<dynamic>?)?.cast<int>(),
      dateTimestamp: map['dateTimestamp'] as int?,
      scenarioId: map['scenarioId'] as String,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
    );
  }
}
