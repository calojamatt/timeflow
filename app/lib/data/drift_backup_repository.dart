import 'package:timeflow/domain/backup_document.dart';
import 'package:timeflow/domain/backup_repository.dart';

import 'app_database.dart';

class DriftBackupRepository implements BackupRepository {
  DriftBackupRepository(this._db);

  final AppDatabase _db;

  @override
  Future<String> createBackup({required DateTime exportedAtUtc}) =>
      _db.transaction(() async {
        final sessions = await _db.select(_db.workSessions).get();
        final blocks = await _db.select(_db.plannedBlocks).get();
        final templates = await _db.select(_db.weeklyTemplates).get();
        final preferences = await _db
            .select(_db.reminderPreferencesTable)
            .get();
        final document = BackupDocument.create(
          exportedAtUtc: exportedAtUtc,
          sourceSchemaVersion: _db.schemaVersion,
          workSessions: sessions
              .map(
                (row) => {
                  'id': row.id,
                  'startedAtUtc': row.startedAtUtc.toUtc().toIso8601String(),
                  'endedAtUtc': row.endedAtUtc?.toUtc().toIso8601String(),
                  'localDay': row.localDay,
                  'note': row.note,
                },
              )
              .toList(),
          plannedBlocks: blocks
              .map(
                (row) => {
                  'id': row.id,
                  'localDay': row.localDay,
                  'startMinute': row.startMinute,
                  'endMinute': row.endMinute,
                  'note': row.note,
                },
              )
              .toList(),
          weeklyTemplates: templates
              .map(
                (row) => {
                  'id': row.id,
                  'name': row.name,
                  'weekday': row.weekday,
                  'startMinute': row.startMinute,
                  'endMinute': row.endMinute,
                  'note': row.note,
                },
              )
              .toList(),
          reminderPreferences: preferences.isEmpty
              ? [
                  {
                    'id': 1,
                    'enabled': true,
                    'shiftStartLeadMinutes': 15,
                    'forgottenSessionAfterMinutes': 30,
                  },
                ]
              : preferences.map((row) => row.toJson()).toList(),
        );
        return document.encode();
      });

  @override
  Future<void> restoreBackup(String content) async {
    // Parsing and domain validation happen before opening the write transaction.
    final document = BackupDocument.parse(content);
    final sessions = document.workSessions
        .map(
          (row) => WorkSessionRow(
            id: row['id'] as String,
            startedAtUtc: DateTime.parse(row['startedAtUtc'] as String).toUtc(),
            endedAtUtc: row['endedAtUtc'] == null
                ? null
                : DateTime.parse(row['endedAtUtc'] as String).toUtc(),
            localDay: row['localDay'] as int,
            note: row['note'] as String?,
          ),
        )
        .toList(growable: false);
    final blocks = document.plannedBlocks
        .map(
          (row) => PlannedBlockRow(
            id: row['id'] as String,
            localDay: row['localDay'] as int,
            startMinute: row['startMinute'] as int,
            endMinute: row['endMinute'] as int,
            note: row['note'] as String?,
          ),
        )
        .toList(growable: false);
    final templates = document.weeklyTemplates
        .map(
          (row) => WeeklyTemplateRow(
            id: row['id'] as String,
            name: row['name'] as String,
            weekday: row['weekday'] as int,
            startMinute: row['startMinute'] as int,
            endMinute: row['endMinute'] as int,
            note: row['note'] as String?,
          ),
        )
        .toList(growable: false);
    final preferences = document.reminderPreferences
        .map(
          (row) => ReminderPreferencesRow(
            id: row['id'] as int,
            enabled: row['enabled'] as bool,
            shiftStartLeadMinutes: row['shiftStartLeadMinutes'] as int,
            forgottenSessionAfterMinutes:
                row['forgottenSessionAfterMinutes'] as int,
          ),
        )
        .toList(growable: false);

    await _db.transaction(() async {
      await _db.delete(_db.workSessions).go();
      await _db.delete(_db.plannedBlocks).go();
      await _db.delete(_db.weeklyTemplates).go();
      await _db.delete(_db.reminderPreferencesTable).go();
      if (sessions.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(_db.workSessions, sessions);
        });
      }
      if (blocks.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(_db.plannedBlocks, blocks);
        });
      }
      if (templates.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(_db.weeklyTemplates, templates);
        });
      }
      await _db.batch((batch) {
        batch.insertAll(_db.reminderPreferencesTable, preferences);
      });
    });
  }
}
