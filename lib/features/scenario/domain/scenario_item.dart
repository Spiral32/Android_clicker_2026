import 'package:equatable/equatable.dart';

class ScenarioItem extends Equatable {
  const ScenarioItem({
    required this.id,
    required this.name,
    required this.orderIndex,
    required this.stepCount,
    required this.quickLaunchEnabled,
    required this.isEnabled,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  final String id;
  final String name;
  final int orderIndex;
  final int stepCount;
  final bool quickLaunchEnabled;
  final bool isEnabled;
  final int createdAtMs;
  final int updatedAtMs;

  ScenarioItem copyWith({
    String? id,
    String? name,
    int? orderIndex,
    int? stepCount,
    bool? quickLaunchEnabled,
    bool? isEnabled,
    int? createdAtMs,
    int? updatedAtMs,
  }) {
    return ScenarioItem(
      id: id ?? this.id,
      name: name ?? this.name,
      orderIndex: orderIndex ?? this.orderIndex,
      stepCount: stepCount ?? this.stepCount,
      quickLaunchEnabled: quickLaunchEnabled ?? this.quickLaunchEnabled,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'orderIndex': orderIndex,
      'stepCount': stepCount,
      'quickLaunchEnabled': quickLaunchEnabled,
      'isEnabled': isEnabled,
      'createdAtMs': createdAtMs,
      'updatedAtMs': updatedAtMs,
    };
  }

  factory ScenarioItem.fromMap(Map<String, dynamic> map) {
    return ScenarioItem(
      id: map['id'] as String,
      name: map['name'] as String,
      orderIndex: map['orderIndex'] as int? ?? 0,
      stepCount: map['stepCount'] as int? ?? 0,
      quickLaunchEnabled: map['quickLaunchEnabled'] as bool? ?? false,
      isEnabled: map['isEnabled'] as bool? ?? true,
      createdAtMs: map['createdAtMs'] as int? ?? 0,
      updatedAtMs: map['updatedAtMs'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        orderIndex,
        stepCount,
        quickLaunchEnabled,
        isEnabled,
        createdAtMs,
        updatedAtMs,
      ];
}
