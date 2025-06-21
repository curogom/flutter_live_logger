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
    _apiServer = DashboardServer();
    await _apiServer!.start(port: httpPort);

    // WebSocket 서버 시작
    _wsServer = await WebSocketServer.start(port: wsPort);

    print('Dashboard connected:');
    print('- HTTP API: http://localhost:${_apiServer!.port}');
    print('- WebSocket: ws://localhost:${_wsServer!.port}');
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
