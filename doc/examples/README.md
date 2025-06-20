# Flutter Live Logger - Examples & Tutorials

> **📖 Examples and Tutorial Guide**  
> **🎯 Purpose**: Provide hands-on examples for quick developer onboarding

## 🚀 Quick Start

### 1. Basic Setup

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Flutter Live Logger
  await FlutterLiveLogger.init(
    config: LoggerConfig(
      logLevel: LogLevel.info,
      enableAutoScreenTracking: true,
    ),
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Live Logger Demo',
      // Enable automatic screen tracking
      navigatorObservers: [
        FlutterLiveLogger.navigatorObserver,
      ],
      home: HomePage(),
    );
  }
}
```

### 2. Basic Logging

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Simple log
              FlutterLiveLogger.info('User clicked button');
              
              // Structured logging with data
              FlutterLiveLogger.info('Button click', data: {
                'button_id': 'home_cta',
                'screen': 'home',
                'timestamp': DateTime.now().toIso8601String(),
              });
            },
            child: Text('Generate Log'),
          ),
        ],
      ),
    );
  }
}
```

## 📚 Detailed Examples

### 1. Log Level Usage

```dart
class LogLevelExamples {
  void demonstrateLogLevels() {
    // Trace level - Very detailed debugging information
    FlutterLiveLogger.trace('Function entry: calculateTotal()');
    
    // Debug level - Useful information during development
    FlutterLiveLogger.debug('User input validation completed', data: {
      'input_length': 10,
      'validation_passed': true,
    });
    
    // Info level - General application flow
    FlutterLiveLogger.info('User login successful', data: {
      'user_id': 'user123',
      'login_method': 'email',
    });
    
    // Warning level - Situations requiring attention
    FlutterLiveLogger.warn('API response time is slow', data: {
      'response_time_ms': 3500,
      'threshold_ms': 2000,
    });
    
    // Error level - Error situations but app continues running
    FlutterLiveLogger.error('Network request failed', data: {
      'error_code': 404,
      'endpoint': '/api/users',
      'retry_count': 2,
    });
    
    // Fatal level - Critical errors that may cause app termination
    FlutterLiveLogger.fatal('Database connection failed', data: {
      'database_host': 'prod-db.example.com',
      'error': 'Connection timeout',
    });
  }
}
```

### 2. Custom Event Tracking

```dart
class EventTrackingExamples {
  // User behavior tracking
  void trackUserActions() {
    // Button click tracking
    FlutterLiveLogger.event('button_click', {
      'button_id': 'purchase_now',
      'screen': 'product_detail',
      'product_id': 'SKU123',
      'price': 29.99,
    });
    
    // Screen view tracking
    FlutterLiveLogger.event('screen_view', {
      'screen_name': 'ProductDetailPage',
      'product_category': 'electronics',
      'user_type': 'premium',
    });
    
    // Feature usage tracking
    FlutterLiveLogger.event('feature_used', {
      'feature_name': 'search',
      'search_query': 'flutter logging',
      'results_count': 24,
    });
  }
  
  // Business metrics tracking
  void trackBusinessMetrics() {
    // Purchase completion
    FlutterLiveLogger.event('purchase_completed', {
      'order_id': 'ORD-2024-001',
      'total_amount': 89.97,
      'currency': 'USD',
      'items_count': 3,
      'payment_method': 'credit_card',
    });
    
    // Add to cart
    FlutterLiveLogger.event('add_to_cart', {
      'product_id': 'SKU456',
      'price': 19.99,
      'quantity': 2,
      'cart_total': 39.98,
    });
  }
}
```

### 3. Error Handling and Exception Logging

```dart
class ErrorHandlingExamples {
  Future<User> loginUser(String email, String password) async {
    try {
      FlutterLiveLogger.info('Login attempt started', data: {
        'email': email,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      final user = await _authService.login(email, password);
      
      FlutterLiveLogger.info('Login successful', data: {
        'user_id': user.id,
        'user_role': user.role,
        'login_duration_ms': 1250,
      });
      
      return user;
    } on NetworkException catch (e) {
      FlutterLiveLogger.error('Login failed due to network error', data: {
        'email': email,
        'error_type': 'network',
        'error_message': e.message,
        'error_code': e.code,
      });
      rethrow;
    } on AuthenticationException catch (e) {
      FlutterLiveLogger.warn('Authentication failed', data: {
        'email': email,
        'error_type': 'authentication',
        'reason': e.reason,
      });
      rethrow;
    } catch (e, stackTrace) {
      FlutterLiveLogger.fatal('Unexpected login error', data: {
        'email': email,
        'error': e.toString(),
        'stack_trace': stackTrace.toString(),
      });
      rethrow;
    }
  }
  
  // Automatically catch Flutter widget errors
  void setupFlutterErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterLiveLogger.error('Flutter Widget Error', data: {
        'error': details.exception.toString(),
        'stack_trace': details.stack.toString(),
        'library': details.library,
        'context': details.context?.toString(),
      });
    };
  }
}
```

### 4. Performance Monitoring

```dart
class PerformanceTrackingExamples {
  // Measure function execution time
  Future<List<Product>> loadProducts() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      FlutterLiveLogger.info('Product loading started');
      
      final products = await _productService.getProducts();
      
      stopwatch.stop();
      FlutterLiveLogger.info('Product loading completed', data: {
        'products_count': products.length,
        'loading_time_ms': stopwatch.elapsedMilliseconds,
      });
      
      return products;
    } catch (e) {
      stopwatch.stop();
      FlutterLiveLogger.error('Product loading failed', data: {
        'error': e.toString(),
        'failed_after_ms': stopwatch.elapsedMilliseconds,
      });
      rethrow;
    }
  }
  
  // Track memory usage
  void trackMemoryUsage() {
    FlutterLiveLogger.info('Memory usage', data: {
      'heap_size_mb': _getHeapSizeMB(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // Track app startup time
  void trackAppStartup() {
    FlutterLiveLogger.event('app_startup_completed', {
      'startup_time_ms': _getStartupTime(),
      'cold_start': _isColdStart(),
      'app_version': _getAppVersion(),
    });
  }
}
```

## 🔧 Advanced Usage

### 1. Custom Transport Implementation

```dart
// Custom Transport example - Slack notifications
class SlackTransport extends LogTransport {
  final String webhookUrl;
  final LogLevel minLevel;
  
  SlackTransport({
    required this.webhookUrl,
    this.minLevel = LogLevel.error,
  });
  
  @override
  String get name => 'slack';
  
  @override
  Future<TransportResult> send(List<LogEntry> entries) async {
    final criticalLogs = entries
        .where((entry) => entry.level.index >= minLevel.index)
        .toList();
    
    if (criticalLogs.isEmpty) {
      return TransportResult.success();
    }
    
    try {
      for (final entry in criticalLogs) {
        await _sendToSlack(entry);
      }
      return TransportResult.success();
    } catch (e) {
      return TransportResult.failure(e.toString());
    }
  }
  
  Future<void> _sendToSlack(LogEntry entry) async {
    final message = {
      'text': '🚨 ${entry.level.name.toUpperCase()}: ${entry.message}',
      'attachments': [
        {
          'color': _getColorForLevel(entry.level),
          'fields': [
            {
              'title': 'Time',
              'value': entry.timestamp.toString(),
              'short': true,
            },
            {
              'title': 'Data',
              'value': jsonEncode(entry.data),
              'short': false,
            },
          ],
        },
      ],
    };
    
    await http.post(
      Uri.parse(webhookUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message),
    );
  }
}

// Usage
await FlutterLiveLogger.init(
  config: LoggerConfig(
    transports: [
      HttpTransport(endpoint: 'https://api.myapp.com/logs'),
      SlackTransport(
        webhookUrl: 'https://hooks.slack.com/services/...',
        minLevel: LogLevel.error,
      ),
    ],
  ),
);
```

## 🧪 Testing Examples

### 1. Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  group('FlutterLiveLogger Tests', () {
    late MockTransport mockTransport;
    
    setUp(() async {
      mockTransport = MockTransport();
      await FlutterLiveLogger.init(
        config: LoggerConfig(
          transports: [mockTransport],
        ),
      );
    });
    
    testWidgets('log transmission test', (tester) async {
      // When
      FlutterLiveLogger.info('test message');
      
      // Then
      await tester.pumpAndSettle();
      expect(mockTransport.sentLogs, hasLength(1));
      expect(mockTransport.sentLogs.first.message, 'test message');
    });
    
    testWidgets('log level filtering test', (tester) async {
      // Given
      await FlutterLiveLogger.setLogLevel(LogLevel.warn);
      
      // When
      FlutterLiveLogger.debug('debug message'); // filtered out
      FlutterLiveLogger.error('error message');  // sent
      
      // Then
      await tester.pumpAndSettle();
      expect(mockTransport.sentLogs, hasLength(1));
      expect(mockTransport.sentLogs.first.level, LogLevel.error);
    });
  });
}

class MockTransport extends LogTransport {
  final List<LogEntry> sentLogs = [];
  
  @override
  String get name => 'mock';
  
  @override
  Future<TransportResult> send(List<LogEntry> entries) async {
    sentLogs.addAll(entries);
    return TransportResult.success();
  }
  
  @override
  Future<void> dispose() async {}
}
```

## 📱 Real-world Use Cases

### 1. E-commerce App

```dart
class EcommerceLoggingExamples {
  // Product search logging
  void logProductSearch(String query, List<Product> results) {
    FlutterLiveLogger.event('product_search', {
      'query': query,
      'results_count': results.length,
      'search_duration_ms': searchDuration.inMilliseconds,
      'user_id': currentUser.id,
    });
  }
  
  // Payment process logging
  void logPaymentFlow(String step, Map<String, dynamic> data) {
    FlutterLiveLogger.event('payment_step', {
      'step': step,
      'order_total': data['total'],
      'payment_method': data['method'],
      'step_timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

### 2. Social Media App

```dart
class SocialMediaLoggingExamples {
  // Post interaction logging
  void logPostInteraction(String action, String postId) {
    FlutterLiveLogger.event('post_interaction', {
      'action': action, // 'like', 'share', 'comment'
      'post_id': postId,
      'user_id': currentUser.id,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // Feed loading performance logging
  void logFeedPerformance(int postsLoaded, Duration loadTime) {
    FlutterLiveLogger.info('Feed loading completed', data: {
      'posts_loaded': postsLoaded,
      'load_time_ms': loadTime.inMilliseconds,
      'cache_hit_rate': _getCacheHitRate(),
    });
  }
}
```

## 🎯 Best Practices

### 1. Log Message Writing Guide

```dart
// ✅ Good example
FlutterLiveLogger.info('User profile update completed', data: {
  'user_id': user.id,
  'updated_fields': ['name', 'email'],
  'update_duration_ms': 150,
});

// ❌ Bad example
FlutterLiveLogger.info('Updated'); // Too vague
```

### 2. Sensitive Information Handling

```dart
// ✅ Good example - Mask sensitive information
FlutterLiveLogger.info('Login attempt', data: {
  'email': maskEmail(user.email), // a***@example.com
  'ip_address': maskIP(request.ip), // 192.168.***.***
});

// ❌ Bad example - Expose sensitive information
FlutterLiveLogger.info('Login attempt', data: {
  'email': user.email, // Full email exposure
  'password': user.password, // Never do this!
});
```

### 3. Structured Logging

```dart
// ✅ Good example - Consistent structure
class LoggingHelper {
  static void logUserAction(String action, {Map<String, dynamic>? metadata}) {
    FlutterLiveLogger.event('user_action', {
      'action': action,
      'user_id': currentUser.id,
      'timestamp': DateTime.now().toIso8601String(),
      'session_id': sessionManager.currentSessionId,
      ...?metadata,
    });
  }
}
```

These examples will be updated with actual working code during **Phase 1 development**. Each example demonstrates various Flutter Live Logger features and provides patterns that can be used in production environments.
