# Flutter Live Logger Dashboard

[![pub package](https://img.shields.io/pub/v/flutter_live_logger_dashboard.svg)](https://pub.dev/packages/flutter_live_logger_dashboard)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Flutter Live Logger를 위한 실시간 웹 대시보드 - 로그 모니터링 및 분석 도구

[English](README.md) | **한국어**

## ✨ 주요 기능

- 📊 **실시간 모니터링**: 라이브 로그 스트리밍 및 분석
- 🌐 **웹 기반 대시보드**: 브라우저에서 바로 접근 가능
- 🔍 **고급 필터링**: 레벨, 시간, 키워드별 필터링
- 📈 **성능 메트릭**: 처리량, 응답시간, 메모리 사용량 모니터링
- 🎨 **반응형 UI**: 모바일부터 데스크톱까지 완벽 지원
- 🚀 **고성능**: 수천 개의 로그 실시간 처리
- 🔄 **자동 새로고침**: 설정 가능한 자동 업데이트
- 📱 **사용자 친화적**: 직관적인 인터페이스

## 🚀 빠른 시작

### 설치

`pubspec.yaml`에 추가:

```yaml
dev_dependencies:
  flutter_live_logger_dashboard: ^0.2.0
```

### 기본 사용법

#### 1. 간단한 서버 실행

```dart
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

void main() async {
  // 대시보드 서버 시작
  final server = DashboardServer(
    port: 7580,
    enableCORS: true,
  );
  
  await server.start();
  print('대시보드 서버 실행: http://localhost:7580');
}
```

#### 2. Flutter 앱에서 로그 전송

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() async {
  await FlutterLiveLogger.init(
    config: LoggerConfig(
      logLevel: LogLevel.debug,
      environment: 'development',
      transports: [
        MemoryTransport(maxEntries: 1000),
        HttpTransport(
          config: HttpTransportConfig.withApiKey(
            endpoint: 'http://localhost:7580/api/logs',
            apiKey: 'your-api-key',
          ),
        ),
      ],
    ),
  );

  runApp(MyApp());
}
```

#### 3. 웹 브라우저에서 확인

브라우저에서 `http://localhost:7580`로 접속하여 실시간 대시보드를 확인하세요.

## 🏗️ 아키텍처

### 서버 컴포넌트

- **HTTP API 서버**: RESTful API로 로그 수신 (포트 7580)
- **WebSocket 서버**: 실시간 로그 스트리밍 (포트 7581)
- **웹 대시보드**: 정적 HTML/CSS/JavaScript UI
- **데이터베이스**: 로그 저장 및 쿼리

### UI 컴포넌트

- **DashboardPage**: 메인 대시보드 레이아웃
- **LogDisplayWidget**: 실시간 로그 테이블
- **FilterWidget**: 고급 필터링 옵션
- **PerformanceDashboard**: 성능 메트릭 차트
- **AnalyticsWidget**: 로그 분석 및 인사이트

## 📊 대시보드 기능

### 실시간 로그 모니터링

```
📋 실시간 로그
┌─────────────┬──────────────────┬─────────────────┐
│ 레벨        │ 메시지           │ 시간            │
├─────────────┼──────────────────┼─────────────────┤
│ [INFO]      │ 사용자 로그인    │ 14:23:45       │
│ [ERROR]     │ 네트워크 오류    │ 14:23:50       │
│ [DEBUG]     │ API 호출 완료    │ 14:23:52       │
└─────────────┴──────────────────┴─────────────────┘
```

### 성능 메트릭

- **처리량**: 초당 로그 처리 개수
- **응답 시간**: 평균 API 응답 시간
- **메모리 사용량**: 서버 메모리 상태
- **오류율**: 오류 로그 비율

### 분석 및 인사이트

- **로그 레벨 분포**: 파이 차트
- **상위 오류 메시지**: 빈도별 정렬
- **시간대별 트렌드**: 라인 차트

## 🔧 설정

### 서버 설정

```dart
DashboardServer(
  port: 7580,                    // HTTP 서버 포트
  websocketPort: 7581,           // WebSocket 포트
  enableCORS: true,              // CORS 활성화
  maxLogs: 1000,                 // 최대 저장 로그 수
  autoRefreshInterval: Duration(seconds: 2), // 자동 새로고침 간격
)
```

### 데이터베이스 설정

```dart
DashboardDatabase.initialize(
  path: 'logs.db',               // 데이터베이스 파일 경로
  enableWAL: true,               // WAL 모드 활성화
  maxEntries: 10000,             // 최대 저장 항목 수
)
```

## 🌐 웹 플랫폼 지원

### CORS 설정

웹에서 대시보드를 사용하려면 서버에 CORS 설정이 필요합니다:

```dart
// 자동으로 CORS 헤더 설정
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Origin, Content-Type, X-API-Key
```

### 브라우저 호환성

- ✅ Chrome/Chromium
- ✅ Safari
- ✅ Firefox  
- ✅ Edge

## 📱 반응형 디자인

### 모바일 지원

- 햄버거 메뉴 네비게이션
- 터치 친화적 인터페이스
- 최적화된 차트 및 테이블

### 데스크톱 지원

- 사이드바 네비게이션
- 멀티 컬럼 레이아웃
- 키보드 단축키 지원

## 🧪 테스트

포괄적인 테스트 커버리지:

```bash
cd packages/flutter_live_logger_dashboard
dart test
```

### 테스트 범위

- **서버 API**: HTTP 엔드포인트 테스트
- **WebSocket**: 실시간 통신 테스트  
- **데이터베이스**: CRUD 작업 테스트
- **UI 컴포넌트**: 위젯 테스트

## 📚 사용 예시

### 개발 환경 모니터링

```dart
// 개발 서버 실행
void main() async {
  final server = DashboardServer(
    port: 7580,
    enableCORS: true,
  );
  
  await server.start();
  
  print('🚀 대시보드 서버가 시작되었습니다!');
  print('   HTTP API: http://localhost:7580');
  print('   WebSocket: ws://localhost:7581');
  print('   웹 대시보드: http://localhost:7580');
}
```

### 프로덕션 환경 설정

```dart
// 프로덕션 서버 설정
final server = DashboardServer(
  port: 8080,
  websocketPort: 8081,
  enableCORS: true,
  maxLogs: 50000,
  enableAuth: true,          // 인증 활성화
  apiKey: 'prod-api-key',    // API 키 설정
);
```

## 🔒 보안

### API 키 인증

```dart
HttpTransportConfig.withApiKey(
  endpoint: 'https://your-server.com/api/logs',
  apiKey: 'your-secure-api-key',
)
```

### HTTPS 지원

프로덕션 환경에서는 HTTPS 사용을 권장합니다:

```dart
final server = DashboardServer(
  port: 443,
  enableSSL: true,
  certificatePath: '/path/to/cert.pem',
  privateKeyPath: '/path/to/key.pem',
);
```

## 🚀 성능 최적화

### 메모리 관리

- 자동 로그 회전 (최대 100개 유지)
- 효율적인 메모리 사용
- 가비지 컬렉션 최적화

### 네트워크 최적화

- 배치 처리로 네트워크 호출 최소화
- Gzip 압축 지원
- 연결 풀링

## 🤝 기여하기

기여를 환영합니다! 자세한 내용은 [기여 가이드](../../CONTRIBUTING.md)를 참조하세요.

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🔗 관련 패키지

- [flutter_live_logger](https://pub.dev/packages/flutter_live_logger) - 핵심 로깅 라이브러리

## 📞 지원

- 🐛 [이슈 제보](https://github.com/curogom/flutter_live_logger/issues)
- 💬 [토론](https://github.com/curogom/flutter_live_logger/discussions)
- 📧 이메일: <support@flutterlivelogger.com>

## 📖 자주 묻는 질문

### Q: 웹에서 CORS 오류가 발생해요

A: 서버에서 `enableCORS: true`로 설정하고, 필요시 도메인을 명시적으로 추가하세요.

### Q: 대시보드가 로그를 받지 못해요

A: Flutter 앱의 HttpTransport 엔드포인트와 대시보드 서버 주소가 일치하는지 확인하세요.

### Q: 모바일에서 대시보드를 사용할 수 있나요?

A: 네! 반응형 디자인으로 모바일 브라우저에서도 완벽하게 작동합니다.

### Q: 데이터베이스를 사용자 정의할 수 있나요?

A: 네! `DashboardDatabase` 클래스를 상속하여 커스텀 구현을 만들 수 있습니다.
