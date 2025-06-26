# Flutter Live Logger

[![pub package](https://img.shields.io/pub/v/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)
[![pub points](https://img.shields.io/pub/points/flutter_live_logger)](https://pub.dev/packages/flutter_live_logger/score)
[![popularity](https://img.shields.io/pub/popularity/flutter_live_logger)](https://pub.dev/packages/flutter_live_logger/score)
[![likes](https://img.shields.io/pub/likes/flutter_live_logger)](https://pub.dev/packages/flutter_live_logger/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-4BC0F5.svg)](https://pub.dev/packages/flutter_lints)

Production-ready real-time logging for Flutter with offline support, performance monitoring, and dashboard UI. Features 400K+ logs/sec throughput.

Flutter Live Logger is a comprehensive logging library designed for Flutter apps in production. It provides multiple transport layers, persistent storage, automatic navigation tracking, and offline support with a clean, developer-friendly API.

> 📖 **Languages**: [**English**](README.md) • [한국어](README.ko.md)

---

## ✨ Features

### 🎯 **Core Capabilities**

- 🚀 **High Performance**: 400,000+ logs/second throughput
- 🌐 **Cross-Platform**: iOS, Android, Web, macOS, Windows, Linux
- 🔥 **Multiple Transport Layers**: Memory, File, HTTP transport options
- 💾 **Persistent Storage**: SQLite and memory-based storage with querying
- 📱 **Auto Navigation Tracking**: Automatic screen transition logging
- 🔄 **Offline Support**: Queue logs offline and sync when connected
- ⚡ **Smart Batching**: Configurable batching for efficiency
- 🎛️ **Configurable**: Multiple environment configurations (dev/prod/test)

### 🛠️ **Developer Experience**

- ⚡ **Easy Setup**: Initialize with one line of code
- 📚 **Complete API**: Comprehensive dartdoc documentation
- 🔒 **Type Safe**: Full null safety and strong typing
- 🧪 **Well Tested**: 95%+ test coverage with 35+ comprehensive tests
- 🌍 **Cross Platform**: iOS, Android, Web, Desktop support

---

## 🚀 Quick Start

### Installation

```yaml
dependencies:
  flutter_live_logger: ^0.2.0
```

### Basic Usage

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Zero-configuration start
  await FlutterLiveLogger.start();
  
  runApp(MyApp());
}
```

That's it! The logger automatically configures itself based on your environment.

### Logging Messages

```dart
// Simple logging
FlutterLiveLogger.info('User logged in');
FlutterLiveLogger.error('Payment failed');

// With structured data
FlutterLiveLogger.event('purchase', {
  'item': 'Premium',
  'price': 9.99,
});
```

### 3. Add Navigation Tracking

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      navigatorObservers: [
        FlutterLiveLoggerNavigatorObserver(
          enableDurationTracking: true,
          enableBreadcrumbs: true,
        ),
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
            // Simple logging
            FlutterLiveLogger.info('User clicked button');
            
            // Event tracking with structured data
            FlutterLiveLogger.event('button_click', {
              'button_id': 'main_cta',
              'screen': 'home',
              'timestamp': DateTime.now().toIso8601String(),
            });
            
            // Error logging with context
            try {
              throw Exception('Demo error');
            } catch (error, stackTrace) {
              FlutterLiveLogger.error(
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

---

## 📖 Advanced Usage

### Configuration Options

```dart
// Development Configuration
await FlutterLiveLogger.init(
  config: LoggerConfig(
    logLevel: LogLevel.debug,
    environment: 'development',
    enableOfflineSupport: true,
    transports: [
      MemoryTransport(maxEntries: 1000),
      HttpTransport(
        config: HttpTransportConfig.withApiKey(
          endpoint: 'https://api.example.com/logs',
          apiKey: 'dev-api-key',
        ),
      ),
    ],
  ),
);

// Production Configuration  
await FlutterLiveLogger.init(
  config: LoggerConfig(
    logLevel: LogLevel.info,
    environment: 'production',
    enableOfflineSupport: true,
    batchSize: 50,
    flushInterval: Duration(seconds: 10),
    transports: [
      HttpTransport(
        config: HttpTransportConfig.withApiKey(
          endpoint: 'https://api.example.com/logs',
          apiKey: 'prod-api-key',
          batchSize: 50,
          timeout: Duration(seconds: 30),
          maxRetries: 3,
        ),
      ),
      FileTransport(
        config: FileTransportConfig(
          directory: '/app/logs',
          maxFileSize: 10 * 1024 * 1024, // 10MB
          maxFiles: 5,
        ),
      ),
    ],
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

// HTTP Transport (for remote logging with full web support)
final httpTransport = HttpTransport(
  config: HttpTransportConfig.withApiKey(
    endpoint: 'https://api.example.com/logs',
    apiKey: 'your-api-key',
    batchSize: 10,
    timeout: Duration(seconds: 30),
    maxRetries: 3,
  ),
);
```

### Storage Options

```dart
// Memory Storage (fast, non-persistent)
final memoryStorage = MemoryStorage(maxEntries: 10000);

// SQLite Storage (persistent, queryable)
final sqliteStorage = SQLiteStorage(
  path: 'app_logs.db',
  maxEntries: 100000,
);
```

## 🌐 Web Platform Support

Flutter Live Logger fully supports web platforms with CORS-enabled HTTP transport:

```dart
// Works seamlessly on web
HttpTransport(
  config: HttpTransportConfig.withApiKey(
    endpoint: 'https://api.example.com/logs',
    apiKey: 'your-key',
  ),
)
```

**Note**: Server must have proper CORS headers configured:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Origin, Content-Type, X-API-Key
```

## 📊 Performance Benchmarks

Benchmarked performance metrics:

- **Throughput**: 434,783 logs/second
- **Initialization**: <50ms startup time  
- **Memory**: <10MB peak usage
- **Cross-platform**: Consistent performance across all platforms

## 📊 Dashboard Integration

For real-time monitoring and analytics, use the companion dashboard:

```yaml
dev_dependencies:
  flutter_live_logger_dashboard: ^0.2.0
```

## 📱 Platform Support

| Platform | Support | Notes |
|----------|---------|-------|
| iOS | ✅ | Full support |
| Android | ✅ | Full support |
| Web | ✅ | CORS required for HTTP transport |
| macOS | ✅ | Full support |
| Windows | ✅ | Full support |
| Linux | ✅ | Full support |

## 🧪 Testing

The package includes comprehensive test coverage:

```bash
flutter test
```

**Test Results**: 35/35 tests passing (100%)

## 📚 Examples

Check out the [example app](example/) for a complete implementation showing:

- Basic logging setup
- HTTP transport configuration (web compatible)
- Navigator observation
- Error handling
- Performance monitoring

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](../../CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Packages

- [flutter_live_logger_dashboard](https://pub.dev/packages/flutter_live_logger_dashboard) - Web dashboard for real-time monitoring

## 📞 Support

- 🐛 [File an issue](https://github.com/curogom/flutter_live_logger/issues)
- 💬 [Discussions](https://github.com/curogom/flutter_live_logger/discussions)
- 📧 Email: <support@flutterlivelogger.com>
