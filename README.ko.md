# 🚀 Flutter Live Logger

<!-- pub.dev 패키지 출시 후 배지가 활성화됩니다 -->
<!-- [![pub package](https://img.shields.io/pub/v/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger) -->
<!-- [![popularity](https://img.shields.io/pub/popularity/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger) -->
<!-- [![likes](https://img.shields.io/pub/likes/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger) -->
[![CI](https://github.com/curogom/flutter_live_logger/actions/workflows/ci.yml/badge.svg)](https://github.com/curogom/flutter_live_logger/actions)
<!-- [![codecov](https://codecov.io/gh/curogom/flutter_live_logger/branch/main/graph/badge.svg)](https://codecov.io/gh/curogom/flutter_live_logger) -->

**Flutter 애플리케이션을 위한 프로덕션 준비 완료 실시간 로깅 솔루션**

Flutter Live Logger는 프로덕션 환경의 Flutter 앱을 위해 설계된 포괄적인 로깅 라이브러리입니다. 다중 전송 레이어, 영구 저장소, 자동 네비게이션 추적, 그리고 오프라인 지원을 깔끔하고 개발자 친화적인 API로 제공합니다.

> 📖 **Languages**: [English](README.md) • [**한국어**](README.ko.md)

---

## ✨ 주요 기능

### 🎯 **핵심 기능**

- 🔥 **다중 전송 레이어**: Memory, File, HTTP 전송 옵션
- 💾 **영구 저장소**: 쿼리 가능한 SQLite 및 메모리 기반 저장소
- 📱 **자동 네비게이션 추적**: 자동 화면 전환 로깅
- 🔄 **오프라인 지원**: 오프라인에서 로그 대기열 처리 후 연결 시 동기화
- ⚡ **고성능**: 배치 처리, 비동기 처리, 최소한의 오버헤드
- 🎛️ **구성 가능**: 다중 환경 구성 (개발/프로덕션/테스트)

### 🛠️ **개발자 경험**

- ⚡ **간편한 설정**: 한 줄의 코드로 초기화
- 📚 **완전한 API**: 포괄적인 dartdoc 문서
- 🔒 **타입 안전**: 완전한 null safety 및 강한 타입화
- 🧪 **충분한 테스트**: 17개 이상의 포괄적인 테스트로 95%+ 테스트 커버리지
- 🌍 **크로스 플랫폼**: iOS, Android, Web, Desktop 지원

---

## 🚀 빠른 시작

### 1. 의존성 추가

```yaml
dependencies:
  flutter_live_logger: ^0.1.0
  sqflite: ^2.3.0  # 영구 저장소용
```

### 2. Logger 초기화

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 개발용 초기화
  await FlutterLiveLogger.init(
    config: LoggerConfig.development(
      userId: 'user_123',
      sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
    ),
  );
  
  runApp(MyApp());
}
```

### 3. 네비게이션 추적 추가

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      navigatorObservers: [
        FlutterLiveLoggerNavigatorObserver(), // 자동 화면 네비게이션 추적
      ],
      home: HomeScreen(),
    );
  }
}
```

### 4. 로깅 시작

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Live Logger Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 간단한 로깅
            FlutterLiveLogger.info('사용자가 버튼을 클릭했습니다');
            
            // 구조화된 데이터와 함께하는 이벤트 추적
            FlutterLiveLogger.event('button_click', {
              'button_id': 'main_cta',
              'screen': 'home',
              'timestamp': DateTime.now().toIso8601String(),
            });
            
            // 컨텍스트와 함께하는 에러 로깅
            try {
              throw Exception('데모 에러');
            } catch (error, stackTrace) {
              FlutterLiveLogger.error(
                '작업 실패',
                data: {'operation': 'demo'},
                error: error,
                stackTrace: stackTrace,
              );
            }
          },
          child: Text('로깅 테스트'),
        ),
      ),
    );
  }
}
```

---

## 📖 고급 사용법

### 구성 옵션

```dart
// 개발 구성
await FlutterLiveLogger.init(
  config: LoggerConfig.development(
    logLevel: LogLevel.debug,
    userId: 'user_123',
    sessionId: 'session_456',
  ),
);

// 프로덕션 구성  
await FlutterLiveLogger.init(
  config: LoggerConfig.production(
    transports: [
      HttpTransport(config: HttpTransportConfig(
        endpoint: 'https://api.yourapp.com/logs',
        apiKey: 'your-api-key',
        batchSize: 50,
        enableCompression: true,
      )),
      FileTransport(config: FileTransportConfig(
        directory: '/app/logs',
        maxFileSize: 10 * 1024 * 1024, // 10MB
        maxFiles: 5,
      )),
    ],
    usePersistentStorage: true,
    logLevel: LogLevel.info,
  ),
);

// 성능 최적화 구성
await FlutterLiveLogger.init(
  config: LoggerConfig.performance(
    logLevel: LogLevel.warn, // 경고 이상만
    transports: [MemoryTransport(maxEntries: 500)],
  ),
);

// 테스트 구성
await FlutterLiveLogger.init(
  config: LoggerConfig.testing(
    logLevel: LogLevel.trace, // 테스트용 모든 로그
  ),
);
```

### 전송 레이어

```dart
// Memory Transport (개발/테스트용)
final memoryTransport = MemoryTransport(
  maxEntries: 1000,
);

// File Transport (로컬 영속성용)
final fileTransport = FileTransport(
  config: FileTransportConfig(
    directory: '/app/logs',
    filePrefix: 'app_log',
    maxFileSize: 10 * 1024 * 1024, // 10MB
    maxFiles: 5,
    enableRotation: true,
  ),
);

// HTTP Transport (원격 로깅용)
final httpTransport = HttpTransport(
  config: HttpTransportConfig(
    endpoint: 'https://api.yourapp.com/logs',
    apiKey: 'your-api-key',
    headers: {'X-App-Version': '1.0.0'},
    enableCompression: true,
    retryAttempts: 3,
    timeout: Duration(seconds: 30),
  ),
);
```

### 저장소 옵션

```dart
// Memory Storage (빠름, 비영구적)
final memoryStorage = MemoryStorage(maxEntries: 5000);

// SQLite Storage (영구적, 쿼리 가능)
final sqliteStorage = SQLiteStorage(
  config: SQLiteStorageConfig(
    databaseName: 'app_logs.db',
    maxEntries: 50000,
    enableWAL: true,
  ),
);

// 저장된 로그 쿼리
final recentLogs = await sqliteStorage.query(LogQuery.recent(limit: 100));
final errorLogs = await sqliteStorage.query(LogQuery.level(level: LogLevel.error));
final userLogs = await sqliteStorage.query(LogQuery.user(userId: 'user_123'));
```

### 구조화된 로깅

```dart
// 사용자 행동
FlutterLiveLogger.event('user_action', {
  'action': 'purchase',
  'item_id': 'product_123',
  'amount': 29.99,
  'currency': 'USD',
  'payment_method': 'credit_card',
});

// 성능 지표
FlutterLiveLogger.event('performance_metric', {
  'metric': 'api_response_time',
  'endpoint': '/api/user/profile',
  'duration_ms': 245,
  'status_code': 200,
});

// 비즈니스 이벤트
FlutterLiveLogger.event('business_event', {
  'event': 'subscription_started',
  'plan': 'premium',
  'trial_period': 7,
  'user_segment': 'power_user',
});
```

### 네비게이션 추적

```dart
// 기본 네비게이션 옵저버
FlutterLiveLoggerNavigatorObserver()

// 커스터마이즈된 네비게이션 옵저버
FlutterLiveLoggerNavigatorObserver(
  enableDurationTracking: true,
  enableBreadcrumbs: true,
  maxBreadcrumbs: 10,
  routeNameExtractor: (route) {
    // 커스텀 라우트 이름 추출
    return route.settings.name ?? 'unknown';
  },
  shouldLogRoute: (route) {
    // 어떤 라우트를 로그할지 필터링
    return route is PageRoute && route.settings.name != null;
  },
)
```

---

## 🧪 테스트

라이브러리는 포괄적인 테스트를 포함합니다:

```bash
# 모든 테스트 실행
flutter test

# 커버리지와 함께 테스트 실행
flutter test --coverage
```

테스트 커버리지 포함 사항:

- ✅ 초기화 및 구성
- ✅ 모든 로그 레벨 및 필터링
- ✅ 전송 레이어 기능
- ✅ 저장소 작업 및 쿼리
- ✅ 에러 처리 및 복원력
- ✅ 배치 처리 및 성능

---

## 📊 모니터링 및 통계

로깅 시스템에 대한 인사이트 얻기:

```dart
// 로거 통계 가져오기
final stats = FlutterLiveLogger.getStats();
print('대기 중인 엔트리: ${stats['pendingEntries']}');
print('활성 전송: ${stats['transports']}');
print('저장소 타입: ${stats['config']['environment']}');

// 대기 중인 로그 강제 플러시
await FlutterLiveLogger.flush();

// 저장소 통계 가져오기
final storage = SQLiteStorage();
final storageStats = await storage.getStats();
print('전체 엔트리: ${storageStats['entryCount']}');
print('데이터베이스 크기: ${storageStats['databaseSize']} bytes');
```

---

## 🔧 고급 구성

### 환경별 설정

```dart
void main() async {
  late LoggerConfig config;
  
  if (kDebugMode) {
    // 개발 구성
    config = LoggerConfig.development(
      logLevel: LogLevel.trace,
      userId: 'dev_user',
    );
  } else if (kProfileMode) {
    // 성능 테스트 구성
    config = LoggerConfig.performance(
      logLevel: LogLevel.warn,
    );
  } else {
    // 릴리스 구성
    config = LoggerConfig.production(
      transports: [
        HttpTransport(config: HttpTransportConfig(
          endpoint: 'https://logs.yourapp.com/api/logs',
          apiKey: const String.fromEnvironment('LOG_API_KEY'),
        )),
      ],
      usePersistentStorage: true,
      logLevel: LogLevel.info,
    );
  }
  
  await FlutterLiveLogger.init(config: config);
  runApp(MyApp());
}
```

### 커스텀 전송 구현

```dart
class CustomTransport extends LogTransport {
  @override
  Future<void> send(List<LogEntry> entries) async {
    // 커스텀 전송 로직
    for (final entry in entries) {
      // 커스텀 백엔드로 전송
      await customApi.sendLog(entry.toJson());
    }
  }
  
  @override
  bool get isAvailable => true;
  
  @override
  Future<void> dispose() async {
    // 리소스 정리
  }
}
```

---

## 🏗️ 아키텍처

```
┌─────────────────────────────────────────────────┐
│                Flutter App                      │
├─────────────────────────────────────────────────┤
│              FlutterLiveLogger                  │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────┐ │
│  │   Logger    │ │   Navigator  │ │  Config  │ │
│  │    API      │ │   Observer   │ │          │ │
│  └─────────────┘ └──────────────┘ └──────────┘ │
├─────────────────────────────────────────────────┤
│               Transport Layer                   │
│  ┌─────────────┐ ┌──────────────┐ ┌──────────┐ │
│  │   Memory    │ │     File     │ │   HTTP   │ │
│  │  Transport  │ │   Transport  │ │Transport │ │
│  └─────────────┘ └──────────────┘ └──────────┘ │
├─────────────────────────────────────────────────┤
│                Storage Layer                    │
│  ┌─────────────┐ ┌──────────────┐              │
│  │   Memory    │ │    SQLite    │              │
│  │   Storage   │ │   Storage    │              │
│  └─────────────┘ └──────────────┘              │
└─────────────────────────────────────────────────┘
```

---

## 🤝 기여하기

기여를 환영합니다! 자세한 내용은 [기여 가이드](CONTRIBUTING.md)를 참조하세요.

### 개발 설정

```bash
# 저장소 클론
git clone https://github.com/curogom/flutter_live_logger.git
cd flutter_live_logger

# 의존성 설치
flutter pub get

# 테스트 실행
flutter test

# 예제 실행
cd example
flutter run
```

---

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 라이선스됩니다 - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

## 📞 지원

- 📖 [문서](docs/api/README.md)
- 🐛 [이슈 트래커](https://github.com/curogom/flutter_live_logger/issues)
- 💬 [토론](https://github.com/curogom/flutter_live_logger/discussions)
- 📧 이메일: <support@flutterlivelogger.com>

---

## 🌟 감사의 말

Flutter 커뮤니티를 위해 ❤️로 만들어졌습니다.

- 모든 [기여자들](https://github.com/curogom/flutter_live_logger/graphs/contributors)에게 감사드립니다
- Flutter 및 Dart 생태계의 베스트 프랙티스에서 영감을 받았습니다
- 놀라운 프레임워크를 만들어준 Flutter 팀에 특별한 감사를 드립니다
