import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/planned_block.dart';
import 'package:timeflow/domain/planned_reminder_scheduler.dart';
import 'package:timeflow/domain/reminder_preferences.dart';
import 'package:timeflow/domain/reminder_scheduler.dart';

void main() {
  test('schedules a planned block using the configured lead time', () async {
    final service = FakeReminderNotificationService();
    final scheduler = PlannedReminderScheduler(service);
    final block = PlannedBlock(
      id: 'p1',
      localDay: 20_000,
      startMinute: 9 * 60,
      endMinute: 17 * 60,
    );

    final reminder = await scheduler.schedule(
      block,
      preferences: ReminderPreferences(shiftStartLeadMinutes: 15),
      now: DateTime(2024, 10, 4, 8),
    );

    expect(reminder!.id, 'shift-p1');
    expect(reminder.scheduledAt, DateTime(2024, 10, 4, 8, 45));
    expect(service.scheduled['shift-p1']!.route, '/calendar');
  });

  test('does not schedule disabled or past reminders', () async {
    final service = FakeReminderNotificationService();
    final scheduler = PlannedReminderScheduler(service);
    final block = PlannedBlock(
      id: 'p1',
      localDay: 20_000,
      startMinute: 9 * 60,
      endMinute: 17 * 60,
    );

    expect(
      await scheduler.schedule(
        block,
        preferences: ReminderPreferences(enabled: false),
      ),
      isNull,
    );
    expect(
      await scheduler.schedule(
        block,
        preferences: ReminderPreferences(),
        now: DateTime(2024, 10, 4, 9),
      ),
      isNull,
    );
    expect(service.scheduled, isEmpty);
  });
}
