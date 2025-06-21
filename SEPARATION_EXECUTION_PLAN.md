# Flutter Live Logger 패키지 분리 실행 계획서

## 📋 현재 상황 분석

### 버전 정보

- **현재 버전**: v0.1.1 (웹 대시보드 기능 없음)
- **목표 버전**: v0.2.0 (새로운 웹 대시보드 기능 추가)
- **Dashboard 버전**: v0.2.0 (새로운 패키지, Core와 동일 버전)

### 현재 프로젝트 구조

```
flutter_live_logger/
├── lib/
│   ├── flutter_live_logger.dart
│   └── src/
│       ├── core/                    # ✅ Core 패키지에 유지
│       ├── transport/               # ✅ Core 패키지에 유지
│       ├── storage/                 # ✅ Core 패키지에 유지
│       └── web_dashboard/           # 📦 Dashboard 패키지로 이동
├── test/
│   ├── flutter_live_logger_test.dart    # ✅ Core 테스트
│   ├── benchmark_test.dart              # ✅ Core 테스트
│   ├── performance_test.dart            # ✅ Core 테스트
│   ├── simple_performance_test.dart     # ✅ Core 테스트
│   └── web_dashboard_*                  # 📦 Dashboard 테스트로 이동
└── pubspec.yaml                         # 🔧 의존성 분리 필요
```

### 의존성 분석

```yaml
현재 dependencies (전체 13개):
├── flutter: sdk                     # ✅ Core 유지
├── sqflite: ^2.3.0                  # ✅ Core 유지
├── http: ^1.1.0                     # ✅ Core 유지
├── path: ^1.8.3                     # ✅ Core 유지
├── shelf: ^1.4.0                    # 📦 Dashboard로 이동
├── shelf_web_socket: ^1.0.4         # 📦 Dashboard로 이동
├── shelf_cors_headers: ^0.1.5       # 📦 Dashboard로 이동
├── flutter_riverpod: ^2.4.9         # 📦 Dashboard로 이동
├── data_table_2: ^2.5.0             # 📦 Dashboard로 이동
├── fl_chart: ^0.68.0                # 📦 Dashboard로 이동
├── drift: ^2.14.0                   # 📦 Dashboard로 이동
├── sqlite3_flutter_libs: ^0.5.0     # 📦 Dashboard로 이동
└── web_socket_channel: ^2.4.0       # 📦 Dashboard로 이동

목표 Core dependencies (4개, 변경 없음):
├── flutter: sdk
├── sqflite: ^2.3.0
├── http: ^1.1.0
└── path: ^1.8.3
```

## 🚀 Phase 1: 사전 준비 및 백업

### 1.1 현재 상태 백업

```bash
# 현재 상태 백업 브랜치 생성
git add .
git commit -m "Pre-separation backup: Phase 2.4 web dashboard TDD complete"
git checkout -b backup/pre-separation
git push origin backup/pre-separation

# 분리 작업용 브랜치 생성
git checkout phase-2.3-web-dashboard
git checkout -b feature/package-separation-v0.2.0
```

### 1.2 코드 분석 스크립트 실행

```bash
# 현재 패키지 크기 측정
flutter pub deps --style=compact > current_dependencies.txt
find lib -name "*.dart" -exec wc -l {} + | tail -1 > current_loc.txt

# Import 관계 분석
grep -r "import.*web_dashboard" lib/ > web_dashboard_imports.txt
grep -r "import.*flutter_live_logger" test/ > test_imports.txt
```

### 1.3 테스트 현황 확인

```bash
# 현재 테스트 실행 및 결과 저장
flutter test --coverage > pre_separation_test_results.txt
genhtml coverage/lcov.info -o coverage/html
```

## 🏗️ Phase 2: Dashboard 패키지 생성

### 2.1 상위 디렉토리에서 Dashboard 패키지 생성

```bash
# 상위 디렉토리로 이동
cd ..

# Dashboard 패키지 생성
flutter create --template=package flutter_live_logger_dashboard
cd flutter_live_logger_dashboard

# 불필요한 파일 제거
rm lib/flutter_live_logger_dashboard.dart
rm test/flutter_live_logger_dashboard_test.dart
```

### 2.2 디렉토리 구조 생성

```bash
# 소스 디렉토리 구조 생성
mkdir -p lib/src/server
mkdir -p lib/src/database  
mkdir -p lib/src/ui
mkdir -p lib/src/connector

# 테스트 디렉토리 구조 생성
mkdir -p test/server
mkdir -p test/database
mkdir -p test/ui
mkdir -p test/connector

# 기타 디렉토리
mkdir -p example
mkdir -p web
```

### 2.3 pubspec.yaml 설정

```yaml
name: flutter_live_logger_dashboard
description: Web dashboard for Flutter Live Logger - Real-time log monitoring and analytics
version: 0.2.0
publish_to: 'none' # 초기에는 pub.dev에 배포하지 않음

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Core 패키지 의존성 (로컬 경로)
  flutter_live_logger:
    path: ../flutter_live_logger
  
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
  flutter_lints: ^3.0.0
  drift_dev: ^2.14.0
  build_runner: ^2.4.7
  mockito: ^5.4.2
  build_test: ^2.1.7
```

## 📦 Phase 3: 코드 이동 및 리팩토링

### 3.1 웹 대시보드 파일 이동

```bash
cd ../flutter_live_logger

# 서버 파일 이동
cp lib/src/web_dashboard/dashboard_server.dart ../flutter_live_logger_dashboard/lib/src/server/
cp lib/src/web_dashboard/websocket_server.dart ../flutter_live_logger_dashboard/lib/src/server/

# 데이터베이스 파일 이동
cp lib/src/web_dashboard/dashboard_database.dart ../flutter_live_logger_dashboard/lib/src/database/
cp lib/src/web_dashboard/dashboard_database.g.dart ../flutter_live_logger_dashboard/lib/src/database/

# UI 파일 이동
cp -r lib/src/web_dashboard/ui/* ../flutter_live_logger_dashboard/lib/src/ui/

# 테스트 파일 이동
cp test/web_dashboard_server_test.dart ../flutter_live_logger_dashboard/test/server/
cp test/web_dashboard_websocket_test.dart ../flutter_live_logger_dashboard/test/server/
cp test/web_dashboard_database_test.dart ../flutter_live_logger_dashboard/test/database/
cp test/web_dashboard_ui_test.dart ../flutter_live_logger_dashboard/test/ui/
```

### 3.2 메인 export 파일 생성

```dart
// flutter_live_logger_dashboard/lib/flutter_live_logger_dashboard.dart
library flutter_live_logger_dashboard;

// Server exports
export 'src/server/dashboard_server.dart';
export 'src/server/websocket_server.dart';

// Database exports  
export 'src/database/dashboard_database.dart';

// UI exports
export 'src/ui/dashboard_page.dart';
export 'src/ui/log_display_widget.dart';
export 'src/ui/filter_widget.dart';
export 'src/ui/performance_dashboard.dart';
export 'src/ui/analytics_widget.dart';
export 'src/ui/settings_widget.dart';

// Connector export
export 'src/connector/dashboard_connector.dart';
```

### 3.3 DashboardConnector 구현

```dart
// flutter_live_logger_dashboard/lib/src/connector/dashboard_connector.dart
import 'package:flutter_live_logger/flutter_live_logger.dart';
import '../server/dashboard_server.dart';
import '../server/websocket_server.dart';

/// Flutter Live Logger와 Dashboard를 연결하는 커넥터
class DashboardConnector {
  static DashboardServer? _apiServer;
  static WebSocketServer? _wsServer;
  
  /// Logger에 Dashboard를 연결합니다.
  /// 
  /// [logger]: 연결할 FlutterLiveLogger 인스턴스
  /// [httpPort]: HTTP API 서버 포트 (기본값: 7580)
  /// [wsPort]: WebSocket 서버 포트 (기본값: 7581)
  static Future<void> attachToLogger(
    FlutterLiveLogger logger, {
    int httpPort = 7580,
    int wsPort = 7581,
  }) async {
    // 이미 연결되어 있다면 기존 서버 정리
    await detachFromLogger();
    
    // HTTP API 서버 시작
    _apiServer = DashboardServer(port: httpPort);
    await _apiServer!.start();
    
    // WebSocket 서버 시작
    _wsServer = WebSocketServer(port: wsPort);
    await _wsServer!.start();
    
    print('Dashboard connected:');
    print('- HTTP API: http://localhost:$httpPort');
    print('- WebSocket: ws://localhost:$wsPort');
  }
  
  /// Dashboard 연결을 해제합니다.
  static Future<void> detachFromLogger() async {
    await _apiServer?.stop();
    await _wsServer?.stop();
    _apiServer = null;
    _wsServer = null;
  }
  
  /// Dashboard가 연결되어 있는지 확인합니다.
  static bool get isConnected => _apiServer != null && _wsServer != null;
}
```

### 3.4 Import 경로 수정 스크립트

```bash
cd ../flutter_live_logger_dashboard

# 모든 Dart 파일에서 import 경로 수정
find lib test -name "*.dart" -exec sed -i '' 's|package:flutter_live_logger/src/web_dashboard/|package:flutter_live_logger_dashboard/src/|g' {} \;

# Core 패키지 import 추가
find lib test -name "*.dart" -exec sed -i '' '1i\
import '\''package:flutter_live_logger/flutter_live_logger.dart'\'';
' {} \;
```

## 🧹 Phase 4: Core 패키지 정리

### 4.1 웹 대시보드 코드 제거

```bash
cd ../flutter_live_logger

# 웹 대시보드 디렉토리 제거
rm -rf lib/src/web_dashboard/

# 웹 대시보드 테스트 제거
rm -f test/web_dashboard_*
```

### 4.2 Export 정리

```dart
// lib/flutter_live_logger.dart
library flutter_live_logger;

// Core exports only
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
```

### 4.3 pubspec.yaml 의존성 정리

```yaml
name: flutter_live_logger
description: High-performance real-time logging solution for Flutter applications
version: 0.2.0  # 웹 대시보드 기능 추가 (별도 패키지)
publish_to: 'none' # 초기에는 pub.dev에 배포하지 않음

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  http: ^1.1.0
  path: ^1.8.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

## 🧪 Phase 5: 테스트 및 검증

### 5.1 Core 패키지 테스트

```bash
cd flutter_live_logger

# 의존성 업데이트
flutter pub get

# 테스트 실행
flutter test --coverage
flutter analyze
dart format --set-exit-if-changed .

# 성능 벤치마크
flutter test test/benchmark_test.dart
flutter test test/performance_test.dart
```

### 5.2 Dashboard 패키지 테스트

```bash
cd ../flutter_live_logger_dashboard

# 의존성 업데이트
flutter pub get

# 코드 생성 (Drift)
dart run build_runner build

# 테스트 실행
flutter test --coverage
flutter analyze
dart format --set-exit-if-changed .
```

### 5.3 통합 테스트 작성

```dart
// flutter_live_logger_dashboard/test/integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

void main() {
  group('Integration Tests', () {
    test('Core 패키지와 Dashboard 패키지 연동', () async {
      // Core 로거 생성
      final logger = FlutterLiveLogger();
      
      // Dashboard 연결
      await DashboardConnector.attachToLogger(logger);
      
      // 연결 상태 확인
      expect(DashboardConnector.isConnected, isTrue);
      
      // 로그 생성
      logger.info('Integration test log');
      
      // 정리
      await DashboardConnector.detachFromLogger();
      expect(DashboardConnector.isConnected, isFalse);
    });
  });
}
```

## 📚 Phase 6: 문서화 및 예제

### 6.1 Core 패키지 README 업데이트

```markdown
# Flutter Live Logger

High-performance real-time logging solution for Flutter applications.

## Installation

```yaml
dependencies:
  flutter_live_logger: ^0.2.0
```

## Basic Usage

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() {
  final logger = FlutterLiveLogger();
  logger.info('Hello, World!');
}
```

## Web Dashboard (New in v0.2.0)

For advanced monitoring and analytics, use the separate dashboard package:

```yaml
dev_dependencies:
  flutter_live_logger_dashboard: ^0.2.0
```

See [flutter_live_logger_dashboard](../flutter_live_logger_dashboard) for details.

## Changelog

### v0.2.0

- Added web dashboard functionality as separate package
- Maintained backward compatibility with v0.1.1
- No breaking changes for existing users

```

### 6.2 Dashboard 패키지 README 작성
```markdown
# Flutter Live Logger Dashboard

Web dashboard for Flutter Live Logger - Real-time log monitoring and analytics.

## Installation

```yaml
dev_dependencies:
  flutter_live_logger_dashboard: ^0.2.0
```

## Usage

```dart
import 'package:flutter_live_logger/flutter_live_logger.dart';
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

void main() async {
  final logger = FlutterLiveLogger();
  
  // Development mode only
  if (kDebugMode) {
    await DashboardConnector.attachToLogger(logger);
  }
  
  logger.info('Dashboard integration example');
}
```

Open <http://localhost:7580> to view the dashboard.

## Features

- Real-time log monitoring
- Performance metrics
- Log analytics and filtering
- WebSocket-based live updates
- Responsive web UI

```

### 6.3 릴리스 노트 작성
```markdown
# Flutter Live Logger v0.2.0 릴리스 노트

## 🆕 새로운 기능

### 웹 대시보드 추가
- 실시간 로그 모니터링 및 분석 도구
- 별도 패키지 `flutter_live_logger_dashboard`로 제공
- TDD 방식으로 개발하여 높은 테스트 커버리지 보장

### 주요 특징
- **포트 전략**: 7580(HTTP API), 7581(WebSocket)
- **UI 컴포넌트**: Riverpod + Material Design 3
- **실시간 업데이트**: WebSocket 기반 라이브 스트리밍
- **성능 최적화**: 메모리 사용량 최소화

## 📦 패키지 구조

- **flutter_live_logger (v0.2.0)**: 핵심 로깅 기능 (~50KB)
- **flutter_live_logger_dashboard (v0.2.0)**: 웹 대시보드 (~500KB)

## 🚀 사용법

### 기본 사용 (변경 없음)
```yaml
dependencies:
  flutter_live_logger: ^0.2.0
```

### 웹 대시보드 사용 (새로운 기능)

```yaml
dev_dependencies:
  flutter_live_logger_dashboard: ^0.2.0
```

```dart
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

await DashboardConnector.attachToLogger(logger);
```

## ⚠️ 호환성

- **v0.1.1 사용자**: 변경 사항 없음 (웹 기능이 없었으므로)
- **새로운 웹 대시보드**: 선택적 기능으로 dev_dependencies에서 사용
- **Breaking Changes**: 없음

## 🔧 기술 스택

- **백엔드**: Shelf + WebSocket
- **프론트엔드**: Flutter Web + Riverpod
- **데이터베이스**: Drift (SQLite)
- **차트**: FL Chart
- **테이블**: DataTable2

```

## 📊 Phase 7: 성능 및 크기 검증

### 7.1 패키지 크기 비교
```bash
# Core 패키지 크기 측정
cd flutter_live_logger
flutter pub deps --style=compact | grep -E "dependencies|transitive"
find lib -name "*.dart" -exec wc -c {} + | tail -1

# Dashboard 패키지 크기 측정  
cd ../flutter_live_logger_dashboard
flutter pub deps --style=compact | grep -E "dependencies|transitive"
find lib -name "*.dart" -exec wc -c {} + | tail -1
```

### 7.2 성능 벤치마크 실행

```bash
# Core 패키지 성능 테스트
cd flutter_live_logger
flutter test test/benchmark_test.dart --reporter=json > core_benchmark_v0.2.0.json

# Dashboard 패키지 성능 테스트
cd ../flutter_live_logger_dashboard
flutter test test/performance_test.dart --reporter=json > dashboard_benchmark_v0.2.0.json
```

## ✅ 완료 체크리스트

### Phase 1: 사전 준비

- [ ] 백업 브랜치 생성 완료
- [ ] 현재 상태 분석 완료
- [ ] 분리 작업용 브랜치 생성 완료

### Phase 2: Dashboard 패키지 생성

- [ ] 패키지 구조 생성 완료
- [ ] pubspec.yaml 설정 완료
- [ ] 디렉토리 구조 생성 완료

### Phase 3: 코드 이동

- [ ] 웹 대시보드 파일 이동 완료
- [ ] 테스트 파일 이동 완료
- [ ] Import 경로 수정 완료
- [ ] DashboardConnector 구현 완료

### Phase 4: Core 정리

- [ ] 웹 대시보드 코드 제거 완료
- [ ] Export 정리 완료
- [ ] 의존성 정리 완료

### Phase 5: 테스트 검증

- [ ] Core 패키지 테스트 통과
- [ ] Dashboard 패키지 테스트 통과
- [ ] 통합 테스트 통과
- [ ] 성능 벤치마크 확인

### Phase 6: 문서화

- [ ] Core README 업데이트 완료
- [ ] Dashboard README 작성 완료
- [ ] 릴리스 노트 작성 완료
- [ ] 예제 코드 작성 완료

### Phase 7: 검증

- [ ] 패키지 크기 목표 달성 (Core < 50KB)
- [ ] 의존성 목표 달성 (Core 4개 유지)
- [ ] 테스트 커버리지 유지 (95%+)
- [ ] 성능 저하 없음 확인

## 🚀 실행 준비

모든 준비가 완료되었습니다. 다음 명령어로 분리 작업을 시작할 수 있습니다:

```bash
# Phase 1 실행
git add .
git commit -m "Pre-separation backup: Phase 2.4 web dashboard TDD complete"
git checkout -b backup/pre-separation
git checkout -b feature/package-separation-v0.2.0

echo "Flutter Live Logger v0.2.0 패키지 분리 작업을 시작합니다!"
echo "- Core: 기존 기능 유지 (v0.1.1 → v0.2.0)"
echo "- Dashboard: 새로운 기능 추가 (v0.2.0, Core와 동일 버전)"
```

각 Phase별로 체크리스트를 확인하며 진행하시면 됩니다. 🎯

## 📝 중요 사항

1. **호환성 보장**: v0.1.1 사용자는 아무 변경 없이 v0.2.0 사용 가능
2. **선택적 기능**: 웹 대시보드는 dev_dependencies로만 사용
3. **No Breaking Changes**: 기존 API 완전 유지
4. **TDD 기반**: 모든 새 기능은 테스트 우선 개발
5. **성능 최적화**: Core 패키지 크기 및 성능 유지
6. **통합 버전 관리**: 모든 패키지가 동일한 버전 번호 공유 (v0.2.0)
