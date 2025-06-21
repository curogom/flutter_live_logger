/// Flutter Live Logger - Performance Dashboard
///
/// Performance metrics and charts widget.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

/// Performance dashboard widget
///
/// Displays performance metrics and charts.
class PerformanceDashboard extends ConsumerWidget {
  const PerformanceDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Performance Dashboard',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Metric cards
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  key: const Key('throughput_card'),
                  title: 'Throughput',
                  value: '1,234 logs/sec',
                  icon: Icons.speed,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  key: const Key('response_time_card'),
                  title: 'Response Time',
                  value: '45ms avg',
                  icon: Icons.timer,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  key: const Key('memory_usage_card'),
                  title: 'Memory Usage',
                  value: '128MB',
                  icon: Icons.memory,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  key: const Key('error_rate_card'),
                  title: 'Error Rate',
                  value: '0.5%',
                  icon: Icons.error_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Charts
          Row(
            children: [
              Expanded(
                child: _ChartCard(
                  key: const Key('throughput_chart'),
                  title: 'Throughput Over Time',
                  child: _ThroughputChart(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ChartCard(
                  key: const Key('response_time_chart'),
                  title: 'Response Time',
                  child: _ResponseTimeChart(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Memory chart
          _ChartCard(
            key: const Key('memory_chart'),
            title: 'Memory Usage',
            child: _MemoryChart(),
          ),
        ],
      ),
    );
  }
}

/// Metric card widget
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Chart card wrapper
class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Throughput chart widget
class _ThroughputChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 1000),
              FlSpot(1, 1200),
              FlSpot(2, 1100),
              FlSpot(3, 1300),
              FlSpot(4, 1234),
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}

/// Response time chart widget
class _ResponseTimeChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 50),
              FlSpot(1, 45),
              FlSpot(2, 48),
              FlSpot(3, 42),
              FlSpot(4, 45),
            ],
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}

/// Memory usage chart widget
class _MemoryChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(0, 120),
              FlSpot(1, 125),
              FlSpot(2, 128),
              FlSpot(3, 126),
              FlSpot(4, 128),
            ],
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}
