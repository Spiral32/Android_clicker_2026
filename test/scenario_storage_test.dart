import 'package:flutter_test/flutter_test.dart';
import 'package:prog_set_touch/features/scenario/data/scenario_storage.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScenarioStorage', () {
    late SharedPreferences prefs;
    late ScenarioStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = ScenarioStorage(prefs);
    });

    ScenarioItem item({
      required String id,
      required String name,
      required int orderIndex,
    }) {
      return ScenarioItem(
        id: id,
        name: name,
        orderIndex: orderIndex,
        stepCount: 3,
        quickLaunchEnabled: false,
        isEnabled: true,
        createdAtMs: 1,
        updatedAtMs: 1,
      );
    }

    test('persists and restores scenarios ordered by orderIndex', () async {
      await storage.saveAll([
        item(id: '2', name: 'Later', orderIndex: 2),
        item(id: '1', name: 'Sooner', orderIndex: 0),
      ]);

      final restored = await storage.getAll();

      expect(restored.map((entry) => entry.id), ['1', '2']);
      expect(restored.map((entry) => entry.orderIndex), [0, 2]);
    });
  });
}
