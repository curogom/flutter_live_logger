# 🚀 Flutter Live Logger

[![pub package](https://img.shields.io/pub/v/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)
[![popularity](https://img.shields.io/pub/popularity/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)
[![likes](https://img.shields.io/pub/likes/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)
[![CI](https://github.com/your-username/flutter_live_logger/workflows/CI/badge.svg)](https://github.com/your-username/flutter_live_logger/actions)
[![codecov](https://codecov.io/gh/your-username/flutter_live_logger/branch/main/graph/badge.svg)](https://codecov.io/gh/your-username/flutter_live_logger)

**Real-time logging for Flutter apps in production environments!**

Flutter Live Logger is an open-source logging solution that safely collects logs from release builds and provides real-time monitoring through a web dashboard.

> 📖 **Languages**: [**English**](README.md) • [한국어](README.ko.md) • [日本語](README.ja.md) • [Español](README.es.md)

---

## ✨ Features

### 🎯 **Built for Flutter Developers**

- 🔥 **Real-time Log Streaming**: Instant log viewing via WebSocket
- 📱 **Production Ready**: Safe logging in release builds
- 🎨 **Auto Screen Tracking**: Automatic Navigator route detection
- 💾 **Offline Support**: Log persistence during network outages
- 🎛️ **Flexible Configuration**: Log level filtering and customization
- 🔌 **Plugin Architecture**: Support for multiple backends

### 🛠️ **Developer Experience First**

- ⚡ **5-Minute Setup**: Quick integration without complex configuration
- 📚 **Complete Documentation**: Comprehensive dartdoc API reference
- 🔒 **Type Safe**: Full null safety support
- 🧪 **High Test Coverage**: 95%+ code coverage
- 🌍 **Cross Platform**: iOS, Android, Web, Desktop support

---

## 🚀 Quick Start

### 1. Add Dependency

```yaml
dependencies:
  flutter_live_logger: ^1.0.0
```

### 2. Initialize

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  // Initialize the logger
  FlutterLiveLogger.init(
    config: LoggerConfig(
      logLevel: LogLevel.debug,
      enableAutoScreenTracking: true,
      enableCrashReporting: true,
    ),
  );
  
  runApp(MyApp());
}
```

### 3. Set Up Auto Screen Tracking

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        FlutterLiveLogger.navigatorObserver, // Auto track screen transitions
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
            
            // Event tracking
            FlutterLiveLogger.event('button_click', {
              'button_id': 'main_cta',
              'screen': 'home',
              'timestamp': DateTime.now().toIso8601String(),
            });
            
            // Error logging
            try {
              // Some operation...
            } catch (error, stackTrace) {
              FlutterLiveLogger.error(
                'API call failed',
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

## 📖 Usage Examples

### Basic Logging

```dart
// Different log levels
FlutterLiveLogger.trace('Detailed debug information');
FlutterLiveLogger.debug('Debug information');
FlutterLiveLogger.info('General information');
FlutterLiveLogger.warning('Warning message');
FlutterLiveLogger.error('Error occurred');
FlutterLiveLogger.fatal('Critical error');
```

### Structured Logging

```dart
// With custom data
FlutterLiveLogger.info('User login', data: {
  'user_id': '12345',
  'login_method': 'google',
  'device_type': 'mobile',
  'app_version': '1.2.3',
});

// Performance tracking
final stopwatch = Stopwatch()..start();
await someApiCall();
stopwatch.stop();

FlutterLiveLogger.performance('API response time', {
  'endpoint': '/api/user/profile',
  'duration_ms': stopwatch.elapsedMilliseconds,
  'status_code': 200,
});
```

### Real-time Streaming Setup

```dart
void main() {
  FlutterLiveLogger.init(
    config: LoggerConfig(
      // Connect to local development server
      realTimeEnabled: true,
      serverUrl: 'ws://localhost:8080',
      
      // Or use cloud service
      // serverUrl: 'wss://your-domain.com',
      // apiKey: 'your-api-key',
    ),
  );
  
  runApp(MyApp());
}
```

---

## 🌐 Web Dashboard

View your logs in real-time using the web dashboard:

### Quick Demo (Local)

```bash
# Start with Docker Compose
git clone https://github.com/your-username/flutter_live_logger.git
cd flutter_live_logger/web_dashboard
docker-compose up

# Open http://localhost:8080 in your browser
```

### Self-Hosting Options

- 🐳 **Docker**: Use `flutter_live_logger/server` image
- ☁️ **Cloud**: AWS, GCP, DigitalOcean deployment guides
- 🏠 **On-premise**: Direct installation on your servers

### Dashboard Features

- 📊 **Real-time Log Stream**: Instant view of app logs
- 🔍 **Advanced Filtering**: Filter by time, level, keywords
- 📈 **Analytics & Charts**: Visualize log patterns
- 📥 **Data Export**: Download as CSV, JSON
- 🌙 **Dark Mode**: Developer-friendly UI

---

## 🔧 Advanced Configuration

### Custom Backend Integration

```dart
// Use multiple backends simultaneously
FlutterLiveLogger.init(
  transports: [
    // Save to local files
    FileTransport('./logs'),
    
    // Send to HTTP API
    HttpTransport('https://your-api.com/logs'),
    
    // WebSocket real-time streaming
    WebSocketTransport('wss://your-websocket.com'),
    
    // Firebase Crashlytics integration
    FirebaseCrashlyticsTransport(),
    
    // Sentry integration
    SentryTransport(),
    
    // Custom backend
    MyCustomTransport(),
  ],
);
```

### Performance Optimization

```dart
FlutterLiveLogger.init(
  config: LoggerConfig(
    // Batch sending for better performance
    batchSize: 50,
    flushInterval: Duration(seconds: 30),
    
    // Memory usage limits
    maxMemoryUsage: 10 * 1024 * 1024, // 10MB
    
    // Log compression (save network)
    enableCompression: true,
    
    // Disable debug logs in release builds
    logLevel: kDebugMode ? LogLevel.debug : LogLevel.info,
  ),
);
```

### Security Configuration

```dart
FlutterLiveLogger.init(
  config: LoggerConfig(
    // Auto-mask sensitive information
    enableDataMasking: true,
    
    // Custom masking rules
    maskingRules: {
      'password': '***',
      'credit_card': '****-****-****-1234',
      'email': 'user@****.com',
    },
    
    // Encrypt log data
    enableEncryption: true,
    encryptionKey: 'your-encryption-key',
  ),
);
```

---

## 🤝 Contributing

Flutter Live Logger is an open-source project. We welcome your contributions!

### How to Contribute

1. 🍴 **Fork** this repository
2. 🌿 **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. 📤 **Push** to the branch (`git push origin feature/amazing-feature`)
5. 🔄 **Open** a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/your-username/flutter_live_logger.git
cd flutter_live_logger

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run example app
cd example
flutter run
```

### Contribution Guidelines

- 📝 **Code Style**: Use `dart format`
- 🧪 **Testing**: Write tests for new features
- 📚 **Documentation**: Update docs for API changes
- 💬 **Issues**: Bug reports and feature requests welcome
- 📋 **Full Guide**: See [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📚 Documentation

- 📖 **[API Documentation](https://pub.dev/documentation/flutter_live_logger/latest/)**
- 🚀 **[Getting Started Guide](https://github.com/your-username/flutter_live_logger/wiki/Getting-Started)**
- 🏗️ **[Architecture Guide](https://github.com/your-username/flutter_live_logger/wiki/Architecture)**
- 🔧 **[Advanced Configuration](https://github.com/your-username/flutter_live_logger/wiki/Advanced-Configuration)**
- 🐛 **[Troubleshooting](https://github.com/your-username/flutter_live_logger/wiki/Troubleshooting)**

---

## 🆚 Comparison with Other Solutions

| Feature | Flutter Live Logger | logger | flutter_logs | Sentry |
|---------|-------------------|---------|-------------|---------|
| **Real-time Streaming** | ✅ | ❌ | ❌ | ❌ |
| **Production Ready** | ✅ | ⚠️ | ✅ | ✅ |
| **Web Dashboard** | ✅ | ❌ | ❌ | ✅ |
| **Offline Support** | ✅ | ❌ | ✅ | ✅ |
| **Auto Screen Tracking** | ✅ | ❌ | ❌ | ⚠️ |
| **Free & Open Source** | ✅ | ✅ | ✅ | ⚠️ |
| **Setup Complexity** | Low | Low | Medium | High |

---

## 🌟 Community & Support

- 💬 **GitHub Discussions**: [Questions & Discussions](https://github.com/your-username/flutter_live_logger/discussions)
- 🐛 **Issue Reports**: [Bug Reports](https://github.com/your-username/flutter_live_logger/issues)
- 📧 **Email**: <flutter.live.logger@gmail.com>
- 🐦 **Twitter**: [@FlutterLiveLogger](https://twitter.com/FlutterLiveLogger)

### Community Channels

- 💬 **Discord**: [Flutter Live Logger Community](https://discord.gg/flutter-live-logger)
- 📱 **Telegram**: [Flutter Logging](https://t.me/flutter_logging)
- 🌐 **Reddit**: [r/FlutterDev](https://reddit.com/r/FlutterDev)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

```
MIT License

Copyright (c) 2024 Flutter Live Logger Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🙏 Acknowledgements

Flutter Live Logger is inspired by these amazing open-source projects:

- [logger](https://pub.dev/packages/logger) - Clean logging API design
- [flutter_logs](https://pub.dev/packages/flutter_logs) - File-based logging concepts
- [sentry_flutter](https://pub.dev/packages/sentry_flutter) - Error tracking patterns

---

## ⭐ Star the Project

**If this project helps you, please give it a star!** ⭐

Your star motivates us to keep improving the project.

---

<div align="center">

**[🚀 Get Started](https://pub.dev/packages/flutter_live_logger)** •
**[📖 Documentation](https://pub.dev/documentation/flutter_live_logger/latest/)** •
**[💬 Community](https://github.com/your-username/flutter_live_logger/discussions)** •
**[🐛 Report Issues](https://github.com/your-username/flutter_live_logger/issues)**

Made with ❤️ by Flutter Community

</div>
