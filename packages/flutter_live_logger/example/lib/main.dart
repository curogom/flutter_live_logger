import 'package:flutter/material.dart';
import 'package:flutter_live_logger/flutter_live_logger.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Live Logger with cross-platform transports
  await FlutterLiveLogger.init(
    config: LoggerConfig(
      logLevel: LogLevel.debug,
      environment: 'development',
      enableOfflineSupport: true,
      transports: [
        MemoryTransport(maxEntries: 1000),
        // HttpTransport는 이제 package:http 기반으로 웹에서도 작동
        // 서버에 CORS가 설정되어 있어야 함 (Access-Control-Allow-Origin: *)
        HttpTransport(
          config: HttpTransportConfig.withApiKey(
            endpoint: 'http://localhost:7580/api/logs',
            apiKey: 'demo-api-key',
            batchSize: 10,
          ),
        ),
      ],
      batchSize: 10,
      flushInterval: const Duration(seconds: 2),
    ),
  );

  // Log app initialization
  FlutterLiveLogger.info('Flutter Live Logger Demo App Started', data: {
    'version': '1.0.0',
    'platform': kIsWeb ? 'web' : 'native',
    'timestamp': DateTime.now().toIso8601String(),
    'http_transport': 'package:http (cross-platform)',
    'cors_required': kIsWeb, // 웹에서는 CORS 설정 필요
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
    FlutterLiveLogger.info('LoggerDemoPage initialized');
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
    FlutterLiveLogger.event('counter_increment', {
      'counter_value': _counter,
      'timestamp': DateTime.now().toIso8601String(),
      'widget': 'LoggerDemoPage',
    });

    if (_counter % 5 == 0) {
      FlutterLiveLogger.warn('Counter reached multiple of 5: $_counter');
    }

    if (_counter >= 10) {
      FlutterLiveLogger.error('Counter is getting high!', data: {
        'counter': _counter,
        'threshold': 10,
      });
    }
  }

  void _sendCustomLog() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      FlutterLiveLogger.info('Custom message: $message', data: {
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
      FlutterLiveLogger.error(
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
    FlutterLiveLogger.info('Navigating to settings');
    Navigator.of(context).pushNamed('/settings');
  }

  void _navigateToProfile() {
    FlutterLiveLogger.info('Navigating to profile');
    Navigator.of(context).pushNamed('/profile');
  }

  Future<void> _showLoggerStats() async {
    final stats = FlutterLiveLogger.getStats();

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
            child: Text(
              value.toString(),
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'monospace',
              ),
            ),
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
            icon: const Icon(Icons.bar_chart),
            onPressed: _showLoggerStats,
            tooltip: 'Show Logger Stats',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Flutter Live Logger Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Counter Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Counter with Logging',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    const Text('You have pushed the button this many times:'),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _incrementCounter,
                      child: const Text('Increment Counter'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Custom Log Message Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Send Custom Log Message',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Log Message',
                        hintText: 'Enter a custom log message...',
                      ),
                      maxLines: 2,
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

            const SizedBox(height: 24),

            // Action Buttons Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Demo Actions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _triggerError,
                          icon: const Icon(Icons.error, color: Colors.red),
                          label: const Text('Trigger Error'),
                        ),
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

            const SizedBox(height: 24),

            // Info Section
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Check Console Output',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'All log messages are being sent to the console. You can also tap the bar chart icon to see logger statistics.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Web Platform Notice
            Card(
              color: Colors.orange[50],
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.web, color: Colors.orange, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Web Platform',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This demo is running on the web platform. HTTP transport is not available, but all logging features work with in-memory storage.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange),
                    ),
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

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Settings Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('This is a demo settings page for navigation tracking.'),
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Profile Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('This is a demo profile page for navigation tracking.'),
          ],
        ),
      ),
    );
  }
}
