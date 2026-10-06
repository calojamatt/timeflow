import 'planned_block.dart';
import 'work_session.dart';

/// Planned and actual time totals for one local calendar day.
class DayPlanSummary {
  const DayPlanSummary({required this.planned, required this.actual});

  final Duration planned;
  final Duration actual;

  /// Positive means more actual time than planned.
  Duration get variance => actual - planned;
}

DayPlanSummary calculateDayPlanSummary({
  required List<PlannedBlock> plannedBlocks,
  required List<WorkSession> sessions,
  required DateTime now,
}) {
  final planned = plannedBlocks.fold<Duration>(
    Duration.zero,
    (total, block) => total + block.duration,
  );
  final actual = sessions.fold<Duration>(
    Duration.zero,
    (total, session) => total + session.elapsedAt(now),
  );
  return DayPlanSummary(planned: planned, actual: actual);
}
