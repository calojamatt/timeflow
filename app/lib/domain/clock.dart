/// A source of "now" that can be injected and faked in tests.
///
/// The timer and all time logic must go through [Clock] so tests are
/// deterministic and never depend on the real wall clock.
abstract interface class Clock {
  DateTime now();
}

/// The production clock backed by the system clock.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
