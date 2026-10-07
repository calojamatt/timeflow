/// The kind of local reminder shown to the user.
enum ReminderKind { shiftStart, forgottenSession }

/// A platform-independent request for one local notification.
class Reminder {
  Reminder({
    required this.id,
    required this.kind,
    required this.scheduledAt,
    required this.title,
    required this.body,
    required this.route,
  }) {
    if (id.trim().isEmpty) throw ArgumentError.value(id, 'id');
    if (title.trim().isEmpty) throw ArgumentError.value(title, 'title');
    if (body.trim().isEmpty) throw ArgumentError.value(body, 'body');
    if (route.isEmpty || !route.startsWith('/')) {
      throw ArgumentError.value(route, 'route');
    }
  }

  final String id;
  final ReminderKind kind;
  final DateTime scheduledAt;
  final String title;
  final String body;
  final String route;
}

/// Boundary for Android/iOS local notification implementations.
abstract interface class ReminderNotificationService {
  Future<void> schedule(Reminder reminder);

  Future<void> cancel(String reminderId);

  Future<void> cancelAll();
}
