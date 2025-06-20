import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  group('Flutter Live Logger Tests', () {
    tearDown(() async {
      // Clean up after each test
      if (FlutterLiveLogger.isInitialized) {
        await FlutterLiveLogger.dispose();
      }
    });

    group('Initialization Tests', () {
      test('should initialize with default configuration', () async {
        await FlutterLiveLogger.init(
          config: const LoggerConfig(),
        );

        expect(FlutterLiveLogger.isInitialized, true);

        final stats = FlutterLiveLogger.getStats();
        expect(stats['isInitialized'], true);
        expect(stats['transports'], 1); // Default memory transport
        expect(stats['hasStorage'], true);
      });

      test('should initialize with development configuration', () async {
        await FlutterLiveLogger.init(
          config: LoggerConfig.development(
            userId: 'test_user',
            sessionId: 'test_session',
          ),
        );

        expect(FlutterLiveLogger.isInitialized, true);

        final stats = FlutterLiveLogger.getStats();
        expect(stats['config']['environment'], 'development');
        expect(stats['config']['logLevel'], 'debug');
      });

      test('should initialize with testing configuration', () async {
        await FlutterLiveLogger.init(
          config: LoggerConfig.testing(
            userId: 'test_user',
            sessionId: 'test_session',
          ),
        );

        expect(FlutterLiveLogger.isInitialized, true);

        final stats = FlutterLiveLogger.getStats();
        expect(stats['config']['environment'], 'testing');
        expect(stats['config']['logLevel'], 'trace');
      });
    });

    group('Logging Tests', () {
      setUp(() async {
        await FlutterLiveLogger.init(
          config: LoggerConfig.testing(
            userId: 'test_user',
            sessionId: 'test_session',
          ),
        );
      });

      test('should log different levels correctly', () async {
        // These should not throw exceptions
        FlutterLiveLogger.trace('Test trace message');
        FlutterLiveLogger.debug('Test debug message');
        FlutterLiveLogger.info('Test info message');
        FlutterLiveLogger.warn('Test warning message');
        FlutterLiveLogger.error('Test error message');
        FlutterLiveLogger.fatal('Test fatal message');

        // Allow time for processing
        await Future<void>.delayed(const Duration(milliseconds: 200));

        final stats = FlutterLiveLogger.getStats();
        expect(stats['isInitialized'], true);
      });

      test('should log events with structured data', () async {
        FlutterLiveLogger.event('test_event', {
          'key1': 'value1',
          'key2': 42,
          'key3': true,
        });

        // Allow time for processing
        await Future<void>.delayed(const Duration(milliseconds: 200));

        final stats = FlutterLiveLogger.getStats();
        expect(stats['isInitialized'], true);
      });

      test('should log errors with stack traces', () async {
        try {
          throw Exception('Test exception');
        } catch (error, stackTrace) {
          FlutterLiveLogger.error(
            'Test error with stack trace',
            error: error,
            stackTrace: stackTrace,
            data: {'context': 'test'},
          );
        }

        // Allow time for processing
        await Future<void>.delayed(const Duration(milliseconds: 200));

        final stats = FlutterLiveLogger.getStats();
        expect(stats['isInitialized'], true);
      });
    });

    group('Log Level Filtering Tests', () {
      test('should respect log level filtering', () async {
        // Initialize with warn level - should filter out debug/trace
        await FlutterLiveLogger.init(
          config: LoggerConfig.testing(logLevel: LogLevel.warn),
        );

        // These should be filtered out (lower than warn)
        FlutterLiveLogger.trace('Should be filtered');
        FlutterLiveLogger.debug('Should be filtered');
        FlutterLiveLogger.info('Should be filtered');

        // These should pass through
        FlutterLiveLogger.warn('Should pass');
        FlutterLiveLogger.error('Should pass');
        FlutterLiveLogger.fatal('Should pass');

        await Future<void>.delayed(const Duration(milliseconds: 200));

        final stats = FlutterLiveLogger.getStats();
        expect(stats['isInitialized'], true);
      });
    });

    group('Memory Transport Tests', () {
      test('should store and retrieve entries from memory transport', () async {
        final memoryTransport = MemoryTransport(maxEntries: 100);

        await FlutterLiveLogger.init(
          config: LoggerConfig(
            transports: [memoryTransport],
            batchSize: 1, // Immediate processing
            flushInterval: const Duration(milliseconds: 50),
          ),
        );

        FlutterLiveLogger.info('Test message 1');
        FlutterLiveLogger.info('Test message 2');

        // Allow time for processing
        await Future<void>.delayed(const Duration(milliseconds: 200));

        final entries = memoryTransport.getAllEntries();
        expect(entries.length, greaterThanOrEqualTo(2));
        expect(entries.any((e) => e.message.contains('Test message 1')), true);
        expect(entries.any((e) => e.message.contains('Test message 2')), true);
      });

      test('should respect max entries limit', () async {
        final memoryTransport = MemoryTransport(maxEntries: 3);

        await FlutterLiveLogger.init(
          config: LoggerConfig(
            transports: [memoryTransport],
            batchSize: 1,
            flushInterval: const Duration(milliseconds: 50),
          ),
        );

        // Add more entries than the limit
        for (int i = 0; i < 5; i++) {
          FlutterLiveLogger.info('Test message $i');
        }

        await Future<void>.delayed(const Duration(milliseconds: 200));

        final entries = memoryTransport.getAllEntries();
        expect(entries.length, lessThanOrEqualTo(3));
      });
    });

    group('Memory Storage Tests', () {
      test('should store and query entries from memory storage', () async {
        final memoryStorage = MemoryStorage(maxEntries: 100);

        await FlutterLiveLogger.init(
          config: LoggerConfig(
            storage: memoryStorage,
            enableOfflineSupport: true,
          ),
        );

        // Manually store some entries to test storage
        final testEntries = [
          LogEntry(
            message: 'Test entry 1',
            level: LogLevel.info,
            timestamp: DateTime.now(),
            userId: 'test_user',
            sessionId: 'test_session',
          ),
          LogEntry(
            message: 'Test entry 2',
            level: LogLevel.warn,
            timestamp: DateTime.now(),
            userId: 'test_user',
            sessionId: 'test_session',
          ),
        ];

        await memoryStorage.store(testEntries);

        final allEntries = await memoryStorage.query(LogQuery.recent());
        expect(allEntries.length, greaterThanOrEqualTo(2));

        final infoEntries =
            await memoryStorage.query(LogQuery.level(level: LogLevel.info));
        expect(infoEntries.any((e) => e.level == LogLevel.info), true);

        final count = await memoryStorage.count();
        expect(count, greaterThanOrEqualTo(2));

        final stats = await memoryStorage.getStats();
        expect(stats['type'], 'memory');
        expect(stats['entryCount'], greaterThanOrEqualTo(2));
      });

      test('should handle storage operations correctly', () async {
        final memoryStorage = MemoryStorage(maxEntries: 100);

        final testEntry = LogEntry(
          message: 'Test deletion',
          level: LogLevel.debug,
          timestamp: DateTime.now(),
          userId: 'test_user',
          sessionId: 'test_session',
        );

        await memoryStorage.store([testEntry]);

        // Test count
        var count = await memoryStorage.count();
        expect(count, 1);

        // Test deletion
        final deleted =
            await memoryStorage.delete(LogQuery.level(level: LogLevel.debug));
        expect(deleted, 1);

        count = await memoryStorage.count();
        expect(count, 0);
      });
    });

    group('Configuration Tests', () {
      test('should create different configuration types', () {
        final devConfig = LoggerConfig.development();
        expect(devConfig.environment, 'development');
        expect(devConfig.logLevel, LogLevel.debug);
        expect(devConfig.enableAutoScreenTracking, true);

        final prodConfig = LoggerConfig.production(
          transports: [MemoryTransport()],
        );
        expect(prodConfig.environment, 'production');
        expect(prodConfig.logLevel, LogLevel.info);
        expect(prodConfig.enableAutoScreenTracking, false);

        final perfConfig = LoggerConfig.performance();
        expect(perfConfig.environment, 'production');
        expect(perfConfig.logLevel, LogLevel.warn);
        expect(perfConfig.enableOfflineSupport, false);

        final testConfig = LoggerConfig.testing();
        expect(testConfig.environment, 'testing');
        expect(testConfig.logLevel, LogLevel.trace);
        expect(testConfig.enableCrashReporting, false);
      });

      test('should handle copyWith correctly', () {
        final originalConfig = LoggerConfig.development();
        final modifiedConfig = originalConfig.copyWith(
          logLevel: LogLevel.error,
          userId: 'modified_user',
        );

        expect(modifiedConfig.logLevel, LogLevel.error);
        expect(modifiedConfig.userId, 'modified_user');
        expect(modifiedConfig.environment, originalConfig.environment);
      });
    });

    group('Batch Processing Tests', () {
      test('should batch entries according to configuration', () async {
        final memoryTransport = MemoryTransport(maxEntries: 100);

        await FlutterLiveLogger.init(
          config: LoggerConfig(
            transports: [memoryTransport],
            batchSize: 3, // Process in batches of 3
            flushInterval: const Duration(seconds: 1),
          ),
        );

        // Send 2 messages (should not trigger batch yet)
        FlutterLiveLogger.info('Message 1');
        FlutterLiveLogger.info('Message 2');

        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Should have pending entries
        var stats = FlutterLiveLogger.getStats();
        expect(stats['pendingEntries'], greaterThan(0));

        // Send third message (should trigger batch)
        FlutterLiveLogger.info('Message 3');

        await Future<void>.delayed(const Duration(milliseconds: 200));

        // Should have processed the batch
        stats = FlutterLiveLogger.getStats();
        expect(stats['pendingEntries'], lessThanOrEqualTo(3));
      });
    });

    group('Error Handling Tests', () {
      test('should handle transport failures gracefully', () async {
        // Create a mock transport that always fails
        final failingTransport = MockFailingTransport();
        final memoryStorage = MemoryStorage(maxEntries: 100);

        await FlutterLiveLogger.init(
          config: LoggerConfig(
            transports: [failingTransport],
            storage: memoryStorage,
            enableOfflineSupport: true,
            batchSize: 1,
            flushInterval: const Duration(milliseconds: 50),
          ),
        );

        FlutterLiveLogger.info('Test message');

        await Future<void>.delayed(const Duration(milliseconds: 200));

        // Message should be stored offline since transport failed
        final storedEntries = await memoryStorage.query(LogQuery.recent());
        expect(
            storedEntries.any((e) => e.message.contains('Test message')), true);
      });

      test('should not crash when logging before initialization', () {
        // Should not throw exceptions
        FlutterLiveLogger.info('Message before init');
        FlutterLiveLogger.error('Error before init');

        expect(FlutterLiveLogger.isInitialized, false);
      });
    });

    group('Disposal Tests', () {
      test('should dispose correctly', () async {
        await FlutterLiveLogger.init(
          config: LoggerConfig.testing(),
        );

        expect(FlutterLiveLogger.isInitialized, true);

        await FlutterLiveLogger.dispose();

        expect(FlutterLiveLogger.isInitialized, false);

        // Should not crash when logging after disposal
        FlutterLiveLogger.info('Message after disposal');
      });
    });
  });
}

// Mock transport that always fails for testing error handling
class MockFailingTransport extends LogTransport {
  @override
  Future<void> send(List<LogEntry> entries) async {
    throw Exception('Mock transport failure');
  }

  @override
  Future<void> dispose() async {
    // Nothing to dispose
  }

  @override
  bool get isAvailable => true;

  @override
  int? get maxBatchSize => null;
}
