abstract interface class CsvShareService {
  Future<void> shareCsv({required String fileName, required String content});
}
