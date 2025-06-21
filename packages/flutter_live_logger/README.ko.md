# Flutter Live Logger

[![pub package](https://img.shields.io/pub/v/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Flutter 애플리케이션을 위한 프로덕션 준비 완료 실시간 로깅 솔루션**

Flutter Live Logger는 프로덕션 환경의 Flutter 앱을 위해 설계된 포괄적인 로깅 라이브러리입니다. 다중 전송 레이어, 영구 저장소, 자동 네비게이션 추적, 그리고 오프라인 지원을 깔끔하고 개발자 친화적인 API로 제공합니다.

> 📖 **Languages**: [English](README.md) • [**한국어**](README.ko.md)

---

## ✨ 주요 기능

### 🎯 **핵심 기능**

- 🚀 **고성능**: 434,000+ 로그/초 처리량
- 🌐 **크로스 플랫폼**: iOS, Android, Web, macOS, Windows, Linux
- 🔥 **다중 전송 레이어**: Memory, File, HTTP 전송 옵션
- 💾 **영구 저장소**: 쿼리 가능한 SQLite 및 메모리 기반 저장소
- 📱 **자동 네비게이션 추적**: 자동 화면 전환 로깅
- 🔄 **오프라인 지원**: 오프라인에서 로그 대기열 처리 후 연결 시 동기화
- ⚡ **스마트 배칭**: 효율성을 위한 구성 가능한 배치 처리
- 🎛️ **구성 가능**: 다중 환경 구성 (개발/프로덕션/테스트)

### 🛠️ **개발자 경험**

- ⚡ **간편한 설정**: 한 줄의 코드로 초기화
- 📚 **완전한 API**: 포괄적인 dartdoc 문서
- 🔒 **타입 안전**: 완전한 null safety 및 강한 타입화
- 🧪 **충분한 테스트**: 35개 이상의 포괄적인 테스트로 95%+ 테스트 커버리지
- 🌍 **크로스 플랫폼**: iOS, Android, Web, Desktop 지원

---

## 🚀 빠른 시작

### 1. 의존성 추가

```yaml
dependencies:
  flutter_live_logger: ^0.2.0
```

### 2. Logger 초기화

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 전송 레이어와 함께 초기화
  await FlutterLiveLogger.init(
    config: LoggerConfig(
      logLevel: LogLevel.debug,
      environment: 'development',
      transports: [
        MemoryTransport(maxEntries: 1000),
        HttpTransport(
          config: HttpTransportConfig.withApiKey(
            endpoint: 'https://your-api.com/logs',
            apiKey: 'your-api-key',
          ),
        ),
      ],
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
        FlutterLiveLoggerNavigatorObserver(
          enableDurationTracking: true,
          enableBreadcrumbs: true,
        ),
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
  config: LoggerConfig(
    logLevel: LogLevel.debug,
    environment: 'development',
    enableOfflineSupport: true,
    transports: [
      MemoryTransport(maxEntries: 1000),
      HttpTransport(
        config: HttpTransportConfig.withApiKey(
          endpoint: 'https://api.example.com/logs',
          apiKey: 'dev-api-key',
        ),
      ),
    ],
  ),
);

// 프로덕션 구성  
await FlutterLiveLogger.init(
  config: LoggerConfig(
    logLevel: LogLevel.info,
    environment: 'production',
    enableOfflineSupport: true,
    batchSize: 50,
    flushInterval: Duration(seconds: 10),
    transports: [
      HttpTransport(
        config: HttpTransportConfig.withApiKey(
          endpoint: 'https://api.example.com/logs',
          apiKey: 'prod-api-key',
          batchSize: 50,
          timeout: Duration(seconds: 30),
          maxRetries: 3,
        ),
      ),
      FileTransport(
        config: FileTransportConfig(
          directory: '/app/logs',
          maxFileSize: 10 * 1024 * 1024, // 10MB
          maxFiles: 5,
        ),
      ),
    ],
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

// HTTP Transport (원격 로깅 및 완전한 웹 지원)
final httpTransport = HttpTransport(
  config: HttpTransportConfig.withApiKey(
    endpoint: 'https://api.example.com/logs',
    apiKey: 'your-api-key',
    batchSize: 10,
    timeout: Duration(seconds: 30),
    maxRetries: 3,
  ),
);
```

### 저장소 옵션

```dart
// Memory Storage (빠름, 비영구적)
final memoryStorage = MemoryStorage(maxEntries: 10000);

// SQLite Storage (영구적, 쿼리 가능)
final sqliteStorage = SQLiteStorage(
  path: 'app_logs.db',
  maxEntries: 100000,
);
```

## 🌐 웹 플랫폼 지원

Flutter Live Logger는 CORS 지원 HTTP 전송으로 웹 플랫폼을 완전히 지원합니다:

```dart
// 웹에서 완벽하게 작동
HttpTransport(
  config: HttpTransportConfig.withApiKey(
    endpoint: 'https://api.example.com/logs',
    apiKey: 'your-key',
  ),
)
```

**참고**: 서버에서 적절한 CORS 헤더를 구성해야 합니다:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Origin, Content-Type, X-API-Key
```

## 📊 성능 벤치마크

성능 측정 지표:

- **처리량**: 434,783 로그/초
- **초기화**: <50ms 시작 시간  
- **메모리**: <10MB 최대 사용량
- **크로스 플랫폼**: 모든 플랫폼에서 일관된 성능

## 📊 대시보드 통합

실시간 모니터링과 분석을 위해 컴패니언 대시보드를 사용하세요:

```yaml
dev_dependencies:
  flutter_live_logger_dashboard: ^0.2.0
```

## 📱 플랫폼 지원

| 플랫폼 | 지원 | 비고 |
|----------|---------|-------|
| iOS | ✅ | 완전 지원 |
| Android | ✅ | 완전 지원 |
| Web | ✅ | HTTP 전송을 위한 CORS 필요 |
| macOS | ✅ | 완전 지원 |
| Windows | ✅ | 완전 지원 |
| Linux | ✅ | 완전 지원 |

## 🧪 테스트

패키지에는 포괄적인 테스트 커버리지가 포함되어 있습니다:

```bash
flutter test
```

**테스트 결과**: 35/35 테스트 통과 (100%)

## 📚 예시

다음 내용을 보여주는 완전한 구현은 [예시 앱](example/)을 확인하세요:

- 기본 로깅 설정
- HTTP 전송 구성 (웹 호환)
- Navigator 관찰
- 에러 처리
- 성능 모니터링

## 🤝 기여하기

기여를 환영합니다! 자세한 내용은 [기여 가이드](../../CONTRIBUTING.md)를 참조하세요.

## 📄 라이선스

이 프로젝트는 MIT 라이선스로 라이선스가 부여됩니다 - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🔗 관련 패키지

- [flutter_live_logger_dashboard](https://pub.dev/packages/flutter_live_logger_dashboard) - 실시간 모니터링을 위한 웹 대시보드

## 📞 지원

- 🐛 [이슈 신고](https://github.com/curogom/flutter_live_logger/issues)
- 💬 [토론](https://github.com/curogom/flutter_live_logger/discussions)
- 📧 이메일: <support@flutterlivelogger.com>
