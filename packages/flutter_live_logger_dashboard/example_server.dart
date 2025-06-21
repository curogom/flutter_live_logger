import 'dart:async';
import 'dart:io';
import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

/// 독립 실행형 대시보드 서버 예제
///
/// 이 예제는 Flutter Live Logger 대시보드 서버를 독립적으로 실행합니다.
/// 웹 브라우저에서 http://localhost:7580 에 접속하여 대시보드를 확인할 수 있습니다.
void main() async {
  print('Flutter Live Logger Dashboard Server 시작 중...');

  try {
    // 대시보드 서버 시작
    final server = DashboardServer();
    await server.start();

    print('✅ 대시보드 서버가 성공적으로 시작되었습니다!');
    print('');
    print('📊 대시보드 접속 정보:');
    print('   HTTP API: http://localhost:7580');
    print('   WebSocket: ws://localhost:7581');
    print('   웹 대시보드: http://localhost:7580 (개발 중)');
    print('');
    print('💡 사용법:');
    print('   1. Flutter Live Logger 앱을 실행하세요');
    print('   2. 로그 메시지들이 이 서버로 전송됩니다');
    print('   3. 브라우저에서 대시보드를 확인하세요');
    print('');
    print('⏹️  서버를 중지하려면 Ctrl+C를 누르세요');

    // 신호 처리 (Ctrl+C)
    ProcessSignal.sigint.watch().listen((signal) async {
      print('\n🛑 서버 종료 중...');
      await server.stop();
      print('✅ 서버가 정상적으로 종료되었습니다.');
      exit(0);
    });

    // 서버 상태 모니터링
    _startStatusMonitoring();
  } catch (error, stackTrace) {
    print('❌ 서버 시작 실패: $error');
    print('스택 추적: $stackTrace');
    exit(1);
  }
}

void _startStatusMonitoring() {
  Timer.periodic(Duration(seconds: 30), (timer) {
    final now = DateTime.now().toIso8601String();
    print('📊 [$now] 서버 실행 중... (메모리: ${_getMemoryUsage()}MB)');
  });
}

String _getMemoryUsage() {
  try {
    final info = ProcessInfo.currentRss;
    return (info / (1024 * 1024)).toStringAsFixed(1);
  } catch (e) {
    return '?';
  }
}
