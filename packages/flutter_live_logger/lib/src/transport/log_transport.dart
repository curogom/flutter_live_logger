/// Flutter Live Logger - Transport Layer Base Interface
///
/// Defines the contract for transporting log entries to various destinations
/// like files, network endpoints, or in-memory buffers.
///
/// Example:
/// ```dart
/// class CustomTransport extends LogTransport {
///   @override
///   Future<void> send(List<LogEntry> entries) async {
///     // Custom implementation
///   }
/// }
/// ```

library flutter_live_logger_log_transport;

import '../core/log_entry.dart';

/// Exception thrown when transport operations fail
class TransportException implements Exception {
  final String message;
  final Object? cause;

  const TransportException(this.message, [this.cause]);

  @override
  String toString() => 'TransportException: $message';
}

/// Base class for log transport implementations
///
/// Transports are responsible for delivering log entries to their
/// destination (file, network, etc.). Each transport should handle
/// its own retry logic and error recovery.
abstract class LogTransport {
  /// Send a batch of log entries
  ///
  /// Returns a Future that completes when the entries are successfully
  /// sent or throws a [TransportException] on failure.
  ///
  /// Implementations should:
  /// - Handle network failures gracefully
  /// - Implement appropriate retry logic
  /// - Respect rate limiting
  /// - Batch operations for efficiency
  Future<void> send(List<LogEntry> entries);

  /// Dispose of resources used by this transport
  ///
  /// Called when the logger is being shut down. Implementations
  /// should clean up any open connections, files, or other resources.
  Future<void> dispose();

  /// Whether this transport is currently available
  ///
  /// Can be used to check connectivity or other prerequisites
  /// before attempting to send logs.
  bool get isAvailable => true;

  /// Maximum number of entries this transport can handle in a single batch
  ///
  /// Returns null if there's no specific limit.
  int? get maxBatchSize => null;
}

/// Transport that combines multiple transports
///
/// Useful for sending logs to multiple destinations simultaneously.
/// If one transport fails, others will still receive the logs.
class MultiTransport extends LogTransport {
  final List<LogTransport> _transports;

  MultiTransport(this._transports);

  @override
  Future<void> send(List<LogEntry> entries) async {
    final futures = _transports
        .where((transport) => transport.isAvailable)
        .map((transport) => transport.send(entries));

    await Future.wait(futures, eagerError: false);
  }

  @override
  Future<void> dispose() async {
    await Future.wait(_transports.map((t) => t.dispose()));
  }

  @override
  bool get isAvailable => _transports.any((t) => t.isAvailable);

  @override
  int? get maxBatchSize {
    final sizes = _transports
        .map((t) => t.maxBatchSize)
        .where((size) => size != null)
        .cast<int>();

    return sizes.isEmpty ? null : sizes.reduce((a, b) => a < b ? a : b);
  }
}
