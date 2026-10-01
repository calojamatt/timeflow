import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';

void main() {
  test(
    'an open session survives a database close/reopen (app restart)',
    () async {
      final dir = await Directory.systemTemp.createTemp('timeflow_recovery');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/timeflow.db');

      final startedAt = DateTime.utc(2026, 1, 1, 9);

      final firstDb = AppDatabase.forTesting(NativeDatabase(file));
      final firstRepo = DriftWorkSessionRepository(firstDb);
      await firstRepo.start(startedAtUtc: startedAt, localDay: 20454);
      await firstDb.close();

      final secondDb = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(secondDb.close);
      final secondRepo = DriftWorkSessionRepository(secondDb);
      final open = await secondRepo.findOpen();

      expect(open, isNotNull);
      expect(open!.startedAtUtc, startedAt);
      expect(
        open.elapsedAt(DateTime.utc(2026, 1, 1, 11, 30)),
        const Duration(hours: 2, minutes: 30),
      );
    },
  );
}
