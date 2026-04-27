part of 'scheduler_bloc.dart';

abstract class SchedulerEvent extends Equatable {
  const SchedulerEvent();

  @override
  List<Object?> get props => [];
}

/// Загрузить все расписания
class SchedulerSchedulesLoaded extends SchedulerEvent {
  const SchedulerSchedulesLoaded();
}

/// Добавить новое расписание
class SchedulerScheduleAdded extends SchedulerEvent {
  const SchedulerScheduleAdded(this.schedule);

  final Schedule schedule;

  @override
  List<Object?> get props => [schedule];
}

/// Обновить существующее расписание
class SchedulerScheduleUpdated extends SchedulerEvent {
  const SchedulerScheduleUpdated(this.schedule);

  final Schedule schedule;

  @override
  List<Object?> get props => [schedule];
}

/// Удалить расписание
class SchedulerScheduleDeleted extends SchedulerEvent {
  const SchedulerScheduleDeleted(this.scheduleId);

  final String scheduleId;

  @override
  List<Object?> get props => [scheduleId];
}

/// Ошибка при операции
class SchedulerErrorOccurred extends SchedulerEvent {
  const SchedulerErrorOccurred(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
