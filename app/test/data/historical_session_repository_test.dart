import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/domain/work_session.dart';

import '../helpers/in_memory_database.dart';

void main() {
  test(
    'updates a closed session and keeps its local-day bucket consistent',
    () async {
      final db = openInMemoryDatabase();
      addTearDown(db.close);
      final repository = DriftWorkSessionRepository(db);
      final start = DateTime(2026, 1, 5, 9).toUtc();
      final original = await repository.start(
        startedAtUtc: start,
        localDay: localDayFrom(start),
      );
      await repository.stop(
        original.id,
        endedAtUtc: DateTime(2026, 1, 5, 10).toUtc(),
      );

      final updatedStart = DateTime(2026, 1, 5, 8, 30).toUtc();
      final updated = await repository.updateHistorical(
        WorkSession(
          id: original.id,
          startedAtUtc: updatedStart,
          endedAtUtc: DateTime(2026, 1, 5, 10, 30).toUtc(),
          localDay: localDayFrom(updatedStart),
          note: 'Corrected entry',
        ),
      );

      expect(updated.startedAtUtc, updatedStart);
      expect(updated.note, 'Corrected entry');
      final stored = (await repository.getByDay(updated.localDay)).single;
      expect(stored.startedAtUtc, updated.startedAtUtc);
      expect(stored.endedAtUtc, updated.endedAtUtc);
      expect(stored.note, updated.note);
    },
  );

  test('rejects overlapping edits without changing stored history', () async {
    final db = openInMemoryDatabase();
    addTearDown(db.close);
    final repository = DriftWorkSessionRepository(db);
    final start = DateTime(2026, 1, 5, 9).toUtc();
    final first = await repository.start(
      startedAtUtc: start,
      localDay: localDayFrom(start),
    );
    await repository.stop(
      first.id,
      endedAtUtc: DateTime(2026, 1, 5, 10).toUtc(),
    );
    final secondStart = DateTime(2026, 1, 5, 11).toUtc();
    final second = await repository.start(
      startedAtUtc: secondStart,
      localDay: localDayFrom(secondStart),
    );
    await repository.stop(
      second.id,
      endedAtUtc: DateTime(2026, 1, 5, 12).toUtc(),
    );

    await expectLater(
      repository.updateHistorical(
        WorkSession(
          id: first.id,
          startedAtUtc: start,
          endedAtUtc: DateTime(2026, 1, 5, 11, 30).toUtc(),
          localDay: localDayFrom(start),
        ),
      ),
      throwsStateError,
    );
    expect(
      (await repository.getByDay(localDayFrom(start))).first.endedAtUtc,
      DateTime(2026, 1, 5, 10).toUtc(),
    );
  });

  test('prevents editing or deleting open sessions', () async {
    final db = openInMemoryDatabase();
    addTearDown(db.close);
    final repository = DriftWorkSessionRepository(db);
    final start = DateTime(2026, 1, 5, 9).toUtc();
    final open = await repository.start(
      startedAtUtc: start,
      localDay: localDayFrom(start),
    );
    final fakeClosed = WorkSession(
      id: open.id,
      startedAtUtc: start,
      endedAtUtc: DateTime(2026, 1, 5, 10).toUtc(),
      localDay: open.localDay,
    );

    await expectLater(
      repository.updateHistorical(fakeClosed),
      throwsStateError,
    );
    await expectLater(repository.deleteHistorical(open.id), throwsStateError);
  });
}
