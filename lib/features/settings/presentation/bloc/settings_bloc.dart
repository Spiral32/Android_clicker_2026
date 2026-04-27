import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/core/localization/app_locale.dart';
import 'package:prog_set_touch/features/settings/domain/app_settings.dart';
import 'package:prog_set_touch/features/settings/domain/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required AppLogger logger,
    required SettingsRepository repository,
  })  : _logger = logger,
        _repository = repository,
        super(SettingsState.fromSettings(repository.load())) {
    on<SettingsLocaleChanged>(_onLocaleChanged);
  }

  final AppLogger _logger;
  final SettingsRepository _repository;

  Future<void> _onLocaleChanged(
    SettingsLocaleChanged event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final settings = await _repository.saveLocale(event.locale);
      emit(state.copyWith(locale: settings.locale));
    } catch (error, stackTrace) {
      _logger.logError('settings_bloc', error, stackTrace);
    }
  }
}
