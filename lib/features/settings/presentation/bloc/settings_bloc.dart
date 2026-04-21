import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/core/localization/app_locale.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required AppLogger logger,
  })  : _logger = logger,
        super(SettingsState.initial()) {
    on<SettingsLocaleChanged>(_onLocaleChanged);
  }

  final AppLogger _logger;

  void _onLocaleChanged(
    SettingsLocaleChanged event,
    Emitter<SettingsState> emit,
  ) {
    try {
      emit(state.copyWith(locale: event.locale));
    } catch (error, stackTrace) {
      _logger.logError('settings_bloc', error, stackTrace);
    }
  }
}
