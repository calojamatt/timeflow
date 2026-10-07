import 'planned_block.dart';
import 'reminder.dart';
import 'reminder_preferences.dart';
import 'weekly_template.dart';

/// Builds and schedules a local notification for a planned block.
class PlannedReminderScheduler {
  PlannedReminderScheduler(this._service);

  final ReminderNotificationService _service;

  Future<Reminder?> schedule(
    PlannedBlock block, {
    required ReminderPreferences preferences,
    DateTime? now,
  }) async {
    if (!preferences.enabled) return null;
    final plannedStart = _localDateTime(block.localDay, block.startMinute);
    final scheduledAt = plannedStart.subtract(
      Duration(minutes: preferences.shiftStartLeadMinutes),
    );
    if (now != null && !scheduledAt.isAfter(now)) return null;
    final reminder = Reminder(
      id: 'shift-${block.id}',
      kind: ReminderKind.shiftStart,
      scheduledAt: scheduledAt,
      title: 'Work starts soon',
      body: 'Your planned work starts at ${_formatMinute(block.startMinute)}.',
      route: '/calendar',
    );
    await _service.schedule(reminder);
    return reminder;
  }

  Future<Reminder?> scheduleTemplate(
    WeeklyTemplate template, {
    required int localDay,
    required ReminderPreferences preferences,
    DateTime? now,
  }) => schedule(
    PlannedBlock(
      id: 'template-${template.id}-$localDay',
      localDay: localDay,
      startMinute: template.startMinute,
      endMinute: template.endMinute,
      note: template.note,
    ),
    preferences: preferences,
    now: now,
  );

  Future<void> cancel(PlannedBlock block) =>
      _service.cancel('shift-${block.id}');

  DateTime _localDateTime(int localDay, int minute) {
    final calendarDate = DateTime.utc(1970, 1, 1).add(Duration(days: localDay));
    return DateTime(
      calendarDate.year,
      calendarDate.month,
      calendarDate.day,
    ).add(Duration(minutes: minute));
  }

  String _formatMinute(int minute) =>
      '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';
}
