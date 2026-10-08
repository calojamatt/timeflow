import 'package:timeflow/domain/local_data_maintenance_repository.dart';

import 'app_database.dart';

class DriftLocalDataMaintenanceRepository
    implements LocalDataMaintenanceRepository {
  DriftLocalDataMaintenanceRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> deleteAllLocalData() => _db.transaction(() async {
    await _db.delete(_db.workSessions).go();
    await _db.delete(_db.plannedBlocks).go();
    await _db.delete(_db.weeklyTemplates).go();
    await _db.delete(_db.reminderPreferencesTable).go();
  });
}
