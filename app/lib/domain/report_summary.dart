/// Aggregated work-time values for one reporting period.
class ReportSummary {
  const ReportSummary({
    required this.fromLocalDay,
    required this.toLocalDay,
    required this.actual,
    required this.planned,
  });

  final int fromLocalDay;
  final int toLocalDay;
  final Duration actual;
  final Duration planned;

  Duration get variance => actual - planned;
}
