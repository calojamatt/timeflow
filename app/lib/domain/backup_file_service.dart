abstract interface class BackupFileService {
  /// Opens the platform share sheet so users can save the backup to local files.
  Future<void> shareBackup({required String fileName, required String content});

  /// Opens the native file picker and returns UTF-8 backup contents.
  Future<String?> pickBackup();
}
