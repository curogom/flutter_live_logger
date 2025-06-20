import 'package:flutter/material.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Live Logger with development configuration
  await FLL.init(
    config: LoggerConfig.development(
      userId: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: 'demo_session_${DateTime.now().millisecondsSinceEpoch}',
    ),
  );

  // Log app initialization
  FLL.info('Flutter Live Logger Demo App Started', data: {
    'version': '1.0.0',
    'platform': 'demo',
    'timestamp': DateTime.now().toIso8601String(),
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Live Logger Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoggerDemoPage(),
      // Add Navigator Observer to track screen navigation
      navigatorObservers: [
        FlutterLiveLoggerNavigatorObserver(
          enableDurationTracking: true,
          enableBreadcrumbs: true,
        ),
      ],
      // Define named routes for better tracking
      routes: {
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

class LoggerDemoPage extends StatefulWidget {
  const LoggerDemoPage({super.key});

  @override
  State<LoggerDemoPage> createState() => _LoggerDemoPageState();
}

class _LoggerDemoPageState extends State<LoggerDemoPage> {
  int _counter = 0;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FLL.info('LoggerDemoPage initialized');
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Log the counter increment with structured data
    FLL.event('counter_increment', {
      'counter_value': _counter,
      'timestamp': DateTime.now().toIso8601String(),
      'widget': 'LoggerDemoPage',
    });

    if (_counter % 5 == 0) {
      FLL.warn('Counter reached multiple of 5: $_counter');
    }

    if (_counter >= 10) {
      FLL.error('Counter is getting high!', data: {
        'counter': _counter,
        'threshold': 10,
      });
    }
  }

  void _sendCustomLog() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      FLL.info('Custom message: $message', data: {
        'source': 'user_input',
        'length': message.length,
      });
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log message sent!')),
      );
    }
  }

  void _triggerError() {
    try {
      // Intentionally cause an error for demonstration
      throw Exception('This is a demo error for testing');
    } catch (error, stackTrace) {
      FLL.error(
        'Demo error occurred',
        data: {
          'error_type': 'demo',
          'triggered_by': 'user',
        },
        error: error,
        stackTrace: stackTrace,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error logged! Check console for details.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToSettings() {
    FLL.info('Navigating to settings');
    Navigator.of(context).pushNamed('/settings');
  }

  void _navigateToProfile() {
    FLL.info('Navigating to profile');
    Navigator.of(context).pushNamed('/profile');
  }

  Future<void> _showLoggerStats() async {
    final stats = FLL.getStats();

    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logger Statistics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('Initialized', stats['isInitialized']),
              _buildStatRow('Pending Entries', stats['pendingEntries']),
              _buildStatRow('Transports', stats['transports']),
              _buildStatRow('Has Storage', stats['hasStorage']),
              if (stats['config'] != null) ...[
                const Divider(),
                const Text('Configuration:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildStatRow('Log Level', stats['config']['logLevel']),
                _buildStatRow('Environment', stats['config']['environment']),
                _buildStatRow('Batch Size', stats['config']['batchSize']),
                _buildStatRow(
                    'Flush Interval', '${stats['config']['flushInterval']}s'),
                _buildStatRow(
                    'Offline Support', stats['config']['offlineSupport']),
              ],
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

  Widget _buildStatRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value.toString()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Live Logger Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showLoggerStats,
            tooltip: 'Show Logger Stats',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Counter Demo',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You have pushed the button this many times:',
                    ),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _incrementCounter,
                      child: const Text('Increment & Log'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Navigation Testing',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _navigateToSettings,
                          icon: const Icon(Icons.settings),
                          label: const Text('Settings'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _navigateToProfile,
                          icon: const Icon(Icons.person),
                          label: const Text('Profile'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Custom Log Message',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Enter your log message',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendCustomLog(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _sendCustomLog,
                      child: const Text('Send Log'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Error Testing',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _triggerError,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Trigger Demo Error'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Check the console output to see the log messages!\nNavigation events are automatically tracked.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Additional pages for navigation testing
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, size: 100, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              'Settings Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FLL.info('Settings back button pressed');
                Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Profile Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FLL.info('Profile back button pressed');
                Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
