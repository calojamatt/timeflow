import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/day_plan_summary.dart';
import 'package:timeflow/domain/planned_block.dart';
import 'package:timeflow/domain/work_session.dart';

void main() {
  final start = DateTime.utc(2026, 1, 5, 9);

  test('calculates planned, actual, and positive variance', () {
    final summary = calculateDayPlanSummary(
      plannedBlocks: [
        PlannedBlock(
          id: 'p1',
          localDay: 20_000,
          startMinute: 9 * 60,
          endMinute: 17 * 60,
        ),
      ],
      sessions: [
        WorkSession(
          id: 's1',
          startedAtUtc: start,
          endedAtUtc: start.add(const Duration(hours: 9)),
          localDay: 20_000,
        ),
      ],
      now: start.add(const Duration(hours: 10)),
    );

    expect(summary.planned, const Duration(hours: 8));
    expect(summary.actual, const Duration(hours: 9));
    expect(summary.variance, const Duration(hours: 1));
  });

  test('includes open sessions using now', () {
    final summary = calculateDayPlanSummary(
      plannedBlocks: const [],
      sessions: [WorkSession(id: 's1', startedAtUtc: start, localDay: 20_000)],
      now: start.add(const Duration(hours: 2)),
    );

    expect(summary.planned, Duration.zero);
    expect(summary.actual, const Duration(hours: 2));
    expect(summary.variance, const Duration(hours: 2));
  });

  test('supports days with no planned or actual time', () {
    final summary = calculateDayPlanSummary(
      plannedBlocks: const [],
      sessions: const [],
      now: start,
    );

    expect(summary.planned, Duration.zero);
    expect(summary.actual, Duration.zero);
    expect(summary.variance, Duration.zero);
  });
}
