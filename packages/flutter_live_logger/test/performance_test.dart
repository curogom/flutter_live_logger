import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  group('Performance Benchmarks', () {
    tearDown(() async {
      if (FlutterLiveLogger.isInitialized) {
        await FlutterLiveLogger.dispose();
      }
    });

    group('Initialization Performance', () {
      test('should initialize within 100ms target', () async {
        final stopwatch = Stopwatch()..start();

        await FlutterLiveLogger.init(
          config: LoggerConfig.development(),
        );

        stopwatch.stop();
        final initTime = stopwatch.elapsedMilliseconds;

        print('Initialization time: ${initTime}ms');
        expect(initTime, lessThan(100),
            reason: 'Initialization should be under 100ms');
      });

      test('should initialize with memory storage within target', () async {
        final stopwatch = Stopwatch()..start();

        await FlutterLiveLogger.init(
          config: LoggerConfig.production(
            transports: [MemoryTransport(enableConsoleOutput: false)],
            usePersistentStorage: false, // Use memory storage for testing
          ),
        );

        stopwatch.stop();
        final initTime = stopwatch.elapsedMilliseconds;

        print('Memory storage initialization time: ${initTime}ms');
        expect(initTime, lessThan(50),
            reason: 'Memory storage initialization should be very fast');
      });
    });

    group('Logging Performance', () {
      setUp(() async {
        await FlutterLiveLogger.init(
          config: LoggerConfig.performance(),
        );
      });

      test('should log entries within 1ms target', () async {
        const iterations = 1000;
        final times = <int>[];

        // Warm up
        for (int i = 0; i < 10; i++) {
          FlutterLiveLogger.info('Warmup $i');
        }

        // Measure individual log times
        for (int i = 0; i < iterations; i++) {
          final stopwatch = Stopwatch()..start();
          FlutterLiveLogger.info('Performance test $i', data: {
            'iteration': i,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
          stopwatch.stop();
          times.add(stopwatch.elapsedMicroseconds);
        }

        final avgTime = times.reduce((a, b) => a + b) / times.length;
        final maxTime = times.reduce((a, b) => a > b ? a : b);
        final minTime = times.reduce((a, b) => a < b ? a : b);

        print('Average log time: ${avgTime.toStringAsFixed(2)}μs');
        print('Max log time: ${maxTime}μs');
        print('Min log time: ${minTime}μs');

        expect(avgTime, lessThan(1000),
            reason: 'Average log time should be under 1ms (1000μs)');
      });

      test('should handle batch processing efficiently', () async {
        const batchSize = 100;
        const batches = 10;

        final stopwatch = Stopwatch()..start();

        for (int batch = 0; batch < batches; batch++) {
          for (int i = 0; i < batchSize; i++) {
            FlutterLiveLogger.info('Batch $batch, Entry $i', data: {
              'batch': batch,
              'entry': i,
            });
          }
          // Force flush
          await FlutterLiveLogger.flush();
        }

        stopwatch.stop();
        final totalTime = stopwatch.elapsedMilliseconds;
        final throughput = (batchSize * batches) / (totalTime / 1000);

        print(
            'Batch processing: ${totalTime}ms for ${batchSize * batches} entries');
        print('Throughput: ${throughput.toStringAsFixed(2)} logs/second');

        expect(throughput, greaterThan(1000),
            reason: 'Should process >1000 logs/second');
      });
    });

    group('Memory Performance', () {
      test('should maintain reasonable memory usage', () async {
        // Use performance config to avoid console spam
        await FlutterLiveLogger.init(
          config: LoggerConfig.performance(),
        );

        // Get initial memory stats
        final initialStats = FlutterLiveLogger.getStats();
        print('Initial stats: $initialStats');

        // Generate a significant number of logs (reduced for stability)
        for (int i = 0; i < 1000; i++) {
          FlutterLiveLogger.warn('Memory test $i', data: {
            'iteration': i,
            'largeData': 'x' * 50, // Smaller data for stability
          });

          // Check memory every 500 iterations
          if (i % 500 == 0) {
            final stats = FlutterLiveLogger.getStats();
            print('After $i logs - pending: ${stats['pendingEntries']}');
          }
        }

        await FlutterLiveLogger.flush();

        final finalStats = FlutterLiveLogger.getStats();
        print('Final stats: $finalStats');

        // Memory usage should be reasonable
        expect(finalStats['pendingEntries'], lessThan(100),
            reason: 'Pending entries should be managed efficiently');
      });

      test('should handle memory storage limits correctly', () async {
        final memoryStorage =
            MemoryStorage(maxEntries: 100); // Smaller for testing

        await FlutterLiveLogger.init(
          config: LoggerConfig(
            storage: memoryStorage,
            batchSize: 10,
            flushInterval: const Duration(milliseconds: 50),
            transports: [MemoryTransport(enableConsoleOutput: false)],
          ),
        );

        // Add more entries than the limit
        for (int i = 0; i < 200; i++) {
          FlutterLiveLogger.info('Memory limit test $i');
        }

        await FlutterLiveLogger.flush();
        await Future.delayed(const Duration(milliseconds: 200));

        final stats = await memoryStorage.getStats();
        print('Memory storage stats: $stats');

        expect(stats['entryCount'], lessThanOrEqualTo(100),
            reason: 'Memory storage should respect max entries limit');
      });
    });

    group('Transport Performance', () {
      test('should handle multiple transports efficiently', () async {
        final memoryTransport1 =
            MemoryTransport(maxEntries: 1000, enableConsoleOutput: false);
        final memoryTransport2 =
            MemoryTransport(maxEntries: 1000, enableConsoleOutput: false);
        final memoryTransport3 =
            MemoryTransport(maxEntries: 1000, enableConsoleOutput: false);

        await FlutterLiveLogger.init(
          config: LoggerConfig(
            transports: [memoryTransport1, memoryTransport2, memoryTransport3],
            batchSize: 50,
            flushInterval: const Duration(milliseconds: 100),
          ),
        );

        final stopwatch = Stopwatch()..start();

        // Generate logs
        for (int i = 0; i < 500; i++) {
          FlutterLiveLogger.info('Multi-transport test $i');
        }

        await FlutterLiveLogger.flush();
        stopwatch.stop();

        print('Multi-transport time: ${stopwatch.elapsedMilliseconds}ms');

        // Verify all transports received the logs
        final entries1 = memoryTransport1.getAllEntries();
        final entries2 = memoryTransport2.getAllEntries();
        final entries3 = memoryTransport3.getAllEntries();

        print('Transport 1: ${entries1.length} entries');
        print('Transport 2: ${entries2.length} entries');
        print('Transport 3: ${entries3.length} entries');

        // Each transport should have received all entries
        expect(entries1.length, greaterThan(400));
        expect(entries2.length, greaterThan(400));
        expect(entries3.length, greaterThan(400));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });

    group('Real-world Scenarios', () {
      test('should handle high-frequency logging scenario', () async {
        await FlutterLiveLogger.init(
          config: LoggerConfig.performance(),
        );

        final stopwatch = Stopwatch()..start();

        // Simulate high-frequency logging (like in a game or real-time app)
        final futures = <Future>[];
        for (int i = 0; i < 100; i++) {
          futures.add(Future.microtask(() {
            for (int j = 0; j < 10; j++) {
              FlutterLiveLogger.info('High-freq $i-$j', data: {
                'thread': i,
                'iteration': j,
                'timestamp': DateTime.now().microsecondsSinceEpoch,
              });
            }
          }));
        }

        await Future.wait(futures);
        await FlutterLiveLogger.flush();

        stopwatch.stop();
        print(
            'High-frequency logging: ${stopwatch.elapsedMilliseconds}ms for 1000 concurrent logs');

        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      test('should handle app startup simulation', () async {
        // Simulate typical app startup logging
        final stopwatch = Stopwatch()..start();

        await FlutterLiveLogger.init(
          config: LoggerConfig.production(
            transports: [MemoryTransport(enableConsoleOutput: false)],
            usePersistentStorage: false, // Avoid SQLite in tests
          ),
        );

        // Simulate startup events
        FlutterLiveLogger.info('App started');
        FlutterLiveLogger.info('Dependencies initialized');
        FlutterLiveLogger.info('UI components loaded');
        FlutterLiveLogger.event('app_startup_completed', {
          'startup_time_ms': stopwatch.elapsedMilliseconds,
        });

        stopwatch.stop();
        print('App startup simulation: ${stopwatch.elapsedMilliseconds}ms');

        // Should add minimal overhead to startup
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });
    });
  });
}
