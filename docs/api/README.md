# Flutter Live Logger API Documentation

> **📋 Status**: Documentation Template (Implementation planned for Phase 1)  
> **🎯 Purpose**: Complete API reference for developers

## 📚 API Documentation Structure

### 1. Core Classes

#### `FlutterLiveLogger`

Main logger class - Entry point for all logging functionality

```dart
/// Main class for Flutter Live Logger
/// 
/// Manages all logging activities in your app and provides real-time log transmission.
/// 
/// Example:
/// ```dart
/// await FlutterLiveLogger.init(
///   config: LoggerConfig(
///     logLevel: LogLevel.debug,
///     enableAutoScreenTracking: true,
///   ),
/// );
/// 
/// FlutterLiveLogger.info('User logged in', data: {
///   'userId': user.id,
///   'timestamp': DateTime.now().toIso8601String(),
/// });
/// ```
class FlutterLiveLogger {
  // API implementation planned (Phase 1)
}
```

#### `LoggerConfig`

Configuration class for logger behavior

```dart
/// Configuration class for logger behavior
/// 
/// Configure log levels, auto tracking, transport options, etc.
class LoggerConfig {
  // Implementation planned
}
```

#### `LogEntry`

Data class representing individual log entries

```dart
/// Immutable class representing a single log entry
/// 
/// Contains log message, metadata, timestamp, etc.
@immutable
class LogEntry {
  // Implementation planned
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
}
```

### 3. Transport System

#### `LogTransport` (Abstract Class)

Base interface for log transmission to destinations

```dart
/// Abstract base class for log transmission
/// 
/// Foundation of plugin architecture supporting various transport methods
/// (HTTP, WebSocket, local files, etc.)
abstract class LogTransport {
  /// Send batch of log entries
  /// 
  /// [entries] Log entries to send
  /// 
  /// Returns: Number of successfully sent entries
  /// Throws: [TransportException] on transmission failure
  Future<int> send(List<LogEntry> entries);
  
  /// Clean up transport resources
  Future<void> dispose();
}
```

#### Planned Transport Implementations

- `HttpTransport` - REST API transmission
- `WebSocketTransport` - Real-time WebSocket transmission
- `FileTransport` - Local file storage
- `MemoryTransport` - In-memory temporary storage

### 4. Flutter Integration

#### `NavigatorObserver`

Observer for automatic screen tracking

```dart
/// Observer that automatically tracks Flutter navigation
/// 
/// Add to MaterialApp's navigatorObservers to automatically
/// log screen transitions.
class FlutterLiveLoggerNavigatorObserver extends NavigatorObserver {
  // Implementation planned
}
```

#### Widget Error Handling

```dart
/// Automatically catch and log Flutter widget errors
void setupFlutterErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterLiveLogger.error(
      'Flutter Widget Error',
      data: {
        'error': details.exception.toString(),
        'stack': details.stack.toString(),
        'library': details.library,
      },
    );
  };
}
```

## 🎯 Usage Patterns

### Basic Setup

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger
  await FlutterLiveLogger.init(
    config: LoggerConfig(
      logLevel: LogLevel.info,
      enableAutoScreenTracking: true,
      enableCrashReporting: true,
      transports: [
        HttpTransport(
          endpoint: 'https://api.myapp.com/logs',
          apiKey: 'your-api-key',
        ),
        FileTransport(
          maxFileSize: 10 * 1024 * 1024, // 10MB
          maxFiles: 5,
        ),
      ],
    ),
  );
  
  runApp(MyApp());
}
```

### Logging Usage Examples

```dart
class UserService {
  Future<User> login(String email) async {
    FlutterLiveLogger.info('User login attempt', data: {
      'email': email,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    try {
      final user = await _authService.login(email);
      
      FlutterLiveLogger.info('Login successful', data: {
        'userId': user.id,
        'userRole': user.role,
      });
      
      return user;
    } catch (e) {
      FlutterLiveLogger.error('Login failed', data: {
        'email': email,
        'error': e.toString(),
      });
      rethrow;
    }
  }
}
```

### Custom Event Tracking

```dart
class AnalyticsService {
  static void trackButtonClick(String buttonId, String screen) {
    FlutterLiveLogger.event('button_click', {
      'button_id': buttonId,
      'screen': screen,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  static void trackScreenView(String screenName) {
    FlutterLiveLogger.event('screen_view', {
      'screen_name': screenName,
      'view_time': DateTime.now().toIso8601String(),
    });
  }
}
```

## 🔧 Advanced Features

### 1. Log Filtering

```dart
// Log sensitive information only during development
if (kDebugMode) {
  FlutterLiveLogger.debug('API Response', data: response.data);
}

// Conditional logging
FlutterLiveLogger.when(
  condition: user.isAdmin,
  level: LogLevel.info,
  message: 'Admin action performed',
);
```

### 2. Batch Logging

```dart
// Batch logging for performance optimization
FlutterLiveLogger.batchBegin();
for (int i = 0; i < items.length; i++) {
  FlutterLiveLogger.trace('Processing item $i');
}
FlutterLiveLogger.batchEnd(); // Send all logs at once
```

### 3. Log Context

```dart
// Set global context
FlutterLiveLogger.setGlobalContext({
  'app_version': '1.0.0',
  'device_id': deviceId,
  'user_id': currentUser?.id,
});

// Log with local context
FlutterLiveLogger.withContext({
  'feature': 'checkout',
  'step': 'payment',
}, () {
  FlutterLiveLogger.info('Payment started');
  // All logs in this block automatically include context information
});
```

## 📊 Performance Considerations

### Memory Usage

- Maximum log queue size: 1000 entries
- Memory usage target: < 10MB
- Automatic cleanup in background

### Network Optimization

- Batch transmission (default 100 entries)
- Compression support (gzip)
- Retry logic (exponential backoff)
- Offline support

### App Performance Impact

- Main thread blocking time: < 1ms
- Background thread processing
- Asynchronous I/O operations

## 🧪 Testing Support

### Mock Transport

```dart
// Mock Transport for testing
class MockTransport extends LogTransport {
  List<LogEntry> sentLogs = [];
  
  @override
  Future<int> send(List<LogEntry> entries) async {
    sentLogs.addAll(entries);
    return entries.length;
  }
}

// Usage in tests
testWidgets('log transmission test', (tester) async {
  final mockTransport = MockTransport();
  await FlutterLiveLogger.init(
    config: LoggerConfig(transports: [mockTransport]),
  );
  
  FlutterLiveLogger.info('test log');
  
  expect(mockTransport.sentLogs, hasLength(1));
  expect(mockTransport.sentLogs.first.message, 'test log');
});
```

## 📖 Next Steps

This API documentation will be updated with actual implementation during **Phase 1 development**.

- **Phase 1** (Week 3-4): Basic logging functionality implementation
- **Phase 2** (Week 5-6): Transport system and offline support
- **Phase 3** (Week 7-8): Flutter integration and auto tracking

Each phase will update this documentation with actual API alongside working code examples.
