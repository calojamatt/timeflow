import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/forgotten_session_scheduler.dart';
import 'package:timeflow/domain/reminder_preferences.dart';
import 'package:timeflow/domain/reminder_scheduler.dart';
import 'package:timeflow/domain/work_session.dart';

void main() {
  final started = DateTime.utc(2026, 1, 5, 9);

  test('schedules a reminder after the configured threshold', () async {
    final service = FakeReminderNotificationService();
    final scheduler = ForgottenSessionScheduler(service);
    final reminder = await scheduler.check(
      WorkSession(id: 's1', startedAtUtc: started, localDay: 20_000),
      preferences: ReminderPreferences(forgottenSessionAfterMinutes: 30),
      now: started.add(const Duration(minutes: 31)),
    );

    expect(reminder!.id, 'forgotten-s1');
    expect(reminder.route, '/today');
  });

  test('does not remind for short, closed, or disabled sessions', () async {
    final service = FakeReminderNotificationService();
    final scheduler = ForgottenSessionScheduler(service);
    final now = started.add(const Duration(minutes: 31));
    final open = WorkSession(id: 's1', startedAtUtc: started, localDay: 20_000);
    final closed = WorkSession(
      id: 's2',
      startedAtUtc: started,
      endedAtUtc: now,
      localDay: 20_000,
    );

    expect(
      await scheduler.check(
        open,
        preferences: ReminderPreferences(forgottenSessionAfterMinutes: 60),
        now: now,
      ),
      isNull,
    );
    expect(
      await scheduler.check(
        closed,
        preferences: ReminderPreferences(),
        now: now,
      ),
      isNull,
    );
    expect(
      await scheduler.check(
        open,
        preferences: ReminderPreferences(enabled: false),
        now: now,
      ),
      isNull,
    );
    expect(service.scheduled, isEmpty);
  });
}
