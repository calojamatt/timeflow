import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Backup & Restore')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'TimeFlow stores your work data on this device. Create a JSON backup '
          'and save it somewhere safe. Restoring replaces all current TimeFlow '
          'data on this device.',
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          key: const Key('create-backup'),
          onPressed: _busy ? null : _createBackup,
          icon: const Icon(Icons.save_alt),
          label: const Text('Create backup'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('restore-backup'),
          onPressed: _busy ? null : _restoreBackup,
          icon: const Icon(Icons.restore),
          label: const Text('Restore from file'),
        ),
        if (_busy) ...[
          const SizedBox(height: 20),
          const Center(child: CircularProgressIndicator()),
        ],
        const SizedBox(height: 24),
        const Text(
          'Backups include work sessions, planned blocks, weekly templates, '
          'and reminder preferences. TimeFlow does not upload this data unless '
          'you choose a sharing destination.',
        ),
        const SizedBox(height: 32),
        const Divider(),
        Text(
          'Privacy controls',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Delete all locally stored sessions, plans, templates, and reminder '
          'preferences. This does not remove copies you previously shared or '
          'saved outside TimeFlow.',
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          key: const Key('delete-local-data'),
          onPressed: _busy ? null : _deleteAllLocalData,
          icon: const Icon(Icons.delete_forever),
          label: const Text('Delete all local data'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    ),
  );

  Future<void> _createBackup() async {
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
      _message('Backup ready to save');
    } catch (error) {
      _message('Could not create backup: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreBackup() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final content = await ref.read(backupFileServiceProvider).pickBackup();
      if (content == null || !mounted) return;
      setState(() => _busy = false);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Replace local data?'),
          content: const Text(
            'The selected backup will replace all work sessions, plans, '
            'templates, and reminder preferences on this device. This cannot '
            'be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Replace data'),
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
      _message('Backup restored');
    } catch (error) {
      _message('Could not restore backup: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAllLocalData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all local data?'),
        content: const Text(
          'All sessions, plans, templates, and reminder preferences on this '
          'device will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete permanently'),
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
      _message('All local TimeFlow data deleted');
    } catch (error) {
      _message('Could not delete all local data: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
