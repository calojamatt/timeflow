abstract interface class LocalDataMaintenanceRepository {
  /// Atomically deletes all work, planning, template, and reminder settings.
  Future<void> deleteAllLocalData();
}
