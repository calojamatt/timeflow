import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/report_repository_impl.dart';
import 'package:timeflow/data/planning_repository_impl.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';

import '../helpers/in_memory_database.dart';

void main() {
  test('aggregates actual and planned time for a period', () async {
    final db = openInMemoryDatabase();
    addTearDown(db.close);
    final now = DateTime.utc(2026, 1, 5, 12);
    final work = DriftWorkSessionRepository(db);
    final planning = DriftPlanningRepository(db);
    await work.start(
      startedAtUtc: DateTime.utc(2026, 1, 5, 9),
      localDay: 20_000,
    );
    final open = await work.findOpen();
    await work.stop(open!.id, endedAtUtc: DateTime.utc(2026, 1, 5, 11));
    await planning.createPlannedBlock(
      localDay: 20_000,
      startMinute: 9 * 60,
      endMinute: 17 * 60,
    );

    final summary = await DriftReportRepository(db)
        .getSummary(fromLocalDay: 20_000, toLocalDay: 20_000, now: now);
    expect(summary.actual, const Duration(hours: 2));
    expect(summary.planned, const Duration(hours: 8));
  });
}
