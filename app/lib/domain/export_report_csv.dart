import 'csv_share_service.dart';
import 'planning_repository.dart';
import 'report_csv.dart';
import 'work_session_repository.dart';

class ExportReportCsv {
  const ExportReportCsv(this._sessions, this._planning, this._share);

  final WorkSessionRepository _sessions;
  final PlanningRepository _planning;
  final CsvShareService _share;

  Future<void> call({
    required int fromLocalDay,
    required int toLocalDay,
    required DateTime now,
  }) async {
    if (toLocalDay < fromLocalDay) {
      throw ArgumentError.value(toLocalDay, 'toLocalDay');
    }
    final sessions = await _sessions.getBetweenDays(
      fromLocalDay: fromLocalDay,
      toLocalDay: toLocalDay,
    );
    final planned = await _planning.getPlannedBlocksBetween(
      fromLocalDay: fromLocalDay,
      toLocalDay: toLocalDay,
    );
    final content = buildReportCsv(
      sessions: sessions,
      plannedBlocks: planned,
      now: now,
    );
    final from = _datePart(fromLocalDay);
    final to = _datePart(toLocalDay);
    await _share.shareCsv(
      fileName: 'timeflow-report-$from-$to.csv',
      content: content,
    );
  }
}

String _datePart(int day) {
  final date = DateTime.utc(1970, 1, 1).add(Duration(days: day));
  return '${date.year.toString().padLeft(4, '0')}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';
}
