import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/features/scheduler/domain/schedule.dart';
import 'package:prog_set_touch/features/scheduler/domain/scheduler_repository.dart';
import 'package:prog_set_touch/features/scheduler/domain/scheduler_service.dart';

part 'scheduler_event.dart';
part 'scheduler_state.dart';

class SchedulerBloc extends Bloc<SchedulerEvent, SchedulerState> {
  SchedulerBloc({
    required AppLogger logger,
    required SchedulerRepository repository,
    required SchedulerService service,
  })  : _logger = logger,
        _repository = repository,
        _service = service,
        super(SchedulerState.initial()) {
    on<SchedulerSchedulesLoaded>(_onSchedulesLoaded);
    on<SchedulerScheduleAdded>(_onScheduleAdded);
    on<SchedulerScheduleUpdated>(_onScheduleUpdated);
    on<SchedulerScheduleDeleted>(_onScheduleDeleted);
    on<SchedulerErrorOccurred>(_onErrorOccurred);

    // Загрузить расписания при инициализации
    add(const SchedulerSchedulesLoaded());
  }

  final AppLogger _logger;
  final SchedulerRepository _repository;
  final SchedulerService _service;

  Future<void> _onSchedulesLoaded(
    SchedulerSchedulesLoaded event,
    Emitter<SchedulerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final schedules = await _repository.getAllSchedules();
      _logger.logInfo(
        'scheduler_bloc',
        'Schedules loaded',
        payload: {'action': 'load', 'count': schedules.length},
      );
      emit(state.copyWith(schedules: schedules, isLoading: false));
    } catch (error, stackTrace) {
      _logger.logError(
        'scheduler_bloc',
        error,
        stackTrace,
        context: 'Failed to load schedules | action=load',
      );
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load schedules',
      ));
    }
  }

  Future<void> _onScheduleAdded(
    SchedulerScheduleAdded event,
    Emitter<SchedulerState> emit,
  ) async {
    try {
      await _repository.saveSchedule(event.schedule);
      await _service.scheduleExecution(event.schedule);
      _logger.logInfo(
        'scheduler_bloc',
        'Schedule added',
        payload: {
          'action': 'add',
          'scheduleId': event.schedule.id,
          'name': event.schedule.name,
          'scenarioId': event.schedule.scenarioId,
        },
      );
      add(const SchedulerSchedulesLoaded());
    } catch (error, stackTrace) {
      _logger.logError(
        'scheduler_bloc',
        error,
        stackTrace,
        context: 'Failed to add schedule | action=add',
      );
      emit(state.copyWith(error: 'Failed to add schedule'));
    }
  }

  Future<void> _onScheduleUpdated(
    SchedulerScheduleUpdated event,
    Emitter<SchedulerState> emit,
  ) async {
    try {
      await _repository.saveSchedule(event.schedule);
      if (event.schedule.isActive) {
        await _service.scheduleExecution(event.schedule);
      } else {
        await _service.cancelSchedule(event.schedule.id);
      }
      _logger.logInfo(
        'scheduler_bloc',
        'Schedule updated',
        payload: {
          'action': 'update',
          'scheduleId': event.schedule.id,
          'isActive': event.schedule.isActive,
          'scenarioId': event.schedule.scenarioId,
        },
      );
      add(const SchedulerSchedulesLoaded());
    } catch (error, stackTrace) {
      _logger.logError(
        'scheduler_bloc',
        error,
        stackTrace,
        context: 'Failed to update schedule | action=update',
      );
      emit(state.copyWith(error: 'Failed to update schedule'));
    }
  }

  Future<void> _onScheduleDeleted(
    SchedulerScheduleDeleted event,
    Emitter<SchedulerState> emit,
  ) async {
    try {
      await _service.cancelSchedule(event.scheduleId);
      await _repository.deleteSchedule(event.scheduleId);
      _logger.logInfo(
        'scheduler_bloc',
        'Schedule deleted',
        payload: {
          'action': 'delete',
          'scheduleId': event.scheduleId,
        },
      );
      add(const SchedulerSchedulesLoaded());
    } catch (error, stackTrace) {
      _logger.logError(
        'scheduler_bloc',
        error,
        stackTrace,
        context: 'Failed to delete schedule | action=delete',
      );
      emit(state.copyWith(error: 'Failed to delete schedule'));
    }
  }

  void _onErrorOccurred(
    SchedulerErrorOccurred event,
    Emitter<SchedulerState> emit,
  ) {
    emit(state.copyWith(error: event.error));
  }
}
