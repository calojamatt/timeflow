import 'reminder.dart';
import 'reminder_preferences.dart';
import 'work_session.dart';

/// Schedules one reminder when an open session exceeds the user threshold.
class ForgottenSessionScheduler {
  ForgottenSessionScheduler(this._service);

  final ReminderNotificationService _service;

  Future<Reminder?> check(
    WorkSession session, {
    required ReminderPreferences preferences,
    required DateTime now,
  }) async {
    if (!session.isOpen || !preferences.enabled) return null;
    if (session.elapsedAt(now).inMinutes <
        preferences.forgottenSessionAfterMinutes) {
      return null;
    }
    final reminder = Reminder(
      id: 'forgotten-${session.id}',
      kind: ReminderKind.forgottenSession,
      scheduledAt: now,
      title: 'Work session is still running',
      body: 'Remember to stop your work session when you finish.',
      route: '/today',
    );
    await _service.schedule(reminder);
    return reminder;
  }

  Future<void> cancel(WorkSession session) =>
      _service.cancel('forgotten-${session.id}');
}
