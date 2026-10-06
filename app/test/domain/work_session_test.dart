import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/work_session.dart';

void main() {
  final startedAt = DateTime.utc(2026, 1, 1, 9);
  const localDay = 20454;

  WorkSession openSession({DateTime? start}) => WorkSession(
    id: 's1',
    startedAtUtc: start ?? startedAt,
    localDay: localDay,
  );

  WorkSession closedSession({DateTime? end}) => WorkSession(
    id: 's1',
    startedAtUtc: startedAt,
    endedAtUtc: end ?? startedAt.add(const Duration(hours: 4)),
    localDay: localDay,
  );

  group('isOpen', () {
    test('is true when endedAtUtc is null', () {
      expect(openSession().isOpen, isTrue);
    });

    test('is false when endedAtUtc is set', () {
      expect(closedSession().isOpen, isFalse);
    });
  });

  group('elapsedAt', () {
    test('returns now - start while open', () {
      final now = startedAt.add(const Duration(hours: 1, minutes: 30));

      expect(
        openSession().elapsedAt(now),
        const Duration(hours: 1, minutes: 30),
      );
    });

    test('returns end - start when closed, ignoring now', () {
      final now = startedAt.add(const Duration(hours: 10));

      expect(closedSession().elapsedAt(now), const Duration(hours: 4));
    });

    test('returns zero when open and now == start', () {
      expect(openSession().elapsedAt(startedAt), Duration.zero);
    });
  });

  group('stop', () {
    test('closes an open session, preserving identity and start', () {
      final end = startedAt.add(const Duration(hours: 8));
      final closed = openSession().stop(end);

      expect(closed.isOpen, isFalse);
      expect(closed.endedAtUtc, end);
      expect(closed.id, 's1');
      expect(closed.startedAtUtc, startedAt);
      expect(closed.localDay, localDay);
    });

    test('throws when the session is already closed', () {
      expect(
        () => closedSession().stop(startedAt.add(const Duration(hours: 5))),
        throwsStateError,
      );
    });
  });

  test('asserts when endedAtUtc is before startedAtUtc', () {
    expect(
      () => WorkSession(
        id: 's1',
        startedAtUtc: startedAt,
        endedAtUtc: startedAt.subtract(const Duration(minutes: 1)),
        localDay: localDay,
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
