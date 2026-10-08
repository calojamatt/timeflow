import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/planned_block.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/domain/report_csv.dart';
import 'package:timeflow/domain/work_session.dart';

void main() {
  test('CSV round-trips actual and planned rows with escaped notes', () {
    final start = DateTime.utc(2026, 1, 5, 9);
    final localDay = DateTime.utc(
      2026,
      1,
      5,
    ).difference(DateTime.utc(1970, 1, 1)).inDays;
    final csv = buildReportCsv(
      sessions: [
        WorkSession(
          id: 's1',
          startedAtUtc: start,
          endedAtUtc: DateTime.utc(2026, 1, 5, 10, 30),
          localDay: localDay,
          note: 'Client, "A"\nfollow-up',
        ),
      ],
      plannedBlocks: [
        PlannedBlock(
          id: 'p1',
          localDay: localDay,
          startMinute: 11 * 60,
          endMinute: 12 * 60,
          note: 'Planning',
        ),
      ],
      now: DateTime.utc(2026, 1, 5, 12),
    );
    final rows = const CsvDecoder(dynamicTyping: true).convert(csv);

    expect(rows.first, [
      'Date',
      'Type',
      'Start',
      'End',
      'Duration seconds',
      'Note',
    ]);
    expect(rows[1][1], 'Actual');
    expect(rows[1][4], 5400);
    expect(rows[1][5], 'Client, "A"\nfollow-up');
    expect(rows[2][1], 'Planned');
    expect(rows[2][2], '11:00');
    expect(rows[2][4], 3600);
  });

  test('includes open-session duration through the supplied current time', () {
    final start = DateTime.utc(2026, 1, 5, 9);
    final csv = buildReportCsv(
      sessions: [
        WorkSession(
          id: 'open',
          startedAtUtc: start,
          localDay: localDayFrom(start),
        ),
      ],
      plannedBlocks: const [],
      now: DateTime.utc(2026, 1, 5, 12),
    );

    expect(const CsvDecoder(dynamicTyping: true).convert(csv)[1][4], 10800);
  });
}
