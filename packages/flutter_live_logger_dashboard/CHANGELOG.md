# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0+1] - 2025-06-22

### Fixed - Pub.dev Score & Dev Dependency Optimization 🛠️

#### Package Quality Improvements

- **Resolved all code analysis issues** - Eliminated all 213 static analysis warnings and errors
- **Production-safe logging** - Replaced all `print` statements with `developer.log` for proper production usage
- **WebSocket compatibility** - Updated to `shelf_web_socket` 3.0.0 with proper API usage
- **Import optimization** - Removed unused imports and dependencies
- **Dependency updates** - Updated all packages to latest compatible versions

#### Development Experience Enhancements

- **Proper example structure** - Added `example/main.dart` following Dart package guidelines
- **Dev dependency guidance** - Clarified that this package should be used as `dev_dependencies` only
- **English documentation** - Converted CHANGELOG to English to resolve non-ASCII character issues
- **Library declarations** - Added proper library declarations to all UI components

#### Technical Improvements

- **Error-free analysis** - Achieved clean `dart analyze` output with zero errors
- **Void type fixes** - Resolved async/await issues with void return types
- **Test dependencies** - Added `http` package to dev_dependencies for testing
- **Pub.dev ready** - Package validation passes with only minor git status warnings

#### Usage Guidelines

- **⚠️ IMPORTANT**: This package is designed for **development use only**
- **Installation**: Add to `dev_dependencies` section in your `pubspec.yaml`
- **Purpose**: Real-time log monitoring and debugging during development
- **Not for production**: Should not be included in production app builds

### Development Workflow

```yaml
dev_dependencies:
  flutter_live_logger_dashboard: ^0.2.0+1
```

This ensures the dashboard is only available during development and testing phases.

**Bug Fixes:**

- Fixed `fl_chart` version compatibility issue by downgrading from 1.0.0 to 0.68.0
- Resolved Dart SDK version conflicts (now compatible with Dart 3.3.4+)
- Fixed dependency resolution failures in CI/CD environments

**Compatibility:**

- Minimum Flutter version: 3.22.0 (balanced modern features with broad compatibility)
- Minimum Dart SDK version: 3.5.0 (supports current development environments)
- Works with Flutter 3.22+ and Dart 3.5+

**Breaking Changes:**

- Minimum Flutter version increased to 3.24.0 (from 3.19.0)
- Minimum Dart SDK version increased to 3.6.0 (from 3.3.0)

**Enhancements:**

- Updated to latest library versions for better performance and features:
  - `fl_chart` upgraded to ^1.0.0 (latest chart library with new features)
  - `shelf_web_socket` upgraded to ^3.0.0 (improved WebSocket performance)
  - Full compatibility with modern Flutter/Dart ecosystem

**Rationale:**

- Dashboard is a development tool supporting current Flutter versions
- Better pub.dev scores with up-to-date dependencies
- Balanced approach between modern features and compatibility

**Migration Guide:**

- Update your Flutter to 3.24.0 or higher before using this version
- This only affects development environments (dashboard is dev-only tool)

## [0.2.0] - 2025-01-22

### Added

- **Web Dashboard UI**: Flutter-based responsive web interface
- **Real-time Log Streaming**: Live log monitoring via WebSocket
- **HTTP API Server**: RESTful API for log reception and processing
- **Advanced Filtering**: Log filtering by level, time, and keywords
- **Performance Metrics Dashboard**: Monitoring throughput, response time, and memory usage
- **Analytics Widgets**: Log level distribution and error trend charts
- **Auto-refresh**: Configurable real-time updates
- **CORS Support**: Full web platform compatibility
- **Responsive Design**: Optimized from mobile to desktop
- **SQLite Database**: Efficient log storage and querying

### Technical Details

- **Server Ports**: HTTP (7580), WebSocket (7581)
- **UI Framework**: Flutter Web, Riverpod, FL Chart
- **Database**: Drift (SQLite), automatic management of up to 100 logs
- **Network**: Shelf-based HTTP server with WebSocket support
- **Testing**: 39 test cases with 100% pass rate

### Performance

- **Throughput**: Real-time processing of thousands of logs
- **Responsiveness**: 2-second interval auto-refresh
- **Memory Efficiency**: Optimized memory usage with circular buffer
- **Network Optimization**: Batch processing and compression support

### UI Components

- **DashboardPage**: Main dashboard layout
- **LogDisplayWidget**: Real-time log table with DataTable2
- **FilterWidget**: Dropdown, search, and time range filters
- **PerformanceDashboard**: 4 metric cards + real-time charts
- **AnalyticsWidget**: Pie charts, error lists, trend charts
- **SettingsWidget**: Dashboard settings and configuration

### Fixed

- **Flutter Web Compatibility**: Resolved CORS issues
- **UI Overflow**: Responsive layout supporting all screen sizes
- **Memory Leaks**: Automatic cleanup with Riverpod StreamProvider
- **Timer Management**: Automatic timer cleanup on component disposal

## [0.1.0] - Initial Release

### Added

- Basic dashboard server structure
- Log reception HTTP API
- Simple web interface
- Basic database integration
