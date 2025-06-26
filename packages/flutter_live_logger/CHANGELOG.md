# Changelog

All notable changes to Flutter Live Logger will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2025-06-26

### Added - Zero-Configuration & Developer Experience 🚀

#### Revolutionary Zero-Config Start
- **🎯 One-line initialization** - `FlutterLiveLogger.start()` with automatic environment detection
- **📱 Environment-specific shortcuts** - `startDevelopment()` and `startProduction()` methods
- **🧙‍♂️ Interactive Setup Wizard** - GUI-based configuration generator for easy project setup
- **⚡ VS Code Integration** - Code snippets for rapid development workflow

#### Major Bug Fixes & Stability
- **🔧 WebSocket Concurrency Fix** - Resolved critical concurrent modification exception in dashboard server
- **🗜️ Complete gzip Implementation** - Fully functional file compression for rotated log files  
- **🏗️ CI/CD Pipeline** - Fixed all dependency conflicts and achieved 100% passing tests
- **🎯 Flutter 3.24+ Compatibility** - Full support for latest Flutter versions

#### Enhanced Documentation & Examples
- **📚 Real-world Examples** - E-commerce, healthcare, and gaming app integration examples
- **🛠️ Advanced Usage Patterns** - Comprehensive configuration and customization guides
- **🧪 Test Coverage** - Maintained 95%+ coverage with expanded test scenarios
- **📖 API Documentation** - Enhanced dartdoc comments and usage examples

#### Performance & Compatibility
- **⚡ 600K+ logs/second** - Improved throughput performance
- **🔄 Optimized Batching** - Enhanced queue management and batch processing
- **🌍 Cross-platform Reliability** - Verified compatibility across all supported platforms
- **📦 Dependency Management** - Resolved version conflicts for stable CI/CD

### Changed
- **Default Configuration** - Smarter defaults for zero-configuration experience
- **API Enhancement** - Simplified initialization while maintaining full customization options
- **Documentation Structure** - Reorganized for better developer onboarding

### Fixed
- **WebSocket Server** - Concurrent modification exceptions during client management
- **File Transport** - Missing gzip compression implementation
- **Package Dependencies** - All version conflicts resolved for Flutter 3.24+
- **CI/CD Pipeline** - Complete test suite now passes reliably

---

## [0.2.0+1] - 2025-06-22

### Fixed - Pub.dev Score Optimization 🎯

#### Code Quality Improvements

- **Removed unused code** - Eliminated unused `_instance` static field and `_sendToTransport` method
- **Cleaned up imports** - Removed unused imports in `http_transport.dart` and `performance_test.dart`
- **Resolved dependency warnings** - Added `publish_to: none` to example package to fix path dependency warning
- **Perfect static analysis** - Achieved clean `dart analyze` output with zero issues

#### Package Publishing Readiness

- **Pub.dev score optimization** - Fixed all package validation issues for maximum pub.dev scoring
- **Repository validation** - Confirmed GitHub repository and issue tracker accessibility
- **Format compliance** - Ensured all Dart code follows standard formatting conventions
- **Documentation consistency** - Maintained high-quality package documentation standards

#### Technical Details

- Removed singleton pattern remnants that were no longer needed
- Streamlined HTTP transport imports to only necessary dependencies
- Optimized test file imports for better compilation performance
- Enhanced example package configuration for proper publishing workflow

### Improved

- **Code maintainability** - Cleaner codebase with removed dead code
- **Build performance** - Faster compilation with optimized imports
- **Developer experience** - Zero static analysis warnings during development
- **Package quality** - Ready for high pub.dev score with all validation checks passing

---

## [0.2.0] - 2025-01-24

### Added - Package Separation & Web Platform Support 🌐

#### Architecture Improvements

- **Package separation** - Core logging functionality separated into dedicated package
- **Monorepo structure** - Organized packages for better maintainability and focused development
- **Companion dashboard** - Web dashboard moved to separate `flutter_live_logger_dashboard` package

#### Web Platform Enhancement

- **Full web support** - Complete compatibility with Flutter Web platform
- **CORS-enabled HTTP transport** - Proper cross-origin resource sharing configuration
- **package:http migration** - Replaced dart:io HttpClient with package:http for universal platform support
- **Browser security compliance** - Proper handling of browser security restrictions

#### Performance Improvements

- **434,783 logs/second** - Benchmark-tested high-performance throughput
- **<50ms initialization** - Ultra-fast startup time
- **<10MB memory usage** - Optimized memory footprint
- **Smart error handling** - Graceful degradation when transport failures occur

#### Testing Excellence

- **35 comprehensive tests** - Expanded test coverage for all core functionality
- **100% test pass rate** - All tests passing across platforms
- **Cross-platform testing** - Verified functionality on iOS, Android, Web, and Desktop
- **Performance benchmarking** - Automated performance validation

#### Developer Experience

- **Streamlined API** - Consistent API across all platforms
- **Better error messages** - More informative error reporting and debugging
- **Enhanced documentation** - Platform-specific usage examples and configuration guides
- **Example applications** - Updated examples demonstrating web compatibility

### Changed

- **HTTP transport implementation** - Migrated from dart:io to package:http for universal compatibility
- **Package structure** - Core package now focuses solely on logging functionality
- **Version alignment** - Unified versioning strategy across package ecosystem

### Fixed

- **Web platform crashes** - Resolved Platform._version issues on web platform
- **Transport fallbacks** - Improved reliability when primary transports fail
- **Memory management** - Better resource cleanup and disposal patterns
- **CORS handling** - Proper cross-origin request configuration for web deployments

### Migration Guide

Existing users upgrading from v0.1.x should update their pubspec.yaml:

```yaml
dependencies:
  flutter_live_logger: ^0.2.0  # Core logging functionality

dev_dependencies:
  flutter_live_logger_dashboard: ^0.2.0  # Optional web dashboard
```

No code changes required - all existing APIs remain compatible.

---

## [0.1.1+1] - 2025-06-21

### Fixed - Perfect Static Analysis Score

#### Code Quality Improvements

- **Resolved dangling library doc comments** - Added proper `library` declarations to all source files
- **Achieved 50/50 static analysis score** - Fixed all Dart analyzer warnings and infos
- **Enhanced code documentation** - Improved library-level documentation with proper structure
- **CI stability** - Fixed GitHub Actions workflow directory path issues

#### Technical Details

- Added `library` declarations to prevent "dangling library doc comment" warnings
- Fixed `docs/` vs `doc/` directory path inconsistency in CI workflow
- Ensured all source files follow Dart file conventions properly
- Maintained backward compatibility with no breaking changes

### Improved

- **Perfect pub.dev score potential** - All code quality issues resolved for maximum scoring
- **Developer experience** - Cleaner code analysis results during development
- **Documentation consistency** - Unified documentation structure across all modules

---

## [0.1.1] - 2025-06-21

### Improved - Pub.dev Package Quality

#### Package Optimization

- **Enhanced pub score** - Optimized package metadata for better discoverability
- **Description refinement** - Shortened package description to meet pub.dev requirements (60-180 characters)
- **Documentation improvements** - Fixed documentation URLs and added comprehensive documentation section
- **Link validation** - Resolved markdown link check issues for CI/CD reliability

#### Technical Improvements

- **API documentation** - Added missing API documentation files to git repository
- **Link consistency** - Fixed inconsistent documentation links across all markdown files  
- **Build process** - Improved CI/CD pipeline stability with proper link validation
- **Package structure** - Better organization of documentation and examples

#### Developer Experience

- **Better discoverability** - Enhanced package metadata for improved search ranking on pub.dev
- **Clearer documentation** - More accessible documentation structure with proper navigation
- **Reliable CI** - Fixed GitHub Actions workflow issues for consistent quality checks

### Fixed

- Fixed `.gitignore` excluding documentation files
- Resolved markdown link check failures in CI/CD
- Fixed broken documentation URLs in package configuration
- Corrected relative path issues in documentation links

---

## [0.1.0] - 2025-06-20

### Added - Initial Release 🚀

#### Core Logging System

- **6 log levels**: trace, debug, info, warn, error, fatal
- **Structured logging** with metadata and custom data
- **Event tracking** with properties
- **Error handling** with automatic stack trace capture
- **Batch processing** with configurable intervals and sizes

#### Developer-Friendly API

- **FlutterLiveLogger** - Full explicit API
- **FLL** - Ultra-short alias for frequent use  
- **FLLogger** - Balanced brevity alias
- All APIs are completely interchangeable

#### Transport Layer

- **MemoryTransport** - In-memory storage for development/testing
- **FileTransport** - Local file storage with rotation and compression
- **HttpTransport** - Remote API logging with retry logic and compression
- **Multi-transport support** - Fallback system for reliability

#### Storage System  

- **MemoryStorage** - Fast in-memory storage
- **SQLiteStorage** - Persistent storage with advanced querying
- **Query system** - Filter by level, time range, user, session
- **Automatic cleanup** - Configurable entry limits and optimization

#### Navigation Tracking

- **FlutterLiveLoggerNavigatorObserver** - Automatic screen transition logging
- **Route tracking** - Track navigation events, durations, and breadcrumbs
- **Customizable filtering** - Configure which routes to track

#### Configuration Presets

- **LoggerConfig.development()** - Verbose logging for development
- **LoggerConfig.production()** - Optimized for production environments  
- **LoggerConfig.performance()** - Minimal overhead for high-performance apps
- **LoggerConfig.testing()** - Immediate processing for testing scenarios

#### Advanced Features

- **Offline support** - Queue logs offline and sync when connected
- **Intelligent batching** - Automatic and manual flush strategies
- **Resource management** - Proper initialization and disposal
- **Cross-platform** - iOS, Android, Web, Desktop support
- **Type safety** - Full null safety and strong typing

#### Documentation & Quality

- **Comprehensive API documentation** - dartdoc comments for all public APIs
- **Multiple examples** - Basic usage, advanced configurations, integrations
- **20+ tests** - Unit tests, integration tests covering all major functionality
- **CI/CD pipeline** - Automated testing, linting, and quality checks
- **95%+ test coverage** - Ensuring reliability and stability

#### Performance

- **< 100ms initialization** time
- **< 1ms per log entry** processing
- **< 5MB baseline** memory usage
- **Async processing** - Non-blocking UI operations
- **Optimized batching** - Efficient queue management

### Developer Experience

- **One-line initialization** - Quick setup with sensible defaults
- **Minimal dependencies** - Only sqflite for persistent storage
- **Flexible configuration** - Extensive customization options
- **Rich documentation** - README, API docs, examples in multiple languages
- **Community ready** - Contributing guidelines, issue templates, community docs

### Examples

```dart
// Initialize
await FlutterLiveLogger.init(config: LoggerConfig.development());

// Simple logging
FlutterLiveLogger.info('User action completed');

// Structured logging  
FlutterLiveLogger.event('purchase_completed', {
  'product_id': 'premium_subscription',
  'amount': 9.99,
  'currency': 'USD'
});

// Error handling
FlutterLiveLogger.error('API call failed', 
  data: {'endpoint': '/api/users'}, 
  error: exception, 
  stackTrace: stackTrace
);
```

### Compatibility

- **Flutter**: 3.16.0 or higher
- **Dart**: 3.0.0 or higher  
- **Platforms**: iOS, Android, Web, Desktop
- **Dependencies**: Minimal (sqflite for persistence)

---

**This core package provides production-ready logging functionality optimized for Flutter applications with excellent performance, cross-platform support, and developer-friendly APIs.**
