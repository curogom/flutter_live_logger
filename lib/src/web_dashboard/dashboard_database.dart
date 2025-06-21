/// Flutter Live Logger - Web Dashboard Database Layer
///
/// SQLite-based database layer for storing and querying log data
/// for the web dashboard. Provides high-performance operations with
/// proper indexing and optimization.
///
/// Example:
/// ```dart
/// final db = await DashboardDatabase.create('logs.db');
/// await db.insertLog({
///   'level': 'info',
///   'message': 'User logged in',
///   'timestamp': DateTime.now().millisecondsSinceEpoch,
/// });
/// ```

import 'dart:io';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;

part 'dashboard_database.g.dart';

/// Log entry table definition for Drift ORM
@DataClassName('LogEntryData')
class LogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get level => text().withLength(min: 1, max: 20)();
  TextColumn get message => text()();
  IntColumn get timestamp => integer()();
  TextColumn get data => text().nullable()();
  TextColumn get source => text().nullable()();
  IntColumn get createdAt => integer()();
}

/// Log statistics table for caching aggregated data
@DataClassName('LogStatData')
class LogStatistics extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get statType => text()();
  TextColumn get statKey => text()();
  IntColumn get statValue => integer()();
  IntColumn get calculatedAt => integer()();
}

/// Dashboard settings table for configuration
@DataClassName('DashboardSettingData')
class DashboardSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get settingKey => text().unique()();
  TextColumn get settingValue => text()();
  IntColumn get updatedAt => integer()();
}

/// High-performance SQLite database for Flutter Live Logger Web Dashboard
///
/// Provides efficient storage and querying of log data with proper indexing,
/// batch operations, and analytics capabilities.
@DriftDatabase(tables: [LogEntries, LogStatistics, DashboardSettings])
class DashboardDatabase extends _$DashboardDatabase {
  DashboardDatabase._(QueryExecutor e) : super(e);

  /// Create a new database instance with the specified path
  ///
  /// Creates all necessary tables and indexes for optimal performance.
  ///
  /// Example:
  /// ```dart
  /// final db = await DashboardDatabase.create('logs.db');
  /// ```
  static Future<DashboardDatabase> create(String dbPath) async {
    final file = File(dbPath);
    final database = DashboardDatabase._(NativeDatabase(file));

    // Ensure database is properly initialized
    await database._initialize();

    return database;
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Handle future schema migrations
          if (from < 1 && to >= 1) {
            await _createIndexes();
          }
        },
      );

  /// Initialize database with performance optimizations
  Future<void> _initialize() async {
    // Enable WAL mode for better concurrent access
    await customStatement('PRAGMA journal_mode = WAL');

    // Optimize SQLite settings for performance
    await customStatement('PRAGMA synchronous = NORMAL');
    await customStatement('PRAGMA cache_size = -64000'); // 64MB cache
    await customStatement('PRAGMA temp_store = MEMORY');
    await customStatement('PRAGMA mmap_size = 268435456'); // 256MB mmap
  }

  /// Create performance indexes
  Future<void> _createIndexes() async {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_logs_timestamp ON log_entries(timestamp)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_logs_level ON log_entries(level)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_logs_created_at ON log_entries(created_at)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_logs_source ON log_entries(source)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_logs_level_timestamp ON log_entries(level, timestamp)');

    // Full-text search index
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS logs_fts USING fts5(
        message, 
        data, 
        content='log_entries', 
        content_rowid='id'
      )
    ''');

    // Triggers to maintain FTS index
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS logs_fts_insert AFTER INSERT ON log_entries BEGIN
        INSERT INTO logs_fts(rowid, message, data) VALUES (new.id, new.message, new.data);
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS logs_fts_delete AFTER DELETE ON log_entries BEGIN
        INSERT INTO logs_fts(logs_fts, rowid, message, data) VALUES('delete', old.id, old.message, old.data);
      END
    ''');

    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS logs_fts_update AFTER UPDATE ON log_entries BEGIN
        INSERT INTO logs_fts(logs_fts, rowid, message, data) VALUES('delete', old.id, old.message, old.data);
        INSERT INTO logs_fts(rowid, message, data) VALUES (new.id, new.message, new.data);
      END
    ''');
  }

  /// Get list of all table names
  Future<List<String>> getTables() async {
    final result = await customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
        .get();

    return result.map((row) => row.data['name'] as String).toList();
  }

  /// Get table schema information
  Future<Map<String, String>> getTableSchema(String tableName) async {
    final result = await customSelect('PRAGMA table_info($tableName)').get();

    final schema = <String, String>{};
    for (final row in result) {
      final columnName = row.data['name'] as String;
      final columnType = row.data['type'] as String;
      final notNull = (row.data['notnull'] as int) == 1;
      final pk = (row.data['pk'] as int) == 1;

      var typeDesc = columnType;
      if (pk) typeDesc += ' PRIMARY KEY';
      if (notNull) typeDesc += ' NOT NULL';

      schema[columnName] = typeDesc;
    }

    return schema;
  }

  /// Get indexes for a table
  Future<List<String>> getIndexes(String tableName) async {
    final result = await customSelect(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name=? AND name NOT LIKE 'sqlite_%'",
        variables: [Variable.withString(tableName)]).get();

    return result.map((row) => row.data['name'] as String).toList();
  }

  /// Get database version
  Future<int> getVersion() async {
    final result = await customSelect('PRAGMA user_version').get();
    return result.first.data['user_version'] as int;
  }

  /// Insert a single log entry
  ///
  /// Returns the ID of the inserted log entry.
  ///
  /// Example:
  /// ```dart
  /// final id = await db.insertLog({
  ///   'level': 'error',
  ///   'message': 'Database connection failed',
  ///   'timestamp': DateTime.now().millisecondsSinceEpoch,
  /// });
  /// ```
  Future<int> insertLog(Map<String, dynamic> logData) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    return await into(logEntries).insert(LogEntriesCompanion(
      level: Value(logData['level'] as String),
      message: Value(logData['message'] as String),
      timestamp: Value(logData['timestamp'] as int),
      data: Value(logData['data'] as String?),
      source: Value(logData['source'] as String?),
      createdAt: Value(now),
    ));
  }

  /// Insert multiple log entries efficiently in a batch
  ///
  /// Returns list of inserted IDs. Uses transaction for atomicity.
  ///
  /// Example:
  /// ```dart
  /// final ids = await db.insertLogsBatch([
  ///   {'level': 'info', 'message': 'Log 1', 'timestamp': 1000},
  ///   {'level': 'error', 'message': 'Log 2', 'timestamp': 2000},
  /// ]);
  /// ```
  Future<List<int>> insertLogsBatch(List<Map<String, dynamic>> logsData) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final ids = <int>[];

    await transaction(() async {
      for (final logData in logsData) {
        final id = await into(logEntries).insert(LogEntriesCompanion(
          level: Value(logData['level'] as String),
          message: Value(logData['message'] as String),
          timestamp: Value(logData['timestamp'] as int),
          data: Value(logData['data'] as String?),
          source: Value(logData['source'] as String?),
          createdAt: Value(now),
        ));
        ids.add(id);
      }
    });

    return ids;
  }

  /// Query logs with filtering and pagination
  ///
  /// Supports filtering by level, time range, source, and pagination.
  /// Results are ordered by timestamp descending (newest first).
  ///
  /// Example:
  /// ```dart
  /// final logs = await db.queryLogs(
  ///   level: 'error',
  ///   startTime: DateTime.now().subtract(Duration(hours: 1)).millisecondsSinceEpoch,
  ///   limit: 50,
  /// );
  /// ```
  Future<List<Map<String, dynamic>>> queryLogs({
    String? level,
    int? startTime,
    int? endTime,
    String? source,
    int? limit,
    int? offset,
  }) async {
    var query = select(logEntries);

    // Apply filters
    if (level != null) {
      query = query..where((tbl) => tbl.level.equals(level));
    }

    if (startTime != null) {
      query = query
        ..where((tbl) => tbl.timestamp.isBiggerOrEqualValue(startTime));
    }

    if (endTime != null) {
      query = query
        ..where((tbl) => tbl.timestamp.isSmallerOrEqualValue(endTime));
    }

    if (source != null) {
      query = query..where((tbl) => tbl.source.equals(source));
    }

    // Order by timestamp descending (newest first)
    query = query..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]);

    // Apply pagination
    if (limit != null) {
      query = query..limit(limit, offset: offset);
    }

    final results = await query.get();

    return results
        .map((row) => {
              'id': row.id,
              'level': row.level,
              'message': row.message,
              'timestamp': row.timestamp,
              'data': row.data,
              'source': row.source,
              'created_at': row.createdAt,
            })
        .toList();
  }

  /// Search logs using full-text search
  ///
  /// Searches in both message and data fields using SQLite FTS5.
  ///
  /// Example:
  /// ```dart
  /// final results = await db.searchLogs('database error');
  /// ```
  Future<List<Map<String, dynamic>>> searchLogs(String searchTerm) async {
    final results = await customSelect('''
      SELECT le.* FROM log_entries le
      JOIN logs_fts fts ON le.id = fts.rowid
      WHERE logs_fts MATCH ?
      ORDER BY le.timestamp DESC
      LIMIT 1000
    ''', variables: [Variable.withString(searchTerm)]).get();

    return results.map((row) => row.data).toList();
  }

  /// Get log statistics by level
  ///
  /// Returns count of logs for each level.
  ///
  /// Example:
  /// ```dart
  /// final stats = await db.getLogStatsByLevel();
  /// print('Errors: ${stats['error']}'); // Errors: 42
  /// ```
  Future<Map<String, int>> getLogStatsByLevel() async {
    final results = await customSelect('''
      SELECT level, COUNT(*) as count
      FROM log_entries
      GROUP BY level
    ''').get();

    final stats = <String, int>{};
    for (final row in results) {
      stats[row.data['level'] as String] = row.data['count'] as int;
    }

    return stats;
  }

  /// Get hourly log activity for the specified number of hours
  ///
  /// Returns a map of hour (as timestamp) to log count.
  ///
  /// Example:
  /// ```dart
  /// final activity = await db.getHourlyActivity(hours: 24);
  /// ```
  Future<Map<int, int>> getHourlyActivity({required int hours}) async {
    final now = DateTime.now();
    final startTime = now.subtract(Duration(hours: hours));

    final results = await customSelect('''
      SELECT 
        (timestamp / 3600000) * 3600000 as hour_timestamp,
        COUNT(*) as count
      FROM log_entries
      WHERE timestamp >= ?
      GROUP BY hour_timestamp
      ORDER BY hour_timestamp
    ''', variables: [Variable.withInt(startTime.millisecondsSinceEpoch)]).get();

    final activity = <int, int>{};
    for (final row in results) {
      activity[row.data['hour_timestamp'] as int] = row.data['count'] as int;
    }

    return activity;
  }

  /// Identify error patterns by finding most common error messages
  ///
  /// Returns list of error patterns with their occurrence count.
  ///
  /// Example:
  /// ```dart
  /// final patterns = await db.getErrorPatterns(limit: 10);
  /// ```
  Future<List<Map<String, dynamic>>> getErrorPatterns({int limit = 20}) async {
    final results = await customSelect('''
      SELECT message, COUNT(*) as count
      FROM log_entries
      WHERE level IN ('error', 'fatal')
      GROUP BY message
      ORDER BY count DESC
      LIMIT ?
    ''', variables: [Variable.withInt(limit)]).get();

    return results
        .map((row) => {
              'message': row.data['message'],
              'count': row.data['count'],
            })
        .toList();
  }

  /// Clean up old log entries
  ///
  /// Deletes log entries older than the specified duration.
  /// Returns the number of deleted entries.
  ///
  /// Example:
  /// ```dart
  /// final deleted = await db.cleanupOldLogs(olderThan: Duration(days: 30));
  /// ```
  Future<int> cleanupOldLogs({required Duration olderThan}) async {
    final cutoffTime = DateTime.now().subtract(olderThan);

    final result = await customUpdate(
      'DELETE FROM log_entries WHERE timestamp < ?',
      variables: [Variable.withInt(cutoffTime.millisecondsSinceEpoch)],
    );

    return result;
  }

  /// Optimize database performance
  ///
  /// Runs VACUUM and ANALYZE commands to optimize database performance.
  /// Should be called periodically for maintenance.
  ///
  /// Example:
  /// ```dart
  /// await db.optimize();
  /// ```
  Future<void> optimize() async {
    await customStatement('ANALYZE');
    await customStatement('PRAGMA optimize');

    // Rebuild FTS index if needed
    await customStatement('INSERT INTO logs_fts(logs_fts) VALUES("rebuild")');
  }
}
