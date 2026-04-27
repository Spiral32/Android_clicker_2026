import 'package:flutter_test/flutter_test.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_item.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_service.dart';

void main() {
  group('ScenarioService', () {
    final service = ScenarioService();

    ScenarioItem item({
      required String id,
      required String name,
      required int orderIndex,
      bool quickLaunchEnabled = false,
      bool isEnabled = true,
      int stepCount = 1,
    }) {
      return ScenarioItem(
        id: id,
        name: name,
        orderIndex: orderIndex,
        stepCount: stepCount,
        quickLaunchEnabled: quickLaunchEnabled,
        isEnabled: isEnabled,
        createdAtMs: 1,
        updatedAtMs: 1,
      );
    }

    test('rejects empty scenarios', () {
      expect(service.hasExecutableSteps(0), isFalse);
      expect(service.hasExecutableSteps(-1), isFalse);
      expect(service.hasExecutableSteps(1), isTrue);
    });

    test('detects duplicate names case-insensitively', () {
      final scenarios = [
        item(id: '1', name: 'Farm', orderIndex: 0),
        item(id: '2', name: 'Mine', orderIndex: 1),
      ];

      expect(
        service.hasDuplicateName(scenarios: scenarios, name: '  farm  '),
        isTrue,
      );
      expect(
        service.hasDuplicateName(
          scenarios: scenarios,
          name: 'farm',
          excludeId: '1',
        ),
        isFalse,
      );
    });

    test('normalizes order to a dense sequence', () {
      final normalized = service.normalizeOrder([
        item(id: '2', name: 'Second', orderIndex: 7),
        item(id: '1', name: 'First', orderIndex: 3),
      ]);

      expect(normalized.map((entry) => entry.id), ['1', '2']);
      expect(normalized.map((entry) => entry.orderIndex), [0, 1]);
    });

    test('quick launch snapshot ignores enabled flag and keeps order', () {
      final snapshot = service.snapshotForQuickLaunch([
        item(
          id: '2',
          name: 'B',
          orderIndex: 1,
          quickLaunchEnabled: true,
          isEnabled: false,
        ),
        item(
          id: '1',
          name: 'A',
          orderIndex: 0,
          quickLaunchEnabled: true,
        ),
        item(id: '3', name: 'C', orderIndex: 2),
      ]);

      expect(snapshot.map((entry) => entry.id), ['1', '2']);
    });

    test('run all snapshot keeps only enabled scenarios in order', () {
      final snapshot = service.snapshotForRunAll([
        item(id: '3', name: 'C', orderIndex: 2, isEnabled: true),
        item(id: '1', name: 'A', orderIndex: 0, isEnabled: false),
        item(id: '2', name: 'B', orderIndex: 1, isEnabled: true),
      ]);

      expect(snapshot.map((entry) => entry.id), ['2', '3']);
    });
  });
}
