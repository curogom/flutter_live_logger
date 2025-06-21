/// Flutter Live Logger - Memory Storage
///
/// In-memory storage implementation for development and testing.
/// Provides fast access but no persistence across app restarts.
///
/// Example:
/// ```dart
/// final storage = MemoryStorage(maxEntries: 10000);
/// await storage.store([logEntry]);
///
/// final recentLogs = await storage.query(LogQuery.recent(limit: 50));
/// ```
library flutter_live_logger_memory_storage;

import 'dart:collection';
import '../core/log_entry.dart';
import '../core/log_level.dart';
import 'storage_interface.dart';

/// Memory-based storage implementation
///
/// Features:
/// - Fast in-memory operations
/// - Configurable size limits with LRU eviction
/// - Full query support with filtering
/// - Thread-safe operations
/// - Ideal for development and testing
class MemoryStorage extends BaseLogStorage {
  final Queue<LogEntry> _entries = Queue<LogEntry>();
  final int _maxEntries;

  /// Create memory storage with configurable size limit
  ///
  /// [maxEntries] Maximum number of entries to keep in memory.
  /// Oldest entries are evicted when limit is exceeded (LRU policy).
  MemoryStorage({int maxEntries = 10000}) : _maxEntries = maxEntries;

  @override
  Future<void> store(List<LogEntry> entries) async {
    checkAvailable();

    for (final entry in entries) {
      _entries.add(entry);

      // Evict oldest entries if we exceed the limit
      while (_entries.length > _maxEntries) {
        _entries.removeFirst();
      }
    }
  }

  @override
  Future<List<LogEntry>> query(LogQuery query) async {
    checkAvailable();

    return applyQueryFilters(_entries.toList(), query);
  }

  @override
  Future<int> count([LogQuery? query]) async {
    checkAvailable();

    if (query == null) {
      return _entries.length;
    }

    return applyQueryFilters(_entries.toList(), query).length;
  }

  @override
  Future<int> delete(LogQuery query) async {
    checkAvailable();

    final toDelete = applyQueryFilters(_entries.toList(), query);
    final deleteCount = toDelete.length;

    // Remove matching entries
    _entries.removeWhere((entry) => toDelete.contains(entry));

    return deleteCount;
  }

  @override
  Future<int> clear() async {
    checkAvailable();

    final count = _entries.length;
    _entries.clear();
    return count;
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    checkAvailable();

    return {
      'type': 'memory',
      'entryCount': _entries.length,
      'maxEntries': _maxEntries,
      'utilizationPercent': (_entries.length / _maxEntries * 100).round(),
      'memoryUsageEstimate': _estimateMemoryUsage(),
    };
  }

  @override
  Future<void> optimize() async {
    checkAvailable();
    // No optimization needed for in-memory storage
  }

  @override
  Future<void> dispose() async {
    _entries.clear();
    await super.dispose();
  }

  @override
  int get maxEntries => _maxEntries;

  /// Get all entries (for debugging/testing)
  ///
  /// Returns a copy to prevent external modification
  List<LogEntry> getAllEntries() {
    checkAvailable();
    return List.unmodifiable(_entries);
  }

  /// Get entries by level
  ///
  /// [level] Minimum log level to include
  Future<List<LogEntry>> getEntriesByLevel(LogLevel level) async {
    return query(LogQuery.level(level: level));
  }

  /// Get entries in time range
  ///
  /// [start] Start time (inclusive)
  /// [end] End time (inclusive)
  Future<List<LogEntry>> getEntriesByTimeRange(
    DateTime start,
    DateTime end,
  ) async {
    return query(LogQuery.timeRange(start: start, end: end));
  }

  /// Check if storage is at capacity
  bool get isFull => _entries.length >= _maxEntries;

  /// Get remaining capacity
  int get remainingCapacity => _maxEntries - _entries.length;

  /// Estimate memory usage in bytes
  int _estimateMemoryUsage() {
    if (_entries.isEmpty) return 0;

    // Rough estimate: average 500 bytes per log entry
    // This includes the LogEntry object overhead, strings, etc.
    return _entries.length * 500;
  }

  /// Trim storage to a specific size
  ///
  /// [targetSize] Target number of entries to keep (keeps most recent)
  Future<int> trimTo(int targetSize) async {
    checkAvailable();

    if (targetSize < 0) {
      throw ArgumentError('Target size must be non-negative');
    }

    final removedCount = _entries.length - targetSize;
    if (removedCount <= 0) return 0;

    // Remove oldest entries
    for (int i = 0; i < removedCount; i++) {
      _entries.removeFirst();
    }

    return removedCount;
  }

  /// Get memory usage summary
  Map<String, dynamic> getMemoryStats() {
    return {
      'entries': _entries.length,
      'maxEntries': _maxEntries,
      'utilizationPercent': (_entries.length / _maxEntries * 100).round(),
      'estimatedMemoryBytes': _estimateMemoryUsage(),
      'isFull': isFull,
      'remainingCapacity': remainingCapacity,
    };
  }
}
