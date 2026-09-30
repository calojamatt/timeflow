import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';
import 'package:timeflow/domain/start_work.dart';
import 'package:timeflow/domain/stop_work.dart';

import '../helpers/fake_clock.dart';
import '../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late DriftWorkSessionRepository repo;
  late FakeClock clock;
  late StartWork startWork;
  late StopWork stopWork;

  setUp(() {
    db = openInMemoryDatabase();
    repo = DriftWorkSessionRepository(db);
    clock = FakeClock(DateTime.utc(2026, 1, 1, 9));
    startWork = StartWork(clock, repo);
    stopWork = StopWork(clock, repo);
  });

  tearDown(() async {
    await db.close();
  });

  test('stops the open session and sets ended_at', () async {
    final started = await startWork();
    clock.advance(const Duration(hours: 8));

    final stopped = await stopWork();

    expect(stopped.id, started.id);
    expect(stopped.isOpen, isFalse);
    expect(stopped.endedAtUtc, DateTime.utc(2026, 1, 1, 17));
    expect(stopped.elapsedAt(stopped.endedAtUtc!), const Duration(hours: 8));

    expect(await repo.findOpen(), isNull);
  });

  test('throws when no session is open', () async {
    await expectLater(stopWork(), throwsStateError);
  });
}
