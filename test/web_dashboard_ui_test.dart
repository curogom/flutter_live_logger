import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_live_logger/src/web_dashboard/ui/dashboard_page.dart';
import 'package:flutter_live_logger/src/web_dashboard/ui/log_display_widget.dart';
import 'package:flutter_live_logger/src/web_dashboard/ui/filter_widget.dart';
import 'package:flutter_live_logger/src/web_dashboard/ui/performance_dashboard.dart';
import 'package:flutter_live_logger/src/web_dashboard/ui/analytics_widget.dart';

/// TDD Test Cases for Flutter Live Logger Web Dashboard UI
///
/// Tests the Flutter Web UI components for the dashboard including
/// real-time log display, filtering, and analytics views.
void main() {
  group('Web Dashboard UI TDD Tests', () {
    group('Dashboard Layout', () {
      testWidgets('should render main dashboard layout', (tester) async {
        // Test basic dashboard structure
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: DashboardPage(),
            ),
          ),
        );

        // Verify main layout components
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Flutter Live Logger Dashboard'), findsOneWidget);
        expect(find.byKey(const Key('sidebar')), findsOneWidget);
        expect(find.byKey(const Key('main_content')), findsOneWidget);
        expect(find.byKey(const Key('status_bar')), findsOneWidget);
      });

      testWidgets('should display connection status', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: DashboardPage(),
            ),
          ),
        );

        // Should show connection status
        expect(find.byKey(const Key('connection_status')), findsOneWidget);
        expect(find.text('Connected'), findsOneWidget);
        expect(find.byIcon(Icons.circle), findsOneWidget); // Green dot
      });

      testWidgets('should handle responsive layout', (tester) async {
        // Test mobile layout
        await tester.binding.setSurfaceSize(const Size(600, 800));
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: DashboardPage(),
            ),
          ),
        );

        // Sidebar should be collapsed on mobile
        expect(find.byKey(const Key('mobile_drawer')), findsOneWidget);
        expect(find.byKey(const Key('desktop_sidebar')), findsNothing);

        // Test desktop layout
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpAndSettle();

        // Sidebar should be visible on desktop
        expect(find.byKey(const Key('desktop_sidebar')), findsOneWidget);
        expect(find.byKey(const Key('mobile_drawer')), findsNothing);
      });
    });

    group('Real-time Log Display', () {
      testWidgets('should display log entries in real-time', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: LogDisplayWidget(),
            ),
          ),
        );

        // Should show log table
        expect(find.byKey(const Key('data_table')), findsOneWidget);
        expect(find.text('Level'), findsOneWidget);
        expect(find.text('Message'), findsOneWidget);
        expect(find.text('Timestamp'), findsOneWidget);

        // Wait for mock data to load
        await tester.pump(const Duration(milliseconds: 100));

        // Should display mock log entries
        expect(find.text('Test log message'), findsOneWidget);
        expect(find.text('INFO'), findsOneWidget);
      });

      testWidgets('should auto-scroll to new logs', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: LogDisplayWidget(),
            ),
          ),
        );

        // Find the scrollable widget
        final scrollable = find.byType(Scrollable);
        expect(scrollable, findsOneWidget);

        // Simulate new log entry
        await tester.pump(const Duration(milliseconds: 500));

        // Should auto-scroll to bottom
        final scrollController =
            tester.widget<Scrollable>(scrollable).controller;
        expect(scrollController?.position.pixels,
            equals(scrollController?.position.maxScrollExtent));
      });

      testWidgets('should handle log entry selection', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: LogDisplayWidget(),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));

        // Tap on a log entry
        await tester.tap(find.text('Test log message'));
        await tester.pumpAndSettle();

        // Should show detailed view
        expect(find.byKey(const Key('log_detail_dialog')), findsOneWidget);
        expect(find.text('Log Details'), findsOneWidget);
        expect(find.text('Raw Data'), findsOneWidget);
      });
    });

    group('Filtering and Search', () {
      testWidgets('should filter logs by level', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: FilterWidget(),
            ),
          ),
        );

        // Should show level filter dropdown
        expect(find.byKey(const Key('level_filter')), findsOneWidget);

        // Tap dropdown
        await tester.tap(find.byKey(const Key('level_filter')));
        await tester.pumpAndSettle();

        // Should show level options
        expect(find.text('ERROR'), findsOneWidget);
        expect(find.text('WARNING'), findsOneWidget);
        expect(find.text('INFO'), findsOneWidget);
        expect(find.text('DEBUG'), findsOneWidget);

        // Select ERROR level
        await tester.tap(find.text('ERROR'));
        await tester.pumpAndSettle();

        // Should apply filter
        expect(find.text('ERROR'), findsOneWidget);
      });

      testWidgets('should search logs by text', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: FilterWidget(),
            ),
          ),
        );

        // Should show search field
        final searchField = find.byKey(const Key('search_field'));
        expect(searchField, findsOneWidget);

        // Enter search text
        await tester.enterText(searchField, 'error message');
        await tester.pumpAndSettle();

        // Should show search results
        expect(find.text('error message'), findsOneWidget);
      });

      testWidgets('should filter by time range', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: FilterWidget(),
            ),
          ),
        );

        // Should show time range picker
        expect(find.byKey(const Key('time_range_picker')), findsOneWidget);

        // Tap time range button
        await tester.tap(find.byKey(const Key('time_range_picker')));
        await tester.pumpAndSettle();

        // Should show time range options
        expect(find.text('Last Hour'), findsOneWidget);
        expect(find.text('Last 24 Hours'), findsOneWidget);
        expect(find.text('Last Week'), findsOneWidget);
        expect(find.text('Custom Range'), findsOneWidget);

        // Select last hour
        await tester.tap(find.text('Last Hour'));
        await tester.pumpAndSettle();

        // Should apply time filter
        expect(find.text('Last Hour'), findsOneWidget);
      });
    });

    group('Performance Dashboard', () {
      testWidgets('should display performance metrics', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: PerformanceDashboard(),
            ),
          ),
        );

        // Should show metric cards
        expect(find.byKey(const Key('throughput_card')), findsOneWidget);
        expect(find.byKey(const Key('response_time_card')), findsOneWidget);
        expect(find.byKey(const Key('memory_usage_card')), findsOneWidget);
        expect(find.byKey(const Key('error_rate_card')), findsOneWidget);

        // Should display metric values
        expect(find.text('1,234 logs/sec'), findsOneWidget);
        expect(find.text('45ms avg'), findsOneWidget);
        expect(find.text('128MB'), findsOneWidget);
        expect(find.text('0.5%'), findsOneWidget);
      });

      testWidgets('should display performance charts', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: PerformanceDashboard(),
            ),
          ),
        );

        // Should show charts
        expect(find.byKey(const Key('throughput_chart')), findsOneWidget);
        expect(find.byKey(const Key('response_time_chart')), findsOneWidget);
        expect(find.byKey(const Key('memory_chart')), findsOneWidget);
      });
    });

    group('Analytics and Insights', () {
      testWidgets('should display log level distribution', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: AnalyticsWidget(),
            ),
          ),
        );

        // Should show pie chart for log levels
        expect(find.byKey(const Key('log_level_chart')), findsOneWidget);
        expect(find.text('Log Level Distribution'), findsOneWidget);

        // Should show legend
        expect(find.text('ERROR (25%)'), findsOneWidget);
        expect(find.text('WARNING (30%)'), findsOneWidget);
        expect(find.text('INFO (40%)'), findsOneWidget);
        expect(find.text('DEBUG (5%)'), findsOneWidget);
      });

      testWidgets('should display error trends', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: AnalyticsWidget(),
            ),
          ),
        );

        // Should show error trend chart
        expect(find.byKey(const Key('error_trend_chart')), findsOneWidget);
        expect(find.text('Error Trends (24h)'), findsOneWidget);

        // Should show top errors list
        expect(find.byKey(const Key('top_errors_list')), findsOneWidget);
        expect(find.text('Top Error Messages'), findsOneWidget);
      });
    });

    group('Settings and Configuration', () {
      testWidgets('should display dashboard settings', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: _SettingsWidget(),
            ),
          ),
        );

        // Should show settings sections
        expect(find.text('Display Settings'), findsOneWidget);
        expect(find.text('Performance Settings'), findsOneWidget);
        expect(find.text('Export Settings'), findsOneWidget);

        // Should show theme toggle
        expect(find.byKey(const Key('theme_toggle')), findsOneWidget);

        // Should show auto-scroll toggle
        expect(find.byKey(const Key('auto_scroll_toggle')), findsOneWidget);
      });

      testWidgets('should save settings changes', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: _SettingsWidget(),
            ),
          ),
        );

        // Toggle auto-scroll setting
        await tester.tap(find.byKey(const Key('auto_scroll_toggle')));
        await tester.pumpAndSettle();

        // Should show save confirmation
        expect(find.text('Settings saved'), findsOneWidget);
      });
    });
  });
}

// Simple settings widget for testing
class _SettingsWidget extends StatefulWidget {
  @override
  State<_SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<_SettingsWidget> {
  bool _autoScroll = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Display Settings'),
          const Text('Performance Settings'),
          const Text('Export Settings'),
          SwitchListTile(
            key: const Key('theme_toggle'),
            title: const Text('Dark Theme'),
            value: false,
            onChanged: (value) {},
          ),
          SwitchListTile(
            key: const Key('auto_scroll_toggle'),
            title: const Text('Auto Scroll'),
            value: _autoScroll,
            onChanged: (value) {
              setState(() {
                _autoScroll = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved')),
              );
            },
          ),
        ],
      ),
    );
  }
}
