import 'package:flutter_test/flutter_test.dart';
import 'package:prog_set_touch/features/scheduler/domain/schedule.dart';

void main() {
  group('Schedule', () {
    test('should create Schedule with required fields', () {
      final schedule = Schedule(
        id: 'test_id',
        name: 'Test Schedule',
        type: ScheduleType.daily,
        hour: 9,
        minute: 30,
        scenarioId: 'scenario_1',
        isActive: true,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(schedule.id, 'test_id');
      expect(schedule.name, 'Test Schedule');
      expect(schedule.type, ScheduleType.daily);
      expect(schedule.hour, 9);
      expect(schedule.minute, 30);
      expect(schedule.scenarioId, 'scenario_1');
      expect(schedule.isActive, true);
    });

    test('should copy Schedule with changes', () {
      final original = Schedule(
        id: 'test_id',
        name: 'Test Schedule',
        type: ScheduleType.daily,
        hour: 9,
        minute: 30,
        scenarioId: 'scenario_1',
        isActive: true,
        createdAt: 1000,
        updatedAt: 1000,
      );

      final updated = original.copyWith(
        name: 'Updated Schedule',
        isActive: false,
      );

      expect(updated.id, 'test_id');
      expect(updated.name, 'Updated Schedule');
      expect(updated.isActive, false);
      expect(updated.type, ScheduleType.daily); // unchanged
    });

    test('should handle weekly schedule with daysOfWeek', () {
      final schedule = Schedule(
        id: 'weekly_id',
        name: 'Weekly Schedule',
        type: ScheduleType.weekly,
        hour: 10,
        minute: 0,
        daysOfWeek: [1, 3, 5], // Mon, Wed, Fri
        scenarioId: 'scenario_1',
        isActive: true,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(schedule.daysOfWeek, [1, 3, 5]);
    });

    test('should handle oneTime schedule with dateTimestamp', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final schedule = Schedule(
        id: 'onetime_id',
        name: 'One Time Schedule',
        type: ScheduleType.oneTime,
        hour: 14,
        minute: 30,
        dateTimestamp: timestamp,
        scenarioId: 'scenario_1',
        isActive: true,
        createdAt: 1000,
        updatedAt: 1000,
      );

      expect(schedule.dateTimestamp, timestamp);
    });
  });

  group('ScheduleType', () {
    test('should have correct enum values', () {
      expect(ScheduleType.oneTime.name, 'oneTime');
      expect(ScheduleType.daily.name, 'daily');
      expect(ScheduleType.weekly.name, 'weekly');
    });
  });
}
