import 'dart:io';
import 'dart:convert';
import 'dart:developer' as developer;

/// 순수 Dart로 구현된 간단한 대시보드 서버
///
/// Flutter Live Logger Core 앱에서 전송되는 로그를 수신하고 콘솔에 출력합니다.

// 저장된 로그들
List<Map<String, dynamic>> storedLogs = [];

void main() async {
  developer.log('🚀 Starting Flutter Live Logger Dashboard Server...');

  try {
    // Start HTTP server for log reception
    final httpServer = await HttpServer.bind('localhost', 7580);
    developer.log('✅ HTTP server running at http://localhost:7580');

    // Handle HTTP requests
    httpServer.listen((request) async {
      try {
        _handleRequest(request);
      } catch (e) {
        developer.log('Error handling request: $e');
      }
    });

    // Start WebSocket server
    final wsServer = await HttpServer.bind('localhost', 7581);
    developer.log('✅ WebSocket server running at ws://localhost:7581');

    developer.log('');
    developer.log('📊 Dashboard Server Ready!');
    developer.log('   • HTTP API: http://localhost:7580');
    developer.log('   • WebSocket: ws://localhost:7581');
    developer.log('   • Dashboard: http://localhost:7580/dashboard');
    developer.log('');
    developer.log('📱 Flutter Live Logger Configuration:');
    developer.log('   • Endpoint: http://localhost:7580/api/logs');
    developer.log('   • Method: POST');
    developer.log('   • Headers: Content-Type: application/json');
    developer.log('');
    developer.log('🔍 Monitoring incoming log messages...');
    developer.log('⏹️  Press Ctrl+C to stop');
  } catch (e) {
    developer.log('❌ Failed to start server: $e');
  }
}

void _handleRequest(HttpRequest request) async {
  // CORS header settings
  request.response.headers.set('Access-Control-Allow-Origin', '*');
  request.response.headers
      .set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  request.response.headers
      .set('Access-Control-Allow-Headers', 'Origin, Content-Type, X-API-Key');

  try {
    if (request.method == 'OPTIONS') {
      // Handle CORS preflight request
      request.response.statusCode = 200;
      await request.response.close();
      return;
    }

    if (request.method == 'GET' && request.uri.path == '/') {
      // Provide Web Dashboard HTML
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.html;
      request.response.write(_getDashboardHtml());
    } else if (request.method == 'GET' && request.uri.path == '/api/logs') {
      // Return stored logs
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'logs': storedLogs,
        'count': storedLogs.length,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } else if (request.method == 'POST' && request.uri.path == '/api/logs') {
      // Handle log reception
      final body = await utf8.decoder.bind(request).join();
      final data = jsonDecode(body);

      developer.log('📥 Log reception [${DateTime.now().toIso8601String()}]');
      developer.log('    Count: ${data['count']} logs');
      developer.log('    Timestamp: ${data['timestamp']}');

      // Print and store each log entry
      final logs = data['logs'] as List;
      for (final log in logs) {
        final level = log['level'] ?? 'INFO';
        final message = log['message'] ?? '';
        final timestamp = log['timestamp'] ?? '';
        final logData = log['data'];

        developer.log('   [$level] $message');
        if (logData != null) {
          developer.log('        Data: $logData');
        }

        // Store log (keep only the latest 100 logs)
        storedLogs.add({
          'level': level,
          'message': message,
          'timestamp': timestamp,
          'data': logData,
          'receivedAt': DateTime.now().toIso8601String(),
        });

        if (storedLogs.length > 100) {
          storedLogs.removeAt(0);
        }
      }
      developer.log('');

      // Success response
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'success': true,
        'received': logs.length,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } else if (request.method == 'GET' && request.uri.path == '/health') {
      // Health check
      request.response.statusCode = 200;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
        'server': 'Flutter Live Logger Dashboard',
        'totalLogs': storedLogs.length,
      }));
    } else {
      // 404 Not Found
      request.response.statusCode = 404;
      request.response.write('Not Found');
    }
  } catch (error) {
    developer.log('❌ Request processing error: $error');
    request.response.statusCode = 500;
    request.response.write('Internal Server Error');
  } finally {
    await request.response.close();
  }
}

String _getDashboardHtml() {
  return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flutter Live Logger Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            color: #333;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        
        .stat-value {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
        }
        
        .logs-section {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .logs-header {
            background: #667eea;
            color: white;
            padding: 15px 20px;
            display: flex;
            justify-content: between;
            align-items: center;
        }
        
        .refresh-btn {
            background: rgba(255,255,255,0.2);
            border: none;
            color: white;
            padding: 8px 16px;
            border-radius: 5px;
            cursor: pointer;
            margin-left: auto;
        }
        
        .refresh-btn:hover {
            background: rgba(255,255,255,0.3);
        }
        
        .logs-container {
            max-height: 600px;
            overflow-y: auto;
        }
        
        .log-entry {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
            font-family: 'Monaco', 'Consolas', monospace;
            font-size: 14px;
        }
        
        .log-entry:last-child {
            border-bottom: none;
        }
        
        .log-level {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 4px;
            font-weight: bold;
            font-size: 12px;
            margin-right: 10px;
        }
        
        .level-INFO { background: #e3f2fd; color: #1976d2; }
        .level-DEBUG { background: #f3e5f5; color: #7b1fa2; }
        .level-WARN { background: #fff3e0; color: #f57c00; }
        .level-ERROR { background: #ffebee; color: #d32f2f; }
        
        .log-timestamp {
            color: #666;
            font-size: 12px;
            margin-left: 10px;
        }
        
        .log-data {
            margin-top: 8px;
            padding: 8px;
            background: #f5f5f5;
            border-radius: 4px;
            font-size: 12px;
            color: #666;
        }
        
        .no-logs {
            text-align: center;
            padding: 40px;
            color: #666;
        }
        
        .auto-refresh {
            margin-left: 10px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Flutter Live Logger Dashboard</h1>
        <p>Real-time log monitoring dashboard</p>
    </div>
    
    <div class="container">
        <div class="stats">
            <div class="stat-card">
                <div class="stat-value" id="totalLogs">0</div>
                <div>Total Logs</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="lastUpdate">-</div>
                <div>Last Update</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="serverStatus">🟢</div>
                <div>Server Status</div>
            </div>
        </div>
        
        <div class="logs-section">
            <div class="logs-header">
                <h3>📋 Real-time Logs</h3>
                <div>
                    <label class="auto-refresh">
                        <input type="checkbox" id="autoRefresh" checked> Auto Refresh
                    </label>
                    <button class="refresh-btn" onclick="loadLogs()">Refresh</button>
                </div>
            </div>
            <div class="logs-container" id="logsContainer">
                <div class="no-logs">Loading logs...</div>
            </div>
        </div>
    </div>
    
    <script>
        let autoRefreshInterval;
        
        async function loadLogs() {
            try {
                const response = await fetch('/api/logs');
                const data = await response.json();
                
                document.getElementById('totalLogs').textContent = data.count;
                document.getElementById('lastUpdate').textContent = new Date().toLocaleTimeString();
                
                const container = document.getElementById('logsContainer');
                
                if (data.logs.length === 0) {
                    container.innerHTML = '<div class="no-logs">No logs received yet.</div>';
                } else {
                    container.innerHTML = data.logs.reverse().map(log => {
                        const levelClass = 'level-' + (log.level || 'INFO');
                        const dataHtml = log.data ? '<div class="log-data">' + JSON.stringify(log.data, null, 2) + '</div>' : '';
                        
                        return '<div class="log-entry">' +
                            '<span class="log-level ' + levelClass + '">' + (log.level || 'INFO') + '</span>' +
                            '<span>' + (log.message || '') + '</span>' +
                            '<span class="log-timestamp">' + new Date(log.timestamp).toLocaleString() + '</span>' +
                            dataHtml +
                            '</div>';
                    }).join('');
                }
            } catch (error) {
                console.error('Failed to load logs:', error);
                document.getElementById('serverStatus').textContent = '🔴';
            }
        }
        
        function toggleAutoRefresh() {
            const checkbox = document.getElementById('autoRefresh');
            
            if (checkbox.checked) {
                autoRefreshInterval = setInterval(loadLogs, 2000);
            } else {
                clearInterval(autoRefreshInterval);
            }
        }
        
        // Initial loading
        loadLogs();
        
        // Auto refresh setting
        document.getElementById('autoRefresh').addEventListener('change', toggleAutoRefresh);
        toggleAutoRefresh();
    </script>
</body>
</html>
''';
}
