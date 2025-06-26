# Flutter Live Logger 🚀

[![pub package](https://img.shields.io/pub/v/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)
[![pub points](https://img.shields.io/pub/points/flutter_live_logger)](https://pub.dev/packages/flutter_live_logger/score)
[![popularity](https://img.shields.io/pub/popularity/flutter_live_logger)](https://pub.dev/packages/flutter_live_logger/score)
[![likes](https://img.shields.io/pub/likes/flutter_live_logger)](https://pub.dev/packages/flutter_live_logger/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI/CD](https://github.com/curogom/flutter_live_logger/actions/workflows/ci.yml/badge.svg)](https://github.com/curogom/flutter_live_logger/actions/workflows/ci.yml)

Production-ready real-time logging solution for Flutter applications with 400K+ logs/second throughput, offline support, and real-time dashboard.

> 📖 **Languages**: [**English**](README.md) • [한국어](README.ko.md)

## 🌟 What's New in v0.3.0

### 🚀 Zero-Configuration Start
```dart
// Just one line to start!
await FlutterLiveLogger.start();
```

### 🧙‍♂️ Major Improvements
- **Zero-config initialization** - Start logging with a single line of code
- **Interactive setup wizard** - GUI-based configuration generator
- **VS Code snippets** - Rapid development with code snippets
- **WebSocket stability** - Fixed critical concurrency bugs
- **Flutter 3.24+ support** - Full compatibility with latest Flutter

## 📦 Packages

This monorepo contains two packages:

### 1. [flutter_live_logger](packages/flutter_live_logger) 
[![pub package](https://img.shields.io/pub/v/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)

Core logging library with:
- 🚀 400K+ logs/second throughput
- 🌐 Cross-platform support (iOS, Android, Web, Desktop)
- 💾 Multiple storage options (Memory, SQLite)
- 🔄 Multiple transport layers (Memory, File, HTTP)
- 📱 Automatic navigation tracking
- 🔌 Offline support with sync

### 2. [flutter_live_logger_dashboard](packages/flutter_live_logger_dashboard)
[![pub package](https://img.shields.io/pub/v/flutter_live_logger_dashboard.svg)](https://pub.dev/packages/flutter_live_logger_dashboard)

Web dashboard for real-time monitoring:
- 📊 Real-time log streaming via WebSocket
- 📈 Performance analytics and metrics
- 🔍 Advanced filtering and search
- 📱 Responsive design
- 🎨 Modern Flutter web UI

## 🚀 Quick Start

### Installation

```yaml
dependencies:
  flutter_live_logger: ^0.3.0

dev_dependencies:
  flutter_live_logger_dashboard: ^0.3.0  # Optional dashboard
```

### Basic Usage

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start with zero configuration
  await FlutterLiveLogger.start();
  
  runApp(MyApp());
}

// Use anywhere in your app
FlutterLiveLogger.info('App started');
FlutterLiveLogger.error('Something went wrong', error: exception);
FlutterLiveLogger.event('user_login', {'user_id': userId});
```

## 💡 Real-World Examples

### E-commerce App
```dart
// Track user journey
FlutterLiveLogger.event('product_viewed', {
  'product_id': product.id,
  'category': product.category,
  'price': product.price,
});

// Monitor performance
final stopwatch = Stopwatch()..start();
await api.processPayment();
FlutterLiveLogger.info('Payment processed', data: {
  'duration_ms': stopwatch.elapsedMilliseconds,
  'amount': payment.amount,
});
```

### Error Tracking
```dart
try {
  await riskyOperation();
} catch (error, stackTrace) {
  FlutterLiveLogger.error(
    'Operation failed',
    error: error,
    stackTrace: stackTrace,
    data: {'user_id': currentUser.id},
  );
}
```

## 🛠️ Configuration

### Environment-Specific Setup

```dart
// Development
await FlutterLiveLogger.startDevelopment();

// Production with custom transports
await FlutterLiveLogger.init(
  config: LoggerConfig.production(
    transports: [
      HttpTransport(config: HttpTransportConfig(
        endpoint: 'https://api.your-domain.com/logs',
        apiKey: 'your-api-key',
      )),
      FileTransport(config: FileTransportConfig(
        directory: '/logs',
        compressRotatedFiles: true,
      )),
    ],
  ),
);
```

### Navigation Tracking

```dart
MaterialApp(
  navigatorObservers: [
    FlutterLiveLoggerNavigatorObserver(
      enableDurationTracking: true,
      enableBreadcrumbs: true,
    ),
  ],
  home: HomeScreen(),
);
```

## 📊 Dashboard Usage

Start the dashboard server:

```dart
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

void main() async {
  final server = DashboardServer();
  await server.start(port: 8080);
  print('Dashboard running at http://localhost:8080');
}
```

## 🎯 Key Features

### Performance
- ⚡ **400,000+ logs/second** throughput
- 🚀 **< 50ms** initialization time
- 💾 **< 10MB** memory footprint
- 🔄 **Smart batching** for efficiency

### Reliability
- 🔌 **Offline support** - Queue logs when offline
- 🛡️ **Error resilience** - Graceful degradation
- 📦 **Multiple transports** - Fallback options
- 🧪 **95%+ test coverage** - Battle-tested

### Developer Experience
- 🎯 **Zero-config start** - One line setup
- 📚 **Rich documentation** - Comprehensive guides
- 🛠️ **VS Code snippets** - Rapid development
- 🌍 **Cross-platform** - Write once, run everywhere

## 📖 Documentation

- [Getting Started Guide](packages/flutter_live_logger/README.md)
- [API Documentation](https://pub.dev/documentation/flutter_live_logger/latest/)
- [Dashboard Guide](packages/flutter_live_logger_dashboard/README.md)
- [Examples](packages/flutter_live_logger/example)
- [Changelog](packages/flutter_live_logger/CHANGELOG.md)

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

# Run example app
cd packages/flutter_live_logger/example
flutter run
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Special thanks to all contributors and the Flutter community for their support and feedback.

## 📬 Support

- 🐛 [Report Issues](https://github.com/curogom/flutter_live_logger/issues)
- 💬 [Discussions](https://github.com/curogom/flutter_live_logger/discussions)
- 📧 [Email](mailto:support@curogom.dev)

---

<p align="center">Made with ❤️ by <a href="https://curogom.dev">curogom.dev</a></p>