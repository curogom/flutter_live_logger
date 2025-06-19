import 'dart:async';
import 'dart:collection';
import 'log_level.dart';
import 'log_entry.dart';
import 'logger_config.dart';
import '../transport/log_transport.dart';
import '../storage/storage_interface.dart';
import '../storage/sqlite_storage.dart';

/// Main Flutter Live Logger class
///
/// This is the primary entry point for all logging functionality.
/// Initialize once at app startup and use static methods for logging.
class FlutterLiveLogger {
  FlutterLiveLogger._();

  static FlutterLiveLogger? _instance;
  static LoggerConfig? _config;
  static List<LogTransport>? _transports;
  static LogStorage? _storage;

  // Batching and queue management
  static final Queue<LogEntry> _pendingEntries = Queue<LogEntry>();
  static Timer? _flushTimer;
  static bool _isDisposed = false;

  /// Initialize the logger with the given configuration
  static Future<void> init({required LoggerConfig config}) async {
    _config = config;
    _instance = FlutterLiveLogger._();
    _transports = config.effectiveTransports;
    _storage = config.effectiveStorage;
    _isDisposed = false;

    // Initialize SQLite storage if needed
    if (_storage is SQLiteStorage) {
      await (_storage as SQLiteStorage).initialize();
    }

    // Start periodic flush timer
    _startFlushTimer();

    // Initialize storage if offline support is enabled
    if (config.enableOfflineSupport) {
      try {
        // Attempt to send any previously stored offline entries
        await _retryOfflineEntries();
      } catch (e) {
        // Ignore errors during offline retry
      }
    }
  }

  /// Log an informational message
  static void info(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, data: data);
  }

  /// Log a debug message
  static void debug(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.debug, message, data: data);
  }

  /// Log a warning message
  static void warn(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.warn, message, data: data);
  }

  /// Log an error message
  static void error(String message,
      {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message,
        data: data, error: error, stackTrace: stackTrace);
  }

  /// Log a trace message
  static void trace(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.trace, message, data: data);
  }

  /// Log a fatal message
  static void fatal(String message,
      {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message,
        data: data, error: error, stackTrace: stackTrace);
  }

  /// Log a custom event
  static void event(String name, Map<String, dynamic> properties) {
    _log(LogLevel.info, 'Event: $name', data: properties);
  }

  /// Manually flush pending log entries
  static Future<void> flush() async {
    if (_isDisposed || _config == null) return;

    try {
      await _processPendingEntries();
    } catch (e) {
      // Log internal errors to avoid infinite recursion
      print('FlutterLiveLogger: Failed to flush entries: $e');
    }
  }

  /// Dispose of the logger and clean up resources
  static Future<void> dispose() async {
    _isDisposed = true;
    _flushTimer?.cancel();
    _flushTimer = null;

    // Flush any remaining entries
    await flush();

    // Dispose of transports and storage
    if (_transports != null) {
      await Future.wait(_transports!.map((t) => t.dispose()));
      _transports = null;
    }

    if (_storage != null) {
      await _storage!.dispose();
      _storage = null;
    }

    _pendingEntries.clear();
    _config = null;
    _instance = null;
  }

  static void _log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_isDisposed ||
        _config == null ||
        !level.isEnabledFor(_config!.logLevel)) {
      return;
    }

    final entry = LogEntry(
      message: message,
      level: level,
      timestamp: DateTime.now(),
      data: data,
      error: error,
      stackTrace: stackTrace,
      userId: _config!.userId,
      sessionId: _config!.sessionId,
    );

    // Add to pending queue
    _pendingEntries.add(entry);

    // Auto-flush for high priority levels
    if (level == LogLevel.fatal || level == LogLevel.error) {
      unawaited(flush());
    } else if (_pendingEntries.length >= _config!.batchSize) {
      // Flush when batch size is reached
      unawaited(flush());
    }

    // Fallback console output for development
    if (_config!.environment == 'development') {
      print('[${level.name.toUpperCase()}] $message');
      if (data != null) print('  Data: $data');
      if (error != null) print('  Error: $error');
    }
  }

  static void _startFlushTimer() {
    _flushTimer?.cancel();
    if (_config != null && !_isDisposed) {
      _flushTimer = Timer.periodic(_config!.flushInterval, (_) {
        unawaited(flush());
      });
    }
  }

  static Future<void> _processPendingEntries() async {
    if (_pendingEntries.isEmpty || _transports == null) return;

    final entries = List<LogEntry>.from(_pendingEntries);
    _pendingEntries.clear();

    // Try to send through transports
    var success = false;
    for (final transport in _transports!) {
      if (!transport.isAvailable) continue;

      try {
        await transport.send(entries);
        success = true;
        break; // Successfully sent through at least one transport
      } catch (e) {
        // Continue trying other transports
        continue;
      }
    }

    // Store offline if all transports failed and offline support is enabled
    if (!success &&
        _config!.enableOfflineSupport &&
        _storage != null &&
        _storage!.isAvailable) {
      try {
        await _storage!.store(entries);
      } catch (e) {
        // Log storage failure but don't crash
        print('FlutterLiveLogger: Failed to store entries offline: $e');
      }
    }
  }

  static Future<void> _retryOfflineEntries() async {
    if (_storage == null || !_storage!.isAvailable) return;

    try {
      final offlineEntries =
          await _storage!.query(LogQuery.recent(limit: 1000));
      if (offlineEntries.isNotEmpty) {
        // Try to send offline entries
        var success = false;
        for (final transport in _transports!) {
          if (!transport.isAvailable) continue;

          try {
            await transport.send(offlineEntries);
            success = true;
            break;
          } catch (e) {
            continue;
          }
        }

        // Clear offline entries if successfully sent
        if (success) {
          await _storage!.clear();
        }
      }
    } catch (e) {
      // Ignore retry failures
    }
  }

  /// Get logger statistics
  static Map<String, dynamic> getStats() {
    return {
      'isInitialized': _instance != null,
      'pendingEntries': _pendingEntries.length,
      'transports': _transports?.length ?? 0,
      'hasStorage': _storage != null,
      'config': _config != null
          ? {
              'logLevel': _config!.logLevel.name.toLowerCase(),
              'environment': _config!.environment,
              'batchSize': _config!.batchSize,
              'flushInterval': _config!.flushInterval.inSeconds,
              'offlineSupport': _config!.enableOfflineSupport,
            }
          : null,
    };
  }

  /// Check if logger is initialized
  static bool get isInitialized => _instance != null && !_isDisposed;
}

/// Helper to avoid unawaited future warnings
void unawaited(Future<void> future) {
  // Intentionally ignore the future
}
