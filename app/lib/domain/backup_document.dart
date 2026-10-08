import 'dart:convert';

import 'planned_block.dart';
import 'weekly_template.dart';
import 'work_session.dart';

/// Portable, versioned JSON representation of all locally persisted data.
class BackupDocument {
  BackupDocument._({
    required this.exportedAtUtc,
    required this.sourceSchemaVersion,
    required this.workSessions,
    required this.plannedBlocks,
    required this.weeklyTemplates,
    required this.reminderPreferences,
  });

  static const formatName = 'timeflow-backup';
  static const formatVersion = 1;
  static const currentSchemaVersion = 3;
  static const maximumContentBytes = 25 * 1024 * 1024;

  final DateTime exportedAtUtc;
  final int sourceSchemaVersion;
  final List<Map<String, dynamic>> workSessions;
  final List<Map<String, dynamic>> plannedBlocks;
  final List<Map<String, dynamic>> weeklyTemplates;
  final List<Map<String, dynamic>> reminderPreferences;

  factory BackupDocument.create({
    required DateTime exportedAtUtc,
    required int sourceSchemaVersion,
    required List<Map<String, dynamic>> workSessions,
    required List<Map<String, dynamic>> plannedBlocks,
    required List<Map<String, dynamic>> weeklyTemplates,
    required List<Map<String, dynamic>> reminderPreferences,
  }) {
    return BackupDocument.parse(
      jsonEncode({
        'format': formatName,
        'formatVersion': formatVersion,
        'sourceSchemaVersion': sourceSchemaVersion,
        'exportedAtUtc': exportedAtUtc.toUtc().toIso8601String(),
        'data': {
          'workSessions': workSessions,
          'plannedBlocks': plannedBlocks,
          'weeklyTemplates': weeklyTemplates,
          'reminderPreferences': reminderPreferences,
        },
      }),
    );
  }

  factory BackupDocument.parse(String content) {
    if (utf8.encode(content).length > maximumContentBytes) {
      throw const FormatException('Backup exceeds the 25 MiB size limit');
    }
    final dynamic decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException catch (error) {
      throw FormatException('Backup is not valid JSON: ${error.message}');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup root must be a JSON object');
    }
    if (decoded['format'] != formatName) {
      throw const FormatException('File is not a TimeFlow backup');
    }
    if (decoded['formatVersion'] != formatVersion) {
      throw FormatException(
        'Unsupported backup format version: ${decoded['formatVersion']}',
      );
    }
    final schema = decoded['sourceSchemaVersion'];
    if (schema is! int || schema < 1 || schema > currentSchemaVersion) {
      throw FormatException('Unsupported database schema version: $schema');
    }
    final exportedAt = _date(decoded['exportedAtUtc'], 'exportedAtUtc');
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Backup data must be a JSON object');
    }

    final sessions = _rows(data['workSessions'], 'workSessions');
    final blocks = schema >= 2
        ? _rows(data['plannedBlocks'], 'plannedBlocks')
        : <Map<String, dynamic>>[];
    final templates = schema >= 2
        ? _rows(data['weeklyTemplates'], 'weeklyTemplates')
        : <Map<String, dynamic>>[];
    final preferences = schema >= 3
        ? _rows(data['reminderPreferences'], 'reminderPreferences')
        : <Map<String, dynamic>>[
            {
              'id': 1,
              'enabled': true,
              'shiftStartLeadMinutes': 15,
              'forgottenSessionAfterMinutes': 30,
            },
          ];

    _validateSessions(sessions);
    _validateBlocks(blocks);
    _validateTemplates(templates);
    _validatePreferences(preferences);

    return BackupDocument._(
      exportedAtUtc: exportedAt,
      sourceSchemaVersion: schema,
      workSessions: sessions,
      plannedBlocks: blocks,
      weeklyTemplates: templates,
      reminderPreferences: preferences,
    );
  }

  String encode() => const JsonEncoder.withIndent('  ').convert({
    'format': formatName,
    'formatVersion': formatVersion,
    'sourceSchemaVersion': sourceSchemaVersion,
    'exportedAtUtc': exportedAtUtc.toUtc().toIso8601String(),
    'data': {
      'workSessions': workSessions,
      'plannedBlocks': plannedBlocks,
      'weeklyTemplates': weeklyTemplates,
      'reminderPreferences': reminderPreferences,
    },
  });

  static List<Map<String, dynamic>> _rows(dynamic value, String label) {
    if (value is! List) throw FormatException('$label must be an array');
    return value
        .map((row) {
          if (row is! Map) {
            throw FormatException('$label entries must be objects');
          }
          return row.map((key, value) => MapEntry(key.toString(), value));
        })
        .toList(growable: false);
  }

  static void _validateSessions(List<Map<String, dynamic>> rows) {
    final ids = <String>{};
    final sessions = <WorkSession>[];
    for (final row in rows) {
      final id = _string(row['id'], 'workSessions.id');
      if (!ids.add(id)) throw FormatException('Duplicate work session id: $id');
      final start = _date(row['startedAtUtc'], 'workSessions.startedAtUtc');
      final rawEnd = row['endedAtUtc'];
      final end = rawEnd == null
          ? null
          : _date(rawEnd, 'workSessions.endedAtUtc');
      if (end != null && !end.isAfter(start)) {
        throw const FormatException('Work session end must be after its start');
      }
      final localDay = _integer(row['localDay'], 'workSessions.localDay');
      final note = _optionalString(row['note'], 'workSessions.note');
      sessions.add(
        WorkSession(
          id: id,
          startedAtUtc: start,
          endedAtUtc: end,
          localDay: localDay,
          note: note,
        ),
      );
    }
    sessions.sort((a, b) => a.startedAtUtc.compareTo(b.startedAtUtc));
    var openCount = 0;
    DateTime? previousEnd;
    for (final session in sessions) {
      if (session.isOpen) openCount++;
      if (previousEnd != null && session.startedAtUtc.isBefore(previousEnd)) {
        throw const FormatException('Work sessions in a backup cannot overlap');
      }
      if (session.endedAtUtc == null) {
        if (session != sessions.last) {
          throw const FormatException(
            'An open session must be the latest session',
          );
        }
      } else {
        previousEnd = session.endedAtUtc;
      }
    }
    if (openCount > 1) {
      throw const FormatException('Backup contains more than one open session');
    }
  }

  static void _validateBlocks(List<Map<String, dynamic>> rows) {
    final ids = <String>{};
    for (final row in rows) {
      final id = _string(row['id'], 'plannedBlocks.id');
      if (!ids.add(id)) {
        throw FormatException('Duplicate planned block id: $id');
      }
      PlannedBlock(
        id: id,
        localDay: _integer(row['localDay'], 'plannedBlocks.localDay'),
        startMinute: _integer(row['startMinute'], 'plannedBlocks.startMinute'),
        endMinute: _integer(row['endMinute'], 'plannedBlocks.endMinute'),
        note: _optionalString(row['note'], 'plannedBlocks.note'),
      );
    }
  }

  static void _validateTemplates(List<Map<String, dynamic>> rows) {
    final ids = <String>{};
    for (final row in rows) {
      final id = _string(row['id'], 'weeklyTemplates.id');
      if (!ids.add(id)) {
        throw FormatException('Duplicate weekly template id: $id');
      }
      WeeklyTemplate(
        id: id,
        name: _string(row['name'], 'weeklyTemplates.name'),
        weekday: _integer(row['weekday'], 'weeklyTemplates.weekday'),
        startMinute: _integer(
          row['startMinute'],
          'weeklyTemplates.startMinute',
        ),
        endMinute: _integer(row['endMinute'], 'weeklyTemplates.endMinute'),
        note: _optionalString(row['note'], 'weeklyTemplates.note'),
      );
    }
  }

  static void _validatePreferences(List<Map<String, dynamic>> rows) {
    if (rows.length != 1) {
      throw const FormatException(
        'Backup must contain one reminder preference row',
      );
    }
    final row = rows.single;
    if (_integer(row['id'], 'reminderPreferences.id') != 1) {
      throw const FormatException('Reminder preference id must be 1');
    }
    if (row['enabled'] is! bool) {
      throw const FormatException(
        'reminderPreferences.enabled must be boolean',
      );
    }
    final lead = _integer(
      row['shiftStartLeadMinutes'],
      'reminderPreferences.shiftStartLeadMinutes',
    );
    final threshold = _integer(
      row['forgottenSessionAfterMinutes'],
      'reminderPreferences.forgottenSessionAfterMinutes',
    );
    if (lead < 0 || lead > 1440 || threshold < 1 || threshold > 10080) {
      throw const FormatException(
        'Reminder preference values are out of range',
      );
    }
  }

  static DateTime _date(dynamic value, String label) {
    if (value is! String) {
      throw FormatException('$label must be an ISO date string');
    }
    final result = DateTime.tryParse(value);
    if (result == null) throw FormatException('$label is not a valid date');
    return result.toUtc();
  }

  static String _string(dynamic value, String label) {
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$label must be a non-empty string');
    }
    return value;
  }

  static String? _optionalString(dynamic value, String label) {
    if (value != null && value is! String) {
      throw FormatException('$label must be a string or null');
    }
    return value as String?;
  }

  static int _integer(dynamic value, String label) {
    if (value is! int) throw FormatException('$label must be an integer');
    return value;
  }
}
