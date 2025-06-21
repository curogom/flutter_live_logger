# Flutter Live Logger 패키지 분리 계획서

## 📋 개요

Flutter Live Logger 프로젝트를 Core 패키지와 Dashboard 패키지로 분리하여 사용자별 니즈에 맞는 최적화된 라이브러리를 제공합니다.

**주요 변경사항**: v0.1.1에서 v0.2.0으로 업그레이드하면서 새로운 웹 대시보드 기능을 별도 패키지로 추가합니다.

## 🎯 분리 목표

### 주요 목표

- **경량화**: Core 패키지 크기 90% 감소 (50KB 목표)
- **선택적 사용**: 웹 대시보드가 필요한 사용자만 별도 설치
- **개발 도구화**: Dashboard를 dev_dependencies로 사용
- **유지보수성**: 각 패키지의 책임 명확화
- **확장성**: 향후 추가 도구들의 분리 기반 마련

### 성능 목표

```
현재 상태 (v0.1.1):
├── 전체 크기: 기본 로깅 기능만
├── 의존성: 4개 패키지 (기본)
└── 웹 기능: 없음

목표 상태 (v0.2.0):
├── Core: ~50KB (기존 기능 유지)
├── Dashboard: ~500KB (새로운 기능, 선택적)
├── Core 의존성: 4개 (변경 없음)
└── 빌드 시간: Core는 기존과 동일
```

## 📦 패키지 구조 설계

### 1. flutter_live_logger (Core Package) - v0.2.0

#### 책임 범위

- 핵심 로깅 기능 (기존 유지)
- Transport 시스템 (HTTP, File, Memory)
- Storage 인터페이스
- 기본 설정 및 관리

#### 디렉토리 구조

```
flutter_live_logger/
├── lib/
│   ├── flutter_live_logger.dart           # 메인 export
│   └── src/
│       ├── core/
│       │   ├── flutter_live_logger.dart   # 메인 로거 클래스
│       │   ├── log_entry.dart             # 로그 엔트리 모델
│       │   ├── log_level.dart             # 로그 레벨 정의
│       │   ├── logger_config.dart         # 설정 클래스
│       │   └── navigator_observer.dart    # 네비게이션 관찰자
│       ├── transport/
│       │   ├── log_transport.dart         # Transport 인터페이스
│       │   ├── http_transport.dart        # HTTP 전송
│       │   ├── file_transport.dart        # 파일 저장
│       │   └── memory_transport.dart      # 메모리 저장
│       └── storage/
│           ├── storage_interface.dart     # Storage 인터페이스
│           ├── memory_storage.dart        # 메모리 저장소
│           └── sqlite_storage.dart        # SQLite 저장소
├── test/                                  # Core 테스트
├── example/                               # 기본 사용 예제
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
└── LICENSE
```

#### 의존성 (최소화)

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0      # SQLite 지원
  http: ^1.1.0         # HTTP Transport
  path: ^1.8.3         # 파일 경로 처리
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
```

### 2. flutter_live_logger_dashboard (Dashboard Package) - v0.2.0

#### 책임 범위

- 웹 대시보드 서버 (HTTP API + WebSocket)
- 실시간 UI 컴포넌트
- 데이터베이스 레이어 (Drift)
- 분석 및 시각화 도구

#### 디렉토리 구조

```
flutter_live_logger_dashboard/
├── lib/
│   ├── flutter_live_logger_dashboard.dart # 메인 export
│   └── src/
│       ├── server/
│       │   ├── dashboard_server.dart      # HTTP API 서버
│       │   └── websocket_server.dart      # WebSocket 서버
│       ├── database/
│       │   ├── dashboard_database.dart    # Drift 데이터베이스
│       │   └── dashboard_database.g.dart  # 생성된 코드
│       ├── ui/
│       │   ├── dashboard_page.dart        # 메인 페이지
│       │   ├── log_display_widget.dart    # 로그 표시
│       │   ├── filter_widget.dart         # 필터링
│       │   ├── performance_dashboard.dart # 성능 메트릭
│       │   ├── analytics_widget.dart      # 분석
│       │   └── settings_widget.dart       # 설정
│       └── connector/
│           └── dashboard_connector.dart   # Core와의 연동
├── web/                                   # 웹 에셋
├── test/                                  # Dashboard 테스트
├── example/                               # Dashboard 사용 예제
├── pubspec.yaml
├── README.md
├── CHANGELOG.md
└── LICENSE
```

#### 의존성

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_live_logger: ^0.2.0  # Core 패키지 의존
  
  # 웹 서버
  shelf: ^1.4.0
  shelf_web_socket: ^1.0.4
  shelf_cors_headers: ^0.1.5
  
  # UI 컴포넌트
  flutter_riverpod: ^2.4.9
  data_table_2: ^2.5.0
  fl_chart: ^0.68.0
  
  # 데이터베이스
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  
  # 웹소켓 클라이언트
  web_socket_channel: ^2.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  drift_dev: ^2.14.0
  build_runner: ^2.4.7
```

#### 2.2 패키지 메타데이터 설정

```yaml
# pubspec.yaml
name: flutter_live_logger_dashboard
description: Web dashboard for Flutter Live Logger - Real-time log monitoring and analytics
version: 0.2.0
homepage: https://github.com/your-org/flutter_live_logger_dashboard
repository: https://github.com/your-org/flutter_live_logger_dashboard

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.16.0"
```

## 🔄 개발 단계별 계획

### Phase 1: 사전 준비 (1일)

#### 1.1 현재 코드 분석

- [ ] 의존성 분석 및 매핑
- [ ] Export/Import 관계 파악
- [ ] 테스트 커버리지 확인
- [ ] 문서 현황 점검

#### 1.2 분리 기준 정립

```
Core에 남길 것:
✅ src/core/* (모든 파일)
✅ src/transport/* (모든 파일)  
✅ src/storage/* (모든 파일)
✅ 관련 테스트 파일

Dashboard로 이동할 것:
📦 src/web_dashboard/* (모든 파일)
📦 관련 테스트 파일
📦 웹 관련 의존성
```

#### 1.3 백업 및 브랜치 생성

```bash
# 현재 상태 백업
git checkout -b backup/pre-separation

# 분리 작업용 브랜치
git checkout -b feature/package-separation
```

### Phase 2: Dashboard 패키지 생성 (1일)

#### 2.1 새 패키지 생성

```bash
# 상위 디렉토리로 이동
cd ..

# Dashboard 패키지 생성
flutter create --template=package flutter_live_logger_dashboard

# 기본 구조 설정
cd flutter_live_logger_dashboard
```

#### 2.2 패키지 메타데이터 설정

```yaml
# pubspec.yaml
name: flutter_live_logger_dashboard
description: Web dashboard for Flutter Live Logger - Real-time log monitoring and analytics
version: 0.2.0
homepage: https://github.com/your-org/flutter_live_logger_dashboard
repository: https://github.com/your-org/flutter_live_logger_dashboard

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.16.0"
```

#### 2.3 디렉토리 구조 생성

```bash
mkdir -p lib/src/{server,database,ui,connector}
mkdir -p test/{server,database,ui,connector}
mkdir -p example
mkdir -p web
```

### Phase 3: 코드 이동 및 리팩토링 (2일)

#### 3.1 웹 대시보드 코드 이동

```bash
# 현재 flutter_live_logger에서
cp -r lib/src/web_dashboard/* ../flutter_live_logger_dashboard/lib/src/
cp -r test/web_dashboard_* ../flutter_live_logger_dashboard/test/
```

#### 3.2 Import 경로 수정

```dart
// 변경 전
import 'package:flutter_live_logger/src/web_dashboard/...';

// 변경 후  
import 'package:flutter_live_logger_dashboard/src/...';
import 'package:flutter_live_logger/flutter_live_logger.dart';
```

#### 3.3 연동 인터페이스 구현

```dart
// lib/src/connector/dashboard_connector.dart
class DashboardConnector {
  static Future<void> attachToLogger(
    FlutterLiveLogger logger, {
    int httpPort = 7580,
    int wsPort = 7581,
  }) async {
    // HTTP API 서버 시작
    final apiServer = DashboardServer(port: httpPort);
    await apiServer.start();
    
    // WebSocket 서버 시작
    final wsServer = WebSocketServer(port: wsPort);
    await wsServer.start();
    
    // Logger에 Dashboard Transport 추가
    logger.addTransport(DashboardTransport(
      apiServer: apiServer,
      wsServer: wsServer,
    ));
  }
}
```

### Phase 4: Core 패키지 정리 (1일)

#### 4.1 웹 대시보드 코드 제거

```bash
# flutter_live_logger에서
rm -rf lib/src/web_dashboard/
rm -f test/web_dashboard_*
```

#### 4.2 Export 정리

```dart
// lib/flutter_live_logger.dart
library flutter_live_logger;

// Core exports
export 'src/core/flutter_live_logger.dart';
export 'src/core/log_entry.dart';
export 'src/core/log_level.dart';
export 'src/core/logger_config.dart';
export 'src/core/navigator_observer.dart';

// Transport exports
export 'src/transport/log_transport.dart';
export 'src/transport/http_transport.dart';
export 'src/transport/file_transport.dart';
export 'src/transport/memory_transport.dart';

// Storage exports
export 'src/storage/storage_interface.dart';
export 'src/storage/memory_storage.dart';
export 'src/storage/sqlite_storage.dart';

// 웹 대시보드 관련 export 제거
```

#### 4.3 의존성 정리

```yaml
# pubspec.yaml에서 제거할 의존성들
dependencies:
  # shelf: ^1.4.0                    # 제거
  # shelf_web_socket: ^1.0.4         # 제거
  # shelf_cors_headers: ^0.1.5       # 제거
  # flutter_riverpod: ^2.4.9         # 제거
  # data_table_2: ^2.5.0             # 제거
  # fl_chart: ^0.68.0                # 제거
  # drift: ^2.14.0                   # 제거
  # sqlite3_flutter_libs: ^0.5.0     # 제거
  # web_socket_channel: ^2.4.0       # 제거

dev_dependencies:
  # drift_dev: ^2.14.0               # 제거
  # riverpod_generator: ^2.3.9       # 제거
  # riverpod_annotation: ^2.3.3      # 제거
```

### Phase 5: 테스트 및 검증 (1일)

#### 5.1 Core 패키지 테스트

```bash
cd flutter_live_logger
flutter test
flutter analyze
dart format --set-exit-if-changed .
```

#### 5.2 Dashboard 패키지 테스트

```bash
cd flutter_live_logger_dashboard
flutter test
flutter analyze
dart format --set-exit-if-changed .
```

#### 5.3 통합 테스트

```bash
# Dashboard에서 Core 패키지 의존성 테스트
flutter pub deps
flutter pub get
flutter test test/integration_test.dart
```

### Phase 6: 문서화 및 예제 (1일)

#### 6.1 README 업데이트

- Core 패키지: 기본 사용법 중심
- Dashboard 패키지: 웹 대시보드 설정 및 사용법

#### 6.2 예제 앱 작성

```dart
// flutter_live_logger/example/main.dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  final logger = FlutterLiveLogger();
  logger.info('Core package example');
}

// flutter_live_logger_dashboard/example/main.dart
import 'package:flutter_live_logger/flutter_live_logger.dart';
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

void main() async {
  final logger = FlutterLiveLogger();
  
  // 개발 환경에서만 대시보드 연결
  if (kDebugMode) {
    await DashboardConnector.attachToLogger(logger);
  }
  
  logger.info('Dashboard integration example');
}
```

#### 6.3 버전 관리 및 릴리스 노트

```markdown
# Flutter Live Logger v0.2.0 릴리스 노트

## 🆕 새로운 기능
- **웹 대시보드**: 실시간 로그 모니터링 및 분석 도구 추가
- **별도 패키지**: flutter_live_logger_dashboard로 분리하여 선택적 사용 가능
- **TDD 개발**: 100% 테스트 커버리지로 안정성 보장

## 📦 패키지 구조
- **flutter_live_logger (v0.2.0)**: 핵심 로깅 기능 (~50KB)
- **flutter_live_logger_dashboard (v0.2.0)**: 웹 대시보드 (~500KB)

## 🚀 사용법
```yaml
dependencies:
  flutter_live_logger: ^0.2.0

dev_dependencies:
  flutter_live_logger_dashboard: ^0.2.0
```

## ⚠️ 호환성

- v0.1.1 사용자: 변경 사항 없음 (웹 기능이 없었으므로)
- 새로운 웹 대시보드는 선택적 기능

```

## 📊 성공 지표

### 정량적 지표
- [ ] Core 패키지 크기: 50KB 이하
- [ ] Core 의존성: 4개 유지 (변경 없음)
- [ ] 테스트 커버리지: 95% 이상 유지
- [ ] 빌드 시간: Core는 기존과 동일

### 정성적 지표
- [ ] 사용자 피드백: 긍정적
- [ ] 문서 완성도: 95% 이상
- [ ] 예제 코드: 동작 확인
- [ ] 새 기능 도입: 무중단

## 🚨 리스크 및 대응책

### 주요 리스크
1. **기존 사용자 혼란**: 새로운 패키지 구조
2. **의존성 충돌**: 두 패키지 간 버전 충돌
3. **성능 저하**: 분리로 인한 오버헤드
4. **문서 부족**: 사용자 혼란

### 대응책
1. **명확한 문서화**: v0.1.1 사용자는 변경 없음을 명시
2. **버전 관리**: Semantic Versioning 엄격 적용
3. **성능 테스트**: 벤치마크 비교 실시
4. **상세한 가이드**: 새 기능 사용법 제공

## 📅 일정 계획

```

Week 1: 사전 준비 + Dashboard 패키지 생성
├── Day 1: 현재 코드 분석 및 분리 기준 정립
├── Day 2: Dashboard 패키지 생성 및 구조 설정
└── Day 3: 코드 이동 시작

Week 2: 코드 이동 + Core 정리
├── Day 4: 웹 대시보드 코드 이동 완료
├── Day 5: Import 경로 수정 및 연동 인터페이스 구현
└── Day 6: Core 패키지 정리 및 의존성 제거

Week 3: 테스트 + 문서화
├── Day 7: 테스트 및 검증
├── Day 8: 문서화 및 예제 작성
└── Day 9: 최종 검토 및 배포 준비

```

## ✅ 체크리스트

### 사전 준비
- [ ] 현재 코드 백업
- [ ] 의존성 분석 완료
- [ ] 분리 기준 확정
- [ ] 브랜치 생성

### Dashboard 패키지
- [ ] 패키지 생성
- [ ] 디렉토리 구조 설정
- [ ] 메타데이터 설정
- [ ] 초기 의존성 설정

### 코드 이동
- [ ] 웹 대시보드 파일 이동
- [ ] 테스트 파일 이동
- [ ] Import 경로 수정
- [ ] 연동 인터페이스 구현

### Core 정리
- [ ] 웹 대시보드 코드 제거
- [ ] Export 정리
- [ ] 의존성 정리
- [ ] 테스트 수정

### 검증
- [ ] Core 패키지 테스트 통과
- [ ] Dashboard 패키지 테스트 통과
- [ ] 통합 테스트 통과
- [ ] 성능 벤치마크 확인

### 문서화
- [ ] README 업데이트
- [ ] 예제 앱 작성
- [ ] 릴리스 노트 작성
- [ ] API 문서 업데이트

### 배포
- [ ] 버전 태그 생성
- [ ] pub.dev 배포
- [ ] GitHub 릴리스 노트
- [ ] 커뮤니티 공지

---

이 계획에 따라 체계적으로 분리 작업을 진행하면 안전하고 효율적인 패키지 분리가 가능할 것입니다. 🚀
