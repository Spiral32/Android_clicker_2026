import 'dart:convert';

import 'package:prog_set_touch/features/scenario/domain/scenario_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScenarioStorage {
  ScenarioStorage(this._prefs);

  static const String _key = 'scenario_items_v1';
  final SharedPreferences _prefs;

  Future<List<ScenarioItem>> getAll() async {
    final jsonList = _prefs.getStringList(_key) ?? const <String>[];
    final scenarios = jsonList.map((entry) {
      final map = jsonDecode(entry) as Map<String, dynamic>;
      return ScenarioItem.fromMap(map);
    }).toList();
    scenarios.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return scenarios;
  }

  Future<void> saveAll(List<ScenarioItem> scenarios) async {
    final sorted = [...scenarios]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final payload = sorted.map((item) => jsonEncode(item.toMap())).toList();
    await _prefs.setStringList(_key, payload);
  }
}
