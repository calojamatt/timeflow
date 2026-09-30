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

/// The application database.
@DriftDatabase(tables: [WorkSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // At most one open session at a time (partial unique index).
      await customStatement(
        'CREATE UNIQUE INDEX ux_one_open_session '
        'ON work_sessions ((ended_at_utc IS NULL)) '
        'WHERE ended_at_utc IS NULL',
      );
    },
  );

  static QueryExecutor _openConnection() => driftDatabase(name: 'timeflow');
}
