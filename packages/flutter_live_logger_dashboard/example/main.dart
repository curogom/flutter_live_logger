import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

/// Standalone Dashboard Server Example
///
/// This example runs the Flutter Live Logger dashboard server independently.
/// You can access the dashboard by visiting http://localhost:7580 in your web browser.
void main() async {
  developer.log('Starting Flutter Live Logger Dashboard Server...');

  try {
    // Start dashboard server
    final server = DashboardServer();
    await server.start();

    developer.log('✅ Dashboard server started successfully!');
    developer.log('');
    developer.log('📊 Dashboard Connection Info:');
    developer.log('   HTTP API: http://localhost:7580');
    developer.log('   WebSocket: ws://localhost:7581');
    developer.log('   Web Dashboard: http://localhost:7580 (in development)');
    developer.log('');
    developer.log('💡 Usage:');
    developer.log('   1. Run your Flutter Live Logger app');
    developer.log('   2. Log messages will be sent to this server');
    developer.log('   3. Check the dashboard in your browser');
    developer.log('');
    developer.log('⏹️  Press Ctrl+C to stop the server');

    // Signal handling (Ctrl+C)
    ProcessSignal.sigint.watch().listen((signal) async {
      developer.log('\n🛑 Stopping server...');
      await server.stop();
      developer.log('✅ Server stopped gracefully.');
      exit(0);
    });

    // Server status monitoring
    _startStatusMonitoring();
  } catch (error, stackTrace) {
    developer.log('❌ Failed to start server: $error');
    developer.log('Stack trace: $stackTrace');
    exit(1);
  }
}

void _startStatusMonitoring() {
  Timer.periodic(const Duration(seconds: 30), (timer) {
    final now = DateTime.now().toIso8601String();
    developer
        .log('📊 [$now] Server running... (Memory: ${_getMemoryUsage()}MB)');
  });
}

String _getMemoryUsage() {
  try {
    final info = ProcessInfo.currentRss;
    return (info / (1024 * 1024)).toStringAsFixed(1);
  } catch (e) {
    return '?';
  }
}
