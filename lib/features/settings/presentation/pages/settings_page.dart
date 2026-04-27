import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/features/main_screen/data/platform_bridge_data_source.dart';
import 'package:prog_set_touch/features/main_screen/presentation/bloc/main_screen_bloc.dart';
import 'package:prog_set_touch/features/scenario/presentation/bloc/scenario_bloc.dart';
import 'package:prog_set_touch/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          previous.errorKey != current.errorKey && current.errorKey != null,
      listener: (context, state) {
        final message = _formatSettingsError(context, state.errorKey);
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.settingsTitle)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _PermissionsSection(),
              const SizedBox(height: 16),
              const _ExecutionSection(),
              const SizedBox(height: 16),
              const _AutostartSection(),
              const SizedBox(height: 16),
              const _WebSocketSection(),
              const SizedBox(height: 16),
              const _LoggingSection(),
              const SizedBox(height: 16),
              const _ScenarioTransferSection(),
            ],
          ),
        ),
      ),
    );
  }

  String? _formatSettingsError(BuildContext context, String? errorKey) {
    if (errorKey == null) return null;
    final l10n = AppLocalizations.of(context)!;
    return switch (errorKey) {
      'settingsNativeStatusLoadError' => l10n.settingsGenericErrorPrefix,
      'settingsAutostartChangeError' => l10n.settingsAutostartChangeError,
      'settingsLoggingChangeError' => l10n.settingsGenericErrorPrefix,
      'settingsLogToFileChangeError' => l10n.settingsGenericErrorPrefix,
      _ => null,
    };
  }
}

class _AutostartSection extends StatelessWidget {
  const _AutostartSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return _SectionCard(
          icon: Icons.autorenew_outlined,
          title: l10n.settingsAutostartTitle,
          subtitle: l10n.settingsAutostartSubtitle,
          child: SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsAutostartToggleTitle),
            subtitle: Text(l10n.settingsAutostartToggleSubtitle),
            value: state.autostartEnabled,
            onChanged: (state.isNativeSettingsLoading || state.isAutostartBusy)
                ? null
                : (enabled) => context
                    .read<SettingsBloc>()
                    .add(SettingsAutostartToggled(enabled)),
          ),
        );
      },
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
  String _logSource = 'buffer';
  bool _isLoading = false;
  String? _lastExportedPath;
  final ScrollController _verticalLogScrollController = ScrollController();
  final ScrollController _horizontalLogScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _verticalLogScrollController.dispose();
    _horizontalLogScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      final dataSource = context.read<PlatformBridgeDataSource>();
      final results = await Future.wait<dynamic>([
        dataSource.getLogsSnapshot(),
        dataSource.getLogFilePath(),
      ]);
      final snapshot = results[0] as Map<String, String>;
      setState(() {
        _logs = snapshot['logs'] ?? '';
        _logSource = snapshot['source'] ?? 'buffer';
        _logFilePath = results[1] as String?;
      });
    } catch (e) {
      setState(() => _logs = '${l10n.settingsErrorLoadingLogsPrefix}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearLogs() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final dataSource = context.read<PlatformBridgeDataSource>();
      await dataSource.clearLogs();
      setState(() => _logs = '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsLogsCleared)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${l10n.settingsErrorClearingLogsPrefix}: $e')),
        );
      }
    }
  }

  Future<void> _exportLogs() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final dataSource = context.read<PlatformBridgeDataSource>();
      final path = await dataSource.exportLogs();

      if (mounted) {
        if (path != null) {
          setState(() => _lastExportedPath = path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('${l10n.settingsLogsExportedPrefix}:\n$path')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.settingsFailedToExportLogs)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${l10n.settingsErrorExportingLogsPrefix}: $e')),
        );
      }
    }
  }

  Future<void> _shareExportedLogs() async {
    final l10n = AppLocalizations.of(context)!;
    if (_lastExportedPath == null) {
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
          SnackBar(content: Text(l10n.settingsNoExportedLogsToShare)),
        );
      }
    }
  }

  Future<void> _setLoggingEnabled(bool enabled) async {
    context.read<SettingsBloc>().add(SettingsLoggingToggled(enabled));
  }

  Future<void> _setLogToFileEnabled(bool enabled) async {
    context.read<SettingsBloc>().add(SettingsLogToFileToggled(enabled));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final togglesBusy = state.isNativeSettingsLoading || state.isLoggingBusy;
        return _SectionCard(
          icon: Icons.monitor_heart_outlined,
          title: l10n.settingsDiagnosticsTitle,
          subtitle: l10n.settingsDiagnosticsSubtitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsEnableLoggingTitle),
                subtitle: Text(l10n.settingsEnableLoggingSubtitle),
                value: state.loggingEnabled,
                onChanged: togglesBusy ? null : _setLoggingEnabled,
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsLogToFileTitle),
                subtitle: Text(_logFilePath ?? l10n.settingsNoLogFilePath),
                value: state.logToFileEnabled,
                onChanged: togglesBusy ? null : _setLogToFileEnabled,
              ),
              const SizedBox(height: 8),
              _LogSourceChip(source: _logSource),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _loadLogs,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.settingsRefreshAction),
                  ),
                  OutlinedButton.icon(
                    onPressed: _clearLogs,
                    icon: const Icon(Icons.clear),
                    label: Text(l10n.settingsClearAction),
                  ),
                  FilledButton.icon(
                    onPressed: _exportLogs,
                    icon: const Icon(Icons.download),
                    label: Text(l10n.settingsExportAction),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _shareExportedLogs,
                    icon: const Icon(Icons.share),
                    label: Text(l10n.settingsShareAction),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1724),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF263445)),
                  ),
                  child: Scrollbar(
                    controller: _verticalLogScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _verticalLogScrollController,
                      padding: const EdgeInsets.all(10),
                      child: Scrollbar(
                        controller: _horizontalLogScrollController,
                        thumbVisibility: true,
                        notificationPredicate: (notification) =>
                            notification.metrics.axis == Axis.horizontal,
                        child: SingleChildScrollView(
                          controller: _horizontalLogScrollController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 80,
                            child: SelectableText(
                              _logs.isEmpty
                                  ? l10n.settingsNoLogsAvailable
                                  : _logs,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                height: 1.35,
                                color: Color(0xFFC7F9CC),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _WebSocketSection extends StatefulWidget {
  const _WebSocketSection();

  @override
  State<_WebSocketSection> createState() => _WebSocketSectionState();
}

class _WebSocketSectionState extends State<_WebSocketSection> {
  final TextEditingController _portController = TextEditingController();
  String? _lastSyncedPort;

  @override
  void dispose() {
    _portController.dispose();
    super.dispose();
  }

  Future<void> _setEnabled(bool enabled) async {
    context.read<SettingsBloc>().add(SettingsWebSocketEnabledToggled(enabled));
  }

  Future<void> _applyPort() async {
    final l10n = AppLocalizations.of(context)!;
    final port = int.tryParse(_portController.text.trim());
    if (port == null || port < 1024 || port > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsWebSocketPortError)),
      );
      return;
    }
    _lastSyncedPort = _portController.text.trim();
    context.read<SettingsBloc>().add(SettingsWebSocketPortSubmitted(port));
  }

  Future<void> _regenerateToken() async {
    context.read<SettingsBloc>().add(const SettingsWebSocketTokenRegenerated());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final status = state.webSocketStatus;
        final enabled = status.enabled;
        final running = status.running;
        final clientConnected = status.clientConnected;
        final port = status.port?.toString() ?? '';
        final token = status.token;
        final clientAddress = status.clientAddress;
        final transport = status.transport;
        final authMode = status.authMode;
        final urls = status.urls;

        final canSyncPort =
            _portController.text.isEmpty || _portController.text == _lastSyncedPort;
        if (canSyncPort && port.isNotEmpty && port != _lastSyncedPort) {
          _portController.text = port;
          _lastSyncedPort = port;
        }

        final loadError = switch (state.webSocketError) {
          'websocket_timeout' => l10n.settingsWebSocketTimeoutError,
          final value? when value.startsWith('websocket_error:') =>
            '${l10n.settingsWebSocketLoadError}: ${value.substring('websocket_error:'.length)}',
          _ => null,
        };

        return _SectionCard(
          icon: Icons.wifi_tethering_outlined,
          title: l10n.settingsWebSocketTitle,
          subtitle: l10n.settingsWebSocketSubtitle,
          child: state.isWebSocketLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsWebSocketEnableSubtitle),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: state.isWebSocketBusy
                              ? null
                              : () => _setEnabled(!enabled),
                          icon: Icon(
                            enabled
                                ? Icons.power_settings_new
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(
                            enabled
                                ? l10n.settingsWebSocketDisableAction
                                : l10n.settingsWebSocketEnableAction,
                          ),
                        ),
                        if (state.isWebSocketBusy)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (loadError != null) ...[
                      _InlineErrorBox(message: loadError),
                      const SizedBox(height: 12),
                    ],
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          label: l10n.settingsWebSocketRunningLabel,
                          value: running
                              ? l10n.settingsWebSocketStatusRunning
                              : l10n.settingsWebSocketStatusStopped,
                        ),
                        _InfoChip(
                          label: l10n.settingsWebSocketClientLabel,
                          value: clientConnected
                              ? (clientAddress ??
                                  l10n.settingsWebSocketStatusClientConnected)
                              : l10n.settingsWebSocketStatusNoClient,
                        ),
                        _InfoChip(
                          label: l10n.settingsWebSocketTransportLabel,
                          value: transport,
                        ),
                        _InfoChip(
                          label: l10n.settingsWebSocketAuthLabel,
                          value: (authMode == 'query_token' ||
                                  authMode == 'bearer_token_preferred')
                              ? l10n.settingsWebSocketAuthModeQueryToken
                              : authMode,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _portController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.settingsWebSocketPortLabel,
                              hintText: port,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.tonal(
                          onPressed: state.isWebSocketBusy ? null : _applyPort,
                          child: Text(l10n.settingsWebSocketApplyPort),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: state.isWebSocketBusy
                              ? null
                              : () => context
                                  .read<SettingsBloc>()
                                  .add(const SettingsWebSocketStatusRequested()),
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.settingsWebSocketRefreshAction),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: state.isWebSocketBusy
                              ? null
                              : _regenerateToken,
                          icon: const Icon(Icons.key_outlined),
                          label: Text(l10n.settingsWebSocketRegenerateToken),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.settingsWebSocketTokenLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    _CodeBox(text: token),
                    const SizedBox(height: 12),
                    Text(
                      l10n.settingsWebSocketUrlsLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    if (urls.isEmpty)
                      Text(
                        l10n.settingsWebSocketUnavailableAddress,
                        style: const TextStyle(color: Color(0xFF5A6B7D)),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: urls
                            .map(
                              (url) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _CodeBox(text: url),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _PermissionsSection extends StatefulWidget {
  const _PermissionsSection();

  @override
  State<_PermissionsSection> createState() => _PermissionsSectionState();
}

class _PermissionsSectionState extends State<_PermissionsSection> {
  bool _isLoading = true;
  bool _isBusy = false;
  bool _accessibilityGranted = false;
  bool _overlayGranted = false;
  bool _mediaProjectionGranted = false;

  @override
  void initState() {
    super.initState();
    _loadPermissionStatus();
  }

  Future<void> _loadPermissionStatus() async {
    final dataSource = context.read<PlatformBridgeDataSource>();
    try {
      final status = await dataSource.getPermissionStatus();
      if (!mounted) return;
      setState(() {
        _accessibilityGranted = status.accessibilityGranted;
        _overlayGranted = status.overlayGranted;
        _mediaProjectionGranted = status.mediaProjectionGranted;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openAccessibility() async {
    final dataSource = context.read<PlatformBridgeDataSource>();
    await dataSource.openAccessibilitySettings();
  }

  Future<void> _openOverlay() async {
    final dataSource = context.read<PlatformBridgeDataSource>();
    await dataSource.openOverlaySettings();
  }

  Future<void> _requestMediaProjection() async {
    final dataSource = context.read<PlatformBridgeDataSource>();
    await dataSource.requestMediaProjectionPermission();
    await _loadPermissionStatus();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allGranted =
        _accessibilityGranted && _overlayGranted && _mediaProjectionGranted;
    final executionPermissionsGranted =
        _accessibilityGranted && _overlayGranted;

    return _SectionCard(
      icon: Icons.verified_user_outlined,
      title: l10n.permissionsTitle,
      subtitle: allGranted
          ? l10n.settingsPermissionsAllGranted
          : l10n.settingsPermissionsMissingSummary,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!executionPermissionsGranted) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD8A8)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFC77800),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.settingsExecutionPermissionsRequired,
                              style: const TextStyle(
                                color: Color(0xFF8A5A00),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PermissionChip(
                      label: l10n.settingsPermissionAccessibilityLabel,
                      granted: _accessibilityGranted,
                    ),
                    _PermissionChip(
                      label: l10n.settingsPermissionOverlayLabel,
                      granted: _overlayGranted,
                    ),
                    _PermissionChip(
                      label: l10n.settingsPermissionMediaProjectionLabel,
                      granted: _mediaProjectionGranted,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (!_accessibilityGranted) ...[
                  _PermissionRow(
                    label: l10n.settingsPermissionAccessibilityLabel,
                    actionLabel: l10n.permissionsAccessibilityAction,
                    onPressed: () => _runAction(_openAccessibility),
                  ),
                  const SizedBox(height: 8),
                ],
                if (!_overlayGranted) ...[
                  _PermissionRow(
                    label: l10n.settingsPermissionOverlayLabel,
                    actionLabel: l10n.permissionsOverlayAction,
                    onPressed: () => _runAction(_openOverlay),
                  ),
                  const SizedBox(height: 8),
                ],
                if (!_mediaProjectionGranted)
                  _PermissionRow(
                    label: l10n.settingsPermissionMediaProjectionLabel,
                    actionLabel: l10n.permissionsMediaProjectionAction,
                    onPressed: () => _runAction(_requestMediaProjection),
                  ),
              ],
            ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.label,
    required this.actionLabel,
    required this.onPressed,
  });

  final String label;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF1D3A5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFC77800)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                onPressed: onPressed,
                icon: const Icon(Icons.open_in_new),
                label: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  const _PermissionChip({
    required this.label,
    required this.granted,
  });

  final String label;
  final bool granted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: granted ? const Color(0xFFEAF9EE) : const Color(0xFFFFF5E8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: granted ? const Color(0xFFB6E0C2) : const Color(0xFFF1D3A5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '$label: ${granted ? l10n.settingsPermissionGranted : l10n.settingsPermissionMissing}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: granted ? const Color(0xFF2E7D32) : const Color(0xFFC77800),
          ),
        ),
      ),
    );
  }
}

class _LogSourceChip extends StatelessWidget {
  const _LogSourceChip({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBuffer = source == 'buffer';
    final label = isBuffer
        ? l10n.settingsLogSourceBuffer
        : l10n.settingsLogSourceFileFallback;

    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3FF),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFBFD7F5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            '${l10n.settingsLogSourceLabel}: $label',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D4F91),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFD7F5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D4F91),
          ),
        ),
      ),
    );
  }
}

class _InlineErrorBox extends StatelessWidget {
  const _InlineErrorBox({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1D3A5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFC77800)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF8A5A00),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9E3EF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SelectableText(
          text,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.35,
            color: Color(0xFF223142),
          ),
        ),
      ),
    );
  }
}

class _ExecutionSection extends StatelessWidget {
  const _ExecutionSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocBuilder<MainScreenBloc, MainScreenState>(
      builder: (context, state) {
        final delaySeconds = (state.executionDelayMs / 1000).round();
        return _SectionCard(
          icon: Icons.speed_outlined,
          title: l10n.settingsExecutionTitle,
          subtitle: l10n.settingsExecutionDelay,
          child: Row(
            children: [
              Expanded(
                child: Slider.adaptive(
                  min: 1,
                  max: 120,
                  divisions: 119,
                  value: delaySeconds.toDouble(),
                  onChanged: (value) {
                    context.read<MainScreenBloc>().add(
                          MainScreenExecutionDelayChanged(
                              (value * 1000).round()),
                        );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD1D9E4)),
                ),
                child: Text(
                  l10n.settingsExecutionDelayUnit(delaySeconds),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScenarioTransferSection extends StatelessWidget {
  const _ScenarioTransferSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final logger = context.read<AppLogger>();
    return BlocBuilder<ScenarioBloc, ScenarioState>(
      builder: (context, scenarioState) {
        return _SectionCard(
          icon: Icons.import_export,
          title: l10n.mainScenarioSectionTitle,
          subtitle: '${l10n.scenarioImport} / ${l10n.scenarioExport}',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (scenarioState.scenarios.isEmpty) {
                    logger.logInfo(
                      'settings_page',
                      'Scenario export skipped from settings',
                      payload: {'action': 'scenario_export_skip_empty'},
                    );
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.scenarioExportEmpty)),
                    );
                    return;
                  }
                  try {
                    final platformBridge =
                        context.read<PlatformBridgeDataSource>();
                    final fileName =
                        'scenarios_${DateTime.now().millisecondsSinceEpoch}.json';
                    final scenariosPayload = <Map<String, dynamic>>[];
                    for (final entry in scenarioState.scenarios) {
                      final actions =
                          await platformBridge.exportScenarioActions(entry.id);
                      scenariosPayload.add({
                        ...entry.toMap(),
                        'actions': actions,
                      });
                    }
                    final payload = jsonEncode({
                      'version': 1,
                      'scenarios': scenariosPayload,
                    });

                    String? path;
                    if (Platform.isAndroid) {
                      final tempDir = await getTemporaryDirectory();
                      final exportFile = File('${tempDir.path}/$fileName');
                      await exportFile.writeAsString(payload);
                      path = exportFile.path;
                      await Share.shareXFiles(
                        [XFile(exportFile.path)],
                        subject: 'ProgSet Touch Scenarios',
                      );
                    } else {
                      path = await FilePicker.platform.saveFile(
                        dialogTitle: l10n.scenarioExport,
                        fileName: fileName,
                        type: FileType.custom,
                        allowedExtensions: const ['json'],
                      );
                      if (path == null) {
                        logger.logInfo(
                          'settings_page',
                          'Scenario export cancelled from settings',
                          payload: {'action': 'scenario_export_cancel'},
                        );
                        return;
                      }
                      await File(path).writeAsString(payload);
                    }

                    logger.logInfo(
                      'settings_page',
                      'Scenario export completed from settings',
                      payload: {
                        'action': 'scenario_export_done',
                        'count': scenarioState.scenarios.length,
                        'withActions': true,
                        'path': path,
                      },
                    );
                    if (context.mounted) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.scenarioExportDone)),
                      );
                    }
                  } catch (error, stackTrace) {
                    logger.logError(
                      'settings_page',
                      error,
                      stackTrace,
                      context:
                          'Scenario export failed in settings | action=scenario_export_failed',
                    );
                    if (context.mounted) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.scenarioExportFailed)),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.file_download_outlined),
                label: Text(l10n.scenarioExport),
              ),
              FilledButton.tonalIcon(
                onPressed: () async {
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: const ['json'],
                      withData: true,
                    );
                    if (result == null || result.files.isEmpty) {
                      logger.logInfo(
                        'settings_page',
                        'Scenario import cancelled from settings',
                        payload: {'action': 'scenario_import_cancel'},
                      );
                      return;
                    }
                    final file = result.files.first;
                    String? content;
                    if (file.bytes != null) {
                      content = utf8.decode(file.bytes!);
                    } else if (file.path != null) {
                      content = await File(file.path!).readAsString();
                    }
                    if (content == null || content.trim().isEmpty) {
                      logger.logInfo(
                        'settings_page',
                        'Scenario import rejected: empty payload from settings',
                        payload: {'action': 'scenario_import_empty_payload'},
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.scenarioImportInvalidJson)),
                        );
                      }
                      return;
                    }
                    logger.logInfo(
                      'settings_page',
                      'Scenario import requested from settings',
                      payload: {
                        'action': 'scenario_import_requested',
                        'bytes': content.length,
                        'file': file.name,
                      },
                    );
                    if (context.mounted) {
                      context
                          .read<ScenarioBloc>()
                          .add(ScenarioImportRequested(content));
                    }
                  } catch (error, stackTrace) {
                    logger.logError(
                      'settings_page',
                      error,
                      stackTrace,
                      context:
                          'Scenario import failed in settings | action=scenario_import_failed',
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.scenarioImportInvalidJson)),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.file_upload_outlined),
                label: Text(l10n.scenarioImport),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E2EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF245EA8), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5A6B7D),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
