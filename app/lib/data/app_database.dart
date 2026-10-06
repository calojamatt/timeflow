import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Persisted form of a [WorkSession] (see `lib/domain/work_session.dart`).
@DataClassName('WorkSessionRow')
class WorkSessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAtUtc => dateTime()();
  DateTimeColumn get endedAtUtc => dateTime().nullable()();
  IntColumn get localDay => integer()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PlannedBlockRow')
class PlannedBlocks extends Table {
  TextColumn get id => text()();
  IntColumn get localDay => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endMinute => integer()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WeeklyTemplateRow')
class WeeklyTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get weekday => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endMinute => integer()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The application database.
@DriftDatabase(tables: [WorkSessions, PlannedBlocks, WeeklyTemplates])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(plannedBlocks);
        await m.createTable(weeklyTemplates);
        await _createPlanningIndexes();
      }
    },
  );

  Future<void> _createIndexes() async {
    // At most one open session at a time (partial unique index).
    await customStatement(
      'CREATE UNIQUE INDEX ux_one_open_session '
      'ON work_sessions ((ended_at_utc IS NULL)) '
      'WHERE ended_at_utc IS NULL',
    );
    await _createPlanningIndexes();
  }

  Future<void> _createPlanningIndexes() async {
    await customStatement(
      'CREATE INDEX ix_planned_blocks_local_day '
      'ON planned_blocks (local_day)',
    );
    await customStatement(
      'CREATE INDEX ix_weekly_templates_weekday '
      'ON weekly_templates (weekday)',
    );
  }

  static QueryExecutor _openConnection() => driftDatabase(name: 'timeflow');
}
