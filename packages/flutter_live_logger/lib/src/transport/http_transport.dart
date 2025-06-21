/// Flutter Live Logger - HTTP Transport
///
/// Network-based transport for sending logs to remote servers.
/// Supports batching, retry logic, and authentication.
///
/// Example:
/// ```dart
/// final transport = HttpTransport(
///   config: HttpTransportConfig(
///     endpoint: 'https://api.example.com/logs',
///     apiKey: 'your-api-key',
///     batchSize: 50,
///   ),
/// );
/// ```

library flutter_live_logger_http_transport;

import 'dart:convert';
import 'dart:io' show gzip, Platform;
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/log_entry.dart';
import 'log_transport.dart';

/// Configuration for HTTP transport
///
/// Supports various authentication methods and customizable request parameters.
///
/// Example with API key:
/// ```dart
/// final config = HttpTransportConfig.withApiKey(
///   endpoint: 'https://api.example.com/logs',
///   apiKey: 'your-api-key',
/// );
/// ```
///
/// Example with bearer token:
/// ```dart
/// final config = HttpTransportConfig.withBearerToken(
///   endpoint: 'https://api.example.com/logs',
///   token: 'your-jwt-token',
/// );
/// ```
class HttpTransportConfig {
  final String endpoint;
  final Map<String, String> headers;
  final String method;
  final String contentType;
  final Duration timeout;
  final Duration retryDelay;
  final int maxRetries;
  final int batchSize;

  const HttpTransportConfig({
    required this.endpoint,
    this.headers = const {},
    this.method = 'POST',
    this.contentType = 'application/json',
    this.timeout = const Duration(seconds: 30),
    this.retryDelay = const Duration(seconds: 1),
    this.maxRetries = 3,
    this.batchSize = 50,
  });

  /// Create configuration with API key authentication
  factory HttpTransportConfig.withApiKey({
    required String endpoint,
    required String apiKey,
    String apiKeyHeader = 'X-API-Key',
    String method = 'POST',
    String contentType = 'application/json',
    Duration timeout = const Duration(seconds: 30),
    Duration retryDelay = const Duration(seconds: 1),
    int maxRetries = 3,
    int batchSize = 50,
    Map<String, String> additionalHeaders = const {},
  }) {
    return HttpTransportConfig(
      endpoint: endpoint,
      headers: {
        apiKeyHeader: apiKey,
        ...additionalHeaders,
      },
      method: method,
      contentType: contentType,
      timeout: timeout,
      retryDelay: retryDelay,
      maxRetries: maxRetries,
      batchSize: batchSize,
    );
  }

  /// Create configuration with Bearer token authentication
  factory HttpTransportConfig.withBearerToken({
    required String endpoint,
    required String token,
    String method = 'POST',
    String contentType = 'application/json',
    Duration timeout = const Duration(seconds: 30),
    Duration retryDelay = const Duration(seconds: 1),
    int maxRetries = 3,
    int batchSize = 50,
    Map<String, String> additionalHeaders = const {},
  }) {
    return HttpTransportConfig(
      endpoint: endpoint,
      headers: {
        'Authorization': 'Bearer $token',
        ...additionalHeaders,
      },
      method: method,
      contentType: contentType,
      timeout: timeout,
      retryDelay: retryDelay,
      maxRetries: maxRetries,
      batchSize: batchSize,
    );
  }
}

/// HTTP transport for sending logs to remote endpoints
///
/// **Platform Support:**
/// - ✅ iOS, Android, macOS, Windows, Linux, Web
///
/// **CORS Support:**
/// - Uses package:http which handles CORS properly on web
/// - Server must set Access-Control-Allow-Origin: * (or specific domain)
/// - Server must handle OPTIONS preflight requests
///
/// Features:
/// - Cross-platform compatibility (including web)
/// - Automatic batching for efficiency
/// - Exponential backoff retry logic
/// - Gzip compression support (disabled on web due to CORS)
/// - Flexible authentication options
class HttpTransport extends LogTransport {
  final HttpTransportConfig _config;
  final http.Client _client;
  bool _disposed = false;

  HttpTransport({required HttpTransportConfig config})
      : _config = config,
        _client = http.Client();

  @override
  Future<void> send(List<LogEntry> entries) async {
    if (_disposed) {
      throw const TransportException('HttpTransport has been disposed');
    }

    if (entries.isEmpty) return;

    // Split entries into batches
    final batches = <List<LogEntry>>[];
    for (int i = 0; i < entries.length; i += _config.batchSize) {
      final end = (i + _config.batchSize < entries.length)
          ? i + _config.batchSize
          : entries.length;
      batches.add(entries.sublist(i, end));
    }

    // Send all batches
    final futures = batches.map((batch) => _sendBatch(batch));
    await Future.wait(futures);
  }

  Future<void> _sendBatch(List<LogEntry> entries) async {
    var retries = 0;
    Exception? lastError;

    while (retries <= _config.maxRetries) {
      try {
        await _sendBatchRequest(entries);
        return; // Success!
      } on http.ClientException catch (e) {
        lastError = e;
        if (retries < _config.maxRetries) {
          await _delayBeforeRetry(retries);
          retries++;
        }
      } catch (e) {
        if (retries < _config.maxRetries && _isRetryableError(e)) {
          lastError = e is Exception ? e : Exception(e.toString());
          await _delayBeforeRetry(retries);
          retries++;
        } else {
          throw TransportException('Failed to send log batch', e);
        }
      }
    }

    throw TransportException(
      'Failed to send log batch after ${_config.maxRetries + 1} attempts',
      lastError,
    );
  }

  Future<void> _sendBatchRequest(List<LogEntry> entries) async {
    final uri = Uri.parse(_config.endpoint);

    // Prepare payload
    final payload = {
      'logs': entries.map((entry) => entry.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
      'count': entries.length,
    };

    final jsonData = jsonEncode(payload);
    final headers = Map<String, String>.from(_config.headers);
    headers['Content-Type'] = _config.contentType;

    // Gzip compression (only on non-web platforms due to CORS complexity)
    List<int> body;
    if (!kIsWeb && jsonData.length > 1024) {
      body = gzip.encode(utf8.encode(jsonData));
      headers['Content-Encoding'] = 'gzip';
    } else {
      body = utf8.encode(jsonData);
    }

    late http.Response response;

    if (_config.method.toUpperCase() == 'POST') {
      response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(_config.timeout);
    } else if (_config.method.toUpperCase() == 'PUT') {
      response = await _client
          .put(uri, headers: headers, body: body)
          .timeout(_config.timeout);
    } else {
      throw TransportException('Unsupported HTTP method: ${_config.method}');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TransportException(
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<void> _delayBeforeRetry(int retryCount) async {
    // Exponential backoff with jitter
    final baseDelay = _config.retryDelay.inMilliseconds;
    final exponentialDelay = baseDelay * (1 << retryCount);
    final jitter =
        (exponentialDelay * 0.1 * (0.5 - DateTime.now().millisecond / 1000.0))
            .round();
    final totalDelay = exponentialDelay + jitter;

    await Future<void>.delayed(Duration(milliseconds: totalDelay));
  }

  bool _isRetryableError(dynamic error) {
    final message = error.toString().toLowerCase();

    // Don't retry for client errors (4xx)
    if (message.contains('400') ||
        message.contains('401') ||
        message.contains('403') ||
        message.contains('404')) {
      return false;
    }

    // Retry for server errors (5xx) and timeouts
    return true;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _client.close();
  }

  @override
  bool get isAvailable => !_disposed;

  @override
  int get maxBatchSize => _config.batchSize;

  /// Test connectivity to the endpoint
  ///
  /// Returns true if the endpoint is reachable and responds correctly.
  Future<bool> testConnection() async {
    if (_disposed) return false;

    try {
      final uri = Uri.parse(_config.endpoint);
      final headers = Map<String, String>.from(_config.headers);

      final response =
          await _client.head(uri, headers: headers).timeout(_config.timeout);

      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      return false;
    }
  }

  /// Get connection statistics
  Map<String, dynamic> getStats() {
    return {
      'endpoint': _config.endpoint,
      'batchSize': _config.batchSize,
      'timeout': _config.timeout.inSeconds,
      'maxRetries': _config.maxRetries,
      'disposed': _disposed,
      'platform': kIsWeb ? 'web' : 'native',
      'gzip_enabled': !kIsWeb,
    };
  }
}
