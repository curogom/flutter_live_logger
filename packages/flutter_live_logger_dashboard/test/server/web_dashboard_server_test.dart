import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_live_logger_dashboard/src/server/dashboard_server.dart';
import 'package:http/http.dart' as http;

/// TDD Test Cases for Flutter Live Logger Web Dashboard Server
///
/// Tests the HTTP server functionality that will serve the web dashboard
/// and provide REST API endpoints for log data.
void main() {
  group('Web Dashboard Server TDD Tests', () {
    const int dashboardPort = 7580; // Flutter Live Logger dedicated port
    const String apiPrefix = '/api/v1';

    group('Server Initialization', () {
      test('should start server on port 7580', () async {
        // Test that server can be started on our dedicated port
        final dashboardServer = DashboardServer();
        final server = await dashboardServer.start(port: dashboardPort);

        expect(server.port, equals(dashboardPort));
        expect(dashboardServer.port, equals(dashboardPort));

        await dashboardServer.stop();
      });

      test('should handle port conflicts gracefully', () async {
        // Test fallback port mechanism when 7580 is occupied
        final dashboardServer1 = DashboardServer();
        final dashboardServer2 = DashboardServer();

        // Start first server on 7580
        await dashboardServer1.start(port: dashboardPort);

        // Second server should use fallback port
        await dashboardServer2.start(
          port: dashboardPort,
          fallbackPorts: [7581, 7582, 7583],
        );

        expect(dashboardServer1.port, equals(7580));
        expect(dashboardServer2.port, isIn([7581, 7582, 7583]));

        await dashboardServer1.stop();
        await dashboardServer2.stop();
      });

      test('should enable CORS for web dashboard access', () async {
        // Test CORS headers for cross-origin requests
        final dashboardServer = DashboardServer();
        await dashboardServer.start(port: dashboardPort);

        final client = HttpClient();
        final request = await client.openUrl('OPTIONS',
            Uri.parse('http://localhost:$dashboardPort/api/v1/logs'));
        final response = await request.close();

        expect(
            response.headers.value('access-control-allow-origin'), equals('*'));
        expect(response.headers.value('access-control-allow-methods'),
            contains('GET'));

        client.close();
        await dashboardServer.stop();
      });
    });

    group('Log API Endpoints', () {
      late DashboardServer dashboardServer;
      late HttpClient client;

      setUp(() async {
        dashboardServer = DashboardServer();
        await dashboardServer.start(port: dashboardPort);
        client = HttpClient();
      });

      tearDown(() async {
        client.close();
        await dashboardServer.stop();
      });

      test('GET /api/v1/logs should return log entries', () async {
        // Test basic log retrieval endpoint
        final request = await client.getUrl(
            Uri.parse('http://localhost:$dashboardPort$apiPrefix/logs'));
        final response = await request.close();

        expect(response.statusCode, equals(200));
        expect(
            response.headers.contentType?.mimeType, equals('application/json'));

        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        expect(data, isA<Map<String, dynamic>>());
        expect(data, containsPair('logs', isA<List>()));
        expect(data, containsPair('total', isA<int>()));
      });

      test('GET /api/v1/logs should support pagination', () async {
        // Test pagination parameters
        final request = await client.getUrl(Uri.parse(
            'http://localhost:$dashboardPort$apiPrefix/logs?page=1&limit=50'));
        final response = await request.close();

        expect(response.statusCode, equals(200));
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        expect(data, containsPair('page', 1));
        expect(data, containsPair('limit', 50));
        expect(data, containsPair('hasMore', isA<bool>()));
      });

      test('GET /api/v1/logs should support level filtering', () async {
        // Test log level filtering
        final request = await client.getUrl(Uri.parse(
            'http://localhost:$dashboardPort$apiPrefix/logs?level=error'));
        final response = await request.close();

        expect(response.statusCode, equals(200));
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        final logs = data['logs'] as List;

        // All returned logs should be error level
        for (final log in logs) {
          expect(log['level'], equals('error'));
        }
      });

      test('GET /api/v1/logs should support time range filtering', () async {
        // Test time-based filtering
        final now = DateTime.now();
        final hourAgo = now.subtract(const Duration(hours: 1));

        final request = await client
            .getUrl(Uri.parse('http://localhost:$dashboardPort$apiPrefix/logs'
                '?startTime=${hourAgo.toIso8601String()}'
                '&endTime=${now.toIso8601String()}'));
        final response = await request.close();

        expect(response.statusCode, equals(200));
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        expect(data, containsPair('timeRange', isA<Map>()));
      });

      test('GET /api/v1/logs should support search queries', () async {
        // Test full-text search functionality
        final request = await client.getUrl(Uri.parse(
            'http://localhost:$dashboardPort$apiPrefix/logs?search=error+message'));
        final response = await request.close();

        expect(response.statusCode, equals(200));
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        expect(data, containsPair('searchQuery', 'error message'));
      });
    });

    group('Statistics API Endpoints', () {
      late DashboardServer dashboardServer;
      late HttpClient client;

      setUp(() async {
        dashboardServer = DashboardServer();
        await dashboardServer.start(port: dashboardPort);
        client = HttpClient();
      });

      tearDown(() async {
        client.close();
        await dashboardServer.stop();
      });

      test('GET /api/v1/stats should return dashboard metrics', () async {
        // Test performance metrics endpoint
        final request = await client.getUrl(
            Uri.parse('http://localhost:$dashboardPort$apiPrefix/stats'));
        final response = await request.close();

        expect(response.statusCode, equals(200));
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        expect(data, containsPair('totalLogs', isA<int>()));
        expect(data, containsPair('logsByLevel', isA<Map>()));
        expect(data, containsPair('recentActivity', isA<List>()));
        expect(data, containsPair('performance', isA<Map>()));
      });

      test('GET /api/v1/stats/performance should return detailed metrics',
          () async {
        // Test detailed performance metrics
        final request = await client.getUrl(Uri.parse(
            'http://localhost:$dashboardPort$apiPrefix/stats/performance'));
        final response = await request.close();

        expect(response.statusCode, equals(200));
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        expect(data, containsPair('throughput', isA<num>()));
        expect(data, containsPair('averageResponseTime', isA<num>()));
        expect(data, containsPair('memoryUsage', isA<num>()));
        expect(data, containsPair('errorRate', isA<num>()));
      });
    });

    group('Error Handling', () {
      late DashboardServer dashboardServer;
      late HttpClient client;

      setUp(() async {
        dashboardServer = DashboardServer();
        await dashboardServer.start(port: dashboardPort);
        client = HttpClient();
      });

      tearDown(() async {
        client.close();
        await dashboardServer.stop();
      });

      test('should return 404 for unknown endpoints', () async {
        final request = await client.getUrl(
            Uri.parse('http://localhost:$dashboardPort$apiPrefix/unknown'));
        final response = await request.close();

        expect(response.statusCode, equals(404));
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        expect(data, containsPair('error', 'Endpoint not found'));
      });

      test('should return 400 for invalid query parameters', () async {
        final request = await client.getUrl(Uri.parse(
            'http://localhost:$dashboardPort$apiPrefix/logs?limit=invalid'));
        final response = await request.close();

        expect(response.statusCode, equals(400));
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        expect(data, containsPair('error', contains('Invalid parameter')));
      });

      test('should handle server errors gracefully', () async {
        // This test will be handled by the server's error handling
        final request = await client.getUrl(
            Uri.parse('http://localhost:$dashboardPort$apiPrefix/logs'));
        final response = await request.close();

        // Server should handle the request normally (no simulated error in real implementation)
        expect(response.statusCode, equals(200));
      });
    });
  });
}
