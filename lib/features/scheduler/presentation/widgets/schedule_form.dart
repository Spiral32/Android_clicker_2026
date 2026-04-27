import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:prog_set_touch/core/localization/localization_extensions.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_item.dart';
import 'package:prog_set_touch/features/scenario/domain/scenario_repository.dart';
import 'package:prog_set_touch/features/scheduler/domain/schedule.dart';

class ScheduleForm extends StatefulWidget {
  const ScheduleForm({
    super.key,
    this.schedule,
  });

  final Schedule? schedule;

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late ScheduleType _type;
  late int _hour;
  late int _minute;
  List<int> _daysOfWeek = [];
  int? _dateTimestamp;
  String _scenarioId = '';
  List<ScenarioItem> _scenarios = const [];
  bool _isLoadingScenarios = true;

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    if (schedule != null) {
      _nameController = TextEditingController(text: schedule.name);
      _type = schedule.type;
      _hour = schedule.hour;
      _minute = schedule.minute;
      _daysOfWeek = schedule.daysOfWeek ?? [];
      _dateTimestamp = schedule.dateTimestamp;
      _scenarioId = schedule.scenarioId;
    } else {
      _nameController = TextEditingController();
      _type = ScheduleType.daily;
      final now = DateTime.now();
      _hour = now.hour;
      _minute = now.minute;
    }
    _loadScenarios();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadScenarios() async {
    try {
      final scenarios = await context.read<ScenarioRepository>().getAll();
      if (!mounted) {
        return;
      }
      setState(() {
        _scenarios = [...scenarios]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        if (_scenarioId.isEmpty && _scenarios.isNotEmpty) {
          _scenarioId = _scenarios.first.id;
        }
        _isLoadingScenarios = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _scenarios = const [];
        _isLoadingScenarios = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedInList =
        _scenarios.any((scenario) => scenario.id == _scenarioId);
    final dropdownItems = [
      ..._scenarios.map(
        (item) => DropdownMenuItem<String>(
          value: item.id,
          child: Text(item.name, overflow: TextOverflow.ellipsis),
        ),
      ),
      if (_scenarioId.isNotEmpty && !hasSelectedInList)
        DropdownMenuItem<String>(
          value: '__missing_scenario__',
          child: Text(context.l10n.scheduleScenarioMissing),
        ),
    ];
    final dropdownValue = _scenarioId.isEmpty
        ? null
        : (hasSelectedInList ? _scenarioId : '__missing_scenario__');

    return AlertDialog(
      title: Text(widget.schedule == null
          ? context.l10n.addScheduleTitle
          : context.l10n.editScheduleTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.scheduleNameLabel,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return context.l10n.scheduleNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ScheduleType>(
                value: _type,
                decoration: InputDecoration(
                  labelText: context.l10n.scheduleTypeLabel,
                ),
                items: ScheduleType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeDisplayName(context, type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _type = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: dropdownValue,
                decoration: InputDecoration(
                  labelText: context.l10n.scheduleScenarioLabel,
                ),
                items: dropdownItems,
                onChanged: _isLoadingScenarios
                    ? null
                    : (value) {
                        if (value == null || value == '__missing_scenario__') {
                          return;
                        }
                        setState(() {
                          _scenarioId = value;
                        });
                      },
                validator: (_) {
                  if (_isLoadingScenarios) {
                    return null;
                  }
                  if (_scenarios.isEmpty) {
                    return context.l10n.scheduleScenarioRequiredToCreate;
                  }
                  if (_scenarioId.isEmpty || !hasSelectedInList) {
                    return context.l10n.scheduleScenarioRequired;
                  }
                  return null;
                },
              ),
              if (_isLoadingScenarios) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(minHeight: 2),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _hour.toString(),
                      decoration: InputDecoration(
                        labelText: context.l10n.hourLabel,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final hour = int.tryParse(value ?? '');
                        if (hour == null || hour < 0 || hour > 23) {
                          return context.l10n.invalidHour;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _hour = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _minute.toString(),
                      decoration: InputDecoration(
                        labelText: context.l10n.minuteLabel,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final minute = int.tryParse(value ?? '');
                        if (minute == null || minute < 0 || minute > 59) {
                          return context.l10n.invalidMinute;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _minute = int.parse(value!);
                      },
                    ),
                  ),
                ],
              ),
              if (_type == ScheduleType.weekly) ...[
                const SizedBox(height: 16),
                Text(context.l10n.daysOfWeekLabel),
                Wrap(
                  spacing: 8,
                  children: List.generate(7, (index) {
                    final day = index;
                    final isSelected = _daysOfWeek.contains(day);
                    return FilterChip(
                      label: Text(_getDayName(context, day)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _daysOfWeek.add(day);
                          } else {
                            _daysOfWeek.remove(day);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _save,
          child: Text(context.l10n.save),
        ),
      ],
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final schedule = Schedule(
        id: widget.schedule?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _type,
        hour: _hour,
        minute: _minute,
        daysOfWeek: _type == ScheduleType.weekly ? _daysOfWeek : null,
        dateTimestamp: _type == ScheduleType.oneTime ? _dateTimestamp : null,
        scenarioId: _scenarioId,
        isActive: widget.schedule?.isActive ?? true,
        createdAt:
            widget.schedule?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );

      Navigator.of(context).pop(schedule);
    }
  }

  String _getTypeDisplayName(BuildContext context, ScheduleType type) {
    return switch (type) {
      ScheduleType.oneTime => context.l10n.scheduleTypeOneTime,
      ScheduleType.daily => context.l10n.scheduleTypeDaily,
      ScheduleType.weekly => context.l10n.scheduleTypeWeekly,
    };
  }

  String _getDayName(BuildContext context, int day) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dayNames[day];
  }
}
