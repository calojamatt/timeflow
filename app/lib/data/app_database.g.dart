// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WorkSessionsTable extends WorkSessions
    with TableInfo<$WorkSessionsTable, WorkSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtUtcMeta = const VerificationMeta(
    'startedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> startedAtUtc = GeneratedColumn<DateTime>(
    'started_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtUtcMeta = const VerificationMeta(
    'endedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> endedAtUtc = GeneratedColumn<DateTime>(
    'ended_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localDayMeta = const VerificationMeta(
    'localDay',
  );
  @override
  late final GeneratedColumn<int> localDay = GeneratedColumn<int>(
    'local_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAtUtc,
    endedAtUtc,
    localDay,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'work_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at_utc')) {
      context.handle(
        _startedAtUtcMeta,
        startedAtUtc.isAcceptableOrUnknown(
          data['started_at_utc']!,
          _startedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtUtcMeta);
    }
    if (data.containsKey('ended_at_utc')) {
      context.handle(
        _endedAtUtcMeta,
        endedAtUtc.isAcceptableOrUnknown(
          data['ended_at_utc']!,
          _endedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('local_day')) {
      context.handle(
        _localDayMeta,
        localDay.isAcceptableOrUnknown(data['local_day']!, _localDayMeta),
      );
    } else if (isInserting) {
      context.missing(_localDayMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at_utc'],
      )!,
      endedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at_utc'],
      ),
      localDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_day'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WorkSessionsTable createAlias(String alias) {
    return $WorkSessionsTable(attachedDatabase, alias);
  }
}

class WorkSessionRow extends DataClass implements Insertable<WorkSessionRow> {
  final String id;
  final DateTime startedAtUtc;
  final DateTime? endedAtUtc;
  final int localDay;
  final String? note;
  const WorkSessionRow({
    required this.id,
    required this.startedAtUtc,
    this.endedAtUtc,
    required this.localDay,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at_utc'] = Variable<DateTime>(startedAtUtc);
    if (!nullToAbsent || endedAtUtc != null) {
      map['ended_at_utc'] = Variable<DateTime>(endedAtUtc);
    }
    map['local_day'] = Variable<int>(localDay);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WorkSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkSessionsCompanion(
      id: Value(id),
      startedAtUtc: Value(startedAtUtc),
      endedAtUtc: endedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAtUtc),
      localDay: Value(localDay),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WorkSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkSessionRow(
      id: serializer.fromJson<String>(json['id']),
      startedAtUtc: serializer.fromJson<DateTime>(json['startedAtUtc']),
      endedAtUtc: serializer.fromJson<DateTime?>(json['endedAtUtc']),
      localDay: serializer.fromJson<int>(json['localDay']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAtUtc': serializer.toJson<DateTime>(startedAtUtc),
      'endedAtUtc': serializer.toJson<DateTime?>(endedAtUtc),
      'localDay': serializer.toJson<int>(localDay),
      'note': serializer.toJson<String?>(note),
    };
  }

  WorkSessionRow copyWith({
    String? id,
    DateTime? startedAtUtc,
    Value<DateTime?> endedAtUtc = const Value.absent(),
    int? localDay,
    Value<String?> note = const Value.absent(),
  }) => WorkSessionRow(
    id: id ?? this.id,
    startedAtUtc: startedAtUtc ?? this.startedAtUtc,
    endedAtUtc: endedAtUtc.present ? endedAtUtc.value : this.endedAtUtc,
    localDay: localDay ?? this.localDay,
    note: note.present ? note.value : this.note,
  );
  WorkSessionRow copyWithCompanion(WorkSessionsCompanion data) {
    return WorkSessionRow(
      id: data.id.present ? data.id.value : this.id,
      startedAtUtc: data.startedAtUtc.present
          ? data.startedAtUtc.value
          : this.startedAtUtc,
      endedAtUtc: data.endedAtUtc.present
          ? data.endedAtUtc.value
          : this.endedAtUtc,
      localDay: data.localDay.present ? data.localDay.value : this.localDay,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkSessionRow(')
          ..write('id: $id, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc, ')
          ..write('localDay: $localDay, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startedAtUtc, endedAtUtc, localDay, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkSessionRow &&
          other.id == this.id &&
          other.startedAtUtc == this.startedAtUtc &&
          other.endedAtUtc == this.endedAtUtc &&
          other.localDay == this.localDay &&
          other.note == this.note);
}

class WorkSessionsCompanion extends UpdateCompanion<WorkSessionRow> {
  final Value<String> id;
  final Value<DateTime> startedAtUtc;
  final Value<DateTime?> endedAtUtc;
  final Value<int> localDay;
  final Value<String?> note;
  final Value<int> rowid;
  const WorkSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAtUtc = const Value.absent(),
    this.endedAtUtc = const Value.absent(),
    this.localDay = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkSessionsCompanion.insert({
    required String id,
    required DateTime startedAtUtc,
    this.endedAtUtc = const Value.absent(),
    required int localDay,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAtUtc = Value(startedAtUtc),
       localDay = Value(localDay);
  static Insertable<WorkSessionRow> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAtUtc,
    Expression<DateTime>? endedAtUtc,
    Expression<int>? localDay,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAtUtc != null) 'started_at_utc': startedAtUtc,
      if (endedAtUtc != null) 'ended_at_utc': endedAtUtc,
      if (localDay != null) 'local_day': localDay,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkSessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAtUtc,
    Value<DateTime?>? endedAtUtc,
    Value<int>? localDay,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return WorkSessionsCompanion(
      id: id ?? this.id,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      endedAtUtc: endedAtUtc ?? this.endedAtUtc,
      localDay: localDay ?? this.localDay,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAtUtc.present) {
      map['started_at_utc'] = Variable<DateTime>(startedAtUtc.value);
    }
    if (endedAtUtc.present) {
      map['ended_at_utc'] = Variable<DateTime>(endedAtUtc.value);
    }
    if (localDay.present) {
      map['local_day'] = Variable<int>(localDay.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAtUtc: $startedAtUtc, ')
          ..write('endedAtUtc: $endedAtUtc, ')
          ..write('localDay: $localDay, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlannedBlocksTable extends PlannedBlocks
    with TableInfo<$PlannedBlocksTable, PlannedBlockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDayMeta = const VerificationMeta(
    'localDay',
  );
  @override
  late final GeneratedColumn<int> localDay = GeneratedColumn<int>(
    'local_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localDay,
    startMinute,
    endMinute,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlannedBlockRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_day')) {
      context.handle(
        _localDayMeta,
        localDay.isAcceptableOrUnknown(data['local_day']!, _localDayMeta),
      );
    } else if (isInserting) {
      context.missing(_localDayMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedBlockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedBlockRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_day'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PlannedBlocksTable createAlias(String alias) {
    return $PlannedBlocksTable(attachedDatabase, alias);
  }
}

class PlannedBlockRow extends DataClass implements Insertable<PlannedBlockRow> {
  final String id;
  final int localDay;
  final int startMinute;
  final int endMinute;
  final String? note;
  const PlannedBlockRow({
    required this.id,
    required this.localDay,
    required this.startMinute,
    required this.endMinute,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_day'] = Variable<int>(localDay);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_minute'] = Variable<int>(endMinute);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PlannedBlocksCompanion toCompanion(bool nullToAbsent) {
    return PlannedBlocksCompanion(
      id: Value(id),
      localDay: Value(localDay),
      startMinute: Value(startMinute),
      endMinute: Value(endMinute),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory PlannedBlockRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedBlockRow(
      id: serializer.fromJson<String>(json['id']),
      localDay: serializer.fromJson<int>(json['localDay']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localDay': serializer.toJson<int>(localDay),
      'startMinute': serializer.toJson<int>(startMinute),
      'endMinute': serializer.toJson<int>(endMinute),
      'note': serializer.toJson<String?>(note),
    };
  }

  PlannedBlockRow copyWith({
    String? id,
    int? localDay,
    int? startMinute,
    int? endMinute,
    Value<String?> note = const Value.absent(),
  }) => PlannedBlockRow(
    id: id ?? this.id,
    localDay: localDay ?? this.localDay,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    note: note.present ? note.value : this.note,
  );
  PlannedBlockRow copyWithCompanion(PlannedBlocksCompanion data) {
    return PlannedBlockRow(
      id: data.id.present ? data.id.value : this.id,
      localDay: data.localDay.present ? data.localDay.value : this.localDay,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedBlockRow(')
          ..write('id: $id, ')
          ..write('localDay: $localDay, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, localDay, startMinute, endMinute, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedBlockRow &&
          other.id == this.id &&
          other.localDay == this.localDay &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.note == this.note);
}

class PlannedBlocksCompanion extends UpdateCompanion<PlannedBlockRow> {
  final Value<String> id;
  final Value<int> localDay;
  final Value<int> startMinute;
  final Value<int> endMinute;
  final Value<String?> note;
  final Value<int> rowid;
  const PlannedBlocksCompanion({
    this.id = const Value.absent(),
    this.localDay = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlannedBlocksCompanion.insert({
    required String id,
    required int localDay,
    required int startMinute,
    required int endMinute,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       localDay = Value(localDay),
       startMinute = Value(startMinute),
       endMinute = Value(endMinute);
  static Insertable<PlannedBlockRow> custom({
    Expression<String>? id,
    Expression<int>? localDay,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localDay != null) 'local_day': localDay,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlannedBlocksCompanion copyWith({
    Value<String>? id,
    Value<int>? localDay,
    Value<int>? startMinute,
    Value<int>? endMinute,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return PlannedBlocksCompanion(
      id: id ?? this.id,
      localDay: localDay ?? this.localDay,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localDay.present) {
      map['local_day'] = Variable<int>(localDay.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedBlocksCompanion(')
          ..write('id: $id, ')
          ..write('localDay: $localDay, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeeklyTemplatesTable extends WeeklyTemplates
    with TableInfo<$WeeklyTemplatesTable, WeeklyTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMinuteMeta = const VerificationMeta(
    'endMinute',
  );
  @override
  late final GeneratedColumn<int> endMinute = GeneratedColumn<int>(
    'end_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    weekday,
    startMinute,
    endMinute,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyTemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('end_minute')) {
      context.handle(
        _endMinuteMeta,
        endMinute.isAcceptableOrUnknown(data['end_minute']!, _endMinuteMeta),
      );
    } else if (isInserting) {
      context.missing(_endMinuteMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeeklyTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyTemplateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      endMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minute'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WeeklyTemplatesTable createAlias(String alias) {
    return $WeeklyTemplatesTable(attachedDatabase, alias);
  }
}

class WeeklyTemplateRow extends DataClass
    implements Insertable<WeeklyTemplateRow> {
  final String id;
  final String name;
  final int weekday;
  final int startMinute;
  final int endMinute;
  final String? note;
  const WeeklyTemplateRow({
    required this.id,
    required this.name,
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['weekday'] = Variable<int>(weekday);
    map['start_minute'] = Variable<int>(startMinute);
    map['end_minute'] = Variable<int>(endMinute);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WeeklyTemplatesCompanion toCompanion(bool nullToAbsent) {
    return WeeklyTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      weekday: Value(weekday),
      startMinute: Value(startMinute),
      endMinute: Value(endMinute),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WeeklyTemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyTemplateRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      weekday: serializer.fromJson<int>(json['weekday']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      endMinute: serializer.fromJson<int>(json['endMinute']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'weekday': serializer.toJson<int>(weekday),
      'startMinute': serializer.toJson<int>(startMinute),
      'endMinute': serializer.toJson<int>(endMinute),
      'note': serializer.toJson<String?>(note),
    };
  }

  WeeklyTemplateRow copyWith({
    String? id,
    String? name,
    int? weekday,
    int? startMinute,
    int? endMinute,
    Value<String?> note = const Value.absent(),
  }) => WeeklyTemplateRow(
    id: id ?? this.id,
    name: name ?? this.name,
    weekday: weekday ?? this.weekday,
    startMinute: startMinute ?? this.startMinute,
    endMinute: endMinute ?? this.endMinute,
    note: note.present ? note.value : this.note,
  );
  WeeklyTemplateRow copyWithCompanion(WeeklyTemplatesCompanion data) {
    return WeeklyTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      endMinute: data.endMinute.present ? data.endMinute.value : this.endMinute,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyTemplateRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weekday: $weekday, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, weekday, startMinute, endMinute, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyTemplateRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.weekday == this.weekday &&
          other.startMinute == this.startMinute &&
          other.endMinute == this.endMinute &&
          other.note == this.note);
}

class WeeklyTemplatesCompanion extends UpdateCompanion<WeeklyTemplateRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> weekday;
  final Value<int> startMinute;
  final Value<int> endMinute;
  final Value<String?> note;
  final Value<int> rowid;
  const WeeklyTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.weekday = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.endMinute = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeeklyTemplatesCompanion.insert({
    required String id,
    required String name,
    required int weekday,
    required int startMinute,
    required int endMinute,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       weekday = Value(weekday),
       startMinute = Value(startMinute),
       endMinute = Value(endMinute);
  static Insertable<WeeklyTemplateRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? weekday,
    Expression<int>? startMinute,
    Expression<int>? endMinute,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (weekday != null) 'weekday': weekday,
      if (startMinute != null) 'start_minute': startMinute,
      if (endMinute != null) 'end_minute': endMinute,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeeklyTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? weekday,
    Value<int>? startMinute,
    Value<int>? endMinute,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return WeeklyTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      weekday: weekday ?? this.weekday,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (endMinute.present) {
      map['end_minute'] = Variable<int>(endMinute.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weekday: $weekday, ')
          ..write('startMinute: $startMinute, ')
          ..write('endMinute: $endMinute, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkSessionsTable workSessions = $WorkSessionsTable(this);
  late final $PlannedBlocksTable plannedBlocks = $PlannedBlocksTable(this);
  late final $WeeklyTemplatesTable weeklyTemplates = $WeeklyTemplatesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workSessions,
    plannedBlocks,
    weeklyTemplates,
  ];
}

typedef $$WorkSessionsTableCreateCompanionBuilder =
    WorkSessionsCompanion Function({
      required String id,
      required DateTime startedAtUtc,
      Value<DateTime?> endedAtUtc,
      required int localDay,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$WorkSessionsTableUpdateCompanionBuilder =
    WorkSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> startedAtUtc,
      Value<DateTime?> endedAtUtc,
      Value<int> localDay,
      Value<String?> note,
      Value<int> rowid,
    });

class $$WorkSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkSessionsTable> {
  $$WorkSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAtUtc => $composableBuilder(
    column: $table.startedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAtUtc => $composableBuilder(
    column: $table.endedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localDay =>
      $composableBuilder(column: $table.localDay, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$WorkSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkSessionsTable,
          WorkSessionRow,
          $$WorkSessionsTableFilterComposer,
          $$WorkSessionsTableOrderingComposer,
          $$WorkSessionsTableAnnotationComposer,
          $$WorkSessionsTableCreateCompanionBuilder,
          $$WorkSessionsTableUpdateCompanionBuilder,
          (
            WorkSessionRow,
            BaseReferences<_$AppDatabase, $WorkSessionsTable, WorkSessionRow>,
          ),
          WorkSessionRow,
          PrefetchHooks Function()
        > {
  $$WorkSessionsTableTableManager(_$AppDatabase db, $WorkSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAtUtc = const Value.absent(),
                Value<DateTime?> endedAtUtc = const Value.absent(),
                Value<int> localDay = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkSessionsCompanion(
                id: id,
                startedAtUtc: startedAtUtc,
                endedAtUtc: endedAtUtc,
                localDay: localDay,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAtUtc,
                Value<DateTime?> endedAtUtc = const Value.absent(),
                required int localDay,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkSessionsCompanion.insert(
                id: id,
                startedAtUtc: startedAtUtc,
                endedAtUtc: endedAtUtc,
                localDay: localDay,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkSessionsTable, WorkSessionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkSessionsTable,
                    WorkSessionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkSessionsTable,
      WorkSessionRow,
      $$WorkSessionsTableFilterComposer,
      $$WorkSessionsTableOrderingComposer,
      $$WorkSessionsTableAnnotationComposer,
      $$WorkSessionsTableCreateCompanionBuilder,
      $$WorkSessionsTableUpdateCompanionBuilder,
      (
        WorkSessionRow,
        BaseReferences<_$AppDatabase, $WorkSessionsTable, WorkSessionRow>,
      ),
      WorkSessionRow,
      PrefetchHooks Function()
    >;
typedef $$PlannedBlocksTableCreateCompanionBuilder =
    PlannedBlocksCompanion Function({
      required String id,
      required int localDay,
      required int startMinute,
      required int endMinute,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$PlannedBlocksTableUpdateCompanionBuilder =
    PlannedBlocksCompanion Function({
      Value<String> id,
      Value<int> localDay,
      Value<int> startMinute,
      Value<int> endMinute,
      Value<String?> note,
      Value<int> rowid,
    });

class $$PlannedBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $PlannedBlocksTable> {
  $$PlannedBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlannedBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $PlannedBlocksTable> {
  $$PlannedBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlannedBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlannedBlocksTable> {
  $$PlannedBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get localDay =>
      $composableBuilder(column: $table.localDay, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$PlannedBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlannedBlocksTable,
          PlannedBlockRow,
          $$PlannedBlocksTableFilterComposer,
          $$PlannedBlocksTableOrderingComposer,
          $$PlannedBlocksTableAnnotationComposer,
          $$PlannedBlocksTableCreateCompanionBuilder,
          $$PlannedBlocksTableUpdateCompanionBuilder,
          (
            PlannedBlockRow,
            BaseReferences<_$AppDatabase, $PlannedBlocksTable, PlannedBlockRow>,
          ),
          PlannedBlockRow,
          PrefetchHooks Function()
        > {
  $$PlannedBlocksTableTableManager(_$AppDatabase db, $PlannedBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlannedBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> localDay = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> endMinute = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlannedBlocksCompanion(
                id: id,
                localDay: localDay,
                startMinute: startMinute,
                endMinute: endMinute,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int localDay,
                required int startMinute,
                required int endMinute,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlannedBlocksCompanion.insert(
                id: id,
                localDay: localDay,
                startMinute: startMinute,
                endMinute: endMinute,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlannedBlocksTable, PlannedBlockRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlannedBlocksTable,
                    PlannedBlockRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlannedBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlannedBlocksTable,
      PlannedBlockRow,
      $$PlannedBlocksTableFilterComposer,
      $$PlannedBlocksTableOrderingComposer,
      $$PlannedBlocksTableAnnotationComposer,
      $$PlannedBlocksTableCreateCompanionBuilder,
      $$PlannedBlocksTableUpdateCompanionBuilder,
      (
        PlannedBlockRow,
        BaseReferences<_$AppDatabase, $PlannedBlocksTable, PlannedBlockRow>,
      ),
      PlannedBlockRow,
      PrefetchHooks Function()
    >;
typedef $$WeeklyTemplatesTableCreateCompanionBuilder =
    WeeklyTemplatesCompanion Function({
      required String id,
      required String name,
      required int weekday,
      required int startMinute,
      required int endMinute,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$WeeklyTemplatesTableUpdateCompanionBuilder =
    WeeklyTemplatesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> weekday,
      Value<int> startMinute,
      Value<int> endMinute,
      Value<String?> note,
      Value<int> rowid,
    });

class $$WeeklyTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyTemplatesTable> {
  $$WeeklyTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeeklyTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyTemplatesTable> {
  $$WeeklyTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinute => $composableBuilder(
    column: $table.endMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklyTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyTemplatesTable> {
  $$WeeklyTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinute =>
      $composableBuilder(column: $table.endMinute, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$WeeklyTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklyTemplatesTable,
          WeeklyTemplateRow,
          $$WeeklyTemplatesTableFilterComposer,
          $$WeeklyTemplatesTableOrderingComposer,
          $$WeeklyTemplatesTableAnnotationComposer,
          $$WeeklyTemplatesTableCreateCompanionBuilder,
          $$WeeklyTemplatesTableUpdateCompanionBuilder,
          (
            WeeklyTemplateRow,
            BaseReferences<
              _$AppDatabase,
              $WeeklyTemplatesTable,
              WeeklyTemplateRow
            >,
          ),
          WeeklyTemplateRow,
          PrefetchHooks Function()
        > {
  $$WeeklyTemplatesTableTableManager(
    _$AppDatabase db,
    $WeeklyTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> endMinute = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeeklyTemplatesCompanion(
                id: id,
                name: name,
                weekday: weekday,
                startMinute: startMinute,
                endMinute: endMinute,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int weekday,
                required int startMinute,
                required int endMinute,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeeklyTemplatesCompanion.insert(
                id: id,
                name: name,
                weekday: weekday,
                startMinute: startMinute,
                endMinute: endMinute,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeeklyTemplatesTable, WeeklyTemplateRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WeeklyTemplatesTable,
                    WeeklyTemplateRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeeklyTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklyTemplatesTable,
      WeeklyTemplateRow,
      $$WeeklyTemplatesTableFilterComposer,
      $$WeeklyTemplatesTableOrderingComposer,
      $$WeeklyTemplatesTableAnnotationComposer,
      $$WeeklyTemplatesTableCreateCompanionBuilder,
      $$WeeklyTemplatesTableUpdateCompanionBuilder,
      (
        WeeklyTemplateRow,
        BaseReferences<_$AppDatabase, $WeeklyTemplatesTable, WeeklyTemplateRow>,
      ),
      WeeklyTemplateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkSessionsTableTableManager get workSessions =>
      $$WorkSessionsTableTableManager(_db, _db.workSessions);
  $$PlannedBlocksTableTableManager get plannedBlocks =>
      $$PlannedBlocksTableTableManager(_db, _db.plannedBlocks);
  $$WeeklyTemplatesTableTableManager get weeklyTemplates =>
      $$WeeklyTemplatesTableTableManager(_db, _db.weeklyTemplates);
}
