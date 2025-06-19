# Flutter Live Logger - Examples & Tutorials

> **📖 예제 및 튜토리얼 가이드**  
> **🎯 목적**: 개발자가 빠르게 시작할 수 있는 실전 예제 제공

## 🚀 빠른 시작 (Quick Start)

### 1. 기본 설정

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Flutter Live Logger 초기화
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
      // 자동 화면 추적 활성화
      navigatorObservers: [
        FlutterLiveLogger.navigatorObserver,
      ],
      home: HomePage(),
    );
  }
}
```

### 2. 기본 로깅

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('홈페이지')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // 정보 로그
              FlutterLiveLogger.info('사용자가 버튼을 클릭했습니다');
              
              // 구조화된 데이터와 함께 로그
              FlutterLiveLogger.info('버튼 클릭', data: {
                'button_id': 'home_cta',
                'screen': 'home',
                'timestamp': DateTime.now().toIso8601String(),
              });
            },
            child: Text('로그 생성'),
          ),
        ],
      ),
    );
  }
}
```

## 📚 상세 예제

### 1. 로그 레벨별 사용법

```dart
class LogLevelExamples {
  void demonstrateLogLevels() {
    // 추적 레벨 - 매우 상세한 디버깅
    FlutterLiveLogger.trace('함수 진입: calculateTotal()');
    
    // 디버그 레벨 - 개발 중 유용한 정보
    FlutterLiveLogger.debug('사용자 입력 검증 완료', data: {
      'input_length': 10,
      'validation_passed': true,
    });
    
    // 정보 레벨 - 일반적인 애플리케이션 흐름
    FlutterLiveLogger.info('사용자 로그인 성공', data: {
      'user_id': 'user123',
      'login_method': 'email',
    });
    
    // 경고 레벨 - 주의가 필요한 상황
    FlutterLiveLogger.warn('API 응답 시간이 느림', data: {
      'response_time_ms': 3500,
      'threshold_ms': 2000,
    });
    
    // 오류 레벨 - 오류 상황이지만 앱은 계속 실행
    FlutterLiveLogger.error('네트워크 요청 실패', data: {
      'error_code': 404,
      'endpoint': '/api/users',
      'retry_count': 2,
    });
    
    // 치명적 레벨 - 앱이 중단될 수 있는 심각한 오류
    FlutterLiveLogger.fatal('데이터베이스 연결 실패', data: {
      'database_host': 'prod-db.example.com',
      'error': 'Connection timeout',
    });
  }
}
```

### 2. 커스텀 이벤트 추적

```dart
class EventTrackingExamples {
  // 사용자 행동 추적
  void trackUserActions() {
    // 버튼 클릭 추적
    FlutterLiveLogger.event('button_click', {
      'button_id': 'purchase_now',
      'screen': 'product_detail',
      'product_id': 'SKU123',
      'price': 29.99,
    });
    
    // 화면 조회 추적
    FlutterLiveLogger.event('screen_view', {
      'screen_name': 'ProductDetailPage',
      'product_category': 'electronics',
      'user_type': 'premium',
    });
    
    // 기능 사용 추적
    FlutterLiveLogger.event('feature_used', {
      'feature_name': 'search',
      'search_query': 'flutter logging',
      'results_count': 24,
    });
  }
  
  // 비즈니스 메트릭 추적
  void trackBusinessMetrics() {
    // 구매 완료
    FlutterLiveLogger.event('purchase_completed', {
      'order_id': 'ORD-2024-001',
      'total_amount': 89.97,
      'currency': 'USD',
      'items_count': 3,
      'payment_method': 'credit_card',
    });
    
    // 장바구니 추가
    FlutterLiveLogger.event('add_to_cart', {
      'product_id': 'SKU456',
      'price': 19.99,
      'quantity': 2,
      'cart_total': 39.98,
    });
  }
}
```

### 3. 오류 처리 및 예외 로깅

```dart
class ErrorHandlingExamples {
  Future<User> loginUser(String email, String password) async {
    try {
      FlutterLiveLogger.info('로그인 시도 시작', data: {
        'email': email,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      final user = await _authService.login(email, password);
      
      FlutterLiveLogger.info('로그인 성공', data: {
        'user_id': user.id,
        'user_role': user.role,
        'login_duration_ms': 1250,
      });
      
      return user;
    } on NetworkException catch (e) {
      FlutterLiveLogger.error('네트워크 오류로 로그인 실패', data: {
        'email': email,
        'error_type': 'network',
        'error_message': e.message,
        'error_code': e.code,
      });
      rethrow;
    } on AuthenticationException catch (e) {
      FlutterLiveLogger.warn('인증 실패', data: {
        'email': email,
        'error_type': 'authentication',
        'reason': e.reason,
      });
      rethrow;
    } catch (e, stackTrace) {
      FlutterLiveLogger.fatal('예상치 못한 로그인 오류', data: {
        'email': email,
        'error': e.toString(),
        'stack_trace': stackTrace.toString(),
      });
      rethrow;
    }
  }
  
  // Flutter 위젯 오류 자동 캐치
  void setupFlutterErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterLiveLogger.error('Flutter 위젯 오류', data: {
        'error': details.exception.toString(),
        'stack_trace': details.stack.toString(),
        'library': details.library,
        'context': details.context?.toString(),
      });
    };
  }
}
```

### 4. 성능 모니터링

```dart
class PerformanceTrackingExamples {
  // 함수 실행 시간 측정
  Future<List<Product>> loadProducts() async {
    final stopwatch = Stopwatch()..start();
    
    try {
      FlutterLiveLogger.info('상품 로딩 시작');
      
      final products = await _productService.getProducts();
      
      stopwatch.stop();
      FlutterLiveLogger.info('상품 로딩 완료', data: {
        'products_count': products.length,
        'loading_time_ms': stopwatch.elapsedMilliseconds,
      });
      
      return products;
    } catch (e) {
      stopwatch.stop();
      FlutterLiveLogger.error('상품 로딩 실패', data: {
        'error': e.toString(),
        'failed_after_ms': stopwatch.elapsedMilliseconds,
      });
      rethrow;
    }
  }
  
  // 메모리 사용량 추적
  void trackMemoryUsage() {
    FlutterLiveLogger.info('메모리 사용량', data: {
      'heap_size_mb': _getHeapSizeMB(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // 앱 시작 시간 추적
  void trackAppStartup() {
    FlutterLiveLogger.event('app_startup_completed', {
      'startup_time_ms': _getStartupTime(),
      'cold_start': _isColdStart(),
      'app_version': _getAppVersion(),
    });
  }
}
```

## 🔧 고급 사용법

### 1. 커스텀 Transport 구현

```dart
// 커스텀 Transport 예제 - Slack 알림
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
              'title': '시간',
              'value': entry.timestamp.toString(),
              'short': true,
            },
            {
              'title': '데이터',
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

// 사용법
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

### 2. 로그 필터링 및 조건부 로깅

```dart
class ConditionalLoggingExamples {
  void demonstrateFiltering() {
    // 개발 모드에서만 로깅
    if (kDebugMode) {
      FlutterLiveLogger.debug('디버그 모드 전용 로그');
    }
    
    // 사용자 권한에 따른 로깅
    if (currentUser.isAdmin) {
      FlutterLiveLogger.info('관리자 작업 수행', data: {
        'admin_action': 'user_data_export',
        'target_user_id': 'user456',
      });
    }
    
    // 성능 기반 조건부 로깅
    if (responseTime > Duration(seconds: 2)) {
      FlutterLiveLogger.warn('느린 API 응답', data: {
        'response_time_ms': responseTime.inMilliseconds,
      });
    }
  }
  
  // 커스텀 필터 구현
  void setupCustomFilters() {
    FlutterLiveLogger.addFilter((entry) {
      // PII 데이터 자동 마스킹
      if (entry.data?.containsKey('email') == true) {
        entry = entry.copyWith(
          data: {
            ...entry.data!,
            'email': _maskEmail(entry.data!['email']),
          },
        );
      }
      return entry;
    });
  }
}
```

### 3. 배치 로깅 및 성능 최적화

```dart
class BatchLoggingExamples {
  // 배치 로깅으로 성능 최적화
  Future<void> processBulkData(List<DataItem> items) async {
    FlutterLiveLogger.batchBegin();
    
    try {
      for (int i = 0; i < items.length; i++) {
        FlutterLiveLogger.trace('아이템 처리 중: $i/${items.length}');
        
        await _processItem(items[i]);
        
        // 주기적으로 진행 상황 로깅
        if (i % 100 == 0) {
          FlutterLiveLogger.info('진행 상황: ${(i / items.length * 100).toInt()}%');
        }
      }
      
      FlutterLiveLogger.info('벌크 데이터 처리 완료', data: {
        'total_items': items.length,
        'processing_time_ms': stopwatch.elapsedMilliseconds,
      });
    } finally {
      // 배치의 모든 로그를 한 번에 전송
      FlutterLiveLogger.batchEnd();
    }
  }
}
```

## 🧪 테스트 예제

### 1. 단위 테스트

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
    
    testWidgets('로그 전송 테스트', (tester) async {
      // When
      FlutterLiveLogger.info('테스트 메시지');
      
      // Then
      await tester.pumpAndSettle();
      expect(mockTransport.sentLogs, hasLength(1));
      expect(mockTransport.sentLogs.first.message, '테스트 메시지');
    });
    
    testWidgets('로그 레벨 필터링 테스트', (tester) async {
      // Given
      await FlutterLiveLogger.setLogLevel(LogLevel.warn);
      
      // When
      FlutterLiveLogger.debug('디버그 메시지'); // 필터링됨
      FlutterLiveLogger.error('오류 메시지');   // 전송됨
      
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

### 2. 통합 테스트

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('로깅 통합 테스트', () {
    testWidgets('실제 앱에서 로깅 동작 확인', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // 화면 자동 추적 확인
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // 로그가 생성되었는지 확인
      // (실제로는 테스트 transport를 통해 확인)
      expect(find.text('로그 생성됨'), findsOneWidget);
    });
  });
}
```

## 📱 실제 사용 사례

### 1. E-commerce 앱

```dart
class EcommerceLoggingExamples {
  // 상품 검색 로깅
  void logProductSearch(String query, List<Product> results) {
    FlutterLiveLogger.event('product_search', {
      'query': query,
      'results_count': results.length,
      'search_duration_ms': searchDuration.inMilliseconds,
      'user_id': currentUser.id,
    });
  }
  
  // 결제 프로세스 로깅
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

### 2. 소셜 미디어 앱

```dart
class SocialMediaLoggingExamples {
  // 게시물 상호작용 로깅
  void logPostInteraction(String action, String postId) {
    FlutterLiveLogger.event('post_interaction', {
      'action': action, // 'like', 'share', 'comment'
      'post_id': postId,
      'user_id': currentUser.id,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // 피드 로딩 성능 로깅
  void logFeedPerformance(int postsLoaded, Duration loadTime) {
    FlutterLiveLogger.info('피드 로딩 완료', data: {
      'posts_loaded': postsLoaded,
      'load_time_ms': loadTime.inMilliseconds,
      'cache_hit_rate': _getCacheHitRate(),
    });
  }
}
```

## 🎯 모범 사례 (Best Practices)

### 1. 로그 메시지 작성 가이드

```dart
// ✅ 좋은 예
FlutterLiveLogger.info('사용자 프로필 업데이트 완료', data: {
  'user_id': user.id,
  'updated_fields': ['name', 'email'],
  'update_duration_ms': 150,
});

// ❌ 나쁜 예
FlutterLiveLogger.info('업데이트됨'); // 너무 모호함
```

### 2. 민감한 정보 처리

```dart
// ✅ 좋은 예 - 민감한 정보 마스킹
FlutterLiveLogger.info('로그인 시도', data: {
  'email': maskEmail(user.email), // a***@example.com
  'ip_address': maskIP(request.ip), // 192.168.***.***
});

// ❌ 나쁜 예 - 민감한 정보 노출
FlutterLiveLogger.info('로그인 시도', data: {
  'email': user.email, // 전체 이메일 노출
  'password': user.password, // 절대 하면 안됨!
});
```

### 3. 구조화된 로깅

```dart
// ✅ 좋은 예 - 일관된 구조
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

이 예제들은 **Phase 1 개발**과 함께 실제 동작하는 코드로 업데이트될 예정입니다. 각 예제는 Flutter Live Logger의 다양한 기능을 보여주며, 실제 프로덕션 환경에서 사용할 수 있는 패턴을 제공합니다.
