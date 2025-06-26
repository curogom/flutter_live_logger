import 'dart:async';
import 'dart:collection';

import 'package:flutter_live_logger/src/core/log_entry.dart';
import 'package:flutter_live_logger/src/core/log_level.dart';
import 'package:flutter_live_logger/src/core/logger_config.dart';
import 'package:flutter_live_logger/src/storage/sqlite_storage.dart';
import 'package:flutter_live_logger/src/storage/storage_interface.dart';
import 'package:flutter_live_logger/src/transport/log_transport.dart';
import 'package:flutter_live_logger/src/transport/memory_transport.dart';

/// Main Flutter Live Logger class
///
/// This is the primary entry point for all logging functionality.
/// Initialize once at app startup and use static methods for logging.
class FlutterLiveLogger {
  FlutterLiveLogger._();

  static LoggerConfig? _config;
  static List<LogTransport>? _transports;
  static LogStorage? _storage;

  // Batching and queue management
  static final Queue<LogEntry> _pendingEntries = Queue<LogEntry>();
  static Timer? _flushTimer;
  static bool _isDisposed = false;

  // Performance optimization: Cache frequently accessed values
  static LogLevel? _cachedLogLevel;
  static bool _isInitialized = false;

  /// Quick start with automatic configuration
  static Future<void> start() async {
    await init(config: LoggerConfig.development());
  }

  /// Start with development configuration
  static Future<void> startDevelopment() async {
    await init(config: LoggerConfig.development());
  }

  /// Start with production configuration
  static Future<void> startProduction() async {
    await init(
        config: LoggerConfig.production(
      transports: [MemoryTransport(maxEntries: 10000)],
      userId: null,
      sessionId: null,
    ));
  }

  /// Initialize the logger with the given configuration
  static Future<void> init({required LoggerConfig config}) async {
    _config = config;
    _transports = config.effectiveTransports;
    _storage = config.effectiveStorage;
    _isDisposed = false;
    _isInitialized = true;

    // Cache log level for performance
    _cachedLogLevel = config.logLevel;

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
        // In production, avoid print statements
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

  /// Log a trace message
  static void trace(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.trace, message, data: data);
  }

  /// Log a warning message
  static void warn(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.warn, message, data: data);
  }

  /// Log an error message
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.error, message,
        error: error, stackTrace: stackTrace, data: data);
  }

  /// Log a fatal error message
  static void fatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _log(LogLevel.fatal, message,
        error: error, stackTrace: stackTrace, data: data);
  }

  /// Log a custom event with structured data
  static void event(String eventName, Map<String, dynamic> data) {
    _log(LogLevel.info, 'Event: $eventName', data: data);
  }

  /// Internal logging method with performance optimizations
  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    // Performance optimization: Early return if not initialized or disposed
    if (!_isInitialized || _isDisposed) return;

    // Performance optimization: Early level filtering using cached value
    if (_cachedLogLevel != null && level.index < _cachedLogLevel!.index) {
      return;
    }

    final config = _config;
    if (config == null) return;

    // Performance optimization: Avoid expensive operations for filtered logs
    if (level.index < config.logLevel.index) return;

    final entry = LogEntry(
      message: message,
      level: level,
      timestamp: DateTime.now(),
      userId: config.userId,
      sessionId: config.sessionId,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );

    // Performance optimization: Add to queue without immediate processing
    _pendingEntries.add(entry);

    // Performance optimization: Only flush if queue is full (avoid frequent I/O)
    if (_pendingEntries.length >= config.batchSize) {
      unawaited(_flushBatch());
    }
  }

  /// Start the periodic flush timer
  static void _startFlushTimer() {
    final config = _config;
    if (config == null) return;

    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(config.flushInterval, (_) {
      if (_pendingEntries.isNotEmpty) {
        unawaited(_flushBatch());
      }
    });
  }

  /// Flush pending entries to transports
  static Future<void> _flushBatch() async {
    if (_pendingEntries.isEmpty || _isDisposed) return;

    // Performance optimization: Process batch without blocking
    final batch = <LogEntry>[];
    final batchSize = _config?.batchSize ?? 10;

    // Take up to batchSize entries
    while (batch.length < batchSize && _pendingEntries.isNotEmpty) {
      batch.add(_pendingEntries.removeFirst());
    }

    if (batch.isEmpty) return;

    final transports = _transports;
    if (transports == null || transports.isEmpty) return;

    // Track transport success/failure for offline support
    bool anyTransportSucceeded = false;

    // Performance optimization: Send to all transports in parallel
    final futures = <Future<bool>>[];
    for (final transport in transports) {
      futures.add(_sendToTransportWithResult(transport, batch));
    }

    try {
      final results = await Future.wait(futures);
      anyTransportSucceeded = results.any((success) => success);
    } catch (e) {
      // If Future.wait fails, no transport succeeded
      anyTransportSucceeded = false;
    }

    // Store in offline storage if all transports failed and offline support is enabled
    if (!anyTransportSucceeded &&
        _config?.enableOfflineSupport == true &&
        _storage != null) {
      try {
        await _storage!.store(batch);
      } catch (storageError) {
        // Silent failure - don't crash the app
      }
    }
  }

  /// Send batch to a specific transport with success/failure tracking
  static Future<bool> _sendToTransportWithResult(
    LogTransport transport,
    List<LogEntry> batch,
  ) async {
    try {
      await transport.send(batch);
      return true; // Success
    } catch (e) {
      // Performance optimization: Silent failure for individual transports
      // This prevents one failing transport from affecting others
      return false; // Failure
    }
  }

  /// Manually flush all pending entries
  static Future<void> flush() async {
    if (_isDisposed || !_isInitialized) return;

    // Safety: Limit flush attempts to prevent infinite loops
    int maxAttempts = 10;
    int attempts = 0;

    while (_pendingEntries.isNotEmpty && attempts < maxAttempts) {
      final initialCount = _pendingEntries.length;
      await _flushBatch();

      // If no progress was made, break to avoid infinite loop
      if (_pendingEntries.length >= initialCount) {
        break;
      }

      attempts++;
    }
  }

  /// Retry offline entries
  static Future<void> _retryOfflineEntries() async {
    final storage = _storage;
    if (storage == null) return;

    try {
      final offlineEntries = await storage.query(LogQuery.recent(limit: 100));
      if (offlineEntries.isNotEmpty) {
        final transports = _transports ?? [];
        for (final transport in transports) {
          try {
            await transport.send(offlineEntries);
            // If successful, remove from storage
            await storage.delete(LogQuery.recent(limit: offlineEntries.length));
            break; // Success with one transport is enough
          } catch (e) {
            // Try next transport
            continue;
          }
        }
      }
    } catch (e) {
      // Ignore errors during offline retry
    }
  }

  /// Dispose of the logger and clean up resources
  static Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;
    _isInitialized = false;

    // Flush any remaining entries
    await flush();

    // Cancel timer
    _flushTimer?.cancel();
    _flushTimer = null;

    // Dispose transports
    final transports = _transports;
    if (transports != null) {
      for (final transport in transports) {
        try {
          await transport.dispose();
        } catch (e) {
          // Ignore disposal errors
        }
      }
    }

    // Dispose storage
    try {
      await _storage?.dispose();
    } catch (e) {
      // Ignore disposal errors
    }

    // Clear state
    _config = null;
    _transports = null;
    _storage = null;
    _cachedLogLevel = null;
    _pendingEntries.clear();
  }

  /// Get logger statistics for monitoring and debugging
  static Map<String, dynamic> getStats() {
    return {
      'isInitialized': _isInitialized && !_isDisposed,
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
  static bool get isInitialized => _isInitialized && !_isDisposed;
}

/// Helper to avoid unawaited future warnings
void unawaited(Future<void> future) {
  // Intentionally ignore the future
}
