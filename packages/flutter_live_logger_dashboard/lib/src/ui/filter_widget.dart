/// Flutter Live Logger Dashboard - Filter Widget
///
/// Filter controls for log level, time range, search queries and other
/// filtering options in the dashboard interface.

library flutter_live_logger_dashboard_filter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Filter widget for log entries
///
/// Provides filtering by level, time range, and text search functionality.
class FilterWidget extends ConsumerStatefulWidget {
  const FilterWidget({super.key});

  @override
  ConsumerState<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends ConsumerState<FilterWidget> {
  String? _selectedLevel;
  String _searchText = '';
  String _selectedTimeRange = 'All Time';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              key: const Key('search_field'),
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Level filter
            Row(
              children: [
                Text(
                  'Level:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    key: const Key('level_filter'),
                    value: _selectedLevel,
                    hint: const Text('All Levels'),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'ERROR', child: Text('ERROR')),
                      DropdownMenuItem(
                          value: 'WARNING', child: Text('WARNING')),
                      DropdownMenuItem(value: 'INFO', child: Text('INFO')),
                      DropdownMenuItem(value: 'DEBUG', child: Text('DEBUG')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Time range filter
            Row(
              children: [
                Text(
                  'Time Range:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    key: const Key('time_range_picker'),
                    value: _selectedTimeRange,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                          value: 'Last Hour', child: Text('Last Hour')),
                      DropdownMenuItem(
                          value: 'Last 24 Hours', child: Text('Last 24 Hours')),
                      DropdownMenuItem(
                          value: 'Last Week', child: Text('Last Week')),
                      DropdownMenuItem(
                          value: 'Custom Range', child: Text('Custom Range')),
                      DropdownMenuItem(
                          value: 'All Time', child: Text('All Time')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTimeRange = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Applied filters display
            if (_selectedLevel != null ||
                _searchText.isNotEmpty ||
                _selectedTimeRange != 'All Time')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Applied Filters:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_selectedLevel != null)
                        _FilterChip(
                          label: 'Level: $_selectedLevel',
                          onDeleted: () {
                            setState(() {
                              _selectedLevel = null;
                            });
                          },
                        ),
                      if (_searchText.isNotEmpty)
                        _FilterChip(
                          label: 'Search: $_searchText',
                          onDeleted: () {
                            setState(() {
                              _searchText = '';
                              _searchController.clear();
                            });
                          },
                        ),
                      if (_selectedTimeRange != 'All Time')
                        _FilterChip(
                          label: 'Time: $_selectedTimeRange',
                          onDeleted: () {
                            setState(() {
                              _selectedTimeRange = 'All Time';
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Action buttons
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Apply filters
                    _applyFilters();
                  },
                  child: const Text('Apply Filters'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    // Clear all filters
                    setState(() {
                      _selectedLevel = null;
                      _searchText = '';
                      _selectedTimeRange = 'All Time';
                      _searchController.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    // Apply filters logic would be implemented here
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Filters applied: Level=${_selectedLevel ?? 'All'}, '
          'Search="$_searchText", Time=$_selectedTimeRange',
        ),
      ),
    );
  }
}

/// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const _FilterChip({
    required this.label,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }
}
