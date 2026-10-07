import 'package:drift/drift.dart';
import 'package:timeflow/domain/reminder_preferences.dart';

import 'app_database.dart';

class DriftReminderPreferencesRepository
    implements ReminderPreferencesRepository {
  DriftReminderPreferencesRepository(this._db);

  final AppDatabase _db;

  @override
  Future<ReminderPreferences> get() async {
    final row = await (_db.select(
      _db.reminderPreferencesTable,
    )..where((table) => table.id.equals(1))).getSingleOrNull();
    if (row == null) return ReminderPreferences();
    return _fromRow(row);
  }

  @override
  Future<void> save(ReminderPreferences preferences) async {
    await _db
        .into(_db.reminderPreferencesTable)
        .insertOnConflictUpdate(
          ReminderPreferencesTableCompanion.insert(
            id: const Value(1),
            enabled: preferences.enabled,
            shiftStartLeadMinutes: preferences.shiftStartLeadMinutes,
            forgottenSessionAfterMinutes:
                preferences.forgottenSessionAfterMinutes,
          ),
        );
  }

  ReminderPreferences _fromRow(ReminderPreferencesRow row) =>
      ReminderPreferences(
        enabled: row.enabled,
        shiftStartLeadMinutes: row.shiftStartLeadMinutes,
        forgottenSessionAfterMinutes: row.forgottenSessionAfterMinutes,
      );
}
