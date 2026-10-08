import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeflow/domain/backup_document.dart';
import 'package:timeflow/domain/backup_file_service.dart';

class NativeBackupFileService implements BackupFileService {
  @override
  Future<void> shareBackup({
    required String fileName,
    required String content,
  }) async {
    final file = XFile.fromData(
      utf8.encode(content),
      mimeType: 'application/json',
      name: fileName,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        fileNameOverrides: [fileName],
        subject: 'TimeFlow backup',
        title: 'Save TimeFlow backup',
      ),
    );
  }

  @override
  Future<String?> pickBackup() async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (result == null) return null;
    final length = await result.length();
    if (length != null && length > BackupDocument.maximumContentBytes) {
      throw const FormatException('Backup exceeds the 25 MiB size limit');
    }
    final bytes = await result.readAsBytes();
    return utf8.decode(bytes, allowMalformed: false);
  }
}
