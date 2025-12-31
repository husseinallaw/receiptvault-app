import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Log levels for filtering
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Simple, reliable logger that outputs to Xcode console
///
/// Usage:
/// ```dart
/// Log.d('MyTag', 'Debug message');
/// Log.i('MyTag', 'Info message');
/// Log.w('MyTag', 'Warning message');
/// Log.e('MyTag', 'Error message', error, stackTrace);
/// ```
class Log {
  // Minimum level to log (set to debug to see everything)
  static LogLevel minLevel = LogLevel.debug;

  // Enable/disable logging entirely
  static bool enabled = true;

  /// Debug log - for development tracing
  static void d(String tag, String message) {
    _log(LogLevel.debug, tag, message);
  }

  /// Info log - for general information
  static void i(String tag, String message) {
    _log(LogLevel.info, tag, message);
  }

  /// Warning log - for potential issues
  static void w(String tag, String message) {
    _log(LogLevel.warning, tag, message);
  }

  /// Error log - for errors and exceptions
  static void e(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, tag, message, error, stackTrace);
  }

  /// Internal logging method
  static void _log(LogLevel level, String tag, String message, [Object? error, StackTrace? stackTrace]) {
    if (!enabled) return;
    if (level.index < minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final levelStr = _levelToString(level);
    final prefix = '[$levelStr][$tag]';

    // Format the message
    final fullMessage = '$prefix $message';

    // Use debugPrint which is guaranteed to work in Xcode console
    // It also handles long messages by splitting them
    debugPrint('$timestamp $fullMessage');

    if (error != null) {
      debugPrint('$timestamp $prefix Error: $error');
    }

    if (stackTrace != null) {
      debugPrint('$timestamp $prefix Stack trace:');
      // Print stack trace line by line to avoid truncation
      final lines = stackTrace.toString().split('\n').take(10);
      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          debugPrint('  $line');
        }
      }
    }

    // Also log to developer console for DevTools
    developer.log(
      message,
      time: DateTime.now(),
      level: _levelToInt(level),
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _levelToString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  static int _levelToInt(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}

/// Common log tags used throughout the app
class LogTags {
  static const String app = 'APP';
  static const String auth = 'AUTH';
  static const String db = 'DB';
  static const String scanner = 'SCANNER';
  static const String receipt = 'RECEIPT';
  static const String ocr = 'OCR';
  static const String sync = 'SYNC';
  static const String network = 'NETWORK';
  static const String storage = 'STORAGE';
  static const String ui = 'UI';
}
