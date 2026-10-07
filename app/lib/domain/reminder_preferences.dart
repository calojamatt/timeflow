/// User-controlled local reminder settings.
class ReminderPreferences {
  ReminderPreferences({
    this.enabled = true,
    this.shiftStartLeadMinutes = 15,
    this.forgottenSessionAfterMinutes = 30,
  }) {
    if (shiftStartLeadMinutes < 0 || shiftStartLeadMinutes > 24 * 60) {
      throw ArgumentError.value(shiftStartLeadMinutes, 'shiftStartLeadMinutes');
    }
    if (forgottenSessionAfterMinutes < 1 ||
        forgottenSessionAfterMinutes > 7 * 24 * 60) {
      throw ArgumentError.value(
        forgottenSessionAfterMinutes,
        'forgottenSessionAfterMinutes',
      );
    }
  }

  final bool enabled;
  final int shiftStartLeadMinutes;
  final int forgottenSessionAfterMinutes;
}

abstract interface class ReminderPreferencesRepository {
  Future<ReminderPreferences> get();

  Future<void> save(ReminderPreferences preferences);
}
