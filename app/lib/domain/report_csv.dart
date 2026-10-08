import 'package:csv/csv.dart';

import 'planned_block.dart';
import 'work_session.dart';

/// Builds an RFC 4180 CSV for actual and planned work.
/// Dates use the stored device-local day bucket; timestamps use local time.
String buildReportCsv({
  required Iterable<WorkSession> sessions,
  required Iterable<PlannedBlock> plannedBlocks,
  required DateTime now,
}) {
  final rows = <({int day, int minute, List<Object?> fields})>[];
  for (final session in sessions) {
    final start = session.startedAtUtc.toLocal();
    final end = (session.endedAtUtc ?? now).toLocal();
    rows.add((
      day: session.localDay,
      minute: start.hour * 60 + start.minute,
      fields: [
        _dayLabel(session.localDay),
        'Actual',
        _dateTimeLabel(start),
        _dateTimeLabel(end),
        session.elapsedAt(now).inSeconds,
        session.note ?? '',
      ],
    ));
  }
  for (final block in plannedBlocks) {
    rows.add((
      day: block.localDay,
      minute: block.startMinute,
      fields: [
        _dayLabel(block.localDay),
        'Planned',
        _timeLabel(block.startMinute),
        _timeLabel(block.endMinute),
        block.duration.inSeconds,
        block.note ?? '',
      ],
    ));
  }
  rows.sort((a, b) {
    final dayOrder = a.day.compareTo(b.day);
    if (dayOrder != 0) return dayOrder;
    final timeOrder = a.minute.compareTo(b.minute);
    if (timeOrder != 0) return timeOrder;
    return a.fields[1].toString().compareTo(b.fields[1].toString());
  });

  return const CsvEncoder(lineDelimiter: '\r\n').convert([
    ['Date', 'Type', 'Start', 'End', 'Duration seconds', 'Note'],
    ...rows.map((row) => row.fields),
  ]);
}

String _dayLabel(int day) =>
    _dateLabel(DateTime.utc(1970, 1, 1).add(Duration(days: day)));

String _dateLabel(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _dateTimeLabel(DateTime date) =>
    '${_dateLabel(date)} ${_timeLabel(date.hour * 60 + date.minute)}';

String _timeLabel(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:'
    '${(minute % 60).toString().padLeft(2, '0')}';
