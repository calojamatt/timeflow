import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/data/planning_repository_impl.dart';
import 'package:timeflow/data/reminder_preferences_repository_impl.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';
import 'package:timeflow/domain/backup_document.dart';
import 'package:timeflow/domain/backup_file_service.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/domain/reminder_preferences.dart';
import 'package:timeflow/domain/reminder_scheduler.dart';
import 'package:timeflow/main.dart';
import 'package:timeflow/presentation/app_router.dart';
import 'package:timeflow/presentation/providers.dart';

import '../helpers/fake_clock.dart';

void main() {
  testWidgets('creates a portable JSON backup through the file boundary', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.utc(2026, 10, 8, 12);
    final start = DateTime.utc(2026, 10, 8, 9);
    await DriftWorkSessionRepository(db)
        .start(startedAtUtc: start, localDay: localDayFrom(now));
    final files = _FakeBackupFileService();
    await _openBackup(tester, db, now, files);

    await tester.tap(find.byKey(const Key('create-backup')));
    await tester.pumpAndSettle();

    expect(find.text('Backup ready to save'), findsOneWidget);
    expect(files.sharedName, 'timeflow-backup-20261008-120000.json');
    final json = jsonDecode(files.sharedContent!) as Map<String, dynamic>;
    expect(json['format'], BackupDocument.formatName);
    expect((json['data']['workSessions'] as List).length, 1);
  });

  testWidgets('requires confirmation and restores selected backup', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime.utc(2026, 10, 8, 12);
    final oldStart = DateTime.utc(2026, 10, 8, 8);
    final repo = DriftWorkSessionRepository(db);
    await repo.start(startedAtUtc: oldStart, localDay: localDayFrom(now));
    final files = _FakeBackupFileService()
      ..pickedContent = BackupDocument.create(
        exportedAtUtc: now.toUtc(),
        sourceSchemaVersion: 3,
        workSessions: [
          {
            'id': 'restored-session',
            'startedAtUtc': DateTime.utc(2026, 10, 8, 9).toIso8601String(),
            'endedAtUtc': DateTime.utc(2026, 10, 8, 10).toIso8601String(),
            'localDay': localDayFrom(now),
            'note': 'From backup',
          },
        ],
        plannedBlocks: [],
        weeklyTemplates: [],
        reminderPreferences: [
          {
            'id': 1,
            'enabled': true,
            'shiftStartLeadMinutes': 15,
            'forgottenSessionAfterMinutes': 30,
          },
        ],
      ).encode();
    await _openBackup(tester, db, now, files);

    await tester.tap(find.byKey(const Key('restore-backup')));
    await tester.pumpAndSettle();
    expect(find.text('Replace local data?'), findsOneWidget);
    expect(
      (await repo.getByDay(localDayFrom(now))).single.id,
      isNot('restored-session'),
    );
    await tester.tap(find.text('Replace data'));
    await tester.pumpAndSettle();

    expect(find.text('Backup restored'), findsOneWidget);
    final restored = await repo.getByDay(localDayFrom(now));
    expect(restored, hasLength(1));
    expect(restored.single.id, 'restored-session');
  });

  testWidgets(
    'clear-data action requires confirmation and deletes every table',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final now = DateTime.utc(2026, 10, 8, 12);
      final day = localDayFrom(now);
      await DriftWorkSessionRepository(db).start(
        startedAtUtc: now.subtract(const Duration(hours: 2)),
        localDay: day,
      );
      final planning = DriftPlanningRepository(db);
      await planning.createPlannedBlock(
        localDay: day,
        startMinute: 540,
        endMinute: 600,
      );
      await planning.createWeeklyTemplate(
        name: 'Schedule',
        weekday: DateTime.thursday,
        startMinute: 540,
        endMinute: 600,
      );
      await DriftReminderPreferencesRepository(db)
          .save(ReminderPreferences(enabled: false));
      await _openBackup(tester, db, now, _FakeBackupFileService());

      await tester.tap(find.byKey(const Key('delete-local-data')));
      await tester.pumpAndSettle();
      expect(find.text('Delete all local data?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        (await DriftWorkSessionRepository(db).getByDay(day)),
        hasLength(1),
      );

      await tester.tap(find.byKey(const Key('delete-local-data')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete permanently'));
      await tester.pumpAndSettle();

      expect(find.text('All local TimeFlow data deleted'), findsOneWidget);
      expect(await (db.select(db.workSessions)).get(), isEmpty);
      expect(await (db.select(db.plannedBlocks)).get(), isEmpty);
      expect(await (db.select(db.weeklyTemplates)).get(), isEmpty);
      expect(await (db.select(db.reminderPreferencesTable)).get(), isEmpty);
    },
  );
}

Future<void> _openBackup(
  WidgetTester tester,
  AppDatabase db,
  DateTime now,
  _FakeBackupFileService files,
) async {
  appRouter.go('/today');
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FakeClock(now)),
        backupFileServiceProvider.overrideWithValue(files),
        reminderNotificationServiceProvider.overrideWithValue(
          FakeReminderNotificationService(),
        ),
      ],
      child: const TimeFlowApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Backup & Restore'));
  await tester.pumpAndSettle();
}

class _FakeBackupFileService implements BackupFileService {
  String? sharedName;
  String? sharedContent;
  String? pickedContent;

  @override
  Future<String?> pickBackup() async => pickedContent;

  @override
  Future<void> shareBackup({
    required String fileName,
    required String content,
  }) async {
    sharedName = fileName;
    sharedContent = content;
  }
}
