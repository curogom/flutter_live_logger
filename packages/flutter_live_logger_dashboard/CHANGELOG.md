# 변경 로그

이 프로젝트의 모든 주목할만한 변경사항이 이 파일에 문서화됩니다.

형식은 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)을 기반으로 하며,
이 프로젝트는 [Semantic Versioning](https://semver.org/spec/v2.0.0.html)을 준수합니다.

[English](CHANGELOG.md) | **한국어**

## [0.2.0] - 2025-01-22

### 추가됨

- **웹 대시보드 UI**: Flutter 기반 반응형 웹 인터페이스
- **실시간 로그 스트리밍**: WebSocket을 통한 라이브 로그 모니터링
- **HTTP API 서버**: RESTful API로 로그 수신 및 처리
- **고급 필터링**: 레벨, 시간, 키워드별 로그 필터링
- **성능 메트릭 대시보드**: 처리량, 응답시간, 메모리 사용량 모니터링
- **분석 위젯**: 로그 레벨 분포, 오류 트렌드 차트
- **자동 새로고침**: 설정 가능한 실시간 업데이트
- **CORS 지원**: 웹 플랫폼 완전 호환
- **반응형 디자인**: 모바일부터 데스크톱까지 최적화
- **SQLite 데이터베이스**: 효율적인 로그 저장 및 쿼리

### 기술적 세부사항

- **서버 포트**: HTTP (7580), WebSocket (7581)
- **UI 프레임워크**: Flutter Web, Riverpod, FL Chart
- **데이터베이스**: Drift (SQLite), 최대 100개 로그 자동 관리
- **네트워크**: Shelf 기반 HTTP 서버, WebSocket 지원
- **테스트**: 39개 테스트 케이스, 100% 통과율

### 성능

- **처리량**: 실시간으로 수천 개 로그 처리
- **응답성**: 2초 간격 자동 새로고침
- **메모리 효율성**: 순환 버퍼로 메모리 사용량 최적화
- **네트워크 최적화**: 배치 처리 및 압축 지원

### UI 컴포넌트

- **DashboardPage**: 메인 대시보드 레이아웃
- **LogDisplayWidget**: 실시간 로그 테이블 with DataTable2
- **FilterWidget**: 드롭다운, 검색, 시간 범위 필터
- **PerformanceDashboard**: 4개 메트릭 카드 + 실시간 차트
- **AnalyticsWidget**: 파이차트, 에러 목록, 트렌드 차트
- **SettingsWidget**: 대시보드 설정 및 환경설정

### 해결됨

- **Flutter Web 호환성**: CORS 문제 해결
- **UI 오버플로우**: 반응형 레이아웃으로 모든 화면 크기 지원
- **메모리 누수**: Riverpod StreamProvider 자동 정리
- **타이머 관리**: 컴포넌트 해제시 자동 타이머 정리

## [0.1.0] - 초기 릴리스

### 추가됨

- 기본 대시보드 서버 구조
- 로그 수신 HTTP API
- 간단한 웹 인터페이스
- 기본 데이터베이스 연동
