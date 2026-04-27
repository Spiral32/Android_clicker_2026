import 'package:prog_set_touch/features/scenario/domain/scenario_item.dart';

class ScenarioService {
  static const int maxScenarios = 50;

  bool hasExecutableSteps(int stepCount) => stepCount > 0;

  List<ScenarioItem> normalizeOrder(List<ScenarioItem> items) {
    return [
      for (var i = 0; i < items.length; i++) items[i].copyWith(orderIndex: i),
    ];
  }

  bool hasDuplicateName({
    required List<ScenarioItem> scenarios,
    required String name,
    String? excludeId,
  }) {
    final target = name.trim().toLowerCase();
    return scenarios.any(
      (item) =>
          item.id != excludeId && item.name.trim().toLowerCase() == target,
    );
  }

  List<ScenarioItem> snapshotForQuickLaunch(List<ScenarioItem> scenarios) {
    return scenarios.where((item) => item.quickLaunchEnabled).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  List<ScenarioItem> snapshotForRunAll(List<ScenarioItem> scenarios) {
    return scenarios.where((item) => item.isEnabled).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }
}
