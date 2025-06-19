import 'log_level.dart';
import '../transport/log_transport.dart';
import '../storage/storage_interface.dart';
import '../transport/memory_transport.dart';
import '../storage/memory_storage.dart';
import '../storage/sqlite_storage.dart';

/// Configuration class for Flutter Live Logger
///
/// Defines how the logger should behave, including log levels,
/// transport methods, and feature flags.
class LoggerConfig {
  /// Creates a new logger configuration
  const LoggerConfig({
    this.logLevel = LogLevel.info,
    this.enableAutoScreenTracking = false,
    this.enableCrashReporting = false,
    this.userId,
    this.sessionId,
    this.environment = 'production',
    this.batchSize = 100,
    this.flushInterval = const Duration(seconds: 10),
    this.transports,
    this.storage,
    this.enableOfflineSupport = true,
    this.maxOfflineEntries = 1000,
  });

  /// Minimum log level to process
  final LogLevel logLevel;

  /// Whether to automatically track screen navigation
  final bool enableAutoScreenTracking;

  /// Whether to automatically catch and log crashes
  final bool enableCrashReporting;

  /// User ID to associate with log entries
  final String? userId;

  /// Session ID to group related log entries
  final String? sessionId;

  /// Environment identifier (e.g., 'development', 'staging', 'production')
  final String environment;

  /// Number of log entries to batch together before sending
  final int batchSize;

  /// How often to flush batched logs
  final Duration flushInterval;

  /// List of transports to send logs to
  /// If null, defaults to MemoryTransport for development
  final List<LogTransport>? transports;

  /// Storage implementation for offline support
  /// If null, defaults to MemoryStorage
  final LogStorage? storage;

  /// Whether to enable offline log storage
  final bool enableOfflineSupport;

  /// Maximum number of log entries to store offline
  final int maxOfflineEntries;

  /// Creates a copy with optional overrides
  LoggerConfig copyWith({
    LogLevel? logLevel,
    bool? enableAutoScreenTracking,
    bool? enableCrashReporting,
    String? userId,
    String? sessionId,
    String? environment,
    int? batchSize,
    Duration? flushInterval,
    List<LogTransport>? transports,
    LogStorage? storage,
    bool? enableOfflineSupport,
    int? maxOfflineEntries,
  }) {
    return LoggerConfig(
      logLevel: logLevel ?? this.logLevel,
      enableAutoScreenTracking:
          enableAutoScreenTracking ?? this.enableAutoScreenTracking,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      environment: environment ?? this.environment,
      batchSize: batchSize ?? this.batchSize,
      flushInterval: flushInterval ?? this.flushInterval,
      transports: transports ?? this.transports,
      storage: storage ?? this.storage,
      enableOfflineSupport: enableOfflineSupport ?? this.enableOfflineSupport,
      maxOfflineEntries: maxOfflineEntries ?? this.maxOfflineEntries,
    );
  }

  /// Create a development configuration with console and memory transports
  factory LoggerConfig.development({
    LogLevel logLevel = LogLevel.debug,
    String? userId,
    String? sessionId,
  }) {
    return LoggerConfig(
      logLevel: logLevel,
      environment: 'development',
      enableAutoScreenTracking: true,
      enableCrashReporting: true,
      userId: userId,
      sessionId: sessionId,
      transports: [
        MemoryTransport(maxEntries: 1000),
      ],
      storage: MemoryStorage(maxEntries: 5000),
      batchSize: 10, // Smaller batches for development
      flushInterval: const Duration(seconds: 2),
    );
  }

  /// Create a production configuration with optimized settings
  factory LoggerConfig.production({
    required List<LogTransport> transports,
    LogStorage? storage,
    LogLevel logLevel = LogLevel.info,
    String? userId,
    String? sessionId,
    bool usePersistentStorage = true,
  }) {
    return LoggerConfig(
      logLevel: logLevel,
      environment: 'production',
      enableAutoScreenTracking: false,
      enableCrashReporting: true,
      userId: userId,
      sessionId: sessionId,
      transports: transports,
      storage: storage ??
          (usePersistentStorage
              ? SQLiteStorage()
              : MemoryStorage(maxEntries: 10000)),
      batchSize: 100,
      flushInterval: const Duration(seconds: 30),
      maxOfflineEntries: 5000,
    );
  }

  /// Create a configuration optimized for high-performance apps
  factory LoggerConfig.performance({
    LogLevel logLevel = LogLevel.warn,
    List<LogTransport>? transports,
    String? userId,
    String? sessionId,
  }) {
    return LoggerConfig(
      logLevel: logLevel,
      environment: 'production',
      enableAutoScreenTracking: false,
      enableCrashReporting: true,
      userId: userId,
      sessionId: sessionId,
      transports: transports ?? [MemoryTransport(maxEntries: 500)],
      storage: MemoryStorage(maxEntries: 2000),
      batchSize: 200, // Larger batches for efficiency
      flushInterval: const Duration(minutes: 1), // Less frequent flushing
      enableOfflineSupport: false, // Disable for maximum performance
    );
  }

  /// Create a testing configuration with minimal overhead
  factory LoggerConfig.testing({
    LogLevel logLevel = LogLevel.trace,
    String? userId,
    String? sessionId,
  }) {
    return LoggerConfig(
      logLevel: logLevel,
      environment: 'testing',
      enableAutoScreenTracking: false,
      enableCrashReporting: false,
      userId: userId,
      sessionId: sessionId,
      transports: [MemoryTransport(maxEntries: 100)],
      storage: MemoryStorage(maxEntries: 500),
      batchSize: 1, // Immediate processing for testing
      flushInterval: const Duration(milliseconds: 100),
    );
  }

  /// Get effective transports (with defaults if none specified)
  List<LogTransport> get effectiveTransports {
    return transports ?? [MemoryTransport(maxEntries: 1000)];
  }

  /// Get effective storage (with default if none specified)
  LogStorage get effectiveStorage {
    return storage ?? MemoryStorage(maxEntries: maxOfflineEntries);
  }
}
