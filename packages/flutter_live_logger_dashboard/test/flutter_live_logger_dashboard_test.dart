import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_live_logger_dashboard/flutter_live_logger_dashboard.dart';

void main() {
  group('Dashboard Connector Tests', () {
    test('DashboardConnector should provide connection status', () {
      expect(DashboardConnector.isConnected, false);
    });
  });
}
