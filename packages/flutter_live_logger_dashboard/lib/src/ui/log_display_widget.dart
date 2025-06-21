/// Flutter Live Logger - Log Display Widget
///
/// Real-time log display widget with auto-scroll and selection features.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'dart:async';

/// Real-time log display widget
///
/// Displays logs in a data table format with auto-scroll to new entries
/// and detailed view on selection.
class LogDisplayWidget extends ConsumerStatefulWidget {
  const LogDisplayWidget({super.key});

  @override
  ConsumerState<LogDisplayWidget> createState() => _LogDisplayWidgetState();
}

class _LogDisplayWidgetState extends ConsumerState<LogDisplayWidget> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _initializeLogs();
  }

  void _initializeLogs() {
    // Initialize with mock data for testing
    _logs = [
      {
        'id': 1,
        'level': 'INFO',
        'message': 'Test log message',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'source': 'flutter_app',
      },
      {
        'id': 2,
        'level': 'ERROR',
        'message': 'Error occurred',
        'timestamp': DateTime.now().millisecondsSinceEpoch - 60000,
        'source': 'flutter_app',
      },
    ];

    // Auto-scroll to bottom after initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to log stream
    ref.listen(_logStreamProvider, (previous, next) {
      next.whenData((logs) {
        setState(() {
          _logs = logs;
        });

        // Auto-scroll to new logs
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    return Material(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.list_alt),
                const SizedBox(width: 8),
                Text(
                  'Live Logs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    // Refresh logs
                  },
                ),
              ],
            ),
          ),

          // Data table
          Expanded(
            child: DataTable2(
              key: const Key('data_table'),
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 600,
              columns: const [
                DataColumn2(
                  label: Text('Level'),
                  size: ColumnSize.S,
                ),
                DataColumn2(
                  label: Text('Message'),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('Timestamp'),
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text('Source'),
                  size: ColumnSize.S,
                ),
              ],
              rows: _logs.map((log) {
                return DataRow2(
                  onSelectChanged: (_) => _showLogDetail(log),
                  cells: [
                    DataCell(_LogLevelChip(level: log['level'] as String)),
                    DataCell(
                      Text(
                        log['message'] as String,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(
                      Text(
                        _formatTimestamp(log['timestamp'] as int),
                      ),
                    ),
                    DataCell(
                      Text(log['source'] as String),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogDetail(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('log_detail_dialog'),
        title: const Text('Log Details'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow('Level', log['level'] as String),
              _DetailRow('Message', log['message'] as String),
              _DetailRow(
                  'Timestamp', _formatTimestamp(log['timestamp'] as int)),
              _DetailRow('Source', log['source'] as String),
              const SizedBox(height: 16),
              Text(
                'Raw Data',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  log.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
}

/// Log level chip widget
class _LogLevelChip extends StatelessWidget {
  final String level;

  const _LogLevelChip({required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (level.toLowerCase()) {
      case 'error':
        color = Colors.red;
        break;
      case 'warning':
        color = Colors.orange;
        break;
      case 'info':
        color = Colors.blue;
        break;
      case 'debug':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Detail row widget for log details dialog
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// Mock log stream provider with proper cleanup
final _logStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  late StreamController<List<Map<String, dynamic>>> controller;
  late Timer timer;

  controller = StreamController<List<Map<String, dynamic>>>();

  var count = 0;
  timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
    if (controller.isClosed) {
      timer.cancel();
      return;
    }

    controller.add([
      {
        'id': count + 1,
        'level': count % 3 == 0 ? 'ERROR' : 'INFO',
        'message': 'Test log message ${count + 1}',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'source': 'flutter_app',
      }
    ]);
    count++;
  });

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
