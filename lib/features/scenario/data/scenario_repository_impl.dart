import 'package:prog_set_touch/features/scenario/data/scenario_storage.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_item.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_repository.dart';

class ScenarioRepositoryImpl implements ScenarioRepository {
  ScenarioRepositoryImpl(this._storage);

  final ScenarioStorage _storage;

  @override
  Future<List<ScenarioItem>> getAll() => _storage.getAll();

  @override
  Future<void> saveAll(List<ScenarioItem> scenarios) => _storage.saveAll(scenarios);
}
