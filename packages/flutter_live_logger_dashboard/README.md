# Flutter Live Logger Dashboard

> ⚠️ **Development Tool Only** - This package is designed for development and debugging purposes. Add it to `dev_dependencies` only.

A comprehensive web dashboard for real-time Flutter application monitoring and log analysis during development. Built with Flutter Web, this dashboard provides live log streaming, performance analytics, and powerful filtering capabilities for debugging and monitoring your Flutter apps.

[![pub package](https://img.shields.io/pub/v/flutter_live_logger_dashboard.svg)](https://pub.dev/packages/flutter_live_logger_dashboard)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

🔴 **Real-time Log Streaming** - Live WebSocket-based log monitoring  
📊 **Performance Analytics** - CPU, memory, and throughput visualization  
🎯 **Advanced Filtering** - Multi-level log filtering with search  
💾 **Data Persistence** - SQLite-based storage with Drift ORM  
🌐 **Web Dashboard** - Responsive Flutter Web interface  
🚀 **High Performance** - Handles 555,556+ logs/second  

## Dashboard Components

- **Log Display Widget**: Real-time log entries with syntax highlighting
- **Performance Dashboard**: Interactive charts for system metrics
- **Analytics Widget**: Statistical insights and trend analysis
- **Filter Widget**: Advanced log querying and search
- **Settings Widget**: Configuration and preferences management

## Getting Started

### Prerequisites

- Flutter 3.16.0 or higher
- Dart 3.0.0 or higher
- [flutter_live_logger](https://pub.dev/packages/flutter_live_logger) core package

### Installation

⚠️ **IMPORTANT**: Add this package to your `dev_dependencies` only, as it's intended for development use:

```yaml
dev_dependencies:
  flutter_live_logger_dashboard: ^0.2.0+1
  # ... other development dependencies
```

**DO NOT** add to regular `dependencies`:

```yaml
# ❌ DON'T DO THIS
dependencies:
  flutter_live_logger_dashboard: ^0.2.0+1  # Wrong!
```

Then run:

```bash
flutter pub get
```

## Usage

### Development Workflow

This dashboard is designed to run alongside your development environment:

1. **Start the dashboard server** (separate process)
2. **Run your Flutter app** with logging enabled
3. **Monitor logs in real-time** via web browser

### Basic Server Setup

Create a development dashboard server (run this separately):

```dart
// dev_tools/dashboard_server.dart
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

void main() async {
  print('🚀 Starting Development Dashboard Server...');
  
  // Start the dashboard server
  final server = DashboardServer();
  await server.start(
    httpPort: 7580,
    webSocketPort: 7581,
  );
  
  print('📊 Dashboard available at http://localhost:7580');
  print('🔌 WebSocket listening on ws://localhost:7581');
  print('💡 Run your Flutter app and logs will appear here');
}
```

### Connecting Your Flutter App

In your main Flutter application (development configuration):

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  // Configure logger to send to development dashboard
  // Only enable this in development builds
  if (kDebugMode) {
    FlutterLiveLogger.configure(
      transports: [
        HttpTransport(
          url: 'http://localhost:7580/api/logs',
          enableBatch: true,
        ),
      ],
    );
  }
  
  runApp(MyApp());
}
```

### Running the Development Workflow

1. **Start dashboard server**:

   ```bash
   cd dev_tools/
   dart run dashboard_server.dart
   ```

2. **Run your Flutter app**:

   ```bash
   flutter run
   ```

3. **Open dashboard** in browser:

   ```
   http://localhost:7580
   ```

## Performance

- **Throughput**: 555,556 logs/second processing capability
- **Memory Usage**: <10MB RAM usage with efficient garbage collection  
- **Real-time Latency**: <100ms from log generation to dashboard display
- **Concurrent Connections**: Supports 100+ simultaneous WebSocket clients

## Examples

Check out the [example/main.dart](example/main.dart) and [simple_server.dart](simple_server.dart) files for complete implementation examples.

## Best Practices

### Development vs Production

- ✅ **Development**: Use dashboard for debugging and monitoring
- ❌ **Production**: Never include dashboard in production builds
- ✅ **CI/CD**: Exclude from production dependency trees
- ✅ **Testing**: Use for integration test monitoring

### Security Considerations

- Dashboard server is **not secure** and intended for local development only
- Never expose dashboard ports to external networks
- Use only on localhost/development environments

## Contributing

Contributions are welcome! Please read our [Contributing Guide](https://github.com/curogom/flutter_live_logger/blob/main/CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Packages

- [flutter_live_logger](https://pub.dev/packages/flutter_live_logger) - Core logging functionality
