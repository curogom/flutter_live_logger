# Flutter Live Logger API Documentation

> **📋 Status**: Complete Implementation Available  
> **🎯 Purpose**: Complete API reference for production-ready Flutter Live Logger

## 📚 API Documentation Structure

### 1. Core Classes

#### `FlutterLiveLogger`

Main logger class - Entry point for all logging functionality

```dart
/// Main class for Flutter Live Logger
/// 
/// Provides a comprehensive logging API with multiple transport layers,
/// storage options, and automatic navigation tracking.
/// 
/// Example:
/// ```dart
/// await FlutterLiveLogger.init(
///   config: LoggerConfig.development(
///     userId: 'user_123',
///     sessionId: 'session_456',
///   ),
/// );
/// 
/// FlutterLiveLogger.info('User logged in', data: {
///   'userId': user.id,
///   'timestamp': DateTime.now().toIso8601String(),
/// });
/// ```
class FlutterLiveLogger {
  /// Initialize the logger with configuration
  static Future<void> init({required LoggerConfig config});
  
  /// Log trace level messages
  static void trace(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace});
  
  /// Log debug level messages
  static void debug(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace});
  
  /// Log info level messages
  static void info(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace});
  
  /// Log warning level messages
  static void warning(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace});
  
  /// Log error level messages
  static void error(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace});
  
  /// Log fatal level messages
  static void fatal(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace});
  
  /// Log custom events with structured data
  static void event(String event, Map<String, dynamic> data);
  
  /// Force flush all pending logs
  static Future<void> flush();
  
  /// Get logger statistics
  static Map<String, dynamic> getStats();
  
  /// Clean up logger resources
  static Future<void> dispose();
}
```

#### `LoggerConfig`

Configuration class for logger behavior with environment-specific presets

```dart
/// Configuration class for logger behavior
/// 
/// Provides environment-specific configurations and customization options.
class LoggerConfig {
  /// Development configuration with debug features
  factory LoggerConfig.development({
    String? userId,
    String? sessionId,
    LogLevel logLevel = LogLevel.debug,
  });
  
  /// Production configuration optimized for performance
  factory LoggerConfig.production({
    required List<LogTransport> transports,
    bool usePersistentStorage = true,
    LogLevel logLevel = LogLevel.info,
    String? userId,
    String? sessionId,
  });
  
  /// Performance testing configuration
  factory LoggerConfig.performance({
    LogLevel logLevel = LogLevel.warn,
  });
  
  /// Testing configuration with maximum verbosity
  factory LoggerConfig.testing({
    LogLevel logLevel = LogLevel.trace,
  });
  
  /// Create copy with modified parameters
  LoggerConfig copyWith({
    LogLevel? logLevel,
    List<LogTransport>? transports,
    LogStorage? storage,
    String? userId,
    String? sessionId,
    String? environment,
    bool? usePersistentStorage,
    int? batchSize,
    Duration? flushInterval,
  });
}
```

#### `LogEntry`

Immutable data class representing individual log entries

```dart
/// Immutable class representing a single log entry
/// 
/// Contains all information about a log event including metadata.
@immutable
class LogEntry {
  const LogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
    this.data,
    this.error,
    this.stackTrace,
    this.userId,
    this.sessionId,
  });
  
  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? data;
  final String? error;
  final String? stackTrace;
  final String? userId;
  final String? sessionId;
  
  /// Convert to JSON representation
  Map<String, dynamic> toJson();
  
  /// Create from JSON representation
  factory LogEntry.fromJson(Map<String, dynamic> json);
}
```

### 2. Log Levels

```dart
/// Enumeration representing log severity levels
enum LogLevel {
  /// Trace level - Very detailed debugging information
  trace,
  
  /// Debug level - Useful information during development
  debug,
  
  /// Info level - General application flow
  info,
  
  /// Warning level - Situations requiring attention
  warn,
  
  /// Error level - Error situations but app continues running
  error,
  
  /// Fatal level - Critical errors that may cause app termination
  fatal,
  
  /// Off level - Disable all logging
  off,
}
```

### 3. Transport System

#### `LogTransport` (Abstract Class)

Base interface for log transmission to destinations

```dart
/// Abstract base class for log transmission
/// 
/// Foundation of plugin architecture supporting various transport methods.
abstract class LogTransport {
  /// Send batch of log entries
  Future<void> send(List<LogEntry> entries);
  
  /// Check if transport is available
  bool get isAvailable;
  
  /// Clean up transport resources
  Future<void> dispose();
}
```

#### Available Transport Implementations

##### `MemoryTransport`

In-memory storage for development and testing

```dart
class MemoryTransport extends LogTransport {
  MemoryTransport({this.maxEntries = 1000});
  
  final int maxEntries;
  
  /// Get stored entries
  List<LogEntry> get entries;
  
  /// Clear all entries
  void clear();
}
```

##### `FileTransport`

Local file storage with rotation support

```dart
class FileTransport extends LogTransport {
  FileTransport({required this.config});
  
  final FileTransportConfig config;
}

class FileTransportConfig {
  const FileTransportConfig({
    required this.directory,
    this.filePrefix = 'app_log',
    this.maxFileSize = 10 * 1024 * 1024, // 10MB
    this.maxFiles = 5,
    this.enableRotation = true,
  });
}
```

##### `HttpTransport`

HTTP-based remote logging

```dart
class HttpTransport extends LogTransport {
  HttpTransport({required this.config});
  
  final HttpTransportConfig config;
}

class HttpTransportConfig {
  const HttpTransportConfig({
    required this.endpoint,
    required this.apiKey,
    this.headers = const {},
    this.enableCompression = true,
    this.retryAttempts = 3,
    this.timeout = const Duration(seconds: 30),
    this.batchSize = 50,
  });
}
```

### 4. Storage System

#### `LogStorage` (Abstract Class)

Base interface for log storage and querying

```dart
/// Abstract base class for log storage
abstract class LogStorage {
  /// Store log entries
  Future<void> store(List<LogEntry> entries);
  
  /// Query stored logs
  Future<List<LogEntry>> query(LogQuery query);
  
  /// Delete logs matching query
  Future<int> delete(LogQuery query);
  
  /// Get storage statistics
  Future<Map<String, dynamic>> getStats();
  
  /// Clean up storage resources
  Future<void> dispose();
}
```

#### Available Storage Implementations

##### `MemoryStorage`

Fast in-memory storage

```dart
class MemoryStorage extends LogStorage {
  MemoryStorage({this.maxEntries = 10000});
  
  final int maxEntries;
}
```

##### `SQLiteStorage`

Persistent SQLite-based storage with indexing

```dart
class SQLiteStorage extends LogStorage {
  SQLiteStorage({this.config = const SQLiteStorageConfig()});
  
  final SQLiteStorageConfig config;
}

class SQLiteStorageConfig {
  const SQLiteStorageConfig({
    this.databaseName = 'flutter_live_logger.db',
    this.maxEntries = 100000,
    this.enableWAL = true,
  });
}
```

#### `LogQuery`

Query builder for log retrieval

```dart
class LogQuery {
  /// Get recent logs
  factory LogQuery.recent({int limit = 100});
  
  /// Get logs by level
  factory LogQuery.level({required LogLevel level, int? limit});
  
  /// Get logs by user
  factory LogQuery.user({required String userId, int? limit});
  
  /// Get logs by session
  factory LogQuery.session({required String sessionId, int? limit});
  
  /// Get logs in time range
  factory LogQuery.timeRange({
    required DateTime start,
    required DateTime end,
    int? limit,
  });
}
```

### 5. Navigation Tracking

#### `FlutterLiveLoggerNavigatorObserver`

Observer for automatic screen tracking

```dart
/// Observer that automatically tracks Flutter navigation
/// 
/// Add to MaterialApp's navigatorObservers to automatically
/// log screen transitions with timing information.
class FlutterLiveLoggerNavigatorObserver extends NavigatorObserver {
  FlutterLiveLoggerNavigatorObserver({
    this.enableDurationTracking = true,
    this.enableBreadcrumbs = true,
    this.maxBreadcrumbs = 10,
    this.routeNameExtractor,
    this.shouldLogRoute,
  });
  
  final bool enableDurationTracking;
  final bool enableBreadcrumbs;
  final int maxBreadcrumbs;
  final String Function(Route route)? routeNameExtractor;
  final bool Function(Route route)? shouldLogRoute;
  
  /// Get current navigation breadcrumbs
  List<String> get breadcrumbs;
  
  /// Get current route timing statistics
  Map<String, dynamic> get routeStats;
  
  /// Clear tracking data
  void clearTrackingData();
}
```

## 🎯 Usage Patterns

### Environment-Specific Setup

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  late LoggerConfig config;
  
  if (kDebugMode) {
    // Development setup
    config = LoggerConfig.development(
      userId: 'dev_user_123',
      sessionId: 'dev_session_${DateTime.now().millisecondsSinceEpoch}',
    );
  } else {
    // Production setup
    config = LoggerConfig.production(
      transports: [
        HttpTransport(config: HttpTransportConfig(
          endpoint: 'https://api.myapp.com/logs',
          apiKey: const String.fromEnvironment('LOG_API_KEY'),
        )),
        FileTransport(config: FileTransportConfig(
          directory: '/app/logs',
          maxFileSize: 10 * 1024 * 1024,
          maxFiles: 5,
        )),
      ],
      usePersistentStorage: true,
      userId: await getUserId(),
      sessionId: generateSessionId(),
    );
  }
  
  await FlutterLiveLogger.init(config: config);
  runApp(MyApp());
}
```

### Comprehensive Logging Examples

```dart
class UserService {
  Future<User> login(String email) async {
    FlutterLiveLogger.info('User login attempt', data: {
      'email': email,
      'timestamp': DateTime.now().toIso8601String(),
      'device': Platform.operatingSystem,
    });
    
    try {
      final user = await _authService.login(email);
      
      FlutterLiveLogger.event('user_login_success', {
        'user_id': user.id,
        'email': user.email,
        'login_method': 'email_password',
        'session_duration': null, // Will be updated on logout
      });
      
      return user;
    } catch (error, stackTrace) {
      FlutterLiveLogger.error(
        'Login failed',
        data: {
          'email': email,
          'error_type': error.runtimeType.toString(),
        },
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  Future<void> logout() async {
    FlutterLiveLogger.event('user_logout', {
      'user_id': _currentUser?.id,
      'session_duration': _sessionDuration.inSeconds,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

### Performance Monitoring

```dart
class ApiService {
  Future<T> makeRequest<T>(String endpoint) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await _client.get(endpoint);
      stopwatch.stop();
      
      FlutterLiveLogger.event('api_request_success', {
        'endpoint': endpoint,
        'duration_ms': stopwatch.elapsedMilliseconds,
        'status_code': response.statusCode,
        'response_size': response.data?.toString().length ?? 0,
      });
      
      return response.data;
    } catch (error) {
      stopwatch.stop();
      
      FlutterLiveLogger.error(
        'API request failed',
        data: {
          'endpoint': endpoint,
          'duration_ms': stopwatch.elapsedMilliseconds,
          'error_type': error.runtimeType.toString(),
        },
        error: error,
      );
      rethrow;
    }
  }
}
```

### Error Handling and Crash Reporting

```dart
void setupGlobalErrorHandling() {
  // Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterLiveLogger.fatal(
      'Flutter framework error',
      data: {
        'library': details.library,
        'context': details.context?.toString(),
        'error_summary': details.exceptionAsString(),
      },
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  
  // Dart VM errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FlutterLiveLogger.fatal(
      'Uncaught Dart error',
      error: error,
      stackTrace: stack,
    );
    return true;
  };
}
```

### Custom Transport Implementation

```dart
class CustomCloudTransport extends LogTransport {
  CustomCloudTransport({required this.config});
  
  final CustomCloudConfig config;
  
  @override
  Future<void> send(List<LogEntry> entries) async {
    final batch = entries.map((e) => e.toJson()).toList();
    
    try {
      await _httpClient.post(
        config.endpoint,
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'logs': batch,
          'app_version': config.appVersion,
          'platform': Platform.operatingSystem,
        }),
      );
    } catch (error) {
      throw TransportException('Failed to send logs: $error');
    }
  }
  
  @override
  bool get isAvailable => config.apiKey.isNotEmpty;
  
  @override
  Future<void> dispose() async {
    _httpClient.close();
  }
}
```

## 📊 Statistics and Monitoring

### Getting Logger Statistics

```dart
void printLoggerStats() {
  final stats = FlutterLiveLogger.getStats();
  
  print('Logger Statistics:');
  print('- Pending entries: ${stats['pendingEntries']}');
  print('- Active transports: ${stats['transports']}');
  print('- Environment: ${stats['config']['environment']}');
  print('- Current user: ${stats['config']['userId']}');
  print('- Session: ${stats['config']['sessionId']}');
}
```

### Storage Statistics

```dart
Future<void> printStorageStats() async {
  final storage = SQLiteStorage();
  final stats = await storage.getStats();
  
  print('Storage Statistics:');
  print('- Total entries: ${stats['entryCount']}');
  print('- Database size: ${stats['databaseSize']} bytes');
  print('- Oldest entry: ${stats['oldestEntry']}');
  print('- Newest entry: ${stats['newestEntry']}');
}
```

## 🔧 Advanced Configuration

### Custom Log Level Filtering

```dart
await FlutterLiveLogger.init(
  config: LoggerConfig.production(
    logLevel: LogLevel.warn, // Only warnings and above
    transports: [
      HttpTransport(config: HttpTransportConfig(
        endpoint: 'https://api.myapp.com/logs',
        apiKey: 'production-key',
      )),
    ],
  ),
);
```

### Multiple Transport Configuration

```dart
await FlutterLiveLogger.init(
  config: LoggerConfig.production(
    transports: [
      // Primary transport - HTTP to cloud
      HttpTransport(config: HttpTransportConfig(
        endpoint: 'https://primary.myapp.com/logs',
        apiKey: 'primary-key',
        retryAttempts: 3,
      )),
      
      // Fallback transport - Local files
      FileTransport(config: FileTransportConfig(
        directory: '/app/logs',
        maxFileSize: 50 * 1024 * 1024, // 50MB
        maxFiles: 10,
      )),
      
      // Development transport - Memory for debugging
      if (kDebugMode)
        MemoryTransport(maxEntries: 1000),
    ],
    usePersistentStorage: true,
  ),
);
```

This API documentation covers all the implemented features of Flutter Live Logger. All classes and methods shown here are available and fully functional in the current version.
