import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/reminder_preferences_repository_impl.dart';
import 'package:timeflow/domain/reminder_preferences.dart';

import '../helpers/in_memory_database.dart';

void main() {
  test('returns defaults when no preferences have been saved', () async {
    final db = openInMemoryDatabase();
    addTearDown(db.close);
    final repository = DriftReminderPreferencesRepository(db);

    final loaded = await repository.get();
    expect(loaded.enabled, isTrue);
    expect(loaded.shiftStartLeadMinutes, 15);
    expect(loaded.forgottenSessionAfterMinutes, 30);
  });

  test('saves and replaces preferences', () async {
    final db = openInMemoryDatabase();
    addTearDown(db.close);
    final repository = DriftReminderPreferencesRepository(db);

    final preferences = ReminderPreferences(
      enabled: false,
      shiftStartLeadMinutes: 30,
      forgottenSessionAfterMinutes: 60,
    );
    await repository.save(preferences);
    final loaded = await repository.get();
    expect(loaded.enabled, isFalse);
    expect(loaded.shiftStartLeadMinutes, 30);
    expect(loaded.forgottenSessionAfterMinutes, 60);
  });
}
