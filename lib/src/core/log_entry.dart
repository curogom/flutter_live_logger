import 'log_level.dart';

/// Immutable data class representing a single log entry
///
/// Contains all the information about a log event including
/// message, level, timestamp, and additional metadata.
class LogEntry {
  /// Creates a new log entry
  const LogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
    this.data,
    this.error,
    this.stackTrace,
    this.userId,
    this.sessionId,
    this.deviceInfo,
  });

  /// The log message
  final String message;

  /// The severity level of this log entry
  final LogLevel level;

  /// When this log entry was created
  final DateTime timestamp;

  /// Additional structured data associated with this log entry
  final Map<String, dynamic>? data;

  /// Error object if this log entry represents an error
  final Object? error;

  /// Stack trace if this log entry represents an error
  final StackTrace? stackTrace;

  /// User ID associated with this log entry
  final String? userId;

  /// Session ID for grouping related log entries
  final String? sessionId;

  /// Device information
  final Map<String, dynamic>? deviceInfo;

  /// Creates a copy of this log entry with optional field overrides
  LogEntry copyWith({
    String? message,
    LogLevel? level,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
    String? userId,
    String? sessionId,
    Map<String, dynamic>? deviceInfo,
  }) {
    return LogEntry(
      message: message ?? this.message,
      level: level ?? this.level,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  /// Converts this log entry to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'level': level.name,
      'timestamp': timestamp.toIso8601String(),
      if (data != null) 'data': data,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      if (userId != null) 'userId': userId,
      if (sessionId != null) 'sessionId': sessionId,
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
    };
  }

  @override
  String toString() {
    return '[${level.name}] ${timestamp.toIso8601String()} - $message';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogEntry &&
        other.message == message &&
        other.level == level &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(message, level, timestamp);
  }
}
