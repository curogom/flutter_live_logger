/// Flutter Live Logger - Web Dashboard Main Page
///
/// Main dashboard page with responsive layout, sidebar navigation,
/// and real-time connection status display.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Main dashboard page widget
///
/// Provides responsive layout with sidebar navigation and main content area.
/// Displays connection status and handles mobile/desktop layout switching.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Live Logger Dashboard'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              // Connection status indicator
              Container(
                key: const Key('connection_status'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Colors.green,
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    const Text('Connected'),
                  ],
                ),
              ),
            ],
          ),
          body: isMobile ? _MobileLayout() : _DesktopLayout(),
          bottomNavigationBar: Container(
            key: const Key('status_bar'),
            height: 32,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    'Flutter Live Logger v1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    'Last updated: ${DateTime.now().toString().substring(11, 19)}',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          drawer: isMobile ? _MobileDrawer() : null,
        );
      },
    );
  }
}

/// Desktop layout with persistent sidebar
class _DesktopLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          key: const Key('desktop_sidebar'),
          width: 250,
          child: _Sidebar(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Container(
            key: const Key('main_content'),
            child: _MainContent(),
          ),
        ),
      ],
    );
  }
}

/// Mobile layout with drawer
class _MobileLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('main_content'),
      child: _MainContent(),
    );
  }
}

/// Mobile drawer for navigation
class _MobileDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      key: const Key('mobile_drawer'),
      child: _Sidebar(),
    );
  }
}

/// Sidebar navigation component
class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('sidebar'),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Dashboard header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Real-time log monitoring',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(),

          // Navigation items
          Expanded(
            child: ListView(
              children: [
                _NavigationTile(
                  icon: Icons.dashboard,
                  title: 'Overview',
                  isSelected: true,
                ),
                _NavigationTile(
                  icon: Icons.list_alt,
                  title: 'Logs',
                  isSelected: false,
                ),
                _NavigationTile(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  isSelected: false,
                ),
                _NavigationTile(
                  icon: Icons.speed,
                  title: 'Performance',
                  isSelected: false,
                ),
                _NavigationTile(
                  icon: Icons.settings,
                  title: 'Settings',
                  isSelected: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation tile component
class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;

  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: isSelected,
      onTap: () {
        // Navigation logic will be implemented later
      },
    );
  }
}

/// Main content area
class _MainContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Text(
            'Welcome to Flutter Live Logger',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor your Flutter app logs in real-time',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Quick stats cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatCard(
                  title: 'Total Logs',
                  value: '1,234',
                  icon: Icons.article,
                  color: Colors.blue,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Errors',
                  value: '12',
                  icon: Icons.error,
                  color: Colors.red,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Warnings',
                  value: '45',
                  icon: Icons.warning,
                  color: Colors.orange,
                ),
                const SizedBox(width: 16),
                _StatCard(
                  title: 'Active Users',
                  value: '3',
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent logs preview
          Text(
            'Recent Logs',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.refresh),
                        const SizedBox(width: 8),
                        Text('Live feed'),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return _LogPreviewTile(
                            level: index % 3 == 0 ? 'ERROR' : 'INFO',
                            message: 'Sample log message ${index + 1}',
                            timestamp: DateTime.now().subtract(
                              Duration(minutes: index * 2),
                            ),
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
    );
  }
}

/// Statistics card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
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
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
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
      ),
    );
  }
}

/// Log preview tile for recent logs
class _LogPreviewTile extends StatelessWidget {
  final String level;
  final String message;
  final DateTime timestamp;

  const _LogPreviewTile({
    required this.level,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final levelColor = level == 'ERROR' ? Colors.red : Colors.blue;

    return ListTile(
      dense: true,
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: levelColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          level,
          style: TextStyle(
            color: levelColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () {
        // Log detail view will be implemented later
      },
    );
  }
}
