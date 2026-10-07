import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/reminder.dart';
import 'package:timeflow/domain/reminder_scheduler.dart';

void main() {
  Reminder reminder({String id = 'shift-1'}) => Reminder(
    id: id,
    kind: ReminderKind.shiftStart,
    scheduledAt: DateTime.utc(2026, 1, 5, 8, 45),
    title: 'Work starts soon',
    body: 'Your planned shift starts at 09:00.',
    route: '/calendar',
  );

  test('validates reminder identity and deep-link route', () {
    expect(reminder().route, '/calendar');
    expect(() => reminder(id: ''), throwsArgumentError);
    expect(
      () => Reminder(
        id: 'r1',
        kind: ReminderKind.shiftStart,
        scheduledAt: DateTime.utc(2026),
        title: 'Title',
        body: 'Body',
        route: 'calendar',
      ),
      throwsArgumentError,
    );
  });

  test('fake service replaces and cancels reminders by id', () async {
    final service = FakeReminderNotificationService();
    await service.schedule(reminder());
    expect(service.scheduled, hasLength(1));

    await service.schedule(reminder().copyWithBody('Updated body'));
    expect(service.scheduled['shift-1']!.body, 'Updated body');

    await service.cancel('shift-1');
    expect(service.scheduled, isEmpty);
  });

  test('fake service cancels all reminders', () async {
    final service = FakeReminderNotificationService();
    await service.schedule(reminder());
    await service.schedule(reminder(id: 'forgotten-1'));
    await service.cancelAll();
    expect(service.scheduled, isEmpty);
  });
}

extension on Reminder {
  Reminder copyWithBody(String body) => Reminder(
    id: id,
    kind: kind,
    scheduledAt: scheduledAt,
    title: title,
    body: body,
    route: route,
  );
}
