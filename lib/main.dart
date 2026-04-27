import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prog_set_touch/core/di/app_scope.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/core/localization/app_locale.dart';
import 'package:prog_set_touch/core/localization/localization_extensions.dart';
import 'package:prog_set_touch/features/main_screen/presentation/pages/main_screen_page.dart';
import 'package:prog_set_touch/features/scheduler/presentation/bloc/scheduler_bloc.dart';
import 'package:prog_set_touch/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:prog_set_touch/shared/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final logger = AppLogger();
  final appScope = AppScope(logger: logger, prefs: prefs);

  FlutterError.onError = (details) {
    logger.logError(
      'flutter_error',
      details.exception,
      details.stack,
      context: details.library,
    );
  };

  await runZonedGuarded(
    () async {
      runApp(ProgSetTouchApp(appScope: appScope));
    },
    (error, stackTrace) {
      logger.logError('zoned_guarded_error', error, stackTrace);
    },
  );
}

class ProgSetTouchApp extends StatelessWidget {
  const ProgSetTouchApp({
    super.key,
    required this.appScope,
  });

  final AppScope appScope;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: appScope),
        RepositoryProvider.value(value: appScope.logger),
        RepositoryProvider.value(value: appScope.platformBridge),
        RepositoryProvider.value(value: appScope.scenarioRepository),
        RepositoryProvider.value(value: appScope.scenarioService),
        RepositoryProvider.value(value: appScope.settingsRepository),
        RepositoryProvider.value(value: appScope.schedulerRepository),
        RepositoryProvider.value(value: appScope.schedulerService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SettingsBloc(
              logger: appScope.logger,
              repository: appScope.settingsRepository,
            ),
          ),
          BlocProvider(
            create: (_) => SchedulerBloc(
              logger: appScope.logger,
              repository: appScope.schedulerRepository,
              service: appScope.schedulerService,
            ),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateTitle: (context) => context.l10n.appTitle,
              theme: AppTheme.light(),
              locale: state.locale.locale,
              supportedLocales: AppLocale.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const MainScreenPage(),
            );
          },
        ),
      ),
    );
  }
}
