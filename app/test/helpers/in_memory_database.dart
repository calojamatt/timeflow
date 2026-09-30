import 'package:drift/native.dart';
import 'package:timeflow/data/app_database.dart';

/// Opens a [AppDatabase] backed by an in-memory SQLite database for tests.
///
/// No file is touched and each call returns a fresh, isolated database.
AppDatabase openInMemoryDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());
