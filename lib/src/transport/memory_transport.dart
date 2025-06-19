/// Flutter Live Logger - Memory Transport
///
/// In-memory transport for development and testing purposes.
/// Stores log entries in memory with configurable size limits.
///
/// Example:
/// ```dart
/// final transport = MemoryTransport(maxEntries: 1000);
/// await transport.send([logEntry]);
///
/// final recentLogs = transport.getRecentEntries(50);
/// ```

import 'dart:collection';
import '../core/log_entry.dart';
import '../core/log_level.dart';
import 'log_transport.dart';

/// Transport that stores log entries in memory
///
/// Useful for:
/// - Development and debugging
/// - Testing scenarios
/// - In-app log viewing
/// - Temporary storage before network transmission
class MemoryTransport extends LogTransport {
  final Queue<LogEntry> _entries = Queue<LogEntry>();
  final int _maxEntries;
  bool _disposed = false;

  /// Create a memory transport with optional size limit
  ///
  /// [maxEntries] Maximum number of entries to keep in memory.
  /// Older entries are removed when limit is exceeded.
  MemoryTransport({int maxEntries = 1000}) : _maxEntries = maxEntries;

  @override
  Future<void> send(List<LogEntry> entries) async {
    if (_disposed) {
      throw const TransportException('MemoryTransport has been disposed');
    }

    for (final entry in entries) {
      _entries.add(entry);

      // Remove oldest entries if we exceed the limit
      while (_entries.length > _maxEntries) {
        _entries.removeFirst();
      }
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

  /// Get all stored log entries
  ///
  /// Returns a copy of the current entries list to prevent
  /// external modification.
  List<LogEntry> getAllEntries() {
    if (_disposed) return [];
    return List.unmodifiable(_entries);
  }

  /// Get the most recent log entries
  ///
  /// [count] Number of recent entries to return
  List<LogEntry> getRecentEntries(int count) {
    if (_disposed) return [];

    final totalEntries = _entries.length;
    if (count >= totalEntries) {
      return List.unmodifiable(_entries);
    }

    return List.unmodifiable(_entries.skip(totalEntries - count));
  }

  /// Get entries filtered by log level
  ///
  /// [level] Minimum log level to include
  List<LogEntry> getEntriesByLevel(LogLevel level) {
    if (_disposed) return [];

    return _entries.where((entry) => entry.level.index >= level.index).toList();
  }

  /// Get entries within a time range
  ///
  /// [start] Start time (inclusive)
  /// [end] End time (inclusive)
  List<LogEntry> getEntriesByTimeRange(DateTime start, DateTime end) {
    if (_disposed) return [];

    return _entries
        .where((entry) =>
            entry.timestamp
                .isAfter(start.subtract(const Duration(microseconds: 1))) &&
            entry.timestamp.isBefore(end.add(const Duration(microseconds: 1))))
        .toList();
  }

  /// Clear all stored entries
  void clear() {
    if (!_disposed) {
      _entries.clear();
    }
  }

  /// Current number of stored entries
  int get entryCount => _disposed ? 0 : _entries.length;

  /// Whether the memory store is at capacity
  bool get isFull => entryCount >= _maxEntries;

  /// Remaining capacity before entries start being dropped
  int get remainingCapacity => _maxEntries - entryCount;
}
