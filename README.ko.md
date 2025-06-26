# Flutter Live Logger 🚀

[![pub package](https://img.shields.io/pub/v/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)
[![pub points](https://img.shields.io/pub/points/flutter_live_logger)](https://pub.dev/packages/flutter_live_logger/score)
[![popularity](https://img.shields.io/pub/popularity/flutter_live_logger)](https://pub.dev/packages/flutter_live_logger/score)
[![likes](https://img.shields.io/pub/likes/flutter_live_logger)](https://pub.dev/packages/flutter_live_logger/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CI/CD](https://github.com/curogom/flutter_live_logger/actions/workflows/ci.yml/badge.svg)](https://github.com/curogom/flutter_live_logger/actions/workflows/ci.yml)

초당 40만 개 이상의 로그를 처리할 수 있는 Flutter 애플리케이션용 프로덕션 레디 실시간 로깅 솔루션. 오프라인 지원과 실시간 대시보드 제공.

> 📖 **Languages**: [English](README.md) • [**한국어**](README.ko.md)

## 🌟 v0.3.0 새로운 기능

### 🚀 제로 설정 시작
```dart
// 단 한 줄로 시작!
await FlutterLiveLogger.start();
```

### 🧙‍♂️ 주요 개선사항
- **제로 설정 초기화** - 한 줄의 코드로 로깅 시작
- **대화형 설정 마법사** - GUI 기반 설정 생성기
- **VS Code 스니펫** - 코드 스니펫으로 빠른 개발
- **WebSocket 안정성** - 치명적인 동시성 버그 수정
- **Flutter 3.24+ 지원** - 최신 Flutter와 완벽 호환

## 📦 패키지 구성

이 모노레포는 두 개의 패키지를 포함합니다:

### 1. [flutter_live_logger](packages/flutter_live_logger) 
[![pub package](https://img.shields.io/pub/v/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)

핵심 로깅 라이브러리:
- 🚀 초당 40만+ 로그 처리량
- 🌐 크로스 플랫폼 지원 (iOS, Android, Web, Desktop)
- 💾 다양한 저장소 옵션 (Memory, SQLite)
- 🔄 다중 전송 계층 (Memory, File, HTTP)
- 📱 자동 네비게이션 추적
- 🔌 동기화를 통한 오프라인 지원

### 2. [flutter_live_logger_dashboard](packages/flutter_live_logger_dashboard)
[![pub package](https://img.shields.io/pub/v/flutter_live_logger_dashboard.svg)](https://pub.dev/packages/flutter_live_logger_dashboard)

실시간 모니터링을 위한 웹 대시보드:
- 📊 WebSocket을 통한 실시간 로그 스트리밍
- 📈 성능 분석 및 메트릭
- 🔍 고급 필터링 및 검색
- 📱 반응형 디자인
- 🎨 모던한 Flutter 웹 UI

## 🚀 빠른 시작

### 설치

```yaml
dependencies:
  flutter_live_logger: ^0.3.0

dev_dependencies:
  flutter_live_logger_dashboard: ^0.3.0  # 선택적 대시보드
```

### 기본 사용법

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 제로 설정으로 시작
  await FlutterLiveLogger.start();
  
  runApp(MyApp());
}

// 앱 어디서나 사용 가능
FlutterLiveLogger.info('앱 시작됨');
FlutterLiveLogger.error('문제가 발생했습니다', error: exception);
FlutterLiveLogger.event('user_login', {'user_id': userId});
```

## 💡 실제 사용 예제

### 이커머스 앱
```dart
// 사용자 여정 추적
FlutterLiveLogger.event('product_viewed', {
  'product_id': product.id,
  'category': product.category,
  'price': product.price,
});

// 성능 모니터링
final stopwatch = Stopwatch()..start();
await api.processPayment();
FlutterLiveLogger.info('결제 처리됨', data: {
  'duration_ms': stopwatch.elapsedMilliseconds,
  'amount': payment.amount,
});
```

### 에러 추적
```dart
try {
  await riskyOperation();
} catch (error, stackTrace) {
  FlutterLiveLogger.error(
    '작업 실패',
    error: error,
    stackTrace: stackTrace,
    data: {'user_id': currentUser.id},
  );
}
```

## 🛠️ 설정

### 환경별 설정

```dart
// 개발 환경
await FlutterLiveLogger.startDevelopment();

// 프로덕션 환경 (커스텀 전송)
await FlutterLiveLogger.init(
  config: LoggerConfig.production(
    transports: [
      HttpTransport(config: HttpTransportConfig(
        endpoint: 'https://api.your-domain.com/logs',
        apiKey: 'your-api-key',
      )),
      FileTransport(config: FileTransportConfig(
        directory: '/logs',
        compressRotatedFiles: true,
      )),
    ],
  ),
);
```

### 네비게이션 추적

```dart
MaterialApp(
  navigatorObservers: [
    FlutterLiveLoggerNavigatorObserver(
      enableDurationTracking: true,
      enableBreadcrumbs: true,
    ),
  ],
  home: HomeScreen(),
);
```

## 📊 대시보드 사용법

대시보드 서버 시작:

```dart
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

void main() async {
  final server = DashboardServer();
  await server.start(port: 8080);
  print('대시보드가 http://localhost:8080 에서 실행 중입니다');
}
```

## 🎯 주요 기능

### 성능
- ⚡ **초당 40만+ 로그** 처리량
- 🚀 **50ms 미만** 초기화 시간
- 💾 **10MB 미만** 메모리 사용량
- 🔄 **스마트 배칭**으로 효율성 극대화

### 신뢰성
- 🔌 **오프라인 지원** - 오프라인 시 로그 큐잉
- 🛡️ **에러 복원력** - 우아한 성능 저하
- 📦 **다중 전송** - 폴백 옵션
- 🧪 **95%+ 테스트 커버리지** - 실전 검증

### 개발자 경험
- 🎯 **제로 설정 시작** - 한 줄 설정
- 📚 **풍부한 문서** - 종합 가이드
- 🛠️ **VS Code 스니펫** - 빠른 개발
- 🌍 **크로스 플랫폼** - 한 번 작성, 어디서나 실행

## 📖 문서

- [시작 가이드](packages/flutter_live_logger/README.md)
- [API 문서](https://pub.dev/documentation/flutter_live_logger/latest/)
- [대시보드 가이드](packages/flutter_live_logger_dashboard/README.md)
- [예제](packages/flutter_live_logger/example)
- [변경 이력](packages/flutter_live_logger/CHANGELOG.md)

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

# 예제 앱 실행
cd packages/flutter_live_logger/example
flutter run
```

## 📄 라이선스

이 프로젝트는 MIT 라이선스에 따라 라이선스가 부여됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🙏 감사의 말

모든 기여자와 Flutter 커뮤니티의 지원과 피드백에 특별히 감사드립니다.

## 📬 지원

- 🐛 [이슈 보고](https://github.com/curogom/flutter_live_logger/issues)
- 💬 [토론](https://github.com/curogom/flutter_live_logger/discussions)
- 📧 [이메일](mailto:support@curogom.dev)

---

<p align="center"><a href="https://curogom.dev">curogom.dev</a>가 ❤️를 담아 만들었습니다</p>