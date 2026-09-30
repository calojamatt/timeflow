import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/app_database.dart';

import '../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = openInMemoryDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  WorkSessionRow openRow({String id = 'a'}) => WorkSessionRow(
    id: id,
    startedAtUtc: DateTime.utc(2026, 1, 1, 9),
    endedAtUtc: null,
    localDay: 20454,
    note: null,
  );

  WorkSessionRow closedRow({String id = 'a'}) => WorkSessionRow(
    id: id,
    startedAtUtc: DateTime.utc(2026, 1, 1, 9),
    endedAtUtc: DateTime.utc(2026, 1, 1, 13),
    localDay: 20454,
    note: null,
  );

  test('inserts and reads a work session row', () async {
    await db.into(db.workSessions).insert(openRow());

    final rows = await db.select(db.workSessions).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'a');
    expect(rows.single.endedAtUtc, isNull);
    expect(rows.single.localDay, 20454);
  });

  test('rejects a second open session at the DB level', () async {
    await db.into(db.workSessions).insert(openRow(id: 'a'));

    await expectLater(
      db.into(db.workSessions).insert(openRow(id: 'b')),
      throwsA(anything),
    );

    final rows = await db.select(db.workSessions).get();
    expect(rows, hasLength(1));
    expect(rows.single.id, 'a');
  });

  test('allows multiple closed sessions', () async {
    await db.into(db.workSessions).insert(closedRow(id: 'a'));
    await db.into(db.workSessions).insert(closedRow(id: 'b'));

    final rows = await db.select(db.workSessions).get();
    expect(rows, hasLength(2));
  });

  test('allows one open session alongside closed sessions', () async {
    await db.into(db.workSessions).insert(openRow(id: 'open'));
    await db.into(db.workSessions).insert(closedRow(id: 'closed'));

    final rows = await db.select(db.workSessions).get();
    expect(rows, hasLength(2));
  });
}
