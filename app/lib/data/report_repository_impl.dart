import 'package:drift/drift.dart';
import 'package:timeflow/domain/report_repository.dart';
import 'package:timeflow/domain/report_summary.dart';

import 'app_database.dart';

class DriftReportRepository implements ReportRepository {
  DriftReportRepository(this._db);

  final AppDatabase _db;

  @override
  Future<ReportSummary> getSummary({
    required int fromLocalDay,
    required int toLocalDay,
    required DateTime now,
  }) async {
    if (toLocalDay < fromLocalDay) {
      throw ArgumentError.value(
        toLocalDay,
        'toLocalDay',
        'must not be before fromLocalDay',
      );
    }
    final actualRow = await _db
        .customSelect(
          'SELECT COALESCE(SUM(ROUND('
          '(julianday(CASE WHEN ended_at_utc IS NULL THEN ? '
          'ELSE ended_at_utc END) - julianday(started_at_utc)) '
          '* 86400000.0)), 0) AS actual_millis '
          'FROM work_sessions WHERE local_day BETWEEN ? AND ?',
          variables: [
            Variable<String>(now.toUtc().toIso8601String()),
            Variable<int>(fromLocalDay),
            Variable<int>(toLocalDay),
          ],
        )
        .getSingle();
    final plannedRow = await _db
        .customSelect(
          'SELECT COALESCE(SUM(end_minute - start_minute), 0) '
          'AS planned_minutes FROM planned_blocks '
          'WHERE local_day BETWEEN ? AND ?',
          variables: [Variable<int>(fromLocalDay), Variable<int>(toLocalDay)],
        )
        .getSingle();
    return ReportSummary(
      fromLocalDay: fromLocalDay,
      toLocalDay: toLocalDay,
      actual: Duration(milliseconds: actualRow.read<int>('actual_millis')),
      planned: Duration(minutes: plannedRow.read<int>('planned_minutes')),
    );
  }
}
