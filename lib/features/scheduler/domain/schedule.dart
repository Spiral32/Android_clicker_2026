import 'package:equatable/equatable.dart';

/// Тип расписания
enum ScheduleType {
  /// Одноразовое расписание
  oneTime,

  /// Повторяющееся ежедневно
  daily,

  /// Повторяющееся еженедельно
  weekly,
}

/// Сущность расписания для планировщика задач
class Schedule extends Equatable {
  /// Уникальный идентификатор расписания
  final String id;

  /// Название расписания
  final String name;

  /// Описание расписания
  final String? description;

  /// Тип расписания
  final ScheduleType type;

  /// Время запуска (часы 0-23)
  final int hour;

  /// Минуты запуска (0-59)
  final int minute;

  /// Дни недели для weekly типа (0=понедельник, 6=воскресенье)
  /// Для daily и oneTime игнорируется
  final List<int>? daysOfWeek;

  /// Дата для oneTime типа (timestamp в миллисекундах)
  final int? dateTimestamp;

  /// ID сценария для запуска
  final String scenarioId;

  /// Активно ли расписание
  final bool isActive;

  /// Время создания
  final int createdAt;

  /// Время последнего обновления
  final int updatedAt;

  const Schedule({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.hour,
    required this.minute,
    this.daysOfWeek,
    this.dateTimestamp,
    required this.scenarioId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Создание копии с изменениями
  Schedule copyWith({
    String? id,
    String? name,
    String? description,
    ScheduleType? type,
    int? hour,
    int? minute,
    List<int>? daysOfWeek,
    int? dateTimestamp,
    String? scenarioId,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      dateTimestamp: dateTimestamp ?? this.dateTimestamp,
      scenarioId: scenarioId ?? this.scenarioId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        hour,
        minute,
        daysOfWeek,
        dateTimestamp,
        scenarioId,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// Преобразование в Map для JSON сериализации
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

  /// Создание из Map (десериализация)
  factory Schedule.fromMap(Map<String, dynamic> map) {
    return Schedule(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      type: ScheduleType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ScheduleType.daily,
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

/// Состояние планировщика
class SchedulerState extends Equatable {
  /// Список всех расписаний
  final List<Schedule> schedules;

  /// Загружается ли список расписаний
  final bool isLoading;

  /// Ошибка при загрузке/сохранении
  final String? error;

  const SchedulerState({
    required this.schedules,
    this.isLoading = false,
    this.error,
  });

  /// Начальное состояние
  factory SchedulerState.initial() {
    return const SchedulerState(schedules: []);
  }

  /// Копия с изменениями
  SchedulerState copyWith({
    List<Schedule>? schedules,
    bool? isLoading,
    String? error,
  }) {
    return SchedulerState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [schedules, isLoading, error];
}
