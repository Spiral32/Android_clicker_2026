import 'package:prog_set_touch/features/scenario/domain/scenario_item.dart';

abstract class ScenarioRepository {
  Future<List<ScenarioItem>> getAll();

  Future<void> saveAll(List<ScenarioItem> scenarios);
}
