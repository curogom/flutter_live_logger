# Flutter Live Logger API Documentation

> **📋 상태**: 문서 템플릿 (Phase 1 개발 예정)  
> **🎯 목적**: 개발자를 위한 완전한 API 레퍼런스 제공

## 📚 API 문서 구조

### 1. 핵심 클래스 (Core Classes)

#### `FlutterLiveLogger`

메인 로거 클래스 - 모든 로깅 기능의 진입점

```dart
/// Flutter Live Logger의 메인 클래스
/// 
/// 앱의 모든 로깅 활동을 관리하고 실시간 로그 전송을 제공합니다.
/// 
/// Example:
/// ```dart
/// await FlutterLiveLogger.init(
///   config: LoggerConfig(
///     logLevel: LogLevel.debug,
///     enableAutoScreenTracking: true,
///   ),
/// );
/// 
/// FlutterLiveLogger.info('사용자가 로그인했습니다', data: {
///   'userId': user.id,
///   'timestamp': DateTime.now().toIso8601String(),
/// });
/// ```
class FlutterLiveLogger {
  // API 구현 예정 (Phase 1)
}
```

#### `LoggerConfig`

로거 설정을 위한 구성 클래스

```dart
/// 로거의 동작을 설정하는 구성 클래스
/// 
/// 로그 레벨, 자동 추적, 전송 옵션 등을 설정할 수 있습니다.
class LoggerConfig {
  // 구현 예정
}
```

#### `LogEntry`

개별 로그 항목을 나타내는 데이터 클래스

```dart
/// 단일 로그 항목을 나타내는 불변 클래스
/// 
/// 로그 메시지, 메타데이터, 타임스탬프 등을 포함합니다.
@immutable
class LogEntry {
  // 구현 예정
}
```

### 2. 로그 레벨 (Log Levels)

```dart
/// 로그의 심각도를 나타내는 열거형
enum LogLevel {
  /// 추적 레벨 - 매우 상세한 디버깅 정보
  trace,
  
  /// 디버그 레벨 - 개발 중 유용한 정보
  debug,
  
  /// 정보 레벨 - 일반적인 애플리케이션 흐름
  info,
  
  /// 경고 레벨 - 주의가 필요한 상황
  warn,
  
  /// 오류 레벨 - 오류 상황이지만 앱은 계속 실행
  error,
  
  /// 치명적 레벨 - 앱이 중단될 수 있는 심각한 오류
  fatal,
}
```

### 3. 전송 시스템 (Transport System)

#### `LogTransport` (추상 클래스)

로그를 목적지로 전송하는 기본 인터페이스

```dart
/// 로그 전송을 위한 추상 기본 클래스
/// 
/// 다양한 전송 방식(HTTP, WebSocket, 로컬 파일 등)을 지원하기 위한
/// 플러그인 아키텍처의 기반이 됩니다.
abstract class LogTransport {
  /// 로그 항목 배치를 전송합니다
  /// 
  /// [entries] 전송할 로그 항목들
  /// 
  /// Returns: 성공적으로 전송된 항목 수
  /// Throws: [TransportException] 전송 실패 시
  Future<int> send(List<LogEntry> entries);
  
  /// 전송기의 리소스를 정리합니다
  Future<void> dispose();
}
```

#### 구현 예정 Transport

- `HttpTransport` - REST API 전송
- `WebSocketTransport` - 실시간 WebSocket 전송
- `FileTransport` - 로컬 파일 저장
- `MemoryTransport` - 메모리 내 임시 저장

### 4. Flutter 통합 (Flutter Integration)

#### `NavigatorObserver`

자동 화면 추적을 위한 Observer

```dart
/// Flutter 네비게이션을 자동으로 추적하는 Observer
/// 
/// MaterialApp의 navigatorObservers에 추가하여 
/// 자동으로 화면 전환을 로깅합니다.
class FlutterLiveLoggerNavigatorObserver extends NavigatorObserver {
  // 구현 예정
}
```

#### Widget Error Handling

```dart
/// Flutter 위젯 오류를 자동으로 캐치하고 로깅
void setupFlutterErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterLiveLogger.error(
      'Flutter Widget Error',
      data: {
        'error': details.exception.toString(),
        'stack': details.stack.toString(),
        'library': details.library,
      },
    );
  };
}
```

## 🎯 사용 패턴 (Usage Patterns)

### 기본 설정

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 로거 초기화
  await FlutterLiveLogger.init(
    config: LoggerConfig(
      logLevel: LogLevel.info,
      enableAutoScreenTracking: true,
      enableCrashReporting: true,
      transports: [
        HttpTransport(
          endpoint: 'https://api.myapp.com/logs',
          apiKey: 'your-api-key',
        ),
        FileTransport(
          maxFileSize: 10 * 1024 * 1024, // 10MB
          maxFiles: 5,
        ),
      ],
    ),
  );
  
  runApp(MyApp());
}
```

### 로깅 사용 예시

```dart
class UserService {
  Future<User> login(String email) async {
    FlutterLiveLogger.info('사용자 로그인 시도', data: {
      'email': email,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    try {
      final user = await _authService.login(email);
      
      FlutterLiveLogger.info('로그인 성공', data: {
        'userId': user.id,
        'userRole': user.role,
      });
      
      return user;
    } catch (e) {
      FlutterLiveLogger.error('로그인 실패', data: {
        'email': email,
        'error': e.toString(),
      });
      rethrow;
    }
  }
}
```

### 커스텀 이벤트 추적

```dart
class AnalyticsService {
  static void trackButtonClick(String buttonId, String screen) {
    FlutterLiveLogger.event('button_click', {
      'button_id': buttonId,
      'screen': screen,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  static void trackScreenView(String screenName) {
    FlutterLiveLogger.event('screen_view', {
      'screen_name': screenName,
      'view_time': DateTime.now().toIso8601String(),
    });
  }
}
```

## 🔧 고급 기능 (Advanced Features)

### 1. 로그 필터링

```dart
// 개발 중에만 민감한 정보 로깅
if (kDebugMode) {
  FlutterLiveLogger.debug('API Response', data: response.data);
}

// 조건부 로깅
FlutterLiveLogger.when(
  condition: user.isAdmin,
  level: LogLevel.info,
  message: 'Admin action performed',
);
```

### 2. 배치 로깅

```dart
// 성능 최적화를 위한 배치 로깅
FlutterLiveLogger.batchBegin();
for (int i = 0; i < items.length; i++) {
  FlutterLiveLogger.trace('Processing item $i');
}
FlutterLiveLogger.batchEnd(); // 한 번에 모든 로그 전송
```

### 3. 로그 컨텍스트

```dart
// 글로벌 컨텍스트 설정
FlutterLiveLogger.setGlobalContext({
  'app_version': '1.0.0',
  'device_id': deviceId,
  'user_id': currentUser?.id,
});

// 로컬 컨텍스트로 로깅
FlutterLiveLogger.withContext({
  'feature': 'checkout',
  'step': 'payment',
}, () {
  FlutterLiveLogger.info('결제 시작');
  // 이 블록 내의 모든 로그는 자동으로 컨텍스트 정보 포함
});
```

## 📊 성능 고려사항

### 메모리 사용량

- 로그 큐 최대 크기: 1000개 항목
- 메모리 사용량 목표: < 10MB
- 백그라운드에서 자동 정리

### 네트워크 최적화

- 배치 전송 (기본 100개씩)
- 압축 지원 (gzip)
- 재시도 로직 (지수 백오프)
- 오프라인 지원

### 앱 성능 영향

- 메인 스레드 차단 시간: < 1ms
- 백그라운드 스레드에서 처리
- 비동기 I/O 작업

## 🧪 테스트 지원

### Mock Transport

```dart
// 테스트용 Mock Transport
class MockTransport extends LogTransport {
  List<LogEntry> sentLogs = [];
  
  @override
  Future<int> send(List<LogEntry> entries) async {
    sentLogs.addAll(entries);
    return entries.length;
  }
}

// 테스트에서 사용
testWidgets('로그 전송 테스트', (tester) async {
  final mockTransport = MockTransport();
  await FlutterLiveLogger.init(
    config: LoggerConfig(transports: [mockTransport]),
  );
  
  FlutterLiveLogger.info('테스트 로그');
  
  expect(mockTransport.sentLogs, hasLength(1));
  expect(mockTransport.sentLogs.first.message, '테스트 로그');
});
```

## 📖 다음 단계

이 API 문서는 **Phase 1 개발**과 함께 실제 구현으로 업데이트될 예정입니다.

- **Phase 1** (Week 3-4): 기본 로깅 기능 구현
- **Phase 2** (Week 5-6): 전송 시스템 및 오프라인 지원
- **Phase 3** (Week 7-8): Flutter 통합 및 자동 추적

각 단계에서 이 문서는 실제 API와 함께 업데이트되며,
코드 예시는 동작하는 실제 코드로 대체됩니다.
