/// Flutter Live Logger Dashboard - Database Module
/// 
/// SQLite 기반의 로그 데이터 저장 및 조회를 담당하는 데이터베이스 모듈입니다.
/// Drift ORM을 사용하여 타입 안전한 데이터베이스 작업을 제공합니다.
/// 
/// 주요 기능:
/// - 로그 엔트리 저장 및 조회
/// - 로그 통계 데이터 관리
/// - 대시보드 설정 저장
/// - 실시간 로그 스트리밍 지원
/// 
/// Example:
/// ```dart
/// final database = DashboardDatabase();
/// await database.addLogEntry('info', 'Test message', {'key': 'value'});
/// final logs = await database.getLogEntries(limit: 100);
/// ``` 