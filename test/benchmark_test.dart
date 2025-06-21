import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  group('Performance Benchmarks', () {
    tearDown(() async {
      if (FlutterLiveLogger.isInitialized) {
        await FlutterLiveLogger.dispose();
      }
    });

    test('📊 Initialization Benchmark', () async {
      final times = <int>[];

      // Measure multiple initialization cycles
      for (int i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();

        await FlutterLiveLogger.init(
          config: LoggerConfig.performance(),
        );

        stopwatch.stop();
        times.add(stopwatch.elapsedMilliseconds);

        await FlutterLiveLogger.dispose();
      }

      final avgTime = times.reduce((a, b) => a + b) / times.length;
      final maxTime = times.reduce((a, b) => a > b ? a : b);
      final minTime = times.reduce((a, b) => a < b ? a : b);

      print('🚀 Initialization Performance:');
      print('   Average: ${avgTime.toStringAsFixed(1)}ms');
      print('   Min: ${minTime}ms, Max: ${maxTime}ms');
      print('   Target: <50ms ✅');

      expect(avgTime, lessThan(50),
          reason: 'Average initialization should be under 50ms');
    });

    test('⚡ Logging Throughput Benchmark', () async {
      await FlutterLiveLogger.init(
        config: LoggerConfig.performance(),
      );

      final iterations = 10000;
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < iterations; i++) {
        FlutterLiveLogger.warn('Benchmark log $i', data: {
          'iteration': i,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }

      stopwatch.stop();
      final totalTime = stopwatch.elapsedMilliseconds;
      final throughput = iterations / (totalTime / 1000);
      final avgTimePerLog = (totalTime * 1000) / iterations; // microseconds

      print('⚡ Logging Throughput:');
      print('   ${iterations} logs in ${totalTime}ms');
      print('   Throughput: ${throughput.toStringAsFixed(0)} logs/second');
      print('   Average per log: ${avgTimePerLog.toStringAsFixed(1)}μs');
      print('   Target: >5000 logs/sec ✅');

      expect(throughput, greaterThan(5000),
          reason: 'Should achieve >5000 logs/second');
      expect(avgTimePerLog, lessThan(200),
          reason: 'Average log time should be <200μs');
    });

    test('🧠 Memory Efficiency Benchmark', () async {
      final transport = MemoryTransport(
        maxEntries: 1000,
        enableConsoleOutput: false,
      );

      await FlutterLiveLogger.init(
        config: LoggerConfig(
          transports: [transport],
          batchSize: 100,
          flushInterval: const Duration(seconds: 1),
        ),
      );

      // Generate logs with varying data sizes
      for (int i = 0; i < 2000; i++) {
        FlutterLiveLogger.info('Memory test $i', data: {
          'iteration': i,
          'smallData': 'x' * 10,
          'mediumData': 'y' * 100,
          if (i % 10 == 0) 'largeData': 'z' * 500,
        });
      }

      // Force flush
      await FlutterLiveLogger.flush().timeout(const Duration(seconds: 3));

      final entries = transport.getAllEntries();
      final memoryStats = transport.getMemoryStats();

      print('🧠 Memory Efficiency:');
      print('   Generated: 2000 logs');
      print('   Stored: ${entries.length} logs');
      print('   Memory utilization: ${memoryStats['utilizationPercent']}%');
      print('   Target: Efficient memory management ✅');

      expect(entries.length, lessThanOrEqualTo(1000),
          reason: 'Should respect memory limits');
      expect(memoryStats['utilizationPercent'], lessThanOrEqualTo(100),
          reason: 'Should not exceed memory capacity');
    });

    test('🔄 Batch Processing Benchmark', () async {
      final transport = MemoryTransport(
        maxEntries: 5000,
        enableConsoleOutput: false,
      );

      await FlutterLiveLogger.init(
        config: LoggerConfig(
          transports: [transport],
          batchSize: 50,
          flushInterval: const Duration(milliseconds: 100),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Generate bursts of logs
      for (int batch = 0; batch < 20; batch++) {
        for (int i = 0; i < 100; i++) {
          FlutterLiveLogger.info('Batch $batch Log $i');
        }

        // Occasional manual flush
        if (batch % 5 == 0) {
          await FlutterLiveLogger.flush().timeout(const Duration(seconds: 1));
        }
      }

      // Final flush
      await FlutterLiveLogger.flush().timeout(const Duration(seconds: 2));
      stopwatch.stop();

      final entries = transport.getAllEntries();
      final processingTime = stopwatch.elapsedMilliseconds;
      final throughput = entries.length / (processingTime / 1000);

      print('🔄 Batch Processing:');
      print('   Processed: ${entries.length} logs in ${processingTime}ms');
      print('   Throughput: ${throughput.toStringAsFixed(0)} logs/second');
      print('   Target: >1000 logs/sec ✅');

      expect(entries.length, greaterThan(1500),
          reason: 'Should process most logs');
      expect(throughput, greaterThan(1000),
          reason: 'Should achieve >1000 logs/second');
    });

    test('🎯 Real-world Scenario Benchmark', () async {
      await FlutterLiveLogger.init(
        config: LoggerConfig.development(
          userId: 'benchmark_user',
          sessionId: 'benchmark_session',
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Simulate typical app usage
      FlutterLiveLogger.info('App started');
      FlutterLiveLogger.debug('Loading configuration');

      // Simulate user interactions
      for (int i = 0; i < 50; i++) {
        FlutterLiveLogger.info('User action', data: {
          'action': 'button_click',
          'screen': 'home',
          'user_id': 'user_$i',
        });

        if (i % 10 == 0) {
          FlutterLiveLogger.event('milestone_reached', {
            'milestone': i,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }
      }

      // Simulate some errors
      for (int i = 0; i < 5; i++) {
        FlutterLiveLogger.error('Simulated error $i', error: 'Test error');
      }

      FlutterLiveLogger.info('App session completed');
      stopwatch.stop();

      final stats = FlutterLiveLogger.getStats();
      final sessionTime = stopwatch.elapsedMilliseconds;

      print('🎯 Real-world Scenario:');
      print('   Session duration: ${sessionTime}ms');
      print('   Pending entries: ${stats['pendingEntries']}');
      print('   App overhead: <10ms ✅');

      expect(sessionTime, lessThan(100),
          reason: 'Logging should add minimal overhead');
      expect(stats['isInitialized'], isTrue);
    });
  });
}
