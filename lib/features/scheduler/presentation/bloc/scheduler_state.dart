part of 'scheduler_bloc.dart';

class SchedulerState extends Equatable {
  const SchedulerState({
    required this.schedules,
    this.isLoading = false,
    this.error,
  });

  /// Список всех расписаний
  final List<Schedule> schedules;

  /// Загружается ли список расписаний
  final bool isLoading;

  /// Ошибка при загрузке/сохранении
  final String? error;

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
