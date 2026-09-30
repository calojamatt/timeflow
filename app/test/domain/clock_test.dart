import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/clock.dart';

import '../helpers/fake_clock.dart';

void main() {
  group('FakeClock', () {
    test('returns the injected time', () {
      final clock = FakeClock(DateTime.utc(2026, 1, 1, 9));

      expect(clock.now(), DateTime.utc(2026, 1, 1, 9));
    });

    test('advances by a given duration', () {
      final clock = FakeClock(DateTime.utc(2026, 1, 1, 9));

      clock.advance(const Duration(minutes: 30));

      expect(clock.now(), DateTime.utc(2026, 1, 1, 9, 30));
    });
  });

  group('SystemClock', () {
    test('is a Clock', () {
      const clock = SystemClock();
      expect(clock, isA<Clock>());
    });

    test('now() is close to DateTime.now()', () {
      const clock = SystemClock();
      final before = DateTime.now();
      final now = clock.now();
      final after = DateTime.now();

      expect(now.isAfter(before) || now.isAtSameMomentAs(before), isTrue);
      expect(now.isBefore(after) || now.isAtSameMomentAs(after), isTrue);
    });
  });
}
