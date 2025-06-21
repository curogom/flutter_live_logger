# Flutter Live Logger Dashboard

A comprehensive web dashboard for real-time Flutter application monitoring and log analysis. Built with Flutter Web, this dashboard provides live log streaming, performance analytics, and powerful filtering capabilities.

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

Add this package to your Flutter project:

```yaml
dependencies:
  flutter_live_logger_dashboard: ^0.2.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Server Setup

Create a simple dashboard server:

```dart
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

void main() async {
  // Start the dashboard server
  final server = DashboardServer();
  await server.start(
    httpPort: 7580,
    webSocketPort: 7581,
  );
  
  print('Dashboard server running on http://localhost:7580');
}
```

### Flutter Web Dashboard

Create a Flutter Web dashboard:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

void main() {
  runApp(MyDashboardApp());
}

class MyDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Log Dashboard',
      home: DashboardPage(
        serverUrl: 'ws://localhost:7581',
      ),
    );
  }
}
```

### Connecting Your Flutter App

In your main Flutter application:

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  // Configure logger to send to dashboard
  FlutterLiveLogger.configure(
    transports: [
      HttpTransport(
        url: 'http://localhost:7580/logs',
        enableBatch: true,
      ),
    ],
  );
  
  runApp(MyApp());
}
```

## Performance

- **Throughput**: 555,556 logs/second processing capability
- **Memory Usage**: <10MB RAM usage with efficient garbage collection  
- **Real-time Latency**: <100ms from log generation to dashboard display
- **Concurrent Connections**: Supports 100+ simultaneous WebSocket clients

## Examples

Check out the [example_server.dart](example_server.dart) and [simple_server.dart](simple_server.dart) files for complete implementation examples.

## Contributing

Contributions are welcome! Please read our [Contributing Guide](https://github.com/curogom/flutter_live_logger/blob/main/CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Packages

- [flutter_live_logger](https://pub.dev/packages/flutter_live_logger) - Core logging functionality
