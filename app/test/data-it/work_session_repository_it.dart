import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';

import '../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late DriftWorkSessionRepository repo;

  setUp(() {
    db = openInMemoryDatabase();
    repo = DriftWorkSessionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  final start = DateTime.utc(2026, 1, 1, 9);

  test('start creates and persists an open session', () async {
    final session = await repo.start(startedAtUtc: start, localDay: 20454);

    expect(session.isOpen, isTrue);
    expect(session.startedAtUtc, start);
    expect(session.id, isNotEmpty);

    final open = await repo.findOpen();
    expect(open, isNotNull);
    expect(open!.id, session.id);
  });

  test('findOpen returns null when no session is open', () async {
    expect(await repo.findOpen(), isNull);
  });

  test('stop closes the open session and persists it', () async {
    final session = await repo.start(startedAtUtc: start, localDay: 20454);
    final end = start.add(const Duration(hours: 8));

    final closed = await repo.stop(session.id, endedAtUtc: end);

    expect(closed.isOpen, isFalse);
    expect(closed.endedAtUtc, end);
    expect(await repo.findOpen(), isNull);
  });

  test('stop throws for an unknown id', () async {
    await expectLater(
      repo.stop('unknown', endedAtUtc: start.add(const Duration(hours: 1))),
      throwsStateError,
    );
  });

  test(
    'getByDay returns sessions for that day ordered by start time',
    () async {
      final s1 = await repo.start(startedAtUtc: start, localDay: 20454);
      await repo.stop(s1.id, endedAtUtc: start.add(const Duration(hours: 4)));

      final s2 = await repo.start(
        startedAtUtc: start.add(const Duration(hours: 6)),
        localDay: 20454,
      );
      await repo.stop(s2.id, endedAtUtc: start.add(const Duration(hours: 8)));

      final s3 = await repo.start(startedAtUtc: start, localDay: 20455);
      await repo.stop(s3.id, endedAtUtc: start.add(const Duration(hours: 4)));

      final sessions = await repo.getByDay(20454);

      expect(sessions, hasLength(2));
      expect(sessions[0].startedAtUtc, start);
      expect(sessions[1].startedAtUtc, start.add(const Duration(hours: 6)));
    },
  );

  test('getByDay returns an empty list for a day with no sessions', () async {
    expect(await repo.getByDay(20454), isEmpty);
  });

  test('start persists the optional note', () async {
    await repo.start(startedAtUtc: start, localDay: 20454, note: 'Deep focus');

    final open = await repo.findOpen();
    expect(open!.note, 'Deep focus');
  });

  test('full lifecycle: start, read, stop, and query by day', () async {
    final started = await repo.start(
      startedAtUtc: start,
      localDay: 20454,
      note: 'Ship it',
    );

    final open = await repo.findOpen();
    expect(open, isNotNull);
    expect(open!.id, started.id);
    expect(open.isOpen, isTrue);

    final end = start.add(const Duration(hours: 7, minutes: 30));
    await repo.stop(started.id, endedAtUtc: end);

    expect(await repo.findOpen(), isNull);

    final day = await repo.getByDay(20454);
    expect(day, hasLength(1));
    expect(day.single.id, started.id);
    expect(day.single.startedAtUtc, start);
    expect(day.single.endedAtUtc, end);
    expect(day.single.localDay, 20454);
    expect(day.single.note, 'Ship it');
  });
}
