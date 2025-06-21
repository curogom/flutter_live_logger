// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_database.dart';

// ignore_for_file: type=lint
class $LogEntriesTable extends LogEntries
    with TableInfo<$LogEntriesTable, LogEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
      'level', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, level, message, timestamp, data, source, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LogEntryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogEntryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}level'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $LogEntriesTable createAlias(String alias) {
    return $LogEntriesTable(attachedDatabase, alias);
  }
}

class LogEntryData extends DataClass implements Insertable<LogEntryData> {
  final int id;
  final String level;
  final String message;
  final int timestamp;
  final String? data;
  final String? source;
  final int createdAt;
  const LogEntryData(
      {required this.id,
      required this.level,
      required this.message,
      required this.timestamp,
      this.data,
      this.source,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<String>(level);
    map['message'] = Variable<String>(message);
    map['timestamp'] = Variable<int>(timestamp);
    if (!nullToAbsent || data != null) {
      map['data'] = Variable<String>(data);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  LogEntriesCompanion toCompanion(bool nullToAbsent) {
    return LogEntriesCompanion(
      id: Value(id),
      level: Value(level),
      message: Value(message),
      timestamp: Value(timestamp),
      data: data == null && nullToAbsent ? const Value.absent() : Value(data),
      source:
          source == null && nullToAbsent ? const Value.absent() : Value(source),
      createdAt: Value(createdAt),
    );
  }

  factory LogEntryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogEntryData(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      message: serializer.fromJson<String>(json['message']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      data: serializer.fromJson<String?>(json['data']),
      source: serializer.fromJson<String?>(json['source']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<String>(level),
      'message': serializer.toJson<String>(message),
      'timestamp': serializer.toJson<int>(timestamp),
      'data': serializer.toJson<String?>(data),
      'source': serializer.toJson<String?>(source),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  LogEntryData copyWith(
          {int? id,
          String? level,
          String? message,
          int? timestamp,
          Value<String?> data = const Value.absent(),
          Value<String?> source = const Value.absent(),
          int? createdAt}) =>
      LogEntryData(
        id: id ?? this.id,
        level: level ?? this.level,
        message: message ?? this.message,
        timestamp: timestamp ?? this.timestamp,
        data: data.present ? data.value : this.data,
        source: source.present ? source.value : this.source,
        createdAt: createdAt ?? this.createdAt,
      );
  LogEntryData copyWithCompanion(LogEntriesCompanion data) {
    return LogEntryData(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      message: data.message.present ? data.message.value : this.message,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      data: data.data.present ? data.data.value : this.data,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogEntryData(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('timestamp: $timestamp, ')
          ..write('data: $data, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, level, message, timestamp, data, source, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogEntryData &&
          other.id == this.id &&
          other.level == this.level &&
          other.message == this.message &&
          other.timestamp == this.timestamp &&
          other.data == this.data &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class LogEntriesCompanion extends UpdateCompanion<LogEntryData> {
  final Value<int> id;
  final Value<String> level;
  final Value<String> message;
  final Value<int> timestamp;
  final Value<String?> data;
  final Value<String?> source;
  final Value<int> createdAt;
  const LogEntriesCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.message = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.data = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LogEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String level,
    required String message,
    required int timestamp,
    this.data = const Value.absent(),
    this.source = const Value.absent(),
    required int createdAt,
  })  : level = Value(level),
        message = Value(message),
        timestamp = Value(timestamp),
        createdAt = Value(createdAt);
  static Insertable<LogEntryData> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<String>? message,
    Expression<int>? timestamp,
    Expression<String>? data,
    Expression<String>? source,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (message != null) 'message': message,
      if (timestamp != null) 'timestamp': timestamp,
      if (data != null) 'data': data,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LogEntriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? level,
      Value<String>? message,
      Value<int>? timestamp,
      Value<String?>? data,
      Value<String?>? source,
      Value<int>? createdAt}) {
    return LogEntriesCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('timestamp: $timestamp, ')
          ..write('data: $data, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $LogStatisticsTable extends LogStatistics
    with TableInfo<$LogStatisticsTable, LogStatData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogStatisticsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _statTypeMeta =
      const VerificationMeta('statType');
  @override
  late final GeneratedColumn<String> statType = GeneratedColumn<String>(
      'stat_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statKeyMeta =
      const VerificationMeta('statKey');
  @override
  late final GeneratedColumn<String> statKey = GeneratedColumn<String>(
      'stat_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statValueMeta =
      const VerificationMeta('statValue');
  @override
  late final GeneratedColumn<int> statValue = GeneratedColumn<int>(
      'stat_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _calculatedAtMeta =
      const VerificationMeta('calculatedAt');
  @override
  late final GeneratedColumn<int> calculatedAt = GeneratedColumn<int>(
      'calculated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, statType, statKey, statValue, calculatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'log_statistics';
  @override
  VerificationContext validateIntegrity(Insertable<LogStatData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stat_type')) {
      context.handle(_statTypeMeta,
          statType.isAcceptableOrUnknown(data['stat_type']!, _statTypeMeta));
    } else if (isInserting) {
      context.missing(_statTypeMeta);
    }
    if (data.containsKey('stat_key')) {
      context.handle(_statKeyMeta,
          statKey.isAcceptableOrUnknown(data['stat_key']!, _statKeyMeta));
    } else if (isInserting) {
      context.missing(_statKeyMeta);
    }
    if (data.containsKey('stat_value')) {
      context.handle(_statValueMeta,
          statValue.isAcceptableOrUnknown(data['stat_value']!, _statValueMeta));
    } else if (isInserting) {
      context.missing(_statValueMeta);
    }
    if (data.containsKey('calculated_at')) {
      context.handle(
          _calculatedAtMeta,
          calculatedAt.isAcceptableOrUnknown(
              data['calculated_at']!, _calculatedAtMeta));
    } else if (isInserting) {
      context.missing(_calculatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LogStatData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LogStatData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      statType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stat_type'])!,
      statKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stat_key'])!,
      statValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}stat_value'])!,
      calculatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}calculated_at'])!,
    );
  }

  @override
  $LogStatisticsTable createAlias(String alias) {
    return $LogStatisticsTable(attachedDatabase, alias);
  }
}

class LogStatData extends DataClass implements Insertable<LogStatData> {
  final int id;
  final String statType;
  final String statKey;
  final int statValue;
  final int calculatedAt;
  const LogStatData(
      {required this.id,
      required this.statType,
      required this.statKey,
      required this.statValue,
      required this.calculatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['stat_type'] = Variable<String>(statType);
    map['stat_key'] = Variable<String>(statKey);
    map['stat_value'] = Variable<int>(statValue);
    map['calculated_at'] = Variable<int>(calculatedAt);
    return map;
  }

  LogStatisticsCompanion toCompanion(bool nullToAbsent) {
    return LogStatisticsCompanion(
      id: Value(id),
      statType: Value(statType),
      statKey: Value(statKey),
      statValue: Value(statValue),
      calculatedAt: Value(calculatedAt),
    );
  }

  factory LogStatData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LogStatData(
      id: serializer.fromJson<int>(json['id']),
      statType: serializer.fromJson<String>(json['statType']),
      statKey: serializer.fromJson<String>(json['statKey']),
      statValue: serializer.fromJson<int>(json['statValue']),
      calculatedAt: serializer.fromJson<int>(json['calculatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'statType': serializer.toJson<String>(statType),
      'statKey': serializer.toJson<String>(statKey),
      'statValue': serializer.toJson<int>(statValue),
      'calculatedAt': serializer.toJson<int>(calculatedAt),
    };
  }

  LogStatData copyWith(
          {int? id,
          String? statType,
          String? statKey,
          int? statValue,
          int? calculatedAt}) =>
      LogStatData(
        id: id ?? this.id,
        statType: statType ?? this.statType,
        statKey: statKey ?? this.statKey,
        statValue: statValue ?? this.statValue,
        calculatedAt: calculatedAt ?? this.calculatedAt,
      );
  LogStatData copyWithCompanion(LogStatisticsCompanion data) {
    return LogStatData(
      id: data.id.present ? data.id.value : this.id,
      statType: data.statType.present ? data.statType.value : this.statType,
      statKey: data.statKey.present ? data.statKey.value : this.statKey,
      statValue: data.statValue.present ? data.statValue.value : this.statValue,
      calculatedAt: data.calculatedAt.present
          ? data.calculatedAt.value
          : this.calculatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LogStatData(')
          ..write('id: $id, ')
          ..write('statType: $statType, ')
          ..write('statKey: $statKey, ')
          ..write('statValue: $statValue, ')
          ..write('calculatedAt: $calculatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, statType, statKey, statValue, calculatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LogStatData &&
          other.id == this.id &&
          other.statType == this.statType &&
          other.statKey == this.statKey &&
          other.statValue == this.statValue &&
          other.calculatedAt == this.calculatedAt);
}

class LogStatisticsCompanion extends UpdateCompanion<LogStatData> {
  final Value<int> id;
  final Value<String> statType;
  final Value<String> statKey;
  final Value<int> statValue;
  final Value<int> calculatedAt;
  const LogStatisticsCompanion({
    this.id = const Value.absent(),
    this.statType = const Value.absent(),
    this.statKey = const Value.absent(),
    this.statValue = const Value.absent(),
    this.calculatedAt = const Value.absent(),
  });
  LogStatisticsCompanion.insert({
    this.id = const Value.absent(),
    required String statType,
    required String statKey,
    required int statValue,
    required int calculatedAt,
  })  : statType = Value(statType),
        statKey = Value(statKey),
        statValue = Value(statValue),
        calculatedAt = Value(calculatedAt);
  static Insertable<LogStatData> custom({
    Expression<int>? id,
    Expression<String>? statType,
    Expression<String>? statKey,
    Expression<int>? statValue,
    Expression<int>? calculatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (statType != null) 'stat_type': statType,
      if (statKey != null) 'stat_key': statKey,
      if (statValue != null) 'stat_value': statValue,
      if (calculatedAt != null) 'calculated_at': calculatedAt,
    });
  }

  LogStatisticsCompanion copyWith(
      {Value<int>? id,
      Value<String>? statType,
      Value<String>? statKey,
      Value<int>? statValue,
      Value<int>? calculatedAt}) {
    return LogStatisticsCompanion(
      id: id ?? this.id,
      statType: statType ?? this.statType,
      statKey: statKey ?? this.statKey,
      statValue: statValue ?? this.statValue,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (statType.present) {
      map['stat_type'] = Variable<String>(statType.value);
    }
    if (statKey.present) {
      map['stat_key'] = Variable<String>(statKey.value);
    }
    if (statValue.present) {
      map['stat_value'] = Variable<int>(statValue.value);
    }
    if (calculatedAt.present) {
      map['calculated_at'] = Variable<int>(calculatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogStatisticsCompanion(')
          ..write('id: $id, ')
          ..write('statType: $statType, ')
          ..write('statKey: $statKey, ')
          ..write('statValue: $statValue, ')
          ..write('calculatedAt: $calculatedAt')
          ..write(')'))
        .toString();
  }
}

class $DashboardSettingsTable extends DashboardSettings
    with TableInfo<$DashboardSettingsTable, DashboardSettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DashboardSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _settingKeyMeta =
      const VerificationMeta('settingKey');
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
      'setting_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _settingValueMeta =
      const VerificationMeta('settingValue');
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
      'setting_value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, settingKey, settingValue, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dashboard_settings';
  @override
  VerificationContext validateIntegrity(
      Insertable<DashboardSettingData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('setting_key')) {
      context.handle(
          _settingKeyMeta,
          settingKey.isAcceptableOrUnknown(
              data['setting_key']!, _settingKeyMeta));
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('setting_value')) {
      context.handle(
          _settingValueMeta,
          settingValue.isAcceptableOrUnknown(
              data['setting_value']!, _settingValueMeta));
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DashboardSettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DashboardSettingData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      settingKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setting_key'])!,
      settingValue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}setting_value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DashboardSettingsTable createAlias(String alias) {
    return $DashboardSettingsTable(attachedDatabase, alias);
  }
}

class DashboardSettingData extends DataClass
    implements Insertable<DashboardSettingData> {
  final int id;
  final String settingKey;
  final String settingValue;
  final int updatedAt;
  const DashboardSettingData(
      {required this.id,
      required this.settingKey,
      required this.settingValue,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DashboardSettingsCompanion toCompanion(bool nullToAbsent) {
    return DashboardSettingsCompanion(
      id: Value(id),
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory DashboardSettingData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DashboardSettingData(
      id: serializer.fromJson<int>(json['id']),
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  DashboardSettingData copyWith(
          {int? id,
          String? settingKey,
          String? settingValue,
          int? updatedAt}) =>
      DashboardSettingData(
        id: id ?? this.id,
        settingKey: settingKey ?? this.settingKey,
        settingValue: settingValue ?? this.settingValue,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DashboardSettingData copyWithCompanion(DashboardSettingsCompanion data) {
    return DashboardSettingData(
      id: data.id.present ? data.id.value : this.id,
      settingKey:
          data.settingKey.present ? data.settingKey.value : this.settingKey,
      settingValue: data.settingValue.present
          ? data.settingValue.value
          : this.settingValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DashboardSettingData(')
          ..write('id: $id, ')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, settingKey, settingValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DashboardSettingData &&
          other.id == this.id &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue &&
          other.updatedAt == this.updatedAt);
}

class DashboardSettingsCompanion extends UpdateCompanion<DashboardSettingData> {
  final Value<int> id;
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<int> updatedAt;
  const DashboardSettingsCompanion({
    this.id = const Value.absent(),
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DashboardSettingsCompanion.insert({
    this.id = const Value.absent(),
    required String settingKey,
    required String settingValue,
    required int updatedAt,
  })  : settingKey = Value(settingKey),
        settingValue = Value(settingValue),
        updatedAt = Value(updatedAt);
  static Insertable<DashboardSettingData> custom({
    Expression<int>? id,
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (settingKey != null) 'setting_key': settingKey,
      if (settingValue != null) 'setting_value': settingValue,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DashboardSettingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? settingKey,
      Value<String>? settingValue,
      Value<int>? updatedAt}) {
    return DashboardSettingsCompanion(
      id: id ?? this.id,
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['setting_value'] = Variable<String>(settingValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DashboardSettingsCompanion(')
          ..write('id: $id, ')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$DashboardDatabase extends GeneratedDatabase {
  _$DashboardDatabase(QueryExecutor e) : super(e);
  $DashboardDatabaseManager get managers => $DashboardDatabaseManager(this);
  late final $LogEntriesTable logEntries = $LogEntriesTable(this);
  late final $LogStatisticsTable logStatistics = $LogStatisticsTable(this);
  late final $DashboardSettingsTable dashboardSettings =
      $DashboardSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [logEntries, logStatistics, dashboardSettings];
}

typedef $$LogEntriesTableCreateCompanionBuilder = LogEntriesCompanion Function({
  Value<int> id,
  required String level,
  required String message,
  required int timestamp,
  Value<String?> data,
  Value<String?> source,
  required int createdAt,
});
typedef $$LogEntriesTableUpdateCompanionBuilder = LogEntriesCompanion Function({
  Value<int> id,
  Value<String> level,
  Value<String> message,
  Value<int> timestamp,
  Value<String?> data,
  Value<String?> source,
  Value<int> createdAt,
});

class $$LogEntriesTableFilterComposer
    extends Composer<_$DashboardDatabase, $LogEntriesTable> {
  $$LogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$LogEntriesTableOrderingComposer
    extends Composer<_$DashboardDatabase, $LogEntriesTable> {
  $$LogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$LogEntriesTableAnnotationComposer
    extends Composer<_$DashboardDatabase, $LogEntriesTable> {
  $$LogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LogEntriesTableTableManager extends RootTableManager<
    _$DashboardDatabase,
    $LogEntriesTable,
    LogEntryData,
    $$LogEntriesTableFilterComposer,
    $$LogEntriesTableOrderingComposer,
    $$LogEntriesTableAnnotationComposer,
    $$LogEntriesTableCreateCompanionBuilder,
    $$LogEntriesTableUpdateCompanionBuilder,
    (
      LogEntryData,
      BaseReferences<_$DashboardDatabase, $LogEntriesTable, LogEntryData>
    ),
    LogEntryData,
    PrefetchHooks Function()> {
  $$LogEntriesTableTableManager(_$DashboardDatabase db, $LogEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> level = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<String?> data = const Value.absent(),
            Value<String?> source = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) =>
              LogEntriesCompanion(
            id: id,
            level: level,
            message: message,
            timestamp: timestamp,
            data: data,
            source: source,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String level,
            required String message,
            required int timestamp,
            Value<String?> data = const Value.absent(),
            Value<String?> source = const Value.absent(),
            required int createdAt,
          }) =>
              LogEntriesCompanion.insert(
            id: id,
            level: level,
            message: message,
            timestamp: timestamp,
            data: data,
            source: source,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LogEntriesTableProcessedTableManager = ProcessedTableManager<
    _$DashboardDatabase,
    $LogEntriesTable,
    LogEntryData,
    $$LogEntriesTableFilterComposer,
    $$LogEntriesTableOrderingComposer,
    $$LogEntriesTableAnnotationComposer,
    $$LogEntriesTableCreateCompanionBuilder,
    $$LogEntriesTableUpdateCompanionBuilder,
    (
      LogEntryData,
      BaseReferences<_$DashboardDatabase, $LogEntriesTable, LogEntryData>
    ),
    LogEntryData,
    PrefetchHooks Function()>;
typedef $$LogStatisticsTableCreateCompanionBuilder = LogStatisticsCompanion
    Function({
  Value<int> id,
  required String statType,
  required String statKey,
  required int statValue,
  required int calculatedAt,
});
typedef $$LogStatisticsTableUpdateCompanionBuilder = LogStatisticsCompanion
    Function({
  Value<int> id,
  Value<String> statType,
  Value<String> statKey,
  Value<int> statValue,
  Value<int> calculatedAt,
});

class $$LogStatisticsTableFilterComposer
    extends Composer<_$DashboardDatabase, $LogStatisticsTable> {
  $$LogStatisticsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statType => $composableBuilder(
      column: $table.statType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statKey => $composableBuilder(
      column: $table.statKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get statValue => $composableBuilder(
      column: $table.statValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt, builder: (column) => ColumnFilters(column));
}

class $$LogStatisticsTableOrderingComposer
    extends Composer<_$DashboardDatabase, $LogStatisticsTable> {
  $$LogStatisticsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statType => $composableBuilder(
      column: $table.statType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statKey => $composableBuilder(
      column: $table.statKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get statValue => $composableBuilder(
      column: $table.statValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$LogStatisticsTableAnnotationComposer
    extends Composer<_$DashboardDatabase, $LogStatisticsTable> {
  $$LogStatisticsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get statType =>
      $composableBuilder(column: $table.statType, builder: (column) => column);

  GeneratedColumn<String> get statKey =>
      $composableBuilder(column: $table.statKey, builder: (column) => column);

  GeneratedColumn<int> get statValue =>
      $composableBuilder(column: $table.statValue, builder: (column) => column);

  GeneratedColumn<int> get calculatedAt => $composableBuilder(
      column: $table.calculatedAt, builder: (column) => column);
}

class $$LogStatisticsTableTableManager extends RootTableManager<
    _$DashboardDatabase,
    $LogStatisticsTable,
    LogStatData,
    $$LogStatisticsTableFilterComposer,
    $$LogStatisticsTableOrderingComposer,
    $$LogStatisticsTableAnnotationComposer,
    $$LogStatisticsTableCreateCompanionBuilder,
    $$LogStatisticsTableUpdateCompanionBuilder,
    (
      LogStatData,
      BaseReferences<_$DashboardDatabase, $LogStatisticsTable, LogStatData>
    ),
    LogStatData,
    PrefetchHooks Function()> {
  $$LogStatisticsTableTableManager(
      _$DashboardDatabase db, $LogStatisticsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogStatisticsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogStatisticsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogStatisticsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> statType = const Value.absent(),
            Value<String> statKey = const Value.absent(),
            Value<int> statValue = const Value.absent(),
            Value<int> calculatedAt = const Value.absent(),
          }) =>
              LogStatisticsCompanion(
            id: id,
            statType: statType,
            statKey: statKey,
            statValue: statValue,
            calculatedAt: calculatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String statType,
            required String statKey,
            required int statValue,
            required int calculatedAt,
          }) =>
              LogStatisticsCompanion.insert(
            id: id,
            statType: statType,
            statKey: statKey,
            statValue: statValue,
            calculatedAt: calculatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LogStatisticsTableProcessedTableManager = ProcessedTableManager<
    _$DashboardDatabase,
    $LogStatisticsTable,
    LogStatData,
    $$LogStatisticsTableFilterComposer,
    $$LogStatisticsTableOrderingComposer,
    $$LogStatisticsTableAnnotationComposer,
    $$LogStatisticsTableCreateCompanionBuilder,
    $$LogStatisticsTableUpdateCompanionBuilder,
    (
      LogStatData,
      BaseReferences<_$DashboardDatabase, $LogStatisticsTable, LogStatData>
    ),
    LogStatData,
    PrefetchHooks Function()>;
typedef $$DashboardSettingsTableCreateCompanionBuilder
    = DashboardSettingsCompanion Function({
  Value<int> id,
  required String settingKey,
  required String settingValue,
  required int updatedAt,
});
typedef $$DashboardSettingsTableUpdateCompanionBuilder
    = DashboardSettingsCompanion Function({
  Value<int> id,
  Value<String> settingKey,
  Value<String> settingValue,
  Value<int> updatedAt,
});

class $$DashboardSettingsTableFilterComposer
    extends Composer<_$DashboardDatabase, $DashboardSettingsTable> {
  $$DashboardSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingValue => $composableBuilder(
      column: $table.settingValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DashboardSettingsTableOrderingComposer
    extends Composer<_$DashboardDatabase, $DashboardSettingsTable> {
  $$DashboardSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingValue => $composableBuilder(
      column: $table.settingValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DashboardSettingsTableAnnotationComposer
    extends Composer<_$DashboardDatabase, $DashboardSettingsTable> {
  $$DashboardSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get settingKey => $composableBuilder(
      column: $table.settingKey, builder: (column) => column);

  GeneratedColumn<String> get settingValue => $composableBuilder(
      column: $table.settingValue, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DashboardSettingsTableTableManager extends RootTableManager<
    _$DashboardDatabase,
    $DashboardSettingsTable,
    DashboardSettingData,
    $$DashboardSettingsTableFilterComposer,
    $$DashboardSettingsTableOrderingComposer,
    $$DashboardSettingsTableAnnotationComposer,
    $$DashboardSettingsTableCreateCompanionBuilder,
    $$DashboardSettingsTableUpdateCompanionBuilder,
    (
      DashboardSettingData,
      BaseReferences<_$DashboardDatabase, $DashboardSettingsTable,
          DashboardSettingData>
    ),
    DashboardSettingData,
    PrefetchHooks Function()> {
  $$DashboardSettingsTableTableManager(
      _$DashboardDatabase db, $DashboardSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DashboardSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DashboardSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DashboardSettingsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> settingKey = const Value.absent(),
            Value<String> settingValue = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
          }) =>
              DashboardSettingsCompanion(
            id: id,
            settingKey: settingKey,
            settingValue: settingValue,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String settingKey,
            required String settingValue,
            required int updatedAt,
          }) =>
              DashboardSettingsCompanion.insert(
            id: id,
            settingKey: settingKey,
            settingValue: settingValue,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DashboardSettingsTableProcessedTableManager = ProcessedTableManager<
    _$DashboardDatabase,
    $DashboardSettingsTable,
    DashboardSettingData,
    $$DashboardSettingsTableFilterComposer,
    $$DashboardSettingsTableOrderingComposer,
    $$DashboardSettingsTableAnnotationComposer,
    $$DashboardSettingsTableCreateCompanionBuilder,
    $$DashboardSettingsTableUpdateCompanionBuilder,
    (
      DashboardSettingData,
      BaseReferences<_$DashboardDatabase, $DashboardSettingsTable,
          DashboardSettingData>
    ),
    DashboardSettingData,
    PrefetchHooks Function()>;

class $DashboardDatabaseManager {
  final _$DashboardDatabase _db;
  $DashboardDatabaseManager(this._db);
  $$LogEntriesTableTableManager get logEntries =>
      $$LogEntriesTableTableManager(_db, _db.logEntries);
  $$LogStatisticsTableTableManager get logStatistics =>
      $$LogStatisticsTableTableManager(_db, _db.logStatistics);
  $$DashboardSettingsTableTableManager get dashboardSettings =>
      $$DashboardSettingsTableTableManager(_db, _db.dashboardSettings);
}
