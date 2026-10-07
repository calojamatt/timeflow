import 'dart:convert';

import 'package:share_plus/share_plus.dart';
import 'package:timeflow/domain/csv_share_service.dart';

class SharePlusCsvShareService implements CsvShareService {
  @override
  Future<void> shareCsv({
    required String fileName,
    required String content,
  }) async {
    final file = XFile.fromData(
      utf8.encode(content),
      mimeType: 'text/csv',
      name: fileName,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        fileNameOverrides: [fileName],
        subject: fileName,
      ),
    );
  }
}
