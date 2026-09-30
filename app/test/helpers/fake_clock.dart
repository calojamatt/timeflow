import 'package:timeflow/domain/clock.dart';

/// A [Clock] test double whose time is fully controlled by the test.
class FakeClock implements Clock {
  FakeClock([DateTime? now]) : _now = now ?? DateTime.utc(2026, 1, 1);

  DateTime _now;

  @override
  DateTime now() => _now;

  /// Moves the fake clock forward by [duration].
  void advance(Duration duration) => _now = _now.add(duration);
}
