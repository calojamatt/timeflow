import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/domain/work_session.dart';
import 'package:timeflow/l10n/app_localizations.dart';

import 'providers.dart';

class HistorySessionsSection extends ConsumerWidget {
  const HistorySessionsSection({required this.localDay, super.key});

  final int localDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sessions = ref.watch(workSessionHistoryProvider(localDay));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(l10n.sessions, style: Theme.of(context).textTheme.titleLarge),
        sessions.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Text(l10n.couldNotLoadSessions),
          data: (items) => items.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(l10n.noSessionsForDay),
                )
              : Column(
                  children: [
                    for (final session in items)
                      _HistorySessionTile(
                        session: session,
                        onEdit: session.isOpen
                            ? null
                            : () => _edit(context, ref, session),
                        onDelete: session.isOpen
                            ? null
                            : () => _delete(context, ref, session),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    WorkSession session,
  ) async {
    final draft = await showDialog<_SessionDraft>(
      context: context,
      builder: (_) => _EditSessionDialog(session: session),
    );
    if (draft == null || !context.mounted) return;
    try {
      await ref
          .read(workSessionRepositoryProvider)
          .updateHistorical(
            WorkSession(
              id: session.id,
              startedAtUtc: draft.startedAt.toUtc(),
              endedAtUtc: draft.endedAt.toUtc(),
              localDay: localDayFrom(draft.startedAt),
              note: draft.note,
            ),
          );
      _refresh(ref);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotUpdateSession),
          ),
        );
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WorkSession session,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteSessionQuestion),
        content: Text(l10n.deleteSessionBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    try {
      await ref
          .read(workSessionRepositoryProvider)
          .deleteHistorical(session.id);
      _refresh(ref);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotDeleteSession),
          ),
        );
      }
    }
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(workSessionHistoryProvider(localDay));
    ref.invalidate(reportSummaryProvider);
  }
}

class _HistorySessionTile extends StatelessWidget {
  const _HistorySessionTile({
    required this.session,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkSession session;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      title: Text(
        '${_formatMoment(session.startedAtUtc)} – '
        '${session.endedAtUtc == null ? AppLocalizations.of(context)!.running : _formatMoment(session.endedAtUtc!)}',
      ),
      subtitle: Text(
        [
          session.endedAtUtc == null
              ? AppLocalizations.of(context)!.inProgress
              : _formatDuration(
                  session.endedAtUtc!.difference(session.startedAtUtc),
                ),
          if (session.note != null && session.note!.isNotEmpty) session.note!,
        ].join(' · '),
      ),
      trailing: onEdit == null
          ? null
          : PopupMenuButton<String>(
              tooltip: AppLocalizations.of(context)!.sessionActions,
              onSelected: (action) {
                if (action == 'edit') onEdit!();
                if (action == 'delete') onDelete!();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(AppLocalizations.of(context)!.editSession),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(AppLocalizations.of(context)!.deleteSession),
                ),
              ],
            ),
    ),
  );
}

class _SessionDraft {
  const _SessionDraft(this.startedAt, this.endedAt, this.note);

  final DateTime startedAt;
  final DateTime endedAt;
  final String? note;
}

class _EditSessionDialog extends StatefulWidget {
  const _EditSessionDialog({required this.session});

  final WorkSession session;

  @override
  State<_EditSessionDialog> createState() => _EditSessionDialogState();
}

class _EditSessionDialogState extends State<_EditSessionDialog> {
  late DateTime _start;
  late DateTime _end;
  late final TextEditingController _note;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start = widget.session.startedAtUtc.toLocal();
    _end = widget.session.endedAtUtc!.toLocal();
    _note = TextEditingController(text: widget.session.note ?? '');
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.editSession),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.startLabel),
            subtitle: Text(_formatMoment(_start)),
            onTap: () => _pickMoment(start: true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.endLabel),
            subtitle: Text(_formatMoment(_end)),
            onTap: () => _pickMoment(start: false),
          ),
          TextField(
            controller: _note,
            decoration: InputDecoration(labelText: l10n.noteOptional),
          ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }

  Future<void> _pickMoment({required bool start}) async {
    final current = start ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (start) {
        _start = selected;
      } else {
        _end = selected;
      }
    });
  }

  void _save() {
    if (!_end.isAfter(_start)) {
      setState(() => _error = AppLocalizations.of(context)!.endMustFollowStart);
      return;
    }
    Navigator.pop(
      context,
      _SessionDraft(
        _start,
        _end,
        _note.text.trim().isEmpty ? null : _note.text.trim(),
      ),
    );
  }
}

String _formatMoment(DateTime value) =>
    '${value.year}-${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')} '
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

String _formatDuration(Duration value) =>
    '${value.inHours}h ${value.inMinutes % 60}m';
