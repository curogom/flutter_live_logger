/// Flutter Live Logger - Storage Interface
///
/// Defines the contract for persistent storage of log entries.
/// Supports offline caching, querying, and batch operations.
///
/// Example:
/// ```dart
/// class CustomStorage implements LogStorage {
///   @override
///   Future<void> store(List<LogEntry> entries) async {
///     // Custom implementation
///   }
/// }
/// ```
library flutter_live_logger_storage_interface;

import '../core/log_entry.dart';
import '../core/log_level.dart';

/// Query parameters for retrieving log entries
class LogQuery {
  /// Filter by minimum log level
  final LogLevel? minLevel;

  /// Filter by maximum log level
  final LogLevel? maxLevel;

  /// Filter by start time (inclusive)
  final DateTime? startTime;

  /// Filter by end time (inclusive)
  final DateTime? endTime;

  /// Filter by user ID
  final String? userId;

  /// Filter by session ID
  final String? sessionId;

  /// Maximum number of entries to return
  final int? limit;

  /// Number of entries to skip (for pagination)
  final int? offset;

  /// Sort order (true for ascending, false for descending)
  final bool ascending;

  const LogQuery({
    this.minLevel,
    this.maxLevel,
    this.startTime,
    this.endTime,
    this.userId,
    this.sessionId,
    this.limit,
    this.offset,
    this.ascending = true,
  });

  /// Create a query for recent entries
  factory LogQuery.recent({int limit = 100}) {
    return LogQuery(
      limit: limit,
      ascending: false,
    );
  }

  /// Create a query for a specific time range
  factory LogQuery.timeRange({
    required DateTime start,
    required DateTime end,
    int? limit,
  }) {
    return LogQuery(
      startTime: start,
      endTime: end,
      limit: limit,
      ascending: true,
    );
  }

  /// Create a query for specific log levels
  factory LogQuery.level({
    required LogLevel level,
    int? limit,
  }) {
    return LogQuery(
      minLevel: level,
      maxLevel: level,
      limit: limit,
      ascending: false,
    );
  }
}

/// Exception thrown when storage operations fail
class StorageException implements Exception {
  final String message;
  final Object? cause;

  const StorageException(this.message, [this.cause]);

  @override
  String toString() => 'StorageException: $message';
}

/// Interface for persistent log storage implementations
///
/// Storage implementations handle:
/// - Persistent storage of log entries
/// - Querying and filtering capabilities
/// - Cleanup and maintenance operations
/// - Data integrity and corruption recovery
abstract class LogStorage {
  /// Store log entries persistently
  ///
  /// [entries] List of log entries to store
  ///
  /// Throws [StorageException] if storage fails
  Future<void> store(List<LogEntry> entries);

  /// Retrieve log entries based on query parameters
  ///
  /// [query] Query parameters for filtering and pagination
  ///
  /// Returns list of matching log entries
  Future<List<LogEntry>> query(LogQuery query);

  /// Get total count of stored log entries
  ///
  /// [query] Optional query to count specific entries
  ///
  /// Returns total number of matching entries
  Future<int> count([LogQuery? query]);

  /// Delete log entries based on query parameters
  ///
  /// [query] Query parameters for selecting entries to delete
  ///
  /// Returns number of deleted entries
  Future<int> delete(LogQuery query);

  /// Clear all stored log entries
  ///
  /// Returns number of deleted entries
  Future<int> clear();

  /// Get storage statistics and health information
  ///
  /// Returns map with storage metrics like size, entry count, etc.
  Future<Map<String, dynamic>> getStats();

  /// Optimize storage (e.g., vacuum, compact, reindex)
  ///
  /// Performs maintenance operations to improve performance
  Future<void> optimize();

  /// Close and dispose of storage resources
  ///
  /// Should be called when storage is no longer needed
  Future<void> dispose();

  /// Whether the storage is currently available for operations
  bool get isAvailable;

  /// Maximum number of entries that can be stored efficiently
  ///
  /// Returns null if there's no specific limit
  int? get maxEntries;
}

/// Base implementation with common functionality
///
/// Provides utilities that most storage implementations can use
abstract class BaseLogStorage implements LogStorage {
  bool _disposed = false;

  @override
  bool get isAvailable => !_disposed;

  /// Validate that storage is available for operations
  void checkAvailable() {
    if (_disposed) {
      throw const StorageException('Storage has been disposed');
    }
  }

  /// Apply query filters to a list of entries
  ///
  /// Utility method for in-memory filtering
  List<LogEntry> applyQueryFilters(List<LogEntry> entries, LogQuery query) {
    var filtered = entries.where((entry) {
      // Level filters
      if (query.minLevel != null && entry.level.index < query.minLevel!.index) {
        return false;
      }
      if (query.maxLevel != null && entry.level.index > query.maxLevel!.index) {
        return false;
      }

      // Time filters
      if (query.startTime != null &&
          entry.timestamp.isBefore(query.startTime!)) {
        return false;
      }
      if (query.endTime != null && entry.timestamp.isAfter(query.endTime!)) {
        return false;
      }

      // User/session filters
      if (query.userId != null && entry.userId != query.userId) {
        return false;
      }
      if (query.sessionId != null && entry.sessionId != query.sessionId) {
        return false;
      }

      return true;
    }).toList();

    // Sort by timestamp
    filtered.sort((a, b) {
      final comparison = a.timestamp.compareTo(b.timestamp);
      return query.ascending ? comparison : -comparison;
    });

    // Apply pagination
    if (query.offset != null) {
      filtered = filtered.skip(query.offset!).toList();
    }
    if (query.limit != null) {
      filtered = filtered.take(query.limit!).toList();
    }

    return filtered;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
  }
}
