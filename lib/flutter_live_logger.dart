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
/// // Log messages
/// FlutterLiveLogger.info('User action completed');
/// FlutterLiveLogger.error('Something went wrong', data: {'error': 'details'});
///
/// // Log custom events
/// FlutterLiveLogger.event('button_click', {
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
/// await FlutterLiveLogger.init(
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
