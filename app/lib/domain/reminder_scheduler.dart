import 'reminder.dart';

/// A deterministic in-memory service useful for domain/widget tests.
class FakeReminderNotificationService implements ReminderNotificationService {
  final Map<String, Reminder> scheduled = {};

  @override
  Future<void> schedule(Reminder reminder) async {
    scheduled[reminder.id] = reminder;
  }

  @override
  Future<void> cancel(String reminderId) async {
    scheduled.remove(reminderId);
  }

  @override
  Future<void> cancelAll() async {
    scheduled.clear();
  }
}
