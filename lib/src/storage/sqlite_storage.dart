/// Flutter Live Logger - SQLite Storage
///
/// Persistent storage implementation using SQLite database.
/// Provides durable log storage with efficient querying and indexing.
///
/// Example:
/// ```dart
/// final storage = SQLiteStorage();
/// await storage.initialize();
/// await storage.store([logEntry]);
///
/// final recentLogs = await storage.query(LogQuery.recent(limit: 100));
/// ```

import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'package:flutter_live_logger/src/core/log_entry.dart';
import 'package:flutter_live_logger/src/core/log_level.dart';
import 'package:flutter_live_logger/src/storage/storage_interface.dart';

/// Configuration for SQLite storage
class SQLiteStorageConfig {
  /// Database file name
  final String databaseName;

  /// Database version for migrations
  final int version;

  /// Maximum number of entries to keep (0 = unlimited)
  final int maxEntries;

  /// Whether to enable Write-Ahead Logging mode for better performance
  final bool enableWAL;

  /// Whether to enable foreign keys support
  final bool enableForeignKeys;

  const SQLiteStorageConfig({
    this.databaseName = 'flutter_live_logger.db',
    this.version = 1,
    this.maxEntries = 50000,
    this.enableWAL = true,
    this.enableForeignKeys = true,
  });
}

/// SQLite-based storage implementation
///
/// Features:
/// - Persistent storage across app restarts
/// - Efficient indexing for fast queries
/// - Automatic cleanup of old entries
/// - Support for complex queries with filtering
/// - Database migrations for schema updates
class SQLiteStorage extends BaseLogStorage {
  final SQLiteStorageConfig _config;
  Database? _database;
  bool _isInitialized = false;

  static const String _tableName = 'log_entries';

  /// Create SQLite storage with configuration
  SQLiteStorage({SQLiteStorageConfig? config})
      : _config = config ?? const SQLiteStorageConfig();

  /// Initialize the database connection and schema
  Future<void> initialize() async {
    if (_isInitialized) return;

    final databasePath = await getDatabasesPath();
    final dbPath = path.join(databasePath, _config.databaseName);

    _database = await openDatabase(
      dbPath,
      version: _config.version,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: _configureDatabase,
    );

    _isInitialized = true;
  }

  Future<void> _configureDatabase(Database db) async {
    if (_config.enableForeignKeys) {
      await db.execute('PRAGMA foreign_keys = ON');
    }

    if (_config.enableWAL) {
      await db.execute('PRAGMA journal_mode = WAL');
    }

    // Performance optimizations
    await db.execute('PRAGMA synchronous = NORMAL');
    await db.execute('PRAGMA cache_size = 10000');
    await db.execute('PRAGMA temp_store = MEMORY');
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT NOT NULL,
        level INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        data TEXT,
        error_message TEXT,
        error_type TEXT,
        stack_trace TEXT,
        user_id TEXT,
        session_id TEXT,
        created_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // Create indexes for common query patterns
    await db.execute('''
      CREATE INDEX idx_level ON $_tableName(level)
    ''');

    await db.execute('''
      CREATE INDEX idx_timestamp ON $_tableName(timestamp)
    ''');

    await db.execute('''
      CREATE INDEX idx_user_session ON $_tableName(user_id, session_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_created_at ON $_tableName(created_at)
    ''');
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    // For now, we're at version 1, so no migrations needed
  }

  @override
  Future<void> store(List<LogEntry> entries) async {
    checkAvailable();
    await _ensureInitialized();

    if (entries.isEmpty) return;

    final batch = _database!.batch();

    for (final entry in entries) {
      batch.insert(_tableName, _entryToMap(entry));
    }

    await batch.commit(noResult: true);

    // Clean up old entries if limit is exceeded
    if (_config.maxEntries > 0) {
      await _cleanupOldEntries();
    }
  }

  @override
  Future<List<LogEntry>> query(LogQuery query) async {
    checkAvailable();
    await _ensureInitialized();

    final sql = _buildQuerySQL(query);
    final maps = await _database!.rawQuery(sql.sql, sql.arguments);

    return maps.map(_mapToEntry).toList();
  }

  @override
  Future<int> count([LogQuery? query]) async {
    checkAvailable();
    await _ensureInitialized();

    String sql = 'SELECT COUNT(*) as count FROM $_tableName';
    List<Object?> arguments = [];

    if (query != null) {
      final whereClause = _buildWhereClause(query);
      if (whereClause.isNotEmpty) {
        sql += ' WHERE ${whereClause.sql}';
        arguments = whereClause.arguments;
      }
    }

    final result = await _database!.rawQuery(sql, arguments);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<int> delete(LogQuery query) async {
    checkAvailable();
    await _ensureInitialized();

    final whereClause = _buildWhereClause(query);
    if (whereClause.isEmpty) {
      throw const StorageException(
          'Delete query must have filtering conditions');
    }

    final result = await _database!.delete(
      _tableName,
      where: whereClause.sql,
      whereArgs: whereClause.arguments,
    );

    return result;
  }

  @override
  Future<int> clear() async {
    checkAvailable();
    await _ensureInitialized();

    final result = await _database!.delete(_tableName);
    return result;
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    checkAvailable();
    await _ensureInitialized();

    final countResult =
        await _database!.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    final totalCount = Sqflite.firstIntValue(countResult) ?? 0;

    final sizeResult = await _database!.rawQuery(
        "SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()");
    final dbSize = Sqflite.firstIntValue(sizeResult) ?? 0;

    final levelStats = await _database!.rawQuery('''
      SELECT level, COUNT(*) as count 
      FROM $_tableName 
      GROUP BY level 
      ORDER BY level
    ''');

    return {
      'type': 'sqlite',
      'entryCount': totalCount,
      'maxEntries': _config.maxEntries,
      'databaseSize': dbSize,
      'databasePath': _database!.path,
      'levelDistribution': Map.fromEntries(
        levelStats.map((row) => MapEntry(
              LogLevel.values[row['level'] as int].name,
              row['count'],
            )),
      ),
    };
  }

  @override
  Future<void> optimize() async {
    checkAvailable();
    await _ensureInitialized();

    // Vacuum the database to reclaim space
    await _database!.execute('VACUUM');

    // Analyze tables for query optimization
    await _database!.execute('ANALYZE');
  }

  @override
  Future<void> dispose() async {
    await _database?.close();
    _database = null;
    _isInitialized = false;
    await super.dispose();
  }

  @override
  int? get maxEntries => _config.maxEntries > 0 ? _config.maxEntries : null;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> _cleanupOldEntries() async {
    final count = await this.count();
    if (count > _config.maxEntries) {
      final excessCount = count - _config.maxEntries;

      // Delete oldest entries
      await _database!.rawDelete('''
        DELETE FROM $_tableName 
        WHERE id IN (
          SELECT id FROM $_tableName 
          ORDER BY created_at ASC 
          LIMIT ?
        )
      ''', [excessCount]);
    }
  }

  Map<String, Object?> _entryToMap(LogEntry entry) {
    return {
      'message': entry.message,
      'level': entry.level.index,
      'timestamp': entry.timestamp.millisecondsSinceEpoch,
      'data': entry.data != null ? jsonEncode(entry.data) : null,
      'error_message': entry.error?.toString(),
      'error_type': entry.error?.runtimeType.toString(),
      'stack_trace': entry.stackTrace?.toString(),
      'user_id': entry.userId,
      'session_id': entry.sessionId,
    };
  }

  LogEntry _mapToEntry(Map<String, Object?> map) {
    Map<String, dynamic>? parsedData;
    if (map['data'] != null) {
      final decoded = jsonDecode(map['data'] as String);
      parsedData = decoded is Map<String, dynamic> ? decoded : null;
    }

    return LogEntry(
      message: map['message'] as String,
      level: LogLevel.values[map['level'] as int],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      data: parsedData,
      error:
          map['error_message'] != null ? Exception(map['error_message']) : null,
      stackTrace: map['stack_trace'] != null
          ? StackTrace.fromString(map['stack_trace'] as String)
          : null,
      userId: map['user_id'] as String?,
      sessionId: map['session_id'] as String?,
    );
  }

  _QueryResult _buildQuerySQL(LogQuery query) {
    String sql = 'SELECT * FROM $_tableName';
    List<Object?> arguments = [];

    final whereClause = _buildWhereClause(query);
    if (whereClause.isNotEmpty) {
      sql += ' WHERE ${whereClause.sql}';
      arguments.addAll(whereClause.arguments);
    }

    // Order by
    sql += ' ORDER BY timestamp ${query.ascending ? 'ASC' : 'DESC'}';

    // Limit and offset
    if (query.limit != null) {
      sql += ' LIMIT ?';
      arguments.add(query.limit);
    }

    if (query.offset != null) {
      sql += ' OFFSET ?';
      arguments.add(query.offset);
    }

    return _QueryResult(sql, arguments);
  }

  _QueryResult _buildWhereClause(LogQuery query) {
    final conditions = <String>[];
    final arguments = <Object?>[];

    if (query.minLevel != null) {
      conditions.add('level >= ?');
      arguments.add(query.minLevel!.index);
    }

    if (query.maxLevel != null) {
      conditions.add('level <= ?');
      arguments.add(query.maxLevel!.index);
    }

    if (query.startTime != null) {
      conditions.add('timestamp >= ?');
      arguments.add(query.startTime!.millisecondsSinceEpoch);
    }

    if (query.endTime != null) {
      conditions.add('timestamp <= ?');
      arguments.add(query.endTime!.millisecondsSinceEpoch);
    }

    if (query.userId != null) {
      conditions.add('user_id = ?');
      arguments.add(query.userId);
    }

    if (query.sessionId != null) {
      conditions.add('session_id = ?');
      arguments.add(query.sessionId);
    }

    if (conditions.isEmpty) {
      return _QueryResult('', []);
    }

    return _QueryResult(conditions.join(' AND '), arguments);
  }
}

class _QueryResult {
  final String sql;
  final List<Object?> arguments;

  _QueryResult(this.sql, this.arguments);

  bool get isEmpty => sql.isEmpty;
  bool get isNotEmpty => sql.isNotEmpty;
}
