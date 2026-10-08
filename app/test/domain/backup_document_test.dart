import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/backup_document.dart';

void main() {
  test('serializes a valid current-format backup with schema metadata', () {
    final document = BackupDocument.create(
      exportedAtUtc: DateTime.utc(2026, 10, 8, 12),
      sourceSchemaVersion: 3,
      workSessions: [
        {
          'id': 'session-1',
          'startedAtUtc': DateTime.utc(2026, 10, 8, 9).toIso8601String(),
          'endedAtUtc': DateTime.utc(2026, 10, 8, 10).toIso8601String(),
          'localDay': 20734,
          'note': 'Focus time',
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
    );
    final parsed = BackupDocument.parse(document.encode());

    expect(parsed.sourceSchemaVersion, 3);
    expect(parsed.workSessions.single['note'], 'Focus time');
    expect(jsonDecode(document.encode())['format'], BackupDocument.formatName);
  });

  test(
    'migrates schema 1 backup by supplying current empty/default tables',
    () {
      final document = BackupDocument.parse(
        jsonEncode({
          'format': BackupDocument.formatName,
          'formatVersion': 1,
          'sourceSchemaVersion': 1,
          'exportedAtUtc': '2026-10-08T12:00:00.000Z',
          'data': {
            'workSessions': [
              {
                'id': 'legacy',
                'startedAtUtc': '2026-10-08T09:00:00.000Z',
                'endedAtUtc': null,
                'localDay': 20734,
                'note': null,
              },
            ],
          },
        }),
      );

      expect(document.plannedBlocks, isEmpty);
      expect(document.weeklyTemplates, isEmpty);
      expect(document.reminderPreferences.single['enabled'], isTrue);
      expect(
        document.reminderPreferences.single['forgottenSessionAfterMinutes'],
        30,
      );
    },
  );

  test('migrates schema 2 backup and supplies reminder defaults', () {
    final document = BackupDocument.parse(
      jsonEncode({
        'format': BackupDocument.formatName,
        'formatVersion': 1,
        'sourceSchemaVersion': 2,
        'exportedAtUtc': '2026-10-08T12:00:00.000Z',
        'data': {
          'workSessions': [],
          'plannedBlocks': [],
          'weeklyTemplates': [],
        },
      }),
    );

    expect(document.workSessions, isEmpty);
    expect(document.plannedBlocks, isEmpty);
    expect(document.weeklyTemplates, isEmpty);
    expect(document.reminderPreferences.single['enabled'], isTrue);
  });

  test('rejects malformed, unsupported, and semantically invalid backups', () {
    expect(() => BackupDocument.parse('{'), throwsFormatException);
    expect(
      () => BackupDocument.parse(
        '''{"format":"timeflow-backup","formatVersion":9}''',
      ),
      throwsFormatException,
    );
    final invalid = {
      'format': BackupDocument.formatName,
      'formatVersion': 1,
      'sourceSchemaVersion': 3,
      'exportedAtUtc': '2026-10-08T12:00:00Z',
      'data': {
        'workSessions': [
          {
            'id': 'bad',
            'startedAtUtc': '2026-10-08T10:00:00Z',
            'endedAtUtc': '2026-10-08T09:00:00Z',
            'localDay': 20734,
            'note': null,
          },
        ],
        'plannedBlocks': [],
        'weeklyTemplates': [],
        'reminderPreferences': [
          {
            'id': 1,
            'enabled': false,
            'shiftStartLeadMinutes': 15,
            'forgottenSessionAfterMinutes': 30,
          },
        ],
      },
    };
    expect(
      () => BackupDocument.parse(jsonEncode(invalid)),
      throwsFormatException,
    );
    invalid['sourceSchemaVersion'] = 999;
    expect(
      () => BackupDocument.parse(jsonEncode(invalid)),
      throwsFormatException,
    );
  });
}
