/// Flutter Live Logger - Settings Widget
///
/// Dashboard settings and configuration widget.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Settings and configuration widget
class SettingsWidget extends ConsumerStatefulWidget {
  const SettingsWidget({super.key});

  @override
  ConsumerState<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends ConsumerState<SettingsWidget> {
  bool _autoRefresh = true;
  bool _darkMode = false;
  int _maxLogEntries = 1000;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.settings),
                const SizedBox(width: 8),
                Text(
                  'Dashboard Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Auto Refresh Setting
            SwitchListTile(
              key: const Key('auto_refresh_switch'),
              title: const Text('Auto Refresh'),
              subtitle: const Text('Automatically refresh log data'),
              value: _autoRefresh,
              onChanged: (value) {
                setState(() {
                  _autoRefresh = value;
                });
              },
            ),

            // Dark Mode Setting
            SwitchListTile(
              key: const Key('dark_mode_switch'),
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),

            const Divider(),

            // About Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Flutter Live Logger Dashboard v1.0.0'),
                    Text('Real-time logging solution for Flutter apps'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
