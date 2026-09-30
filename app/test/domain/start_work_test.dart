import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';
import 'package:timeflow/domain/start_work.dart';

import '../helpers/fake_clock.dart';
import '../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late DriftWorkSessionRepository repo;
  late FakeClock clock;
  late StartWork startWork;

  setUp(() {
    db = openInMemoryDatabase();
    repo = DriftWorkSessionRepository(db);
    clock = FakeClock(DateTime.utc(2026, 1, 1, 9));
    startWork = StartWork(clock, repo);
  });

  tearDown(() async {
    await db.close();
  });

  test('starts a new open session at the current time', () async {
    final session = await startWork();

    expect(session.isOpen, isTrue);
    expect(session.startedAtUtc, DateTime.utc(2026, 1, 1, 9));

    final open = await repo.findOpen();
    expect(open, isNotNull);
    expect(open!.id, session.id);
  });

  test('persists the session immediately (findable without re-open)', () async {
    final session = await startWork();

    expect(await repo.findOpen(), isNotNull);
    expect((await repo.getByDay(session.localDay)).single.id, session.id);
  });

  test('throws when a session is already open', () async {
    await startWork();

    await expectLater(startWork(), throwsStateError);
  });
}
