import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prog_set_touch/features/main_screen/data/platform_bridge_data_source.dart';
import 'package:prog_set_touch/core/localization/app_localizations.dart';
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
        for (var i = 0; i < _steps.length; i++)
          if (i == index) updated else _steps[i],
      ];
    });
  }

  Future<void> _addStep() async {
    final newStep = await showDialog<ScenarioStep>(
      context: context,
      builder: (_) => _ScenarioStepEditDialog(
        step: ScenarioStep.initial(),
        isNew: true,
      ),
    );
    if (newStep == null || !mounted) return;
    setState(() {
      _steps = [..._steps, newStep];
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
        for (var i = 0; i < _steps.length; i++)
          if (i != index) _steps[i],
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
    final theme = Theme.of(context);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: SizedBox(
        width: 760,
        height: 600,
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
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.layers_outlined,
                        size: 20, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      l10n.scenarioStepEditorCount(_steps.length),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.save),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _addStep,
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text(l10n.scenarioStepEditorAddStep),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed:
                      _isSaving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: Text(l10n.commonCancel),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
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
                        text: l10n
                            .scenarioStepEditorPointerCount(step.pointerCount),
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
                      if (step.verificationEnabled)
                        _StepInfoChip(
                          text: 'Verify (${step.thresholdPercent}%)',
                          color: Colors.blue.shade50,
                          borderColor: Colors.blue.shade100,
                          textColor: Colors.blue.shade700,
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
            _TestStepButton(step: step),
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

class _TestStepButton extends StatefulWidget {
  const _TestStepButton({required this.step});

  final ScenarioStep step;

  @override
  State<_TestStepButton> createState() => _TestStepButtonState();
}

class _TestStepButtonState extends State<_TestStepButton> {
  bool _isTesting = false;

  Future<void> _test() async {
    setState(() => _isTesting = true);
    try {
      final repository = context.read<PlatformBridgeDataSource>();
      final success = await repository.testScenarioStep(widget.step);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Test success" : "Test failed"),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isTesting) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      onPressed: _test,
      tooltip: "Test step",
      icon: const Icon(Icons.play_circle_outline, color: Colors.green),
    );
  }
}

class _StepInfoChip extends StatelessWidget {
  const _StepInfoChip({
    required this.text,
    this.color,
    this.borderColor,
    this.textColor,
  });

  final String text;
  final Color? color;
  final Color? borderColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor ?? const Color(0xFFD8E2EE)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _ScenarioStepEditDialog extends StatefulWidget {
  const _ScenarioStepEditDialog({
    required this.step,
    this.isNew = false,
  });

  final ScenarioStep step;
  final bool isNew;

  @override
  State<_ScenarioStepEditDialog> createState() =>
      _ScenarioStepEditDialogState();
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
  late bool _verificationEnabled;
  double _thresholdPercent = 0.0;
  late final TextEditingController _timeoutController;
  late bool _continueOnFailure;

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
    _delayController = TextEditingController(text: step.stepDelayMs.toString());
    _verificationEnabled = step.verificationEnabled;
    _thresholdPercent = step.thresholdPercent.toDouble();
    _timeoutController = TextEditingController(text: (step.timeoutMs ~/ 1000).toString());
    _continueOnFailure = step.continueOnFailure;
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
    _timeoutController.dispose();
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
    final double threshold = _thresholdPercent;
    final timeoutSec = int.tryParse(_timeoutController.text.trim()) ?? 5;
    final timeoutMs = timeoutSec * 1000;

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
        verificationEnabled: _verificationEnabled,
        thresholdPercent: threshold.clamp(
          ScenarioStep.minThresholdPercent,
          ScenarioStep.maxThresholdPercent,
        ),
        timeoutMs: timeoutMs.clamp(
          ScenarioStep.minTimeoutMs,
          ScenarioStep.maxTimeoutMs,
        ),
        continueOnFailure: _continueOnFailure,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.isNew
          ? l10n.scenarioStepEditorAddStep
          : l10n.scenarioStepEditorEditTitle),
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
                            ScenarioStepType.swipe =>
                              l10n.scenarioStepTypeSwipe,
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
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.scenarioStepEditorVerificationLabel),
                subtitle: Text(l10n.scenarioStepEditorVerificationSubtitle),
                value: _verificationEnabled,
                onChanged: (value) =>
                    setState(() => _verificationEnabled = value),
              ),
              if (_verificationEnabled) ...[
                const SizedBox(height: 8),
                Text(l10n.scenarioStepEditorThresholdLabel),
                Slider(
                  min: 1.0,
                  max: 100.0,
                  divisions: 99,
                  value: _thresholdPercent.clamp(1.0, 100.0),
                  label: "${_thresholdPercent.round()}%",
                  onChanged: (value) => setState(() => _thresholdPercent = value),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    l10n.scenarioStepEditorThresholdCurrent(_thresholdPercent.toStringAsFixed(1)),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 16),
                _NumberField(
                  controller: _timeoutController,
                  label: l10n.scenarioStepEditorTimeoutLabel,
                  helperText: l10n.scenarioStepEditorTimeoutHelper,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l10n.scenarioStepEditorContinueOnFailure),
                  value: _continueOnFailure,
                  onChanged: (value) => setState(() => _continueOnFailure = value ?? false),
                ),
              ],

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
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
