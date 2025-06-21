import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

/// Flutter Live Logger Web Dashboard Server
///
/// Provides HTTP API endpoints for the web dashboard to access log data,
/// statistics, and real-time streaming capabilities.
class DashboardServer {
  static const int defaultPort = 7580;
  static const List<int> fallbackPorts = [7581, 7582, 7583];
  static const String apiPrefix = '/api/v1';

  HttpServer? _server;
  int? _actualPort;

  /// Start the dashboard server on the specified port
  Future<HttpServer> start({
    int port = defaultPort,
    List<int>? fallbackPorts,
  }) async {
    final handler = _createHandler();

    // Try to start on the preferred port, fall back if needed
    final portsToTry = [
      port,
      ...(fallbackPorts ?? DashboardServer.fallbackPorts)
    ];

    for (final tryPort in portsToTry) {
      try {
        _server = await shelf_io.serve(handler, 'localhost', tryPort);
        _actualPort = tryPort;
        print('Flutter Live Logger Dashboard Server started on port $tryPort');
        return _server!;
      } catch (e) {
        if (tryPort == portsToTry.last) {
          throw Exception(
              'Could not start server on any available port: $portsToTry');
        }
        // Try next port
        continue;
      }
    }

    throw Exception('Failed to start server');
  }

  /// Stop the dashboard server
  Future<void> stop() async {
    await _server?.close();
    _server = null;
    _actualPort = null;
  }

  /// Get the actual port the server is running on
  int? get port => _actualPort;

  /// Create the main request handler with all routes
  Handler _createHandler() {
    return Pipeline()
        .addMiddleware(corsHeaders())
        .addMiddleware(_loggingMiddleware())
        .addHandler(_router);
  }

  /// Main router for all API endpoints
  Response _router(Request request) {
    final path = request.url.path;

    // Handle CORS preflight requests
    if (request.method == 'OPTIONS') {
      return Response.ok('', headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
    }

    // Route API requests
    if (path.startsWith('api/v1/')) {
      return _handleApiRequest(request);
    }

    // Serve static dashboard files (placeholder)
    if (path.isEmpty || path == '/') {
      return _serveDashboard();
    }

    return Response.notFound(
      jsonEncode({'error': 'Endpoint not found'}),
      headers: {'content-type': 'application/json'},
    );
  }

  /// Handle API requests
  Response _handleApiRequest(Request request) {
    final pathSegments = request.url.pathSegments;

    if (pathSegments.length < 3) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Invalid API path'}),
        headers: {'content-type': 'application/json'},
      );
    }

    final endpoint = pathSegments[2]; // Skip 'api' and 'v1'

    switch (endpoint) {
      case 'logs':
        return _handleLogsEndpoint(request);
      case 'stats':
        return _handleStatsEndpoint(request);
      default:
        return Response.notFound(
          jsonEncode({'error': 'Endpoint not found'}),
          headers: {'content-type': 'application/json'},
        );
    }
  }

  /// Handle /api/v1/logs endpoint
  Response _handleLogsEndpoint(Request request) {
    if (request.method != 'GET') {
      return Response(405, body: jsonEncode({'error': 'Method not allowed'}));
    }

    try {
      final queryParams = request.url.queryParameters;

      // Parse pagination parameters with validation
      int page = 0;
      int limit = 50;

      if (queryParams.containsKey('page')) {
        final pageStr = queryParams['page']!;
        final parsedPage = int.tryParse(pageStr);
        if (parsedPage == null) {
          return Response.badRequest(
            body: jsonEncode(
                {'error': 'Invalid parameter: page must be a number'}),
            headers: {'content-type': 'application/json'},
          );
        }
        page = parsedPage;
      }

      if (queryParams.containsKey('limit')) {
        final limitStr = queryParams['limit']!;
        final parsedLimit = int.tryParse(limitStr);
        if (parsedLimit == null) {
          return Response.badRequest(
            body: jsonEncode(
                {'error': 'Invalid parameter: limit must be a number'}),
            headers: {'content-type': 'application/json'},
          );
        }
        if (parsedLimit <= 0 || parsedLimit > 1000) {
          return Response.badRequest(
            body: jsonEncode({
              'error': 'Invalid parameter: limit must be between 1 and 1000'
            }),
            headers: {'content-type': 'application/json'},
          );
        }
        limit = parsedLimit;
      }

      // Parse filter parameters
      final level = queryParams['level'];
      final search = queryParams['search']?.replaceAll('+', ' ');
      final startTime = queryParams['startTime'];
      final endTime = queryParams['endTime'];

      // Mock response for TDD Green phase
      final response = {
        'logs': _getMockLogs(
          limit: limit,
          level: level,
          search: search,
        ),
        'total': 100, // Mock total
        'page': page,
        'limit': limit,
        'hasMore': page * limit < 100,
      };

      // Add time range info if provided
      if (startTime != null && endTime != null) {
        response['timeRange'] = {
          'start': startTime,
          'end': endTime,
        };
      }

      // Add search query if provided
      if (search != null) {
        response['searchQuery'] = search;
      }

      return Response.ok(
        jsonEncode(response),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Internal server error'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  /// Handle /api/v1/stats endpoint
  Response _handleStatsEndpoint(Request request) {
    if (request.method != 'GET') {
      return Response(405, body: jsonEncode({'error': 'Method not allowed'}));
    }

    final pathSegments = request.url.pathSegments;

    if (pathSegments.length > 3 && pathSegments[3] == 'performance') {
      // Detailed performance stats
      return Response.ok(
        jsonEncode({
          'throughput': 1234.5,
          'averageResponseTime': 45.2,
          'memoryUsage': 128.7,
          'errorRate': 0.5,
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    // General dashboard metrics
    return Response.ok(
      jsonEncode({
        'totalLogs': 10000,
        'logsByLevel': {
          'error': 250,
          'warning': 500,
          'info': 8000,
          'debug': 1250,
        },
        'recentActivity': [
          {'timestamp': DateTime.now().millisecondsSinceEpoch, 'count': 45},
          {
            'timestamp': DateTime.now()
                .subtract(const Duration(minutes: 1))
                .millisecondsSinceEpoch,
            'count': 38
          },
        ],
        'performance': {
          'throughput': 1234.5,
          'responseTime': 45.2,
        },
      }),
      headers: {'content-type': 'application/json'},
    );
  }

  /// Serve the dashboard HTML (placeholder)
  Response _serveDashboard() {
    const html = '''
<!DOCTYPE html>
<html>
<head>
    <title>Flutter Live Logger Dashboard</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
    <h1>Flutter Live Logger Dashboard</h1>
    <p>Dashboard UI will be implemented here</p>
    <p>API available at <a href="/api/v1/logs">/api/v1/logs</a></p>
</body>
</html>
    ''';

    return Response.ok(html, headers: {'content-type': 'text/html'});
  }

  /// Generate mock log data for testing
  List<Map<String, dynamic>> _getMockLogs({
    int limit = 50,
    String? level,
    String? search,
  }) {
    final logs = <Map<String, dynamic>>[];
    final levels = ['error', 'warning', 'info', 'debug'];
    final messages = [
      'User authentication successful',
      'Database connection established',
      'API request processed',
      'File upload completed',
      'Cache invalidated',
      'Session expired',
      'Network timeout occurred',
      'Validation failed',
    ];

    for (int i = 0; i < limit; i++) {
      final logLevel = level ?? levels[i % levels.length];
      final message = messages[i % messages.length];

      // Apply search filter
      if (search != null &&
          !message.toLowerCase().contains(search.toLowerCase())) {
        continue;
      }

      logs.add({
        'id': i + 1,
        'level': logLevel,
        'message': message,
        'timestamp': DateTime.now()
            .subtract(Duration(minutes: i))
            .millisecondsSinceEpoch,
        'source': 'flutter_app',
        'data': jsonEncode({'userId': '123', 'action': 'test'}),
      });
    }

    return logs;
  }

  /// Logging middleware for request/response logging
  Middleware _loggingMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        final stopwatch = Stopwatch()..start();
        final response = await innerHandler(request);
        stopwatch.stop();

        print('${request.method} ${request.requestedUri.path} - '
            '${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');

        return response;
      };
    };
  }
}
