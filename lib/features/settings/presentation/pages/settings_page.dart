import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:prog_set_touch/core/localization/app_locale.dart';
import 'package:prog_set_touch/features/main_screen/data/platform_bridge_data_source.dart';
import 'package:prog_set_touch/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:prog_set_touch/shared/widgets/app_language_switcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        actions: const [
          AppLanguageSwitcher(),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.settingsLanguageTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<AppLocale>(
              segments: [
                ButtonSegment<AppLocale>(
                  value: AppLocale.ru,
                  label: Text(l10n.settingsLanguageRussian),
                ),
                ButtonSegment<AppLocale>(
                  value: AppLocale.en,
                  label: Text(l10n.settingsLanguageEnglish),
                ),
              ],
              selected: {
                context.select((SettingsBloc bloc) => bloc.state.locale),
              },
              onSelectionChanged: (selection) {
                context.read<SettingsBloc>().add(
                      SettingsLocaleChanged(selection.first),
                    );
              },
            ),
            const SizedBox(height: 24),
            const _LoggingSection(),
            const SizedBox(height: 24),
            Text(
              l10n.settingsWebSocketTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.settingsWebSocketPlaceholder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoggingSection extends StatefulWidget {
  const _LoggingSection();

  @override
  State<_LoggingSection> createState() => _LoggingSectionState();
}

class _LoggingSectionState extends State<_LoggingSection> {
  String _logs = '';
  String? _logFilePath;
  bool _isLoading = false;
  bool _loggingEnabled = true;
  bool _logToFileEnabled = true;
  String? _lastExportedPath;
  final TextEditingController _exportPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _exportPathController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final dataSource = context.read<PlatformBridgeDataSource>();
      final logs = await dataSource.getLogs();
      final path = await dataSource.getLogFilePath();
      setState(() {
        _logs = logs;
        _logFilePath = path;
      });
    } catch (e) {
      setState(() => _logs = 'Error loading logs: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearLogs() async {
    try {
      final dataSource = context.read<PlatformBridgeDataSource>();
      await dataSource.clearLogs();
      setState(() => _logs = '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logs cleared')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing logs: $e')),
        );
      }
    }
  }

  Future<void> _exportLogs() async {
    try {
      final dataSource = context.read<PlatformBridgeDataSource>();
      final path = await dataSource.exportLogs();

      if (mounted) {
        if (path != null) {
          setState(() => _lastExportedPath = path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logs exported to:\n$path')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to export logs')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting logs: \$e')),
        );
      }
    }
  }

  Future<void> _shareExportedLogs() async {
    if (_lastExportedPath == null) {
      // Export first
      await _exportLogs();
    }
    if (_lastExportedPath != null && File(_lastExportedPath!).existsSync()) {
      await Share.shareXFiles(
        [XFile(_lastExportedPath!)],
        subject: 'ProgSet Touch Logs',
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No exported logs to share. Export first.')),
        );
      }
    }
  }

  Future<void> _setLoggingEnabled(bool enabled) async {
    try {
      final dataSource = context.read<PlatformBridgeDataSource>();
      await dataSource.setLoggingEnabled(enabled);
      setState(() => _loggingEnabled = enabled);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _setLogToFileEnabled(bool enabled) async {
    try {
      final dataSource = context.read<PlatformBridgeDataSource>();
      await dataSource.setLogToFileEnabled(enabled);
      setState(() => _logToFileEnabled = enabled);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logging & Diagnostics',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text('Enable Logging'),
                  subtitle: const Text('Capture debug information'),
                  value: _loggingEnabled,
                  onChanged: _setLoggingEnabled,
                ),
                SwitchListTile(
                  title: const Text('Log to File'),
                  subtitle: Text(_logFilePath ?? 'No file path available'),
                  value: _logToFileEnabled,
                  onChanged: _setLogToFileEnabled,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Export Location'),
                  subtitle: const Text(
                    'Внутренняя память/Download/',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _loadLogs,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _clearLogs,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _exportLogs,
                      icon: const Icon(Icons.download),
                      label: const Text('Export'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _shareExportedLogs,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: SelectableText(
                        _logs.isEmpty ? 'No logs available' : _logs,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
