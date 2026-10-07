import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/reminder_coordinator.dart';
import 'package:timeflow/domain/reminder_preferences.dart';
import 'package:timeflow/domain/reminder_scheduler.dart';
import 'package:timeflow/domain/planned_block.dart';

class _Preferences implements ReminderPreferencesRepository {
  @override
  Future<ReminderPreferences> get() async => ReminderPreferences();

  @override
  Future<void> save(ReminderPreferences preferences) async {}
}

void main() {
  test('coordinates planned reminder scheduling through preferences', () async {
    final service = FakeReminderNotificationService();
    final coordinator = ReminderCoordinator(
      notificationService: service,
      preferencesRepository: _Preferences(),
    );
    final reminder = await coordinator.schedulePlannedBlock(
      PlannedBlock(
        id: 'p1',
        localDay: 20_000,
        startMinute: 9 * 60,
        endMinute: 17 * 60,
      ),
      now: DateTime(2024, 10, 4, 8),
    );

    expect(reminder, isNotNull);
    expect(service.scheduled, hasLength(1));
  });
}
