import 'report_summary.dart';

abstract interface class ReportRepository {
  Future<ReportSummary> getSummary({
    required int fromLocalDay,
    required int toLocalDay,
    required DateTime now,
  });
}
