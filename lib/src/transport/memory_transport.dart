/// Flutter Live Logger - Memory Transport
///
/// In-memory transport for development and testing.
/// Stores logs in memory with configurable size limits.
///
/// Example:
/// ```dart
/// final transport = MemoryTransport(
///   maxEntries: 1000,
///   enableConsoleOutput: false, // Disable for performance
/// );
/// ```

library flutter_live_logger_memory_transport;

import 'dart:collection';
import '../core/log_entry.dart';
import '../core/log_level.dart';
import 'log_transport.dart';

/// Memory-based transport implementation
///
/// Features:
/// - Fast in-memory storage
/// - Configurable size limits with LRU eviction
/// - Optional console output for development
/// - Thread-safe operations
/// - Ideal for development and testing
class MemoryTransport extends LogTransport {
  final Queue<LogEntry> _entries = Queue<LogEntry>();
  final int _maxEntries;
  final bool _enableConsoleOutput;
  bool _disposed = false;

  /// Create memory transport with configurable options
  ///
  /// [maxEntries] Maximum number of entries to keep in memory.
  /// Oldest entries are evicted when limit is exceeded (LRU policy).
  /// [enableConsoleOutput] Whether to print logs to console (default: true in development)
  MemoryTransport({
    int maxEntries = 1000,
    bool? enableConsoleOutput,
  })  : _maxEntries = maxEntries,
        _enableConsoleOutput = enableConsoleOutput ?? _isDebugMode();

  static bool _isDebugMode() {
    bool debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }

  @override
  Future<void> send(List<LogEntry> entries) async {
    if (_disposed) {
      throw const TransportException('MemoryTransport has been disposed');
    }

    for (final entry in entries) {
      _entries.add(entry);

      // Evict oldest entries if we exceed the limit
      while (_entries.length > _maxEntries) {
        _entries.removeFirst();
      }

      // Performance optimization: Optional console output
      if (_enableConsoleOutput) {
        _printToConsole(entry);
      }
    }
  }

  /// Print entry to console with optimized formatting
  void _printToConsole(LogEntry entry) {
    final levelName = entry.level.name.toUpperCase();

    // Performance optimization: Minimal string operations
    final message = '[$levelName] ${entry.message}';
    print(message);

    // Only print additional data if it exists and is reasonably sized
    if (entry.data != null && entry.data!.isNotEmpty) {
      final dataStr = entry.data.toString();
      if (dataStr.length < 200) {
        // Avoid huge data dumps
        print('  Data: ${entry.data}');
      } else {
        print('  Data: <${dataStr.length} chars>');
      }
    }

    if (entry.error != null) {
      print('  Error: ${entry.error}');
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _entries.clear();
  }

  @override
  bool get isAvailable => !_disposed;

  @override
  int get maxBatchSize => _maxEntries;

  /// Get all stored entries (for testing/debugging)
  ///
  /// Returns a copy to prevent external modification
  List<LogEntry> getAllEntries() {
    if (_disposed) return [];
    return List.unmodifiable(_entries);
  }

  /// Get entries by level
  ///
  /// [level] Minimum log level to include
  List<LogEntry> getEntriesByLevel(LogLevel level) {
    if (_disposed) return [];
    return _entries.where((entry) => entry.level.index >= level.index).toList();
  }

  /// Get recent entries
  ///
  /// [limit] Maximum number of entries to return (most recent first)
  List<LogEntry> getRecentEntries({int limit = 100}) {
    if (_disposed) return [];
    final entries = _entries.toList();
    if (entries.length <= limit) return entries.reversed.toList();
    return entries.skip(entries.length - limit).toList().reversed.toList();
  }

  /// Check if storage is at capacity
  bool get isFull => _entries.length >= _maxEntries;

  /// Get remaining capacity
  int get remainingCapacity => _maxEntries - _entries.length;

  /// Get current entry count
  int get entryCount => _entries.length;

  /// Get maximum entries limit
  int get maxEntries => _maxEntries;

  /// Check if console output is enabled
  bool get isConsoleOutputEnabled => _enableConsoleOutput;

  /// Clear all stored entries
  void clear() {
    if (!_disposed) {
      _entries.clear();
    }
  }

  /// Get memory usage summary
  Map<String, dynamic> getMemoryStats() {
    return {
      'entries': _entries.length,
      'maxEntries': _maxEntries,
      'utilizationPercent': (_entries.length / _maxEntries * 100).round(),
      'isFull': isFull,
      'remainingCapacity': remainingCapacity,
      'consoleOutputEnabled': _enableConsoleOutput,
    };
  }

  /// Trim storage to a specific size
  ///
  /// [targetSize] Target number of entries to keep (keeps most recent)
  void trimTo(int targetSize) {
    if (_disposed) return;

    if (targetSize < 0) {
      throw ArgumentError('Target size must be non-negative');
    }

    while (_entries.length > targetSize) {
      _entries.removeFirst();
    }
  }
}
