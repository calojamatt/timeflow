import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/domain/planned_block.dart';

import 'calendar_controller.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendar = ref.watch(calendarControllerProvider);
    final date = _dateFromDay(calendar.localDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDate: date,
              );
              if (selected != null && context.mounted) {
                await ref
                    .read(calendarControllerProvider.notifier)
                    .selectDay(selected);
              }
            },
            tooltip: 'Select date',
            icon: const Icon(Icons.event),
          ),
          IconButton(
            onPressed: () => _createTemplate(context, ref),
            tooltip: 'Weekly templates',
            icon: const Icon(Icons.view_week),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editBlock(context, ref),
        tooltip: 'Add planned block',
        child: const Icon(Icons.add),
      ),
      body: calendar.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  _formatDate(date),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                _SummaryCard(state: calendar),
                const SizedBox(height: 16),
                if (calendar.blocks.isEmpty)
                  const Center(child: Text('No planned blocks'))
                else
                  ...calendar.blocks.map(
                    (block) => _BlockTile(
                      block: block,
                      onEdit: () => _editBlock(context, ref, block: block),
                      onDelete: () => ref
                          .read(calendarControllerProvider.notifier)
                          .deleteBlock(block.id),
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _editBlock(
    BuildContext context,
    WidgetRef ref, {
    PlannedBlock? block,
  }) async {
    final result = await showDialog<_BlockDraft>(
      context: context,
      builder: (_) => _BlockDialog(block: block),
    );
    if (result == null || !context.mounted) return;
    await ref
        .read(calendarControllerProvider.notifier)
        .saveBlock(
          id: block?.id,
          startMinute: result.startMinute,
          endMinute: result.endMinute,
          note: result.note,
        );
  }

  Future<void> _createTemplate(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_TemplateDraft>(
      context: context,
      builder: (_) => const _TemplateDialog(),
    );
    if (result == null || !context.mounted) return;
    await ref
        .read(calendarControllerProvider.notifier)
        .saveTemplateAndApply(
          name: result.name,
          weekday: result.weekday,
          startMinute: result.startMinute,
          endMinute: result.endMinute,
        );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});

  final CalendarState state;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Planned: ${formatDuration(state.planned)}'),
          Text('Actual: ${formatDuration(state.actual)}'),
          Text('Variance: ${formatDuration(state.variance.abs())}'),
        ],
      ),
    ),
  );
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({
    required this.block,
    required this.onEdit,
    required this.onDelete,
  });

  final PlannedBlock block;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(
      '${formatMinute(block.startMinute)} – ${formatMinute(block.endMinute)}',
    ),
    subtitle: Text(formatDuration(block.duration)),
    onTap: onEdit,
    trailing: IconButton(
      onPressed: onDelete,
      tooltip: 'Delete planned block',
      icon: const Icon(Icons.delete_outline),
    ),
  );
}

class _BlockDraft {
  const _BlockDraft(this.startMinute, this.endMinute, this.note);

  final int startMinute;
  final int endMinute;
  final String? note;
}

class _BlockDialog extends StatefulWidget {
  const _BlockDialog({this.block});

  final PlannedBlock? block;

  @override
  State<_BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<_BlockDialog> {
  late final TextEditingController _start;
  late final TextEditingController _end;
  late final TextEditingController _note;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start = TextEditingController(
      text: formatMinute(widget.block?.startMinute ?? 9 * 60),
    );
    _end = TextEditingController(
      text: formatMinute(widget.block?.endMinute ?? 17 * 60),
    );
    _note = TextEditingController(text: widget.block?.note ?? '');
  }

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.block == null ? 'Add planned block' : 'Edit planned block',
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _start,
          decoration: const InputDecoration(labelText: 'Start (HH:MM)'),
          keyboardType: TextInputType.datetime,
        ),
        TextField(
          controller: _end,
          decoration: const InputDecoration(labelText: 'End (HH:MM)'),
          keyboardType: TextInputType.datetime,
        ),
        TextField(
          controller: _note,
          decoration: const InputDecoration(labelText: 'Note (optional)'),
        ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  );

  void _save() {
    final start = parseMinute(_start.text);
    final end = parseMinute(_end.text);
    if (start == null || end == null || end <= start) {
      setState(() => _error = 'Enter a valid non-overnight time range');
      return;
    }
    Navigator.pop(
      context,
      _BlockDraft(
        start,
        end,
        _note.text.trim().isEmpty ? null : _note.text.trim(),
      ),
    );
  }
}

class _TemplateDraft {
  const _TemplateDraft({
    required this.name,
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
  });

  final String name;
  final int weekday;
  final int startMinute;
  final int endMinute;
}

class _TemplateDialog extends StatefulWidget {
  const _TemplateDialog();

  @override
  State<_TemplateDialog> createState() => _TemplateDialogState();
}

class _TemplateDialogState extends State<_TemplateDialog> {
  final _name = TextEditingController();
  final _start = TextEditingController(text: '09:00');
  final _end = TextEditingController(text: '17:00');
  int _weekday = DateTime.monday;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create weekly template'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        DropdownButtonFormField<int>(
          initialValue: _weekday,
          decoration: const InputDecoration(labelText: 'Weekday'),
          items: [
            for (var day = DateTime.monday; day <= DateTime.sunday; day++)
              DropdownMenuItem(value: day, child: Text(_weekdayName(day))),
          ],
          onChanged: (value) => setState(() => _weekday = value ?? _weekday),
        ),
        TextField(
          controller: _start,
          decoration: const InputDecoration(labelText: 'Start (HH:MM)'),
        ),
        TextField(
          controller: _end,
          decoration: const InputDecoration(labelText: 'End (HH:MM)'),
        ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save & apply')),
    ],
  );

  void _save() {
    final start = parseMinute(_start.text);
    final end = parseMinute(_end.text);
    if (_name.text.trim().isEmpty ||
        start == null ||
        end == null ||
        end <= start) {
      setState(() => _error = 'Enter a name and valid time range');
      return;
    }
    Navigator.pop(
      context,
      _TemplateDraft(
        name: _name.text.trim(),
        weekday: _weekday,
        startMinute: start,
        endMinute: end,
      ),
    );
  }
}

String _weekdayName(int weekday) => const [
  '',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][weekday];

DateTime _dateFromDay(int localDay) =>
    DateTime(1970, 1, 1).add(Duration(days: localDay));

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String formatMinute(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';

int? parseMinute(String text) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(text.trim());
  if (match == null) return null;
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final value = hour * 60 + minute;
  return hour <= 23 && minute <= 59 ? value : null;
}

String formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  return '$hours:${minutes}h';
}
