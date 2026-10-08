import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/l10n/app_localizations.dart';

import 'calendar_controller.dart';
import 'providers.dart';
import 'today_controller.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.backupIntro),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('create-backup'),
            onPressed: _busy ? null : _createBackup,
            icon: const Icon(Icons.save_alt),
            label: Text(l10n.createBackup),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('restore-backup'),
            onPressed: _busy ? null : _restoreBackup,
            icon: const Icon(Icons.restore),
            label: Text(l10n.restoreFromFile),
          ),
          if (_busy) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
          ],
          const SizedBox(height: 24),
          Text(l10n.backupContents),
          const SizedBox(height: 32),
          const Divider(),
          Text(
            l10n.privacyControls,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.deleteAllLocalDataDescription),
          const SizedBox(height: 8),
          TextButton.icon(
            key: const Key('delete-local-data'),
            onPressed: _busy ? null : _deleteAllLocalData,
            icon: const Icon(Icons.delete_forever),
            label: Text(l10n.deleteAllLocalData),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final now = ref.read(clockProvider).now().toUtc();
      final content = await ref
          .read(backupRepositoryProvider)
          .createBackup(exportedAtUtc: now);
      final stamp =
          '${now.year.toString().padLeft(4, '0')}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}-'
          '${now.hour.toString().padLeft(2, '0')}'
          '${now.minute.toString().padLeft(2, '0')}'
          '${now.second.toString().padLeft(2, '0')}';
      await ref
          .read(backupFileServiceProvider)
          .shareBackup(
            fileName: 'timeflow-backup-$stamp.json',
            content: content,
          );
      _message(l10n.backupReadyToSave);
    } catch (error) {
      _message(l10n.couldNotCreateBackup);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final content = await ref.read(backupFileServiceProvider).pickBackup();
      if (content == null || !mounted) return;
      setState(() => _busy = false);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.replaceLocalDataQuestion),
          content: Text(l10n.replaceLocalDataBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.replaceData),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      setState(() => _busy = true);
      await ref.read(backupRepositoryProvider).restoreBackup(content);
      ref.invalidate(todayControllerProvider);
      ref.invalidate(calendarControllerProvider);
      ref.invalidate(workSessionHistoryProvider);
      ref.invalidate(reportSummaryProvider);
      _message(l10n.backupRestored);
    } catch (error) {
      _message(l10n.couldNotRestoreBackup);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAllLocalData() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAllDataQuestion),
        content: Text(l10n.deleteAllDataBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.deletePermanently),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(localDataMaintenanceRepositoryProvider)
          .deleteAllLocalData();
      await ref.read(reminderNotificationServiceProvider).cancelAll();
      ref.invalidate(todayControllerProvider);
      ref.invalidate(calendarControllerProvider);
      ref.invalidate(workSessionHistoryProvider);
      ref.invalidate(reportSummaryProvider);
      _message(l10n.allLocalDataDeleted);
    } catch (error) {
      _message(l10n.couldNotDeleteLocalData);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
