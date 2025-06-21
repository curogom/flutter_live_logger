import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter_live_logger_dashboard/src/server/websocket_server.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';

/// TDD Test Cases for Flutter Live Logger WebSocket Real-time Streaming
///
/// Tests the WebSocket functionality for real-time log streaming to the
/// web dashboard.
void main() {
  group('WebSocket Real-time Streaming TDD Tests', () {
    int currentPort = 7581; // Start from base port
    const String websocketPath = '/ws/logs';

    // Helper to get next available port
    int getNextPort() => currentPort++;

    group('WebSocket Connection', () {
      test('should establish WebSocket connection on port 7581', () async {
        // Test WebSocket server startup and connection
        final port = getNextPort();
        final server = await WebSocketServer.start(port: port);

        // Create WebSocket connection with auth header
        final socket = await WebSocket.connect(
          'ws://localhost:$port$websocketPath',
          headers: {'Authorization': 'Bearer valid_token'},
        );
        final channel = IOWebSocketChannel(socket);

        expect(channel.closeCode, isNull); // Connection should be open

        await channel.sink.close();
        await server.stop();
        await Future.delayed(
            const Duration(milliseconds: 100)); // Wait for cleanup
      });

      test('should handle multiple concurrent connections', () async {
        // Test that server can handle multiple dashboard clients
        final port = getNextPort();
        final server = await WebSocketServer.start(port: port);
        final channels = <IOWebSocketChannel>[];

        // Create 5 concurrent connections
        for (int i = 0; i < 5; i++) {
          final socket = await WebSocket.connect(
            'ws://localhost:$port$websocketPath',
            headers: {'Authorization': 'Bearer valid_token$i'},
          );
          final channel = IOWebSocketChannel(socket);
          channels.add(channel);
        }

        expect(channels.length, equals(5));
        expect(server.clientCount, equals(5));

        // Clean up
        for (final channel in channels) {
          await channel.sink.close();
        }
        await server.stop();
        await Future.delayed(
            const Duration(milliseconds: 100)); // Wait for cleanup
      });

      test('should authenticate WebSocket connections', () async {
        // Test authentication for WebSocket connections
        final port = getNextPort();
        final server = await WebSocketServer.start(port: port);

        // Test connection without auth token (should fail)
        try {
          await WebSocket.connect('ws://localhost:$port$websocketPath');
          fail('Should have thrown WebSocketException');
        } catch (e) {
          expect(e, isA<WebSocketException>());
        }

        // Test connection with invalid auth token (should fail)
        try {
          await WebSocket.connect(
            'ws://localhost:$port$websocketPath',
            headers: {'Authorization': 'Bearer invalid'},
          );
          fail('Should have thrown WebSocketException');
        } catch (e) {
          expect(e, isA<WebSocketException>());
        }

        // Test connection with valid auth token (should succeed)
        final socket = await WebSocket.connect(
          'ws://localhost:$port$websocketPath',
          headers: {'Authorization': 'Bearer valid_token'},
        );
        final authenticatedChannel = IOWebSocketChannel(socket);
        expect(authenticatedChannel.closeCode, isNull);

        await authenticatedChannel.sink.close();
        await server.stop();
        await Future.delayed(
            const Duration(milliseconds: 100)); // Wait for cleanup
      });
    });

    group('Real-time Log Streaming', () {
      test('should stream new log entries in real-time', () async {
        // Test that new logs are immediately sent to connected clients
        final port = getNextPort();
        final server = await WebSocketServer.start(port: port);
        final socket = await WebSocket.connect(
          'ws://localhost:$port$websocketPath',
          headers: {'Authorization': 'Bearer valid_token'},
        );
        final channel = IOWebSocketChannel(socket);

        final receivedMessages = <Map<String, dynamic>>[];
        final subscription = channel.stream.listen((message) {
          final data = jsonDecode(message as String);
          if (data['type'] == 'log') {
            receivedMessages.add(data as Map<String, dynamic>);
          }
        });

        // Wait for welcome message
        await Future.delayed(const Duration(milliseconds: 50));

        // Simulate new log entry
        await server.broadcastLogEntry({
          'level': 'info',
          'message': 'Test log message',
          'timestamp': DateTime.now().toIso8601String(),
          'data': {'userId': '123'},
        });

        // Wait for message to be received
        await Future.delayed(const Duration(milliseconds: 100));

        expect(receivedMessages.length, equals(1));
        expect(receivedMessages.first['message'], equals('Test log message'));
        expect(receivedMessages.first['level'], equals('info'));

        await subscription.cancel();
        await channel.sink.close();
        await server.stop();
        await Future.delayed(
            const Duration(milliseconds: 100)); // Wait for cleanup
      });

      test('should support log level filtering in real-time', () async {
        // Test that clients can subscribe to specific log levels
        final port = getNextPort();
        final server = await WebSocketServer.start(port: port);
        final socket = await WebSocket.connect(
          'ws://localhost:$port$websocketPath',
          headers: {'Authorization': 'Bearer valid_token'},
        );
        final channel = IOWebSocketChannel(socket);

        // Subscribe to error logs only
        channel.sink.add(jsonEncode({
          'type': 'subscribe',
          'filters': {'level': 'error'},
        }));

        final receivedMessages = <Map<String, dynamic>>[];
        final subscription = channel.stream.listen((message) {
          final data = jsonDecode(message as String);
          if (data['type'] == 'log') {
            receivedMessages.add(data as Map<String, dynamic>);
          }
        });

        // Wait for subscription to be processed
        await Future.delayed(const Duration(milliseconds: 50));

        // Send info log (should be filtered out)
        await server.broadcastLogEntry({
          'level': 'info',
          'message': 'Info message',
          'timestamp': DateTime.now().toIso8601String(),
        });

        // Send error log (should be received)
        await server.broadcastLogEntry({
          'level': 'error',
          'message': 'Error message',
          'timestamp': DateTime.now().toIso8601String(),
        });

        await Future.delayed(const Duration(milliseconds: 100));

        expect(receivedMessages.length, equals(1));
        expect(receivedMessages.first['level'], equals('error'));

        await subscription.cancel();
        await channel.sink.close();
        await server.stop();
        await Future.delayed(
            const Duration(milliseconds: 100)); // Wait for cleanup
      });

      test('should handle client-specific subscriptions', () async {
        // Test that different clients can have different filters
        final port = getNextPort();
        final server = await WebSocketServer.start(port: port);

        // Client 1: Subscribe to error logs
        final socket1 = await WebSocket.connect(
          'ws://localhost:$port$websocketPath',
          headers: {'Authorization': 'Bearer token1'},
        );
        final channel1 = IOWebSocketChannel(socket1);
        channel1.sink.add(jsonEncode({
          'type': 'subscribe',
          'filters': {'level': 'error'},
        }));

        // Client 2: Subscribe to all logs
        final socket2 = await WebSocket.connect(
          'ws://localhost:$port$websocketPath',
          headers: {'Authorization': 'Bearer token2'},
        );
        final channel2 = IOWebSocketChannel(socket2);
        channel2.sink.add(jsonEncode({
          'type': 'subscribe',
          'filters': {},
        }));

        final messages1 = <Map<String, dynamic>>[];
        final messages2 = <Map<String, dynamic>>[];

        final sub1 = channel1.stream.listen((message) {
          final data = jsonDecode(message as String);
          if (data['type'] == 'log')
            messages1.add(data as Map<String, dynamic>);
        });

        final sub2 = channel2.stream.listen((message) {
          final data = jsonDecode(message as String);
          if (data['type'] == 'log')
            messages2.add(data as Map<String, dynamic>);
        });

        // Wait for subscriptions to be processed
        await Future.delayed(const Duration(milliseconds: 50));

        // Send different level logs
        await server.broadcastLogEntry({'level': 'info', 'message': 'Info'});
        await server.broadcastLogEntry({'level': 'error', 'message': 'Error'});

        await Future.delayed(const Duration(milliseconds: 100));

        // Client 1 should only receive error log
        expect(messages1.length, equals(1));
        expect(messages1.first['level'], equals('error'));

        // Client 2 should receive both logs
        expect(messages2.length, equals(2));

        await sub1.cancel();
        await sub2.cancel();
        await channel1.sink.close();
        await channel2.sink.close();
        await server.stop();
        await Future.delayed(
            const Duration(milliseconds: 100)); // Wait for cleanup
      });
    });

    group('Performance and Reliability', () {
      test('should handle high-frequency log streaming', () async {
        // Test performance with rapid log generation
        final port = getNextPort();
        final server = await WebSocketServer.start(port: port);
        final socket = await WebSocket.connect(
          'ws://localhost:$port$websocketPath',
          headers: {'Authorization': 'Bearer valid_token'},
        );
        final channel = IOWebSocketChannel(socket);

        final receivedCount = <int>[0];
        final subscription = channel.stream.listen((message) {
          final data = jsonDecode(message as String);
          if (data['type'] == 'log') {
            receivedCount[0]++;
          }
        });

        // Send 50 logs rapidly (reduced for test speed)
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 50; i++) {
          await server.broadcastLogEntry({
            'level': 'info',
            'message': 'High frequency log $i',
            'timestamp': DateTime.now().toIso8601String(),
          });
        }

        // Wait for all messages to be processed
        await Future.delayed(const Duration(seconds: 1));
        stopwatch.stop();

        expect(receivedCount[0], equals(50));
        expect(stopwatch.elapsedMilliseconds,
            lessThan(5000)); // Should complete in <5s

        await subscription.cancel();
        await channel.sink.close();
        await server.stop();
        await Future.delayed(
            const Duration(milliseconds: 100)); // Wait for cleanup
      });

      test('should handle connection drops gracefully', () async {
        // Test reconnection and message buffering
        final port = getNextPort();
        final server = await WebSocketServer.start(port: port);
        var socket = await WebSocket.connect(
          'ws://localhost:$port$websocketPath',
          headers: {'Authorization': 'Bearer valid_token'},
        );
        var channel = IOWebSocketChannel(socket);

        // Abruptly close connection
        await channel.sink.close(1000, 'Client disconnect');

        // Simulate logs while disconnected
        await server.broadcastLogEntry(
            {'level': 'error', 'message': 'While disconnected'});

        // Reconnect
        socket = await WebSocket.connect(
          'ws://localhost:$port$websocketPath',
          headers: {'Authorization': 'Bearer valid_token'},
        );
        channel = IOWebSocketChannel(socket);

        // Request missed messages
        channel.sink.add(jsonEncode({
          'type': 'get_missed',
          'since': DateTime.now()
              .subtract(const Duration(minutes: 1))
              .toIso8601String(),
        }));

        final receivedMessages = <Map<String, dynamic>>[];
        final subscription = channel.stream.listen((message) {
          receivedMessages
              .add(jsonDecode(message as String) as Map<String, dynamic>);
        });

        await Future.delayed(const Duration(milliseconds: 200));

        // Should receive the missed message
        expect(
            receivedMessages
                .any((msg) => msg['message'] == 'While disconnected'),
            isTrue);

        await subscription.cancel();
        await channel.sink.close();
        await server.stop();
        await Future.delayed(
            const Duration(milliseconds: 100)); // Wait for cleanup
      });
    });
  });
}

/// Helper function to start WebSocket server (will be implemented)
Future<HttpServer> _startWebSocketServer({required int port}) async {
  // This will fail initially - TDD Red phase
  throw UnimplementedError('WebSocket server implementation not yet created');
}

/// Helper function to simulate new log entry (will be implemented)
Future<void> _simulateNewLogEntry(Map<String, dynamic> logEntry) async {
  // This will fail initially - TDD Red phase
  throw UnimplementedError('Log simulation not yet implemented');
}
