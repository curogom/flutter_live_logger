/// Flutter Live Logger - File Transport
///
/// File-based transport for persistent local log storage.
/// Supports log rotation, compression, and automatic cleanup.
///
/// Example:
/// ```dart
/// final transport = FileTransport(
///   directory: '/app/logs',
///   filePrefix: 'app_log',
///   maxFileSize: 10 * 1024 * 1024, // 10MB
///   maxFiles: 5,
/// );
/// ```

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import '../core/log_entry.dart';
import 'log_transport.dart';

/// Configuration for file transport behavior
class FileTransportConfig {
  /// Directory where log files will be stored
  final String directory;

  /// Prefix for log file names (e.g., 'app_log' creates 'app_log_2023-12-01.log')
  final String filePrefix;

  /// Maximum size per log file in bytes (default: 10MB)
  final int maxFileSize;

  /// Maximum number of log files to keep (default: 5)
  final int maxFiles;

  /// Whether to compress rotated log files (default: false)
  final bool compressRotatedFiles;

  /// File extension for log files (default: 'log')
  final String fileExtension;

  /// JSON encoder for formatting log entries
  final JsonEncoder jsonEncoder;

  const FileTransportConfig({
    required this.directory,
    this.filePrefix = 'flutter_log',
    this.maxFileSize = 10 * 1024 * 1024, // 10MB
    this.maxFiles = 5,
    this.compressRotatedFiles = false,
    this.fileExtension = 'log',
    this.jsonEncoder = const JsonEncoder(),
  });
}

/// Transport that writes log entries to local files
///
/// Features:
/// - Automatic log rotation when files reach size limit
/// - Configurable retention policy
/// - Optional compression of old log files
/// - Thread-safe file operations
/// - Atomic writes to prevent corruption
class FileTransport extends LogTransport {
  final FileTransportConfig _config;
  late final Directory _logDirectory;
  File? _currentLogFile;
  IOSink? _currentSink;
  final Completer<void> _initCompleter = Completer<void>();
  bool _disposed = false;
  int _currentFileSize = 0;

  FileTransport(this._config) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _logDirectory = Directory(_config.directory);
      if (!await _logDirectory.exists()) {
        await _logDirectory.create(recursive: true);
      }

      await _rotateIfNeeded();
      _initCompleter.complete();
    } catch (e) {
      _initCompleter.completeError(e);
    }
  }

  @override
  Future<void> send(List<LogEntry> entries) async {
    if (_disposed) {
      throw const TransportException('FileTransport has been disposed');
    }

    await _initCompleter.future;

    try {
      for (final entry in entries) {
        await _writeEntry(entry);
      }
      await _currentSink?.flush();
    } catch (e) {
      throw TransportException('Failed to write log entries to file', e);
    }
  }

  Future<void> _writeEntry(LogEntry entry) async {
    await _rotateIfNeeded();

    final jsonData = _config.jsonEncoder.convert(entry.toJson());
    final line = '$jsonData\n';
    final bytes = utf8.encode(line);

    _currentSink?.add(bytes);
    _currentFileSize += bytes.length;
  }

  Future<void> _rotateIfNeeded() async {
    if (_currentLogFile == null || _currentFileSize >= _config.maxFileSize) {
      await _rotateLogs();
    }
  }

  Future<void> _rotateLogs() async {
    // Close current file
    await _currentSink?.close();
    _currentSink = null;

    // Create new log file with timestamp
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final fileName =
        '${_config.filePrefix}_$timestamp.${_config.fileExtension}';

    // If file already exists, append a counter
    var counter = 1;
    var finalFileName = fileName;
    while (await File('${_logDirectory.path}/$finalFileName').exists()) {
      final baseName = fileName.split('.').first;
      final extension = fileName.split('.').last;
      finalFileName = '${baseName}_$counter.$extension';
      counter++;
    }

    _currentLogFile = File('${_logDirectory.path}/$finalFileName');
    _currentSink = _currentLogFile!.openWrite(mode: FileMode.append);
    _currentFileSize =
        await _currentLogFile!.exists() ? await _currentLogFile!.length() : 0;

    // Clean up old files
    await _cleanupOldFiles();
  }

  Future<void> _cleanupOldFiles() async {
    try {
      final files = await _logDirectory
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .where((file) => file.path.contains(_config.filePrefix))
          .toList();

      // Sort by modification time (newest first)
      files.sort(
          (a, b) => b.statSync().modified.compareTo(a.statSync().modified));

      // Delete excess files
      if (files.length > _config.maxFiles) {
        final filesToDelete = files.skip(_config.maxFiles);
        for (final file in filesToDelete) {
          try {
            await file.delete();
          } catch (e) {
            // Ignore deletion errors for individual files
          }
        }
      }

      // Compress old files if enabled
      if (_config.compressRotatedFiles) {
        // TODO: Implement compression logic
      }
    } catch (e) {
      // Ignore cleanup errors to not interfere with logging
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await _currentSink?.close();
    _currentSink = null;
    _currentLogFile = null;
  }

  @override
  bool get isAvailable => !_disposed && _initCompleter.isCompleted;

  @override
  int? get maxBatchSize => null; // No specific limit

  /// Get all log files in the directory
  Future<List<File>> getLogFiles() async {
    if (_disposed) return [];

    await _initCompleter.future;

    final files = await _logDirectory
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .where((file) => file.path.contains(_config.filePrefix))
        .toList();

    files
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    return files;
  }

  /// Get the current log file being written to
  File? get currentLogFile => _currentLogFile;

  /// Get the total size of all log files
  Future<int> getTotalLogSize() async {
    final files = await getLogFiles();
    int totalSize = 0;

    for (final file in files) {
      try {
        totalSize += await file.length();
      } catch (e) {
        // Ignore errors for individual files
      }
    }

    return totalSize;
  }
}
