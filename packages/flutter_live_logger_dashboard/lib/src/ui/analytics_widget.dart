/// Flutter Live Logger - Analytics Widget
///
/// Analytics and insights widget.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

/// Analytics widget
///
/// Displays log analytics and insights.
class AnalyticsWidget extends ConsumerWidget {
  const AnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Analytics & Insights',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Log level distribution
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Log Level Distribution',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          key: const Key('log_level_chart'),
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: 25,
                                  title: 'ERROR (25%)',
                                  color: Colors.red,
                                ),
                                PieChartSectionData(
                                  value: 30,
                                  title: 'WARNING (30%)',
                                  color: Colors.orange,
                                ),
                                PieChartSectionData(
                                  value: 40,
                                  title: 'INFO (40%)',
                                  color: Colors.blue,
                                ),
                                PieChartSectionData(
                                  value: 5,
                                  title: 'DEBUG (5%)',
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Error Messages',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          key: const Key('top_errors_list'),
                          height: 200,
                          child: ListView.builder(
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  child: Text('${index + 1}'),
                                ),
                                title: Text('Error message ${index + 1}'),
                                subtitle: Text('${20 - index * 3} occurrences'),
                                trailing: Text('${(20 - index * 3) * 5}%'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Error trends
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Trends (24h)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    key: const Key('error_trend_chart'),
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(show: true),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 5),
                              FlSpot(4, 8),
                              FlSpot(8, 12),
                              FlSpot(12, 15),
                              FlSpot(16, 10),
                              FlSpot(20, 7),
                              FlSpot(24, 6),
                            ],
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
