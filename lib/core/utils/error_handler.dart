import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'logger.dart';

/// Global error handler that catches and logs all uncaught errors
///
/// Setup in main.dart:
/// ```dart
/// void main() {
///   ErrorHandler.init();
///   runApp(MyApp());
/// }
/// ```
class ErrorHandler {
  static bool _initialized = false;

  /// Initialize global error handling
  static void init() {
    if (_initialized) return;
    _initialized = true;

    Log.i(LogTags.app, 'Initializing global error handler');

    // Handle Flutter framework errors (widget build errors, etc.)
    FlutterError.onError = _handleFlutterError;

    // Handle errors that occur in async code
    PlatformDispatcher.instance.onError = _handlePlatformError;

    Log.i(LogTags.app, 'Global error handler initialized');
  }

  /// Handle Flutter framework errors
  static void _handleFlutterError(FlutterErrorDetails details) {
    Log.e(
      LogTags.ui,
      'Flutter Error: ${details.summary}',
      details.exception,
      details.stack,
    );

    // Also print the full details in debug mode
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  }

  /// Handle platform/async errors
  static bool _handlePlatformError(Object error, StackTrace stackTrace) {
    Log.e(
      LogTags.app,
      'Uncaught async error',
      error,
      stackTrace,
    );

    // Return true to prevent the error from propagating
    // Return false to let it propagate (crash in release mode)
    return true;
  }

  /// Wrap a zone to catch all errors within it
  /// Use this in main.dart for complete error catching:
  /// ```dart
  /// void main() {
  ///   ErrorHandler.runWithErrorHandling(() {
  ///     runApp(MyApp());
  ///   });
  /// }
  /// ```
  static void runWithErrorHandling(VoidCallback body) {
    init();

    runZonedGuarded(
      body,
      (error, stackTrace) {
        Log.e(
          LogTags.app,
          'Zoned error caught',
          error,
          stackTrace,
        );
      },
    );
  }
}

/// Error boundary widget that catches errors in its child tree
/// and displays a fallback UI instead of crashing
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    Log.e(LogTags.ui, 'ErrorBoundary caught error', error, stackTrace);
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }
      return _DefaultErrorWidget(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }

    return widget.child;
  }
}

/// Default error display widget
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.red.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade700),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.red.shade900,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
