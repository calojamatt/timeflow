import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/local_day.dart';

void main() {
  group('localDayFrom', () {
    test('maps a local calendar day to its day-since-epoch index', () {
      expect(localDayFrom(DateTime(1970, 1, 1)), 0);
      expect(localDayFrom(DateTime(2026, 1, 1)), 20454);
    });

    test('buckets every time within a local day to the same index', () {
      final early = localDayFrom(DateTime(2026, 1, 1, 0, 5));
      final noon = localDayFrom(DateTime(2026, 1, 1, 12));
      final late = localDayFrom(DateTime(2026, 1, 1, 23, 59));

      expect(early, noon);
      expect(noon, late);
    });

    test('increments by one across consecutive local days', () {
      expect(
        localDayFrom(DateTime(2026, 1, 2)),
        localDayFrom(DateTime(2026, 1, 1)) + 1,
      );
    });

    test('accounts for leap years', () {
      expect(
        localDayFrom(DateTime(2025, 1, 1)),
        localDayFrom(DateTime(2024, 1, 1)) + 366,
      );
    });
  });
}
