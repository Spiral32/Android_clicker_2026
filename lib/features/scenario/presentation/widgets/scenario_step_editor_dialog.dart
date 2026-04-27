import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prog_set_touch/features/main_screen/data/platform_bridge_data_source.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_item.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_step.dart';
import 'package:prog_set_touch/features/scenario/presentation/bloc/scenario_bloc.dart';

class ScenarioStepEditorDialog extends StatefulWidget {
  const ScenarioStepEditorDialog({
    super.key,
    required this.scenario,
  });

  final ScenarioItem scenario;

  @override
  State<ScenarioStepEditorDialog> createState() =>
      _ScenarioStepEditorDialogState();
}

class _ScenarioStepEditorDialogState extends State<ScenarioStepEditorDialog> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorText;
  List<ScenarioStep> _steps = const <ScenarioStep>[];

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      final bridge = context.read<PlatformBridgeDataSource>();
      final steps = await bridge.getScenarioSteps(widget.scenario.id);
      if (!mounted) return;
      setState(() {
        _steps = steps;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorText = '${l10n.scenarioStepEditorLoadFailed}: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _editStep(int index) async {
    final updated = await showDialog<ScenarioStep>(
      context: context,
      builder: (_) => _ScenarioStepEditDialog(step: _steps[index]),
    );
    if (updated == null || !mounted) return;
    setState(() {
      _steps = [
        for (var i = 0; i < _steps.length; i++) if (i == index) updated else _steps[i],
      ];
    });
  }

  void _deleteStep(int index) {
    if (_steps.length <= 1) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.scenarioEmptyNotAllowed)),
        );
      return;
    }
    setState(() {
      _steps = [
        for (var i = 0; i < _steps.length; i++) if (i != index) _steps[i],
      ];
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    var adjusted = newIndex;
    if (newIndex > oldIndex) {
      adjusted = newIndex - 1;
    }
    final mutable = [..._steps];
    final moved = mutable.removeAt(oldIndex);
    mutable.insert(adjusted, moved);
    setState(() {
      _steps = mutable;
    });
  }

  void _save() {
    if (_steps.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.scenarioEmptyNotAllowed)),
        );
      return;
    }
    setState(() => _isSaving = true);
    context.read<ScenarioBloc>().add(
          ScenarioStepsSaveRequested(
            scenarioId: widget.scenario.id,
            steps: _steps,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.scenarioStepEditorTitle(widget.scenario.name),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.scenarioStepEditorSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5A6B7D),
                    ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorText != null)
                Expanded(
                  child: Center(
                    child: Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ReorderableListView.builder(
                    itemCount: _steps.length,
                    onReorder: _onReorder,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return _ScenarioStepCard(
                        key: ValueKey('${step.type.value}-$index'),
                        index: index,
                        step: step,
                        onEdit: () => _editStep(index),
                        onDelete: _isSaving ? null : () => _deleteStep(index),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    l10n.scenarioStepEditorCount(_steps.length),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n.commonCancel),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(l10n.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScenarioStepCard extends StatelessWidget {
  const _ScenarioStepCard({
    super.key,
    required this.index,
    required this.step,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final ScenarioStep step;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.drag_handle),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.scenarioStepEditorStepLabel(index + 1)}: ${_labelForType(l10n, step.type)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StepInfoChip(
                        text: l10n.scenarioStepEditorPointerCount(step.pointerCount),
                      ),
                      _StepInfoChip(
                        text: l10n.scenarioStepEditorDuration(step.durationMs),
                      ),
                      _StepInfoChip(
                        text: l10n.scenarioStepEditorDelay(step.stepDelayMs),
                      ),
                      _StepInfoChip(
                        text: l10n.scenarioStepEditorStart(
                          step.startX.toStringAsFixed(1),
                          step.startY.toStringAsFixed(1),
                        ),
                      ),
                      if (step.type == ScenarioStepType.swipe)
                        _StepInfoChip(
                          text: l10n.scenarioStepEditorEnd(
                            step.endX.toStringAsFixed(1),
                            step.endY.toStringAsFixed(1),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: onDelete,
              color: Colors.red,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  String _labelForType(AppLocalizations l10n, ScenarioStepType type) {
    return switch (type) {
      ScenarioStepType.tap => l10n.scenarioStepTypeTap,
      ScenarioStepType.doubleTap => l10n.scenarioStepTypeDoubleTap,
      ScenarioStepType.longPress => l10n.scenarioStepTypeLongPress,
      ScenarioStepType.swipe => l10n.scenarioStepTypeSwipe,
    };
  }
}

class _StepInfoChip extends StatelessWidget {
  const _StepInfoChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8E2EE)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ScenarioStepEditDialog extends StatefulWidget {
  const _ScenarioStepEditDialog({
    required this.step,
  });

  final ScenarioStep step;

  @override
  State<_ScenarioStepEditDialog> createState() => _ScenarioStepEditDialogState();
}

class _ScenarioStepEditDialogState extends State<_ScenarioStepEditDialog> {
  late ScenarioStepType _type;
  late final TextEditingController _pointerCountController;
  late final TextEditingController _startXController;
  late final TextEditingController _startYController;
  late final TextEditingController _endXController;
  late final TextEditingController _endYController;
  late final TextEditingController _durationController;
  late final TextEditingController _delayController;

  @override
  void initState() {
    super.initState();
    final step = widget.step;
    _type = step.type;
    _pointerCountController =
        TextEditingController(text: step.pointerCount.toString());
    _startXController = TextEditingController(text: step.startX.toString());
    _startYController = TextEditingController(text: step.startY.toString());
    _endXController = TextEditingController(text: step.endX.toString());
    _endYController = TextEditingController(text: step.endY.toString());
    _durationController =
        TextEditingController(text: step.durationMs.toString());
    _delayController =
        TextEditingController(text: step.stepDelayMs.toString());
  }

  @override
  void dispose() {
    _pointerCountController.dispose();
    _startXController.dispose();
    _startYController.dispose();
    _endXController.dispose();
    _endYController.dispose();
    _durationController.dispose();
    _delayController.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    final pointerCount = int.tryParse(_pointerCountController.text.trim());
    final durationMs = int.tryParse(_durationController.text.trim());
    final delayMs = int.tryParse(_delayController.text.trim());
    final startX = double.tryParse(_startXController.text.trim());
    final startY = double.tryParse(_startYController.text.trim());
    final endX = double.tryParse(_endXController.text.trim());
    final endY = double.tryParse(_endYController.text.trim());

    if (pointerCount == null ||
        durationMs == null ||
        delayMs == null ||
        startX == null ||
        startY == null ||
        endX == null ||
        endY == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.scenarioStepEditorInvalidValues)),
        );
      return;
    }

    Navigator.of(context).pop(
      widget.step.copyWith(
        type: _type,
        pointerCount: pointerCount,
        startX: startX,
        startY: startY,
        endX: endX,
        endY: endY,
        durationMs: durationMs,
        stepDelayMs: delayMs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.scenarioStepEditorEditTitle),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ScenarioStepType>(
                value: _type,
                decoration: InputDecoration(
                  labelText: l10n.scenarioStepEditorTypeLabel,
                ),
                items: ScenarioStepType.values
                    .map(
                      (type) => DropdownMenuItem<ScenarioStepType>(
                        value: type,
                        child: Text(
                          switch (type) {
                            ScenarioStepType.tap => l10n.scenarioStepTypeTap,
                            ScenarioStepType.doubleTap =>
                              l10n.scenarioStepTypeDoubleTap,
                            ScenarioStepType.longPress =>
                              l10n.scenarioStepTypeLongPress,
                            ScenarioStepType.swipe => l10n.scenarioStepTypeSwipe,
                          },
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _type = value);
                },
              ),
              const SizedBox(height: 12),
              _NumberField(
                controller: _pointerCountController,
                label: l10n.scenarioStepEditorPointerCountLabel,
              ),
              const SizedBox(height: 12),
              _NumberField(
                controller: _durationController,
                label: l10n.scenarioStepEditorDurationLabel,
              ),
              const SizedBox(height: 12),
              _NumberField(
                controller: _delayController,
                label: l10n.scenarioStepEditorDelayLabel,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: _startXController,
                      label: l10n.scenarioStepEditorStartXLabel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberField(
                      controller: _startYController,
                      label: l10n.scenarioStepEditorStartYLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: _endXController,
                      label: l10n.scenarioStepEditorEndXLabel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberField(
                      controller: _endYController,
                      label: l10n.scenarioStepEditorEndYLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
