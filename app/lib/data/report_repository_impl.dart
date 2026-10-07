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
    final sessions =
        await (_db.select(_db.workSessions)..where(
              (t) => t.localDay.isBetweenValues(fromLocalDay, toLocalDay),
            ))
            .get();
    final blocks =
        await (_db.select(_db.plannedBlocks)..where(
              (t) => t.localDay.isBetweenValues(fromLocalDay, toLocalDay),
            ))
            .get();
    final actual = sessions.fold<Duration>(
      Duration.zero,
      (total, row) =>
          total + (row.endedAtUtc ?? now).difference(row.startedAtUtc),
    );
    final planned = blocks.fold<Duration>(
      Duration.zero,
      (total, row) =>
          total + Duration(minutes: row.endMinute - row.startMinute),
    );
    return ReportSummary(
      fromLocalDay: fromLocalDay,
      toLocalDay: toLocalDay,
      actual: actual,
      planned: planned,
    );
  }
}
