import 'package:equatable/equatable.dart';

enum AppStateValue {
  idle,
  recording,
  executing,
  paused,
  error,
}

class AppState extends Equatable {
  const AppState({
    required this.state,
    required this.description,
    required this.canRecord,
    required this.canExecute,
    required this.canPause,
    required this.canResume,
    required this.canReset,
  });

  const AppState.initial()
      : state = AppStateValue.idle,
        description = 'Ready',
        canRecord = true,
        canExecute = true,
        canPause = false,
        canResume = false,
        canReset = false;

  factory AppState.fromMap(Map<String, dynamic> map) {
    final stateString = map['state'] as String? ?? 'IDLE';
    return AppState(
      state: _parseState(stateString),
      description: map['description'] as String? ?? 'Unknown',
      canRecord: map['canRecord'] as bool? ?? false,
      canExecute: map['canExecute'] as bool? ?? false,
      canPause: map['canPause'] as bool? ?? false,
      canResume: map['canResume'] as bool? ?? false,
      canReset: map['canReset'] as bool? ?? false,
    );
  }

  final AppStateValue state;
  final String description;
  final bool canRecord;
  final bool canExecute;
  final bool canPause;
  final bool canResume;
  final bool canReset;

  bool get isIdle => state == AppStateValue.idle;
  bool get isRecording => state == AppStateValue.recording;
  bool get isExecuting => state == AppStateValue.executing;
  bool get isPaused => state == AppStateValue.paused;
  bool get isError => state == AppStateValue.error;

  static AppStateValue _parseState(String value) {
    switch (value) {
      case 'RECORDING':
        return AppStateValue.recording;
      case 'EXECUTING':
        return AppStateValue.executing;
      case 'PAUSED':
        return AppStateValue.paused;
      case 'ERROR':
        return AppStateValue.error;
      case 'IDLE':
      default:
        return AppStateValue.idle;
    }
  }

  @override
  List<Object?> get props => [
        state,
        description,
        canRecord,
        canExecute,
        canPause,
        canResume,
        canReset,
      ];
}
