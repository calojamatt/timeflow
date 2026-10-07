import 'planned_block.dart';
import 'planned_reminder_scheduler.dart';
import 'reminder.dart';
import 'reminder_preferences.dart';
import 'forgotten_session_scheduler.dart';
import 'work_session.dart';

/// Coordinates reminder scheduling without exposing platform APIs to callers.
class ReminderCoordinator {
  ReminderCoordinator({
    required ReminderNotificationService notificationService,
    required this._preferencesRepository,
  }) : _planned = PlannedReminderScheduler(notificationService),
       _forgotten = ForgottenSessionScheduler(notificationService),
       _notificationService = notificationService;

  final ReminderPreferencesRepository _preferencesRepository;
  final PlannedReminderScheduler _planned;
  final ForgottenSessionScheduler _forgotten;
  final ReminderNotificationService _notificationService;

  Future<void> initialize({void Function(String route)? onRoute}) =>
      _notificationService.initialize(onRoute: onRoute);

  Future<Reminder?> schedulePlannedBlock(
    PlannedBlock block, {
    DateTime? now,
  }) async => _planned.schedule(
    block,
    preferences: await _preferencesRepository.get(),
    now: now,
  );

  Future<Reminder?> checkForgottenSession(
    WorkSession session, {
    required DateTime now,
  }) async => _forgotten.check(
    session,
    preferences: await _preferencesRepository.get(),
    now: now,
  );
}
