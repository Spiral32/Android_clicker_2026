import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  void logInfo(String tag, String message, {Object? payload}) {
    developer.log(
      message,
      name: tag,
      error: payload,
      level: 800,
    );
  }

  void logError(
    String tag,
    Object error,
    StackTrace? stackTrace, {
    String? context,
  }) {
    developer.log(
      context ?? error.toString(),
      name: tag,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );

    if (kDebugMode) {
      debugPrint('[$tag] $error');
      if (stackTrace != null) {
        debugPrintStack(stackTrace: stackTrace);
      }
    }
  }
}
