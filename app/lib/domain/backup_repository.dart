abstract interface class BackupRepository {
  Future<String> createBackup({required DateTime exportedAtUtc});

  /// Validates completely before atomically replacing the local data set.
  Future<void> restoreBackup(String content);
}
