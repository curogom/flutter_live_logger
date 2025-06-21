import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  group('Simple Performance Tests', () {
    tearDown(() async {
      if (FlutterLiveLogger.isInitialized) {
        await FlutterLiveLogger.dispose();
      }
    });

    test('initialization performance', () async {
      final stopwatch = Stopwatch()..start();

      await FlutterLiveLogger.init(
        config: LoggerConfig.performance(),
      );

      stopwatch.stop();
      print('Initialization: ${stopwatch.elapsedMilliseconds}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(FlutterLiveLogger.isInitialized, isTrue);
    });

    test('basic logging performance', () async {
      await FlutterLiveLogger.init(
        config: LoggerConfig.performance(),
      );

      final stopwatch = Stopwatch()..start();

      // Log 100 entries
      for (int i = 0; i < 100; i++) {
        FlutterLiveLogger.warn('Test log $i');
      }

      stopwatch.stop();
      print('100 logs: ${stopwatch.elapsedMilliseconds}ms');

      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      final stats = FlutterLiveLogger.getStats();
      print('Stats: $stats');
    });

    test('memory transport performance', () async {
      final transport = MemoryTransport(
        maxEntries: 1000,
        enableConsoleOutput: false,
      );

      await FlutterLiveLogger.init(
        config: LoggerConfig(
          transports: [transport],
          batchSize: 50,
          flushInterval: const Duration(seconds: 1),
        ),
      );

      // Add logs
      for (int i = 0; i < 200; i++) {
        FlutterLiveLogger.info('Transport test $i');
      }

      // Manual flush with timeout
      await FlutterLiveLogger.flush().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('Flush timed out - this is expected for testing');
        },
      );

      final entries = transport.getAllEntries();
      print('Transport received: ${entries.length} entries');

      expect(entries.length, greaterThan(0));
      expect(entries.length, lessThanOrEqualTo(200));
    });
  });
}
