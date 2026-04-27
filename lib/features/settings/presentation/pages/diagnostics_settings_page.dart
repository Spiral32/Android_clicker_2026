import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prog_set_touch/features/main_screen/data/platform_bridge_data_source.dart';
import 'package:prog_set_touch/features/main_screen/presentation/bloc/main_screen_bloc.dart';

class DiagnosticsSettingsPage extends StatefulWidget {
  const DiagnosticsSettingsPage({super.key});

  @override
  State<DiagnosticsSettingsPage> createState() => _DiagnosticsSettingsPageState();
}

class _DiagnosticsSettingsPageState extends State<DiagnosticsSettingsPage> {
  static const MethodChannel _channel =
      MethodChannel('prog_set_touch/platform');

  bool _isLoading = true;
  bool _isBusy = false;
  bool _loggingEnabled = true;
  bool _fileLoggingEnabled = true;
  bool _autostartEnabled = true;
  bool _mediaProjectionGranted = false;
  bool _exactAlarmsAllowed = true;
  String? _logFilePath;
  String _logPreview = '';
  String? _message;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDiagnostics());
  }

  Future<void> _loadDiagnostics() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _channel.invokeMethod<String>('getLogFilePath'),
        _channel.invokeMethod<String>('getLogs'),
        _channel.invokeMethod<bool>('getAutostartEnabled'),
        _channel.invokeMethod<Map<dynamic, dynamic>>('getPermissionStatus'),
      ]);
      final exactAlarmStatus = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('getExactAlarmStatus');

      if (!mounted) {
        return;
      }

      setState(() {
        _logFilePath = results[0] as String?;
        _logPreview = (results[1] as String?)?.trim() ?? '';
        _autostartEnabled = results[2] as bool? ?? true;
        final permissionMap = results[3] as Map<dynamic, dynamic>?;
        _mediaProjectionGranted =
            permissionMap?['mediaProjectionGranted'] as bool? ?? false;
        _exactAlarmsAllowed =
            exactAlarmStatus?['exactAlarmsAllowed'] as bool? ?? true;
        _isLoading = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _message = error.message ??
            (l10n?.settingsDiagnosticsLoadError ??
                'Failed to load diagnostics.');
      });
    }
  }

  Future<void> _setMaximumLogging(bool enabled) async {
    setState(() {
      _isBusy = true;
      _message = null;
    });

    try {
      await _channel.invokeMethod<void>(
        'setLoggingEnabled',
        {'enabled': enabled},
      );
      await _channel.invokeMethod<void>(
        'setLogToFileEnabled',
        {'enabled': enabled},
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loggingEnabled = enabled;
        _fileLoggingEnabled = enabled;
        _isBusy = false;
        _message = enabled
            ? 'Максимальное логирование включено.'
            : 'Максимальное логирование отключено.';
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isBusy = false;
        _message = error.message ?? 'Не удалось изменить режим логирования.';
      });
    }
  }

  Future<void> _setAutostartEnabled(bool enabled) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isBusy = true;
      _message = null;
    });

    try {
      await _channel.invokeMethod<void>(
        'setAutostartEnabled',
        {'enabled': enabled},
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _autostartEnabled = enabled;
        _isBusy = false;
        _message = enabled
            ? (l10n?.settingsAutostartEnabledMessage ??
                'Autostart after reboot is enabled.')
            : (l10n?.settingsAutostartDisabledMessage ??
                'Autostart after reboot is disabled.');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message!)),
      );
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isBusy = false;
        _message = error.message ??
            (l10n?.settingsAutostartChangeError ??
                'Failed to change autostart setting.');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message!)),
      );
    }
  }

  Future<void> _requestMediaProjectionPermission() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isBusy = true;
      _message = null;
    });

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'requestMediaProjectionPermission',
      );
      final granted = result?['mediaProjectionGranted'] as bool? ?? false;

      if (!mounted) {
        return;
      }

      setState(() {
        _mediaProjectionGranted = granted;
        _isBusy = false;
        _message = granted
            ? (l10n?.settingsMediaProjectionGrantedMessage ??
                'MediaProjection permission granted.')
            : (l10n?.settingsMediaProjectionDeniedMessage ??
                'MediaProjection permission not granted.');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message!)),
      );
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isBusy = false;
        _message = error.message ??
            (l10n?.settingsMediaProjectionRequestError ??
                'Failed to request MediaProjection.');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message!)),
      );
    }
  }

  Future<void> _exportLog() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isBusy = true;
      _message = null;
    });

    try {
      final dataSource = context.read<PlatformBridgeDataSource>();
      final exportedPath = await dataSource.exportLogs();

      if (!mounted) {
        return;
      }

      setState(() {
        _logFilePath = exportedPath;
        _isBusy = false;
        _message = l10n?.settingsLogExportedMessage ??
            'Log exported to Download folder.';
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isBusy = false;
        _message = error.message ??
            (l10n?.settingsLogExportError ?? 'Failed to export log.');
      });
    }
  }

  Future<void> _openLogLocation() async {
    final l10n = AppLocalizations.of(context);
    try {
      await _channel.invokeMethod<void>(
        'openLogLocation',
        {'path': _logFilePath},
      );
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.message ??
            (l10n?.settingsLogOpenLocationError ??
                'Failed to open log file location.');
      });
    }
  }

  Future<void> _clearLogs() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isBusy = true;
      _message = null;
    });

    try {
      await _channel.invokeMethod<void>('clearLogs');
      if (!mounted) {
        return;
      }
      setState(() {
        _logPreview = '';
        _isBusy = false;
        _message = l10n?.settingsLogClearedMessage ?? 'Log buffer cleared.';
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isBusy = false;
        _message = error.message ??
            (l10n?.settingsLogClearError ?? 'Failed to clear log.');
      });
    }
  }

  Future<void> _openExactAlarmSettings() async {
    final l10n = AppLocalizations.of(context);
    try {
      await _channel.invokeMethod<void>('openExactAlarmSettings');
      await _loadDiagnostics();
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.message ??
            (l10n?.settingsExactAlarmOpenError ??
                'Failed to open exact alarm settings.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDiagnostics,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SectionCard(
                    title: l10n.settingsLanguageTitle,
                    subtitle: l10n.settingsLanguageSubtitle,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: AppLanguageSwitcher(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: l10n.settingsAutostartTitle,
                    subtitle:
                        l10n.settingsAutostartSubtitle,
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _autostartEnabled,
                      onChanged: _isBusy ? null : _setAutostartEnabled,
                      title: Text(l10n.settingsAutostartToggleTitle),
                      subtitle: Text(l10n.settingsAutostartToggleSubtitle),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: l10n.settingsMediaProjectionTitle,
                    subtitle:
                        l10n.settingsMediaProjectionSubtitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _mediaProjectionGranted
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: _mediaProjectionGranted
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _mediaProjectionGranted
                                  ? l10n.settingsMediaProjectionStatusGranted
                                  : l10n.settingsMediaProjectionStatusMissing,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _isBusy ? null : _requestMediaProjectionPermission,
                          icon: const Icon(Icons.screen_share_outlined),
                          label: Text(l10n.settingsMediaProjectionRequestAction),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: l10n.settingsExactAlarmTitle,
                    subtitle: l10n.settingsExactAlarmSubtitle,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _exactAlarmsAllowed
                                  ? Icons.check_circle_outline
                                  : Icons.warning_amber_outlined,
                              color:
                                  _exactAlarmsAllowed ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _exactAlarmsAllowed
                                    ? l10n.settingsExactAlarmStatusAllowed
                                    : l10n.settingsExactAlarmStatusLimited,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _isBusy ? null : _openExactAlarmSettings,
                          icon: const Icon(Icons.alarm_outlined),
                          label: Text(l10n.settingsExactAlarmOpenAction),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<MainScreenBloc, MainScreenState>(
                    builder: (context, state) {
                      return _SectionCard(
                        title: l10n.settingsExecutionTitle,
                        subtitle: l10n.settingsExecutionDelay,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.settingsExecutionDelay,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Slider.adaptive(
                                    min: 1,
                                    max: 120,
                                    divisions: 119,
                                    value: state.executionDelayMs / 1000,
                                    onChanged: (value) {
                                      context.read<MainScreenBloc>().add(
                                            MainScreenExecutionDelayChanged(
                                              (value * 1000).round(),
                                            ),
                                          );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F4F8),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFD1D9E4),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.settingsExecutionDelayUnit(
                                      (state.executionDelayMs / 1000).round(),
                                    ),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Диагностика и логирование',
                    subtitle:
                        'Включите подробный сбор логов, чтобы видеть ход выполнения программы и быстрее находить ошибки.',
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _loggingEnabled && _fileLoggingEnabled,
                          onChanged: _isBusy ? null : _setMaximumLogging,
                          title: const Text('Максимальное логирование'),
                          subtitle: const Text(
                            'Включает подробный лог процессов и запись лога в файл.',
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: _isBusy ? null : _exportLog,
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Экспортировать лог в Download'),
                        ),
                        const SizedBox(height: 12),
                        _PathTile(
                          path: _logFilePath,
                          onTap: _logFilePath == null ? null : _openLogLocation,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Просмотр лога',
                    subtitle:
                        'Проверьте последние сообщения перед отправкой логов для диагностики.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _isBusy ? null : _loadDiagnostics,
                              icon: const Icon(Icons.refresh_outlined),
                              label: const Text('Обновить'),
                            ),
                            TextButton.icon(
                              onPressed: _isBusy ? null : _clearLogs,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Очистить'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 300,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10151C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF243244),
                            ),
                          ),
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              child: SelectableText(
                                _logPreview.isEmpty
                                    ? 'Логи пока пусты.'
                                    : _logPreview,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFFD9E2F1),
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 16),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F7EF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF9FD5B3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          _message!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7DFEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B1F33),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _PathTile extends StatelessWidget {
  const _PathTile({
    required this.path,
    required this.onTap,
  });

  final String? path;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8FC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD8E1ED)),
        ),
        child: Row(
          children: [
            const Icon(Icons.folder_open_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                path ?? 'Файл лога ещё не экспортирован.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      onTap == null ? Colors.black54 : const Color(0xFF0057B8),
                  decoration: onTap == null
                      ? TextDecoration.none
                      : TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
