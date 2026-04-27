import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:prog_set_touch/core/error/app_logger.dart';
import 'package:prog_set_touch/features/main_screen/domain/execution_summary.dart';
import 'package:prog_set_touch/features/main_screen/domain/platform_bridge_repository.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_item.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_repository.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_service.dart';

part 'scenario_event.dart';
part 'scenario_state.dart';

class ScenarioBloc extends Bloc<ScenarioEvent, ScenarioState> {
  ScenarioBloc({
    required ScenarioRepository repository,
    required ScenarioService service,
    required PlatformBridgeRepository platformBridgeRepository,
    required AppLogger logger,
  })  : _repository = repository,
        _service = service,
        _platformBridgeRepository = platformBridgeRepository,
        _logger = logger,
        super(const ScenarioState()) {
    on<ScenarioLoadRequested>(_onLoadRequested);
    on<ScenarioCreateRequested>(_onCreateRequested);
    on<ScenarioQuickLaunchToggled>(_onQuickLaunchToggled);
    on<ScenarioEnabledToggled>(_onEnabledToggled);
    on<ScenarioReordered>(_onReordered);
    on<ScenarioSelectAllQuickLaunchToggled>(_onSelectAllQuickLaunchToggled);
    on<ScenarioQuickLaunchRunRequested>(_onQuickLaunchRunRequested);
    on<ScenarioRunAllRequested>(_onRunAllRequested);
    on<ScenarioSingleRunRequested>(_onSingleRunRequested);
    on<ScenarioRenameRequested>(_onRenameRequested);
    on<ScenarioDeleteRequested>(_onDeleteRequested);
    on<ScenarioStopRequested>(_onStopRequested);
    on<ScenarioImportRequested>(_onImportRequested);
  }

  final ScenarioRepository _repository;
  final ScenarioService _service;
  final PlatformBridgeRepository _platformBridgeRepository;
  final AppLogger _logger;

  Future<void> _onLoadRequested(
    ScenarioLoadRequested event,
    Emitter<ScenarioState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, clearMessage: true));
      final scenarios = await _repository.getAll();
      _logScenarioAction(
        'load_requested',
        'Scenarios loaded from storage',
        payload: {'count': scenarios.length},
      );
      emit(
        state.copyWith(
          isLoading: false,
          scenarios: _service.normalizeOrder(scenarios),
        ),
      );
    } catch (error, stackTrace) {
      _logScenarioError(
        'load_failed',
        error,
        stackTrace,
        context: 'Scenario load failed',
      );
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onCreateRequested(
    ScenarioCreateRequested event,
    Emitter<ScenarioState> emit,
  ) async {
    final trimmedName = event.name.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    if (!_service.hasExecutableSteps(event.stepCount)) {
      _logScenarioError(
        'create_rejected_empty',
        ArgumentError.value(event.stepCount, 'stepCount'),
        null,
        context: 'Scenario creation rejected due to empty steps',
      );
      emit(state.copyWith(messageKey: 'scenarioEmptyNotAllowed'));
      return;
    }

    if (state.scenarios.length >= ScenarioService.maxScenarios) {
      _logScenarioError(
        'create_rejected_limit',
        StateError('Scenario limit reached'),
        null,
        context: 'Scenario creation rejected due to limit',
      );
      emit(state.copyWith(messageKey: 'scenarioLimitReached'));
      return;
    }

    if (_service.hasDuplicateName(
        scenarios: state.scenarios, name: trimmedName)) {
      _logScenarioError(
        'create_rejected_duplicate',
        StateError('Scenario name must be unique'),
        null,
        context: 'Scenario creation rejected due to duplicate name',
      );
      emit(state.copyWith(messageKey: 'scenarioNameMustBeUnique'));
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final created = ScenarioItem(
      id: 'scenario_$now',
      name: trimmedName,
      orderIndex: state.scenarios.length,
      stepCount: event.stepCount,
      quickLaunchEnabled: false,
      isEnabled: true,
      createdAtMs: now,
      updatedAtMs: now,
    );
    final updated = _service.normalizeOrder([...state.scenarios, created]);
    try {
      final bindSuccess =
          await _platformBridgeRepository.bindCurrentRecordingToScenario(
        created.id,
      );
      if (!bindSuccess) {
        _logScenarioError(
          'create_rejected_bind_failed',
          StateError('Current recording could not be bound to scenario'),
          null,
          context: 'Scenario creation rejected due to missing native actions',
        );
        emit(state.copyWith(messageKey: 'scenarioEmptyNotAllowed'));
        return;
      }
      await _repository.saveAll(updated);
      _logScenarioAction(
        'create',
        'Scenario created',
        payload: {'scenarioId': created.id, 'name': created.name},
      );
      emit(state.copyWith(scenarios: updated, clearMessage: true));
    } catch (error, stackTrace) {
      _logScenarioError(
        'create_failed',
        error,
        stackTrace,
        context: 'Scenario creation failed',
      );
    }
  }

  Future<void> _onQuickLaunchToggled(
    ScenarioQuickLaunchToggled event,
    Emitter<ScenarioState> emit,
  ) async {
    final updated = _service.normalizeOrder([
      for (final item in state.scenarios)
        if (item.id == event.scenarioId)
          item.copyWith(
            quickLaunchEnabled: !item.quickLaunchEnabled,
            updatedAtMs: DateTime.now().millisecondsSinceEpoch,
          )
        else
          item,
    ]);
    try {
      await _repository.saveAll(updated);
      _logScenarioAction(
        'toggle_quick_launch',
        'Scenario quick-launch flag updated',
        payload: {'scenarioId': event.scenarioId},
      );
      emit(state.copyWith(scenarios: updated, clearMessage: true));
    } catch (error, stackTrace) {
      _logScenarioError(
        'toggle_quick_launch_failed',
        error,
        stackTrace,
        context: 'Scenario quick-launch toggle failed',
      );
    }
  }

  Future<void> _onEnabledToggled(
    ScenarioEnabledToggled event,
    Emitter<ScenarioState> emit,
  ) async {
    final updated = _service.normalizeOrder([
      for (final item in state.scenarios)
        if (item.id == event.scenarioId)
          item.copyWith(
            isEnabled: !item.isEnabled,
            updatedAtMs: DateTime.now().millisecondsSinceEpoch,
          )
        else
          item,
    ]);
    try {
      await _repository.saveAll(updated);
      _logScenarioAction(
        'toggle_enabled',
        'Scenario enabled flag updated',
        payload: {'scenarioId': event.scenarioId},
      );
      emit(state.copyWith(scenarios: updated, clearMessage: true));
    } catch (error, stackTrace) {
      _logScenarioError(
        'toggle_enabled_failed',
        error,
        stackTrace,
        context: 'Scenario enabled toggle failed',
      );
    }
  }

  Future<void> _onReordered(
    ScenarioReordered event,
    Emitter<ScenarioState> emit,
  ) async {
    final mutable = [...state.scenarios]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    if (event.oldIndex < 0 ||
        event.oldIndex >= mutable.length ||
        event.newIndex < 0 ||
        event.newIndex >= mutable.length) {
      _logScenarioError(
        'reorder_rejected_bounds',
        RangeError('Reorder indexes out of bounds'),
        null,
        context: 'Scenario reorder rejected',
      );
      return;
    }
    final moved = mutable.removeAt(event.oldIndex);
    mutable.insert(event.newIndex, moved);
    final updated = _service.normalizeOrder(mutable);
    try {
      await _repository.saveAll(updated);
      _logScenarioAction(
        'reorder',
        'Scenario list reordered',
        payload: {'oldIndex': event.oldIndex, 'newIndex': event.newIndex},
      );
      emit(state.copyWith(scenarios: updated, clearMessage: true));
    } catch (error, stackTrace) {
      _logScenarioError(
        'reorder_failed',
        error,
        stackTrace,
        context: 'Scenario reorder failed',
      );
    }
  }

  Future<void> _onSelectAllQuickLaunchToggled(
    ScenarioSelectAllQuickLaunchToggled event,
    Emitter<ScenarioState> emit,
  ) async {
    final allSelected = state.scenarios.isNotEmpty &&
        state.scenarios.every((item) => item.quickLaunchEnabled);
    final target = !allSelected;
    final now = DateTime.now().millisecondsSinceEpoch;
    final updated = _service.normalizeOrder([
      for (final item in state.scenarios)
        item.copyWith(
          quickLaunchEnabled: target,
          updatedAtMs: now,
        ),
    ]);
    try {
      await _repository.saveAll(updated);
      _logScenarioAction(
        'select_all_quick_launch',
        'Scenario quick-launch bulk toggle applied',
        payload: {'enabled': target, 'count': updated.length},
      );
      emit(state.copyWith(scenarios: updated, clearMessage: true));
    } catch (error, stackTrace) {
      _logScenarioError(
        'select_all_quick_launch_failed',
        error,
        stackTrace,
        context: 'Scenario bulk quick-launch toggle failed',
      );
    }
  }

  void _onQuickLaunchRunRequested(
    ScenarioQuickLaunchRunRequested event,
    Emitter<ScenarioState> emit,
  ) async {
    final snapshot = _service.snapshotForQuickLaunch(state.scenarios);
    if (snapshot.isEmpty) {
      _logScenarioError(
        'quick_launch_rejected_empty',
        StateError('No quick-launch scenarios selected'),
        null,
        context: 'Quick launch run rejected',
      );
      emit(state.copyWith(messageKey: 'scenarioQuickLaunchEmpty'));
      return;
    }
    await _runBatch(snapshot, emit);
  }

  void _onRunAllRequested(
    ScenarioRunAllRequested event,
    Emitter<ScenarioState> emit,
  ) async {
    final snapshot = _service.snapshotForRunAll(state.scenarios);
    if (snapshot.isEmpty) {
      _logScenarioError(
        'run_all_rejected_empty',
        StateError('No enabled scenarios to run'),
        null,
        context: 'Run-all rejected',
      );
      emit(state.copyWith(messageKey: 'scenarioRunAllEmpty'));
      return;
    }
    await _runBatch(snapshot, emit);
  }

  Future<void> _onSingleRunRequested(
    ScenarioSingleRunRequested event,
    Emitter<ScenarioState> emit,
  ) async {
    final selected =
        state.scenarios.where((s) => s.id == event.scenarioId).toList();
    if (selected.isEmpty) {
      return;
    }
    await _runBatch(selected, emit);
  }

  Future<void> _onRenameRequested(
    ScenarioRenameRequested event,
    Emitter<ScenarioState> emit,
  ) async {
    final trimmedName = event.newName.trim();
    if (trimmedName.isEmpty) return;

    if (_service.hasDuplicateName(
      scenarios: state.scenarios,
      name: trimmedName,
      excludeId: event.scenarioId,
    )) {
      _logScenarioError(
        'rename_rejected_duplicate',
        StateError('Scenario name must be unique'),
        null,
        context: 'Scenario rename rejected due to duplicate name',
      );
      emit(state.copyWith(messageKey: 'scenarioNameMustBeUnique'));
      return;
    }

    final updated = [
      for (final item in state.scenarios)
        if (item.id == event.scenarioId)
          item.copyWith(
            name: trimmedName,
            updatedAtMs: DateTime.now().millisecondsSinceEpoch,
          )
        else
          item,
    ];

    try {
      await _repository.saveAll(updated);
      _logScenarioAction(
        'rename',
        'Scenario renamed',
        payload: {'scenarioId': event.scenarioId, 'newName': trimmedName},
      );
      emit(state.copyWith(scenarios: updated, clearMessage: true));
    } catch (error, stackTrace) {
      _logScenarioError(
        'rename_failed',
        error,
        stackTrace,
        context: 'Scenario rename failed',
      );
    }
  }

  Future<void> _onDeleteRequested(
    ScenarioDeleteRequested event,
    Emitter<ScenarioState> emit,
  ) async {
    final updated =
        state.scenarios.where((s) => s.id != event.scenarioId).toList();
    final normalized = _service.normalizeOrder(updated);
    try {
      await _platformBridgeRepository.deleteScenarioActions(event.scenarioId);
      await _repository.saveAll(normalized);
      _logScenarioAction(
        'delete',
        'Scenario deleted',
        payload: {'scenarioId': event.scenarioId},
      );
      emit(state.copyWith(scenarios: normalized, clearMessage: true));
    } catch (error, stackTrace) {
      _logScenarioError(
        'delete_failed',
        error,
        stackTrace,
        context: 'Scenario delete failed',
      );
    }
  }

  Future<void> _onStopRequested(
    ScenarioStopRequested event,
    Emitter<ScenarioState> emit,
  ) async {
    try {
      await _platformBridgeRepository.stopExecution();
      _logScenarioAction('stop', 'Scenario execution stop requested');
      emit(state.copyWith(isExecuting: false, clearActiveScenario: true));
    } catch (error, stackTrace) {
      _logScenarioError(
        'stop_failed',
        error,
        stackTrace,
        context: 'Scenario execution stop failed',
      );
    }
  }

  Future<void> _onImportRequested(
    ScenarioImportRequested event,
    Emitter<ScenarioState> emit,
  ) async {
    final decoded = _decodeScenarioImport(event.jsonContent);
    if (decoded == null) {
      _logScenarioError(
        'import_rejected_json',
        FormatException('Invalid scenario import JSON'),
        null,
        context: 'Scenario import rejected due to invalid JSON',
      );
      emit(state.copyWith(messageKey: 'scenarioImportInvalidJson'));
      return;
    }
    final imported = _normalizeImported(decoded);
    if (imported.isEmpty) {
      _logScenarioError(
        'import_rejected_no_items',
        StateError('No valid scenarios in import payload'),
        null,
        context: 'Scenario import rejected due to empty normalized payload',
      );
      emit(state.copyWith(messageKey: 'scenarioImportNoItems'));
      return;
    }

    final merged = [...state.scenarios];
    for (final entry in imported) {
      final item = entry.item;
      if (merged.length >= ScenarioService.maxScenarios) {
        _logScenarioError(
          'import_rejected_limit',
          StateError('Scenario limit reached'),
          null,
          context: 'Scenario import rejected due to limit',
        );
        emit(state.copyWith(messageKey: 'scenarioLimitReached'));
        return;
      }
      if (_service.hasDuplicateName(scenarios: merged, name: item.name)) {
        _logScenarioError(
          'import_rejected_duplicate',
          StateError('Scenario name must be unique'),
          null,
          context: 'Scenario import rejected due to duplicate name',
        );
        emit(state.copyWith(messageKey: 'scenarioNameMustBeUnique'));
        return;
      }
      merged.add(
        item.copyWith(
          orderIndex: merged.length,
          updatedAtMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    try {
      final normalized = _service.normalizeOrder(merged);
      for (final entry in imported) {
        if (entry.actions.isEmpty) {
          continue;
        }
        final importSuccess = await _platformBridgeRepository.importScenarioActions(
          scenarioId: entry.item.id,
          actions: entry.actions,
        );
        if (!importSuccess) {
          throw StateError(
            'Scenario actions import failed for scenarioId=${entry.item.id}',
          );
        }
      }
      await _repository.saveAll(normalized);
      _logScenarioAction(
        'import',
        'Scenario import finished',
        payload: {'imported': imported.length, 'total': normalized.length},
      );
      emit(
        state.copyWith(
          scenarios: normalized,
          messageKey: 'scenarioImportDone',
        ),
      );
    } catch (error, stackTrace) {
      _logScenarioError(
        'import_failed',
        error,
        stackTrace,
        context: 'Scenario import failed',
      );
    }
  }

  List<Map<String, dynamic>>? _decodeScenarioImport(String raw) {
    try {
      final parsed = jsonDecode(raw);
      if (parsed is List) {
        return parsed.whereType<Map>().map((entry) {
          return entry.map(
            (key, value) => MapEntry(key.toString(), value),
          );
        }).toList();
      }
      if (parsed is Map<String, dynamic>) {
        final scenarios = parsed['scenarios'];
        if (scenarios is List) {
          return scenarios.whereType<Map>().map((entry) {
            return entry.map(
              (key, value) => MapEntry(key.toString(), value),
            );
          }).toList();
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<_ImportedScenarioEntry> _normalizeImported(
    List<Map<String, dynamic>> source,
  ) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final result = <_ImportedScenarioEntry>[];
    for (var i = 0; i < source.length; i++) {
      final map = source[i];
      final name = (map['name']?.toString() ?? '').trim();
      final importedActions = _normalizeImportedActions(map['actions']);
      final stepCountRaw = map['stepCount'];
      final fallbackStepCount = stepCountRaw is num
          ? stepCountRaw.toInt()
          : int.tryParse(stepCountRaw?.toString() ?? '') ?? 0;
      final stepCount =
          importedActions.isNotEmpty ? importedActions.length : fallbackStepCount;
      if (name.isEmpty || !_service.hasExecutableSteps(stepCount)) {
        continue;
      }
      result.add(
        _ImportedScenarioEntry(
          item: ScenarioItem(
            id: 'scenario_import_${now}_$i',
            name: name,
            orderIndex: i,
            stepCount: stepCount,
            quickLaunchEnabled: map['quickLaunchEnabled'] == true,
            isEnabled: map['isEnabled'] != false,
            createdAtMs: now,
            updatedAtMs: now,
          ),
          actions: importedActions,
        ),
      );
    }
    return result;
  }

  List<Map<String, dynamic>> _normalizeImportedActions(dynamic rawActions) {
    if (rawActions is! List) {
      return const <Map<String, dynamic>>[];
    }
    return rawActions
        .whereType<Map>()
        .map(
          (entry) => entry.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .where((entry) => (entry['type']?.toString().trim() ?? '').isNotEmpty)
        .toList();
  }

  Future<void> _runBatch(
    List<ScenarioItem> snapshot,
    Emitter<ScenarioState> emit,
  ) async {
    if (state.isExecuting) {
      _logScenarioError(
        'batch_rejected_busy_local',
        StateError('Local scenario state is already executing'),
        null,
        context: 'Scenario batch rejected by local busy flag',
      );
      return;
    }

    try {
      final appState = await _platformBridgeRepository.getCurrentState();
      if (appState.isExecuting) {
        _logScenarioError(
          'batch_rejected_busy_platform',
          StateError('Platform reports execution in progress'),
          null,
          context: 'Scenario batch rejected by platform busy state',
        );
        emit(state.copyWith(messageKey: 'scenarioExecutionBusy'));
        return;
      }

      emit(
        state.copyWith(
          isExecuting: true,
          lastSnapshot: snapshot,
          completedInBatch: 0,
          totalInBatch: snapshot.length,
          clearMessage: true,
        ),
      );
      _logScenarioAction(
        'batch_start',
        'Scenario batch execution started',
        payload: {'count': snapshot.length},
      );

      var completed = 0;
      for (final scenario in snapshot) {
        if (!state.isExecuting) break;

        emit(
          state.copyWith(
            activeScenarioId: scenario.id,
            completedInBatch: completed,
            totalInBatch: snapshot.length,
          ),
        );

        final started = await _platformBridgeRepository.startScenarioExecution(
          scenarioId: scenario.id,
        );
        if (!started.isExecuting) {
          _logScenarioError(
            'batch_item_start_failed',
            StateError(
                started.error ?? 'Scenario execution did not enter EXECUTING'),
            null,
            context: 'Scenario batch item failed to start',
          );
          completed += 1;
          continue;
        }

        await _waitUntilExecutionStops(emit);
        completed += 1;
      }

      emit(
        state.copyWith(
          isExecuting: false,
          clearActiveScenario: true,
          completedInBatch: completed,
          totalInBatch: snapshot.length,
          messageKey: 'scenarioBatchDone',
        ),
      );
      _logScenarioAction(
        'batch_done',
        'Scenario batch execution finished',
        payload: {'completed': completed, 'total': snapshot.length},
      );
    } catch (error, stackTrace) {
      _logScenarioError(
        'batch_failed',
        error,
        stackTrace,
        context: 'Scenario batch execution failed',
      );
      emit(
        state.copyWith(
          isExecuting: false,
          clearActiveScenario: true,
        ),
      );
    }
  }

  Future<void> _waitUntilExecutionStops(Emitter<ScenarioState> emit) async {
    while (true) {
      final status = await _platformBridgeRepository.getExecutionStatus();
      if (!status.isExecuting) {
        return;
      }
      emit(state.copyWith(executionSummary: status));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  void _logScenarioAction(
    String action,
    String message, {
    Map<String, Object?>? payload,
  }) {
    _logger.logInfo(
      '[SCENARIO]',
      message,
      payload: {
        'action': action,
        if (payload != null) ...payload,
      },
    );
  }

  void _logScenarioError(
    String action,
    Object error,
    StackTrace? stackTrace, {
    required String context,
  }) {
    _logger.logError(
      '[ERROR][SCENARIO]',
      error,
      stackTrace,
      context: '$context | action=$action',
    );
  }
}

class _ImportedScenarioEntry {
  const _ImportedScenarioEntry({
    required this.item,
    required this.actions,
  });

  final ScenarioItem item;
  final List<Map<String, dynamic>> actions;
}
