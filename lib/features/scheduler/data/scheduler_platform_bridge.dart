import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:prog_set_touch/core/constants/platform_constants.dart';
import 'package:prog_set_touch/features/scheduler/domain/schedule.dart';

/// Платформенный мост для взаимодействия с SchedulerManager
class SchedulerPlatformBridge {
  SchedulerPlatformBridge({
    required this.logger,
  }) : _channel = const MethodChannel(PlatformConstants.platformChannel);

  final MethodChannel _channel;
  final Function(String message) logger;

  /// Запланировать выполнение расписания
  Future<bool> scheduleExecution(Schedule schedule) async {
    try {
      final result = await _channel.invokeMethod<dynamic>('scheduleExecution', {
        'schedule': jsonEncode(schedule.toPlatformMap()),
      });
      final map = result as Map<dynamic, dynamic>;
      return map['success'] as bool? ?? false;
    } catch (e) {
      logger('SchedulerPlatformBridge.scheduleExecution error: $e');
      return false;
    }
  }

  /// Отменить расписание
  Future<bool> cancelSchedule(String scheduleId) async {
    try {
      final result = await _channel.invokeMethod<dynamic>('cancelSchedule', {
        'scheduleId': scheduleId,
      });
      final map = result as Map<dynamic, dynamic>;
      return map['success'] as bool? ?? false;
    } catch (e) {
      logger('SchedulerPlatformBridge.cancelSchedule error: $e');
      return false;
    }
  }

  /// Отменить все расписания
  Future<bool> cancelAllSchedules() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('cancelAllSchedules');
      final map = result as Map<dynamic, dynamic>;
      return map['success'] as bool? ?? false;
    } catch (e) {
      logger('SchedulerPlatformBridge.cancelAllSchedules error: $e');
      return false;
    }
  }
}

/// Расширение для преобразования Schedule в платформенный формат
extension SchedulePlatformExtension on Schedule {
  /// Преобразовать в Map для отправки на платформу
  Map<String, dynamic> toPlatformMap() {
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
}
