import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/report_summary.dart';

void main() {
  test('calculates planned-versus-actual variance', () {
    const summary = ReportSummary(
      fromLocalDay: 20_000,
      toLocalDay: 20_006,
      actual: Duration(hours: 37),
      planned: Duration(hours: 40),
    );

    expect(summary.variance, const Duration(hours: -3));
  });
}
