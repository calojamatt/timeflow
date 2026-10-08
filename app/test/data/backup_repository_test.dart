import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/drift_backup_repository.dart';
import 'package:timeflow/data/planning_repository_impl.dart';
import 'package:timeflow/data/reminder_preferences_repository_impl.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';
import 'package:timeflow/domain/backup_document.dart';
import 'package:timeflow/domain/reminder_preferences.dart';

import '../helpers/in_memory_database.dart';

void main() {
  test('round-trips every table through a versioned backup', () async {
    final source = openInMemoryDatabase();
    addTearDown(source.close);
    final sourceSessions = DriftWorkSessionRepository(source);
    final start = DateTime.utc(2026, 10, 8, 9);
    final session = await sourceSessions.start(
      startedAtUtc: start,
      localDay: 20734,
      note: 'Imported item',
    );
    await sourceSessions.stop(
      session.id,
      endedAtUtc: DateTime.utc(2026, 10, 8, 10),
    );
    final sourcePlanning = DriftPlanningRepository(source);
    await sourcePlanning.createPlannedBlock(
      localDay: 20734,
      startMinute: 11 * 60,
      endMinute: 12 * 60,
      note: 'Plan',
    );
    await sourcePlanning.createWeeklyTemplate(
      name: 'Standard',
      weekday: DateTime.thursday,
      startMinute: 9 * 60,
      endMinute: 17 * 60,
    );
    await DriftReminderPreferencesRepository(source).save(
      ReminderPreferences(
        enabled: false,
        shiftStartLeadMinutes: 20,
        forgottenSessionAfterMinutes: 45,
      ),
    );

    final backup = await DriftBackupRepository(source)
        .createBackup(exportedAtUtc: DateTime.utc(2026, 10, 8, 12));
    expect(jsonDecode(backup)['sourceSchemaVersion'], 3);
    await source.close();
    final target = openInMemoryDatabase();
    addTearDown(target.close);
    await DriftBackupRepository(target).restoreBackup(backup);

    expect(
      (await DriftWorkSessionRepository(target).getByDay(20734)).single.note,
      'Imported item',
    );
    expect(
      (await DriftPlanningRepository(target).getPlannedBlocksForDay(20734))
          .single
          .note,
      'Plan',
    );
    expect(
      (await DriftPlanningRepository(target).getWeeklyTemplates()).single.name,
      'Standard',
    );
    final preferences = await DriftReminderPreferencesRepository(target).get();
    expect(preferences.enabled, isFalse);
    expect(preferences.shiftStartLeadMinutes, 20);
    expect(preferences.forgottenSessionAfterMinutes, 45);
  });

  test('rejects a corrupt backup without changing existing data', () async {
    final db = openInMemoryDatabase();
    addTearDown(db.close);
    final sessions = DriftWorkSessionRepository(db);
    final start = DateTime.utc(2026, 10, 8, 9);
    await sessions.start(startedAtUtc: start, localDay: 20734);

    await expectLater(
      DriftBackupRepository(db).restoreBackup('{not json'),
      throwsFormatException,
    );
    expect((await sessions.getByDay(20734)).single.startedAtUtc, start);
  });

  test('restores schema-1 backups and applies compatible defaults', () async {
    final db = openInMemoryDatabase();
    addTearDown(db.close);
    final legacy = BackupDocument.parse('''
      {
        "format":"timeflow-backup",
        "formatVersion":1,
        "sourceSchemaVersion":1,
        "exportedAtUtc":"2026-10-08T12:00:00.000Z",
        "data":{"workSessions":[]}
      }
    ''').encode();

    await DriftBackupRepository(db).restoreBackup(legacy);
    expect((await DriftPlanningRepository(db).getWeeklyTemplates()), isEmpty);
    expect(
      (await DriftReminderPreferencesRepository(db).get()).enabled,
      isTrue,
    );
  });

  test('rolls back all table changes if any restore write fails', () async {
    final db = openInMemoryDatabase();
    addTearDown(db.close);
    final repository = DriftBackupRepository(db);
    final sessions = DriftWorkSessionRepository(db);
    final existingStart = DateTime.utc(2026, 10, 8, 8);
    final existing = await sessions.start(
      startedAtUtc: existingStart,
      localDay: 20734,
    );
    await sessions.stop(existing.id, endedAtUtc: DateTime.utc(2026, 10, 8, 9));

    await db.customStatement(
      "CREATE TRIGGER reject_backup_block BEFORE INSERT ON planned_blocks "
      "BEGIN SELECT RAISE(ABORT, 'simulated disk write failure'); END",
    );
    final document = BackupDocument.create(
      exportedAtUtc: DateTime.utc(2026, 10, 8, 12),
      sourceSchemaVersion: 3,
      workSessions: [
        {
          'id': 'replacement',
          'startedAtUtc': DateTime.utc(2026, 10, 8, 10).toIso8601String(),
          'endedAtUtc': DateTime.utc(2026, 10, 8, 11).toIso8601String(),
          'localDay': 20734,
          'note': null,
        },
      ],
      plannedBlocks: [
        {
          'id': 'plan',
          'localDay': 20734,
          'startMinute': 600,
          'endMinute': 660,
          'note': null,
        },
      ],
      weeklyTemplates: [],
      reminderPreferences: [
        {
          'id': 1,
          'enabled': false,
          'shiftStartLeadMinutes': 15,
          'forgottenSessionAfterMinutes': 30,
        },
      ],
    );

    await expectLater(
      repository.restoreBackup(document.encode()),
      throwsA(anything),
    );
    final restored = await sessions.getByDay(20734);
    expect(restored, hasLength(1));
    expect(restored.single.id, existing.id);
  });
}
