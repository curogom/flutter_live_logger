# 🚀 Flutter Live Logger

[![pub package](https://img.shields.io/pub/v/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)
[![popularity](https://img.shields.io/pub/popularity/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)
[![likes](https://img.shields.io/pub/likes/flutter_live_logger.svg)](https://pub.dev/packages/flutter_live_logger)
[![CI](https://github.com/curogom/flutter_live_logger/workflows/CI/badge.svg)](https://github.com/curogom/flutter_live_logger/actions)
[![codecov](https://codecov.io/gh/curogom/flutter_live_logger/branch/main/graph/badge.svg)](https://codecov.io/gh/curogom/flutter_live_logger)

**상용 환경에서도 Flutter 앱 로그를 실시간으로 확인하세요!**

Flutter Live Logger는 Release 빌드된 앱에서도 로그를 안전하게 수집하고, 실시간으로 웹 대시보드에서 모니터링할 수 있는 오픈소스 로깅 솔루션입니다.

> 📖 **Languages**: [English](README.md) • [**한국어**](README.ko.md)

---

## ✨ 주요 기능

### 🎯 **Flutter 개발자를 위한 특별한 기능들**

- 🔥 **실시간 로그 스트리밍**: WebSocket으로 즉시 확인
- 📱 **Release 빌드 지원**: 상용 환경에서도 안전한 로깅
- 🎨 **자동 화면 추적**: Navigator 변화 자동 감지
- 💾 **오프라인 지원**: 네트워크 단절 시에도 로그 보관
- 🎛️ **유연한 설정**: 로그 레벨별 필터링
- 🔌 **플러그인 아키텍처**: 다양한 백엔드 지원

### 🛠️ **개발자 경험 최우선**

- ⚡ **5분 설정**: 복잡한 설정 없이 바로 사용
- 📚 **완벽한 문서화**: dartdoc 기반 API 문서
- 🔒 **타입 안전**: Null safety 완벽 지원
- 🧪 **높은 테스트 커버리지**: 95%+ 커버리지
- 🌍 **크로스 플랫폼**: iOS, Android, Web, Desktop 모두 지원

---

## 🚀 빠른 시작

### 1. 의존성 추가

```yaml
dependencies:
  flutter_live_logger: ^1.0.0
```

### 2. 초기화

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  // Logger 초기화
  FlutterLiveLogger.init(
    config: LoggerConfig(
      logLevel: LogLevel.debug,
      enableAutoScreenTracking: true,
      enableCrashReporting: true,
    ),
  );
  
  runApp(MyApp());
}
```

### 3. 자동 화면 추적 설정

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [
        FlutterLiveLogger.navigatorObserver, // 화면 전환 자동 추적
      ],
      home: HomeScreen(),
    );
  }
}
```

### 4. 로그 사용

```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Live Logger Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // 간단한 로그
            FlutterLiveLogger.info('사용자가 버튼을 클릭했습니다');
            
            // 이벤트 추적
            FlutterLiveLogger.event('button_click', {
              'button_id': 'main_cta',
              'screen': 'home',
              'timestamp': DateTime.now().toIso8601String(),
            });
            
            // 에러 로깅
            try {
              // 어떤 작업...
            } catch (error, stackTrace) {
              FlutterLiveLogger.error(
                'API 호출 실패',
                error: error,
                stackTrace: stackTrace,
              );
            }
          },
          child: Text('로그 테스트'),
        ),
      ),
    );
  }
}
```

---

## 📖 더 많은 예제

### 기본 로깅

```dart
// 다양한 로그 레벨
FlutterLiveLogger.trace('상세한 디버그 정보');
FlutterLiveLogger.debug('디버그 정보');
FlutterLiveLogger.info('일반 정보');
FlutterLiveLogger.warning('경고 메시지');
FlutterLiveLogger.error('에러 발생');
FlutterLiveLogger.fatal('심각한 오류');
```

### 구조화된 로깅

```dart
// 커스텀 데이터와 함께
FlutterLiveLogger.info('사용자 로그인', data: {
  'user_id': '12345',
  'login_method': 'google',
  'device_type': 'mobile',
  'app_version': '1.2.3',
});

// 성능 측정
final stopwatch = Stopwatch()..start();
await someApiCall();
stopwatch.stop();

FlutterLiveLogger.performance('API 응답 시간', {
  'endpoint': '/api/user/profile',
  'duration_ms': stopwatch.elapsedMilliseconds,
  'status_code': 200,
});
```

## 🤝 기여하기

Flutter Live Logger는 오픈소스 프로젝트입니다. 여러분의 기여를 환영합니다!

자세한 내용은 [CONTRIBUTING.md](CONTRIBUTING.md)를 참고해주세요.

---

## 📄 라이선스

이 프로젝트는 [MIT License](LICENSE) 하에 배포됩니다.

---

<div align="center">

**[🚀 시작하기](https://pub.dev/packages/flutter_live_logger)** •
**[📖 문서](https://pub.dev/documentation/flutter_live_logger/latest/)** •
**[💬 커뮤니티](https://github.com/your-username/flutter_live_logger/discussions)** •
**[🐛 이슈 신고](https://github.com/your-username/flutter_live_logger/issues)**

Made with ❤️ by Flutter Community

</div>
