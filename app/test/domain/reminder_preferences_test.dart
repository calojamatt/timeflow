import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/reminder_preferences.dart';

void main() {
  test('provides safe defaults', () {
    final preferences = ReminderPreferences();
    expect(preferences.enabled, isTrue);
    expect(preferences.shiftStartLeadMinutes, 15);
    expect(preferences.forgottenSessionAfterMinutes, 30);
  });

  test('rejects invalid lead time and forgotten-session threshold', () {
    expect(
      () => ReminderPreferences(shiftStartLeadMinutes: -1),
      throwsArgumentError,
    );
    expect(
      () => ReminderPreferences(forgottenSessionAfterMinutes: 0),
      throwsArgumentError,
    );
  });
}
