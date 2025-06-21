/// Flutter Live Logger - Real-time logging solution for Flutter applications
///
/// A production-ready logging library that provides:
/// - Multiple transport layers (Memory, File, HTTP)
/// - Persistent storage with SQLite support
/// - Automatic screen navigation tracking
/// - Structured logging with metadata
/// - Offline support and retry mechanisms
/// - Configurable log levels and filtering
/// - High performance with batching
///
/// ## Quick Start
///
/// ```dart
/// // Initialize the logger
/// await FlutterLiveLogger.init(
///   config: LoggerConfig.development(
///     userId: 'user_123',
///     sessionId: 'session_456',
///   ),
/// );
///
/// // Log messages (full API)
/// FlutterLiveLogger.info('User action completed');
/// FlutterLiveLogger.error('Something went wrong', data: {'error': 'details'});
///
/// // Or use convenient shortcuts
/// FLL.info('User action completed');
/// FLL.error('Something went wrong', data: {'error': 'details'});
///
/// // Log custom events
/// FLL.event('button_click', {
///   'button_id': 'purchase',
///   'amount': 29.99,
/// });
/// ```
///
/// ## Navigator Tracking
///
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     FlutterLiveLoggerNavigatorObserver(),
///   ],
///   // ... rest of app
/// );
/// ```
///
/// ## Production Configuration
///
/// ```dart
/// await FLL.init(
///   config: LoggerConfig.production(
///     transports: [
///       HttpTransport(config: HttpTransportConfig(
///         endpoint: 'https://api.yourapp.com/logs',
///         apiKey: 'your-api-key',
///       )),
///       FileTransport(config: FileTransportConfig(
///         directory: '/path/to/logs',
///       )),
///     ],
///     usePersistentStorage: true,
///   ),
/// );
/// ```
library flutter_live_logger;

// Core exports
export 'src/core/flutter_live_logger.dart';
export 'src/core/log_entry.dart';
export 'src/core/log_level.dart';
export 'src/core/logger_config.dart';
export 'src/core/navigator_observer.dart';

// Storage exports
export 'src/storage/memory_storage.dart';
export 'src/storage/sqlite_storage.dart';
export 'src/storage/storage_interface.dart';

// Transport exports
export 'src/transport/file_transport.dart';
export 'src/transport/http_transport.dart';
export 'src/transport/log_transport.dart';
export 'src/transport/memory_transport.dart';

// Web Dashboard exports
export 'src/web_dashboard/dashboard_server.dart';
export 'src/web_dashboard/websocket_server.dart';
export 'src/web_dashboard/dashboard_database.dart';

// Convenience imports
import 'src/core/flutter_live_logger.dart';
import 'src/core/logger_config.dart';

/// Short alias for FlutterLiveLogger
///
/// Use this for a more convenient API:
/// ```dart
/// FLL.info('User logged in');
/// FLL.error('API call failed', error: e);
/// FLL.event('purchase_completed', {'amount': 29.99});
/// ```
class FLL {
  FLL._(); // Private constructor to prevent instantiation

  /// Initialize the logger with the given configuration
  static Future<void> init({required LoggerConfig config}) =>
      FlutterLiveLogger.init(config: config);

  /// Log an informational message
  static void info(String message, {Map<String, dynamic>? data}) =>
      FlutterLiveLogger.info(message, data: data);

  /// Log a debug message
  static void debug(String message, {Map<String, dynamic>? data}) =>
      FlutterLiveLogger.debug(message, data: data);

  /// Log a warning message
  static void warn(String message, {Map<String, dynamic>? data}) =>
      FlutterLiveLogger.warn(message, data: data);

  /// Log an error message
  static void error(String message,
          {Map<String, dynamic>? data,
          Object? error,
          StackTrace? stackTrace}) =>
      FlutterLiveLogger.error(message,
          data: data, error: error, stackTrace: stackTrace);

  /// Log a trace message
  static void trace(String message, {Map<String, dynamic>? data}) =>
      FlutterLiveLogger.trace(message, data: data);

  /// Log a fatal message
  static void fatal(String message,
          {Map<String, dynamic>? data,
          Object? error,
          StackTrace? stackTrace}) =>
      FlutterLiveLogger.fatal(message,
          data: data, error: error, stackTrace: stackTrace);

  /// Log a custom event
  static void event(String name, Map<String, dynamic> properties) =>
      FlutterLiveLogger.event(name, properties);

  /// Manually flush pending log entries
  static Future<void> flush() => FlutterLiveLogger.flush();

  /// Dispose of the logger and clean up resources
  static Future<void> dispose() => FlutterLiveLogger.dispose();

  /// Get logger statistics
  static Map<String, dynamic> getStats() => FlutterLiveLogger.getStats();

  /// Check if logger is initialized
  static bool get isInitialized => FlutterLiveLogger.isInitialized;
}

/// Alternative short alias for FlutterLiveLogger
///
/// Use this for a slightly longer but more descriptive API:
/// ```dart
/// FLLogger.info('User logged in');
/// FLLogger.error('API call failed', error: e);
/// FLLogger.event('purchase_completed', {'amount': 29.99});
/// ```
class FLLogger {
  FLLogger._(); // Private constructor to prevent instantiation

  /// Initialize the logger with the given configuration
  static Future<void> init({required LoggerConfig config}) =>
      FlutterLiveLogger.init(config: config);

  /// Log an informational message
  static void info(String message, {Map<String, dynamic>? data}) =>
      FlutterLiveLogger.info(message, data: data);

  /// Log a debug message
  static void debug(String message, {Map<String, dynamic>? data}) =>
      FlutterLiveLogger.debug(message, data: data);

  /// Log a warning message
  static void warn(String message, {Map<String, dynamic>? data}) =>
      FlutterLiveLogger.warn(message, data: data);

  /// Log an error message
  static void error(String message,
          {Map<String, dynamic>? data,
          Object? error,
          StackTrace? stackTrace}) =>
      FlutterLiveLogger.error(message,
          data: data, error: error, stackTrace: stackTrace);

  /// Log a trace message
  static void trace(String message, {Map<String, dynamic>? data}) =>
      FlutterLiveLogger.trace(message, data: data);

  /// Log a fatal message
  static void fatal(String message,
          {Map<String, dynamic>? data,
          Object? error,
          StackTrace? stackTrace}) =>
      FlutterLiveLogger.fatal(message,
          data: data, error: error, stackTrace: stackTrace);

  /// Log a custom event
  static void event(String name, Map<String, dynamic> properties) =>
      FlutterLiveLogger.event(name, properties);

  /// Manually flush pending log entries
  static Future<void> flush() => FlutterLiveLogger.flush();

  /// Dispose of the logger and clean up resources
  static Future<void> dispose() => FlutterLiveLogger.dispose();

  /// Get logger statistics
  static Map<String, dynamic> getStats() => FlutterLiveLogger.getStats();

  /// Check if logger is initialized
  static bool get isInitialized => FlutterLiveLogger.isInitialized;
}
