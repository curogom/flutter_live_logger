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
import 'dart:io';
import 'dart:async';
import '../core/log_entry.dart';
import 'log_transport.dart';

/// Configuration for HTTP transport behavior
class HttpTransportConfig {
  /// Remote endpoint URL for log submission
  final String endpoint;

  /// API key for authentication (if required)
  final String? apiKey;

  /// Custom headers to include with requests
  final Map<String, String> headers;

  /// Maximum number of log entries per batch
  final int batchSize;

  /// Request timeout duration
  final Duration timeout;

  /// Maximum number of retry attempts for failed requests
  final int maxRetries;

  /// Base delay between retry attempts
  final Duration retryDelay;

  /// HTTP method to use (POST, PUT)
  final String method;

  /// Content-Type header value
  final String contentType;

  const HttpTransportConfig({
    required this.endpoint,
    this.apiKey,
    this.headers = const {},
    this.batchSize = 50,
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.method = 'POST',
    this.contentType = 'application/json',
  });

  /// Create configuration with API key authentication
  factory HttpTransportConfig.withApiKey({
    required String endpoint,
    required String apiKey,
    String apiKeyHeader = 'X-API-Key',
    int batchSize = 50,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return HttpTransportConfig(
      endpoint: endpoint,
      apiKey: apiKey,
      headers: {apiKeyHeader: apiKey},
      batchSize: batchSize,
      timeout: timeout,
    );
  }

  /// Create configuration with bearer token authentication
  factory HttpTransportConfig.withBearerToken({
    required String endpoint,
    required String token,
    int batchSize = 50,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return HttpTransportConfig(
      endpoint: endpoint,
      headers: {'Authorization': 'Bearer $token'},
      batchSize: batchSize,
      timeout: timeout,
    );
  }
}

/// Transport that sends log entries to a remote HTTP endpoint
///
/// Features:
/// - Automatic batching for efficiency
/// - Exponential backoff retry logic
/// - Connection pooling and reuse
/// - Gzip compression support
/// - Flexible authentication options
class HttpTransport extends LogTransport {
  final HttpTransportConfig _config;
  final HttpClient _httpClient;
  bool _disposed = false;

  HttpTransport({required HttpTransportConfig config})
      : _config = config,
        _httpClient = HttpClient() {
    _httpClient.connectionTimeout = _config.timeout;
    _httpClient.idleTimeout = const Duration(seconds: 15);
  }

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
      } on SocketException catch (e) {
        lastError = e;
        if (retries < _config.maxRetries) {
          await _delayBeforeRetry(retries);
          retries++;
        }
      } on HttpException catch (e) {
        lastError = e;
        if (retries < _config.maxRetries && _isRetryableError(e)) {
          await _delayBeforeRetry(retries);
          retries++;
        } else {
          break; // Don't retry for non-retryable errors
        }
      } on TimeoutException catch (e) {
        lastError = e;
        if (retries < _config.maxRetries) {
          await _delayBeforeRetry(retries);
          retries++;
        }
      } catch (e) {
        throw TransportException('Failed to send log batch', e);
      }
    }

    throw TransportException(
      'Failed to send log batch after ${_config.maxRetries + 1} attempts',
      lastError,
    );
  }

  Future<void> _sendBatchRequest(List<LogEntry> entries) async {
    final uri = Uri.parse(_config.endpoint);
    final request = await _httpClient.openUrl(_config.method, uri);

    try {
      // Set headers
      request.headers.contentType = ContentType.parse(_config.contentType);
      _config.headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Prepare payload
      final payload = {
        'logs': entries.map((entry) => entry.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
        'count': entries.length,
      };

      final jsonData = jsonEncode(payload);
      final bytes = utf8.encode(jsonData);

      // Enable compression for large payloads
      if (bytes.length > 1024) {
        request.headers.set('Content-Encoding', 'gzip');
        request.add(gzip.encode(bytes));
      } else {
        request.add(bytes);
      }

      final response = await request.close();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Consume response to free connection
        await response.drain<void>();
      } else {
        final body = await response.transform(utf8.decoder).join();
        throw HttpException(
          'HTTP ${response.statusCode}: $body',
          uri: uri,
        );
      }
    } catch (e) {
      request.abort();
      rethrow;
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

  bool _isRetryableError(HttpException e) {
    final message = e.message.toLowerCase();

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
    _httpClient.close(force: true);
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
      final request = await _httpClient.openUrl('HEAD', uri);

      _config.headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      final response = await request.close();
      await response.drain<void>();

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
    };
  }
}
