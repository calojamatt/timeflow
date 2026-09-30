import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// The application database.
///
/// Tables are added incrementally as the domain grows (Phase 1 adds
/// `work_session`). The [forTesting] constructor allows tests to inject an
/// in-memory executor so no real database is touched.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => driftDatabase(name: 'timeflow');
}
