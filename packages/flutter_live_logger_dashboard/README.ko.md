# Flutter Live Logger Dashboard

> ⚠️ **개발 전용 도구** - 이 패키지는 개발 및 디버깅 목적으로 설계되었습니다. `dev_dependencies`에만 추가하세요.

Flutter 애플리케이션의 실시간 모니터링 및 로그 분석을 위한 종합적인 웹 대시보드입니다. Flutter Web으로 구축된 이 대시보드는 개발 중 디버깅과 모니터링을 위해 실시간 로그 스트리밍, 성능 분석, 강력한 필터링 기능을 제공합니다.

[![pub package](https://img.shields.io/pub/v/flutter_live_logger_dashboard.svg)](https://pub.dev/packages/flutter_live_logger_dashboard)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 기능

🔴 **실시간 로그 스트리밍** - WebSocket 기반 실시간 로그 모니터링  
📊 **성능 분석** - CPU, 메모리, 처리량 시각화  
🎯 **고급 필터링** - 다중 레벨 로그 필터링 및 검색  
💾 **데이터 영속성** - Drift ORM 기반 SQLite 저장소  
🌐 **웹 대시보드** - 반응형 Flutter Web 인터페이스  
🚀 **고성능** - 초당 555,556개 이상의 로그 처리  

## 대시보드 구성요소

- **로그 표시 위젯**: 구문 강조 기능이 있는 실시간 로그 항목
- **성능 대시보드**: 시스템 지표를 위한 인터랙티브 차트
- **분석 위젯**: 통계적 인사이트 및 추세 분석
- **필터 위젯**: 고급 로그 쿼리 및 검색
- **설정 위젯**: 구성 및 환경설정 관리

## 시작하기

### 사전 요구사항

- Flutter 3.16.0 이상
- Dart 3.0.0 이상
- [flutter_live_logger](https://pub.dev/packages/flutter_live_logger) 코어 패키지

### 설치

⚠️ **중요**: 이 패키지는 개발 용도로만 사용되므로 `dev_dependencies`에만 추가하세요:

```yaml
dev_dependencies:
  flutter_live_logger_dashboard: ^0.2.0+1
  # ... 기타 개발 의존성
```

**일반 `dependencies`에 추가하지 마세요**:

```yaml
# ❌ 이렇게 하지 마세요
dependencies:
  flutter_live_logger_dashboard: ^0.2.0+1  # 잘못됨!
```

그런 다음 실행:

```bash
flutter pub get
```

## 사용법

### 개발 워크플로우

이 대시보드는 개발 환경과 함께 실행되도록 설계되었습니다:

1. **대시보드 서버 시작** (별도 프로세스)
2. **로깅이 활성화된 Flutter 앱 실행**
3. **웹 브라우저를 통한 실시간 로그 모니터링**

### 기본 서버 설정

개발 대시보드 서버 생성 (별도로 실행):

```dart
// dev_tools/dashboard_server.dart
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

void main() async {
  print('🚀 개발 대시보드 서버 시작 중...');
  
  // 대시보드 서버 시작
  final server = DashboardServer();
  await server.start(
    httpPort: 7580,
    webSocketPort: 7581,
  );
  
  print('📊 대시보드 접속: http://localhost:7580');
  print('🔌 WebSocket 연결: ws://localhost:7581');
  print('💡 Flutter 앱을 실행하면 로그가 여기에 표시됩니다');
}
```

### Flutter 앱 연결

메인 Flutter 애플리케이션에서 (개발 구성):

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  // 개발 대시보드로 로그 전송 구성
  // 개발 빌드에서만 활성화
  if (kDebugMode) {
    FlutterLiveLogger.configure(
      transports: [
        HttpTransport(
          url: 'http://localhost:7580/api/logs',
          enableBatch: true,
        ),
      ],
    );
  }
  
  runApp(MyApp());
}
```

### 개발 워크플로우 실행

1. **대시보드 서버 시작**:

   ```bash
   cd dev_tools/
   dart run dashboard_server.dart
   ```

2. **Flutter 앱 실행**:

   ```bash
   flutter run
   ```

3. **브라우저에서 대시보드 열기**:

   ```
   http://localhost:7580
   ```

## 성능

- **처리량**: 초당 555,556개의 로그 처리 능력
- **메모리 사용량**: 효율적인 가비지 컬렉션으로 10MB 미만 RAM 사용  
- **실시간 지연시간**: 로그 생성부터 대시보드 표시까지 100ms 미만
- **동시 연결**: 100개 이상의 동시 WebSocket 클라이언트 지원

## 예제

완전한 구현 예제는 [example/main.dart](example/main.dart)와 [simple_server.dart](simple_server.dart) 파일을 확인하세요.

## 모범 사례

### 개발 vs 프로덕션

- ✅ **개발**: 디버깅 및 모니터링을 위한 대시보드 사용
- ❌ **프로덕션**: 프로덕션 빌드에 대시보드를 절대 포함하지 마세요
- ✅ **CI/CD**: 프로덕션 의존성 트리에서 제외
- ✅ **테스트**: 통합 테스트 모니터링에 사용

### 보안 고려사항

- 대시보드 서버는 **보안이 없으며** 로컬 개발 전용입니다
- 대시보드 포트를 외부 네트워크에 노출하지 마세요
- localhost/개발 환경에서만 사용하세요

## 기여

기여를 환영합니다! 자세한 내용은 [기여 가이드](https://github.com/curogom/flutter_live_logger/blob/main/CONTRIBUTING.md)를 읽어주세요.

## 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다 - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 관련 패키지

- [flutter_live_logger](https://pub.dev/packages/flutter_live_logger) - 코어 로깅 기능
