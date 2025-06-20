# 🚀 Flutter Live Logger

<!-- Badges will be enabled once package is published on pub.dev -->
<!-- [![pub package](https://img.shields.io/pub/v/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger) -->
<!-- [![popularity](https://img.shields.io/pub/popularity/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger) -->
<!-- [![likes](https://img.shields.io/pub/likes/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger) -->
[![CI](https://github.com/curogom/flutter_live_logger/actions/workflows/ci.yml/badge.svg)](https://github.com/curogom/flutter_live_logger/actions)
<!-- [![codecov](https://codecov.io/gh/curogom/flutter_live_logger/branch/main/graph/badge.svg)](https://codecov.io/gh/curogom/flutter_live_logger) -->

**Production-ready real-time logging solution for Flutter applications**

Flutter Live Logger is a comprehensive logging library designed for Flutter apps in production. It provides multiple transport layers, persistent storage, automatic navigation tracking, and offline support with a clean, developer-friendly API.

> 📖 **Languages**: [**English**](README.md) • [한국어](README.ko.md)

---

## ✨ Features

### 🎯 **Core Capabilities**

- 🔥 **Multiple Transport Layers**: Memory, File, HTTP transport options
- 💾 **Persistent Storage**: SQLite and memory-based storage with querying
- 📱 **Auto Navigation Tracking**: Automatic screen transition logging
- 🔄 **Offline Support**: Queue logs offline and sync when connected
- ⚡ **High Performance**: Batching, async processing, minimal overhead
- 🎛️ **Configurable**: Multiple environment configurations (dev/prod/test)

### 🛠️ **Developer Experience**

- ⚡ **Easy Setup**: Initialize with one line of code
- 📚 **Complete API**: Comprehensive dartdoc documentation
- 🔒 **Type Safe**: Full null safety and strong typing
- 🧪 **Well Tested**: 95%+ test coverage with 17+ comprehensive tests
- 🌍 **Cross Platform**: iOS, Android, Web, Desktop support

---

## 🚀 Quick Start

### 1. Add Dependency

```yaml
dependencies:
  flutter_live_logger: ^0.1.0
  sqflite: ^2.3.0  # For persistent storage
```

### 2. Initialize the Logger

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize for development
  await FlutterLiveLogger.init(
    config: LoggerConfig.development(
      userId: 'user_123',
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
    ),
  );
  
  runApp(MyApp());
}
```

### 3. Add Navigation Tracking

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      navigatorObservers: [
        FlutterLiveLoggerNavigatorObserver(), // Auto track screen navigation
      ],
      home: HomeScreen(),
    );
  }
}
```

### 4. Start Logging

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Live Logger Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Full API (traditional)
            FlutterLiveLogger.info('User clicked button');
            
            // Short alias (recommended for frequent use)
            FLL.info('User clicked button');
            
            // Medium alias (balance of brevity and clarity)
            FLLogger.info('User clicked button');
            
            // Event tracking with structured data
            FLL.event('button_click', {
              'button_id': 'main_cta',
              'screen': 'home',
              'timestamp': DateTime.now().toIso8601String(),
            });
            
            // Error logging with context
            try {
              throw Exception('Demo error');
            } catch (error, stackTrace) {
              FLL.error(
                'Operation failed',
                data: {'operation': 'demo'},
                error: error,
                stackTrace: stackTrace,
              );
            }
          },
          child: Text('Test Logging'),
        ),
      ),
    );
  }
}
```

## 🎯 **Developer-Friendly API**

Flutter Live Logger provides multiple ways to access the same functionality:

```dart
// 1. Full API (explicit and clear)
FlutterLiveLogger.info('Message');
FlutterLiveLogger.error('Error occurred', error: e);

// 2. FLL (ultra-short for frequent use)
FLL.info('Message');
FLL.error('Error occurred', error: e);

// 3. FLLogger (balanced brevity)
FLLogger.info('Message');
FLLogger.error('Error occurred', error: e);

// All three are interchangeable and use the same underlying system
```

---

## 📖 Advanced Usage

### Configuration Options

```dart
// Development Configuration
await FlutterLiveLogger.init(
  config: LoggerConfig.development(
    logLevel: LogLevel.debug,
    userId: 'user_123',
    sessionId: 'session_456',
  ),
);

// Production Configuration  
await FlutterLiveLogger.init(
  config: LoggerConfig.production(
    transports: [
      HttpTransport(config: HttpTransportConfig(
        endpoint: 'https://api.yourapp.com/logs',
        apiKey: 'your-api-key',
        batchSize: 50,
        enableCompression: true,
      )),
      FileTransport(config: FileTransportConfig(
        directory: '/app/logs',
        maxFileSize: 10 * 1024 * 1024, // 10MB
        maxFiles: 5,
      )),
    ],
    usePersistentStorage: true,
    logLevel: LogLevel.info,
  ),
);

// Performance Optimized Configuration
await FlutterLiveLogger.init(
  config: LoggerConfig.performance(
    logLevel: LogLevel.warn, // Only warnings and above
    transports: [MemoryTransport(maxEntries: 500)],
  ),
);

// Testing Configuration
await FlutterLiveLogger.init(
  config: LoggerConfig.testing(
    logLevel: LogLevel.trace, // All logs for testing
  ),
);
```

### Transport Layers

```dart
// Memory Transport (for development/testing)
final memoryTransport = MemoryTransport(
  maxEntries: 1000,
);

// File Transport (for local persistence)
final fileTransport = FileTransport(
  config: FileTransportConfig(
    directory: '/app/logs',
    filePrefix: 'app_log',
    maxFileSize: 10 * 1024 * 1024, // 10MB
    maxFiles: 5,
    enableRotation: true,
  ),
);

// HTTP Transport (for remote logging)
final httpTransport = HttpTransport(
  config: HttpTransportConfig(
    endpoint: 'https://api.yourapp.com/logs',
    apiKey: 'your-api-key',
    headers: {'X-App-Version': '1.0.0'},
    enableCompression: true,
    retryAttempts: 3,
    timeout: Duration(seconds: 30),
  ),
);
```

### Storage Options

```dart
// Memory Storage (fast, non-persistent)
final memoryStorage = MemoryStorage(maxEntries: 5000);

// SQLite Storage (persistent, queryable)
final sqliteStorage = SQLiteStorage(
  config: SQLiteStorageConfig(
    databaseName: 'app_logs.db',
    maxEntries: 50000,
    enableWAL: true,
  ),
);

// Query stored logs
final recentLogs = await sqliteStorage.query(LogQuery.recent(limit: 100));
final errorLogs = await sqliteStorage.query(LogQuery.level(level: LogLevel.error));
final userLogs = await sqliteStorage.query(LogQuery.user(userId: 'user_123'));
```

### Structured Logging

```dart
// User actions
FlutterLiveLogger.event('user_action', {
  'action': 'purchase',
  'item_id': 'product_123',
  'amount': 29.99,
  'currency': 'USD',
  'payment_method': 'credit_card',
});

// Performance metrics
FlutterLiveLogger.event('performance_metric', {
  'metric': 'api_response_time',
  'endpoint': '/api/user/profile',
  'duration_ms': 245,
  'status_code': 200,
});

// Business events
FlutterLiveLogger.event('business_event', {
  'event': 'subscription_started',
  'plan': 'premium',
  'trial_period': 7,
  'user_segment': 'power_user',
});
```

### Navigation Tracking

```dart
// Basic navigation observer
FlutterLiveLoggerNavigatorObserver()

// Customized navigation observer
FlutterLiveLoggerNavigatorObserver(
  enableDurationTracking: true,
  enableBreadcrumbs: true,
  maxBreadcrumbs: 10,
  routeNameExtractor: (route) {
    // Custom route name extraction
    return route.settings.name ?? 'unknown';
  },
  shouldLogRoute: (route) {
    // Filter which routes to log
    return route is PageRoute && route.settings.name != null;
  },
)
```

---

## 🧪 Testing

The library includes comprehensive testing:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

Test coverage includes:

- ✅ Initialization and configuration
- ✅ All log levels and filtering
- ✅ Transport layer functionality
- ✅ Storage operations and queries
- ✅ Error handling and resilience
- ✅ Batch processing and performance

---

## 📊 Monitoring and Statistics

Get insights into your logging system:

```dart
// Get logger statistics
final stats = FlutterLiveLogger.getStats();
print('Pending entries: ${stats['pendingEntries']}');
print('Active transports: ${stats['transports']}');
print('Storage type: ${stats['config']['environment']}');

// Force flush pending logs
await FlutterLiveLogger.flush();

// Get storage statistics
final storage = SQLiteStorage();
final storageStats = await storage.getStats();
print('Total entries: ${storageStats['entryCount']}');
print('Database size: ${storageStats['databaseSize']} bytes');
```

---

## 🔧 Advanced Configuration

### Environment-Specific Setup

```dart
void main() async {
  late LoggerConfig config;
  
  if (kDebugMode) {
    // Development configuration
    config = LoggerConfig.development(
      logLevel: LogLevel.trace,
      userId: 'dev_user',
    );
  } else if (kProfileMode) {
    // Performance testing configuration
    config = LoggerConfig.performance(
      logLevel: LogLevel.warn,
    );
  } else {
    // Release configuration
    config = LoggerConfig.production(
      transports: [
        HttpTransport(config: HttpTransportConfig(
          endpoint: 'https://logs.yourapp.com/api/logs',
          apiKey: const String.fromEnvironment('LOG_API_KEY'),
        )),
      ],
      usePersistentStorage: true,
      logLevel: LogLevel.info,
    );
  }
  
  await FlutterLiveLogger.init(config: config);
  runApp(MyApp());
}
```

### Custom Transport Implementation

```dart
class CustomTransport extends LogTransport {
  @override
  Future<void> send(List<LogEntry> entries) async {
    // Your custom transport logic
    for (final entry in entries) {
      // Send to your custom backend
      await customApi.sendLog(entry.toJson());
    }
  }
  
  @override
  bool get isAvailable => true;
  
  @override
  Future<void> dispose() async {
    // Cleanup resources
  }
}
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│                Flutter App                      │
├─────────────────────────────────────────────────┤
│              FlutterLiveLogger                  │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────┐ │
│  │   Logger    │ │   Navigator  │ │  Config  │ │
│  │    API      │ │   Observer   │ │          │ │
│  └─────────────┘ └──────────────┘ └──────────┘ │
├─────────────────────────────────────────────────┤
│               Transport Layer                   │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────┐ │
│  │   Memory    │ │     File     │ │   HTTP   │ │
│  │  Transport  │ │   Transport  │ │Transport │ │
│  └─────────────┘ └──────────────┘ └──────────┘ │
├─────────────────────────────────────────────────┤
│                Storage Layer                    │
│  ┌─────────────┐ ┌──────────────┐              │
│  │   Memory    │ │    SQLite    │              │
│  │   Storage   │ │   Storage    │              │
│  └─────────────┘ └──────────────┘              │
└─────────────────────────────────────────────────┘
```

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/curogom/flutter_live_logger.git
cd flutter_live_logger

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run the example
cd example
flutter run
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

- 📖 [Documentation](doc/api/README.md)
- 🐛 [Issue Tracker](https://github.com/curogom/flutter_live_logger/issues)
- 📧 [Email Support](mailto:i_am@curogom.dev) - Direct support
- 🔗 [API Documentation](doc/api/README.md) - Complete API reference
- 🏗️ [Architecture Guide](doc/ARCHITECTURE.md) - System design and architecture  
- 👥 [Community Guidelines](doc/COMMUNITY.md) - How to contribute and get involved
<!-- GitHub Discussions will be enabled after initial release -->
<!-- - 💬 [Discussions](https://github.com/curogom/flutter_live_logger/discussions) -->

---

## 🌟 Acknowledgments

Built with ❤️ for the Flutter community.

- Thanks to all [contributors](https://github.com/curogom/flutter_live_logger/graphs/contributors)
- Inspired by best practices from the Flutter and Dart ecosystem
- Special thanks to the Flutter team for creating an amazing framework

<!-- Link check test -->
