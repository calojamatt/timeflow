import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:timeflow/domain/planned_block.dart';
import 'package:timeflow/l10n/app_localizations.dart';

import 'calendar_controller.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final calendar = ref.watch(calendarControllerProvider);
    final date = _dateFromDay(calendar.localDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendarTitle),
        actions: [
          IconButton(
            onPressed: () => _createTemplate(context, ref),
            tooltip: l10n.weeklyTemplates,
            icon: const Icon(Icons.view_week),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editBlock(context, ref),
        tooltip: l10n.addPlannedBlock,
        child: const Icon(Icons.add),
      ),
      body: calendar.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _InlineMonthCalendar(
                  selectedDate: date,
                  onDateSelected: (selected) => ref
                      .read(calendarControllerProvider.notifier)
                      .selectDay(selected),
                ),
                const SizedBox(height: 16),
                _SummaryCard(state: calendar),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: Text(
                    l10n.plannedBlocksTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (calendar.blocks.isEmpty)
                  Card(
                    key: const Key('empty-planned-blocks-card'),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 32,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(l10n.noPlannedBlocks),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _editBlock(context, ref),
                            icon: const Icon(Icons.add),
                            label: Text(l10n.addPlannedBlock),
                          ),
                        ],
                      ),
                    ),
                  )
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

class _InlineMonthCalendar extends StatefulWidget {
  const _InlineMonthCalendar({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime selectedDate;
  final Future<void> Function(DateTime date) onDateSelected;

  @override
  State<_InlineMonthCalendar> createState() => _InlineMonthCalendarState();
}

class _InlineMonthCalendarState extends State<_InlineMonthCalendar> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  @override
  void didUpdateWidget(covariant _InlineMonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate.year != widget.selectedDate.year ||
        oldWidget.selectedDate.month != widget.selectedDate.month) {
      _visibleMonth = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final materialL10n = MaterialLocalizations.of(context);
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month);
    final leadingDays = firstOfMonth.weekday - DateTime.monday;
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final cellCount = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;

    return Card(
      key: const Key('calendar-day-card'),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    materialL10n.formatMonthYear(_visibleMonth),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: materialL10n.previousMonthTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: materialL10n.nextMonthTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Row(
              children: [
                for (
                  var weekday = DateTime.monday;
                  weekday <= DateTime.sunday;
                  weekday++
                )
                  Expanded(
                    child: Center(
                      child: Text(
                        _weekdayName(l10n, weekday).substring(0, 2),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            GridView.builder(
              key: const Key('calendar-month-grid'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cellCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: 38,
              ),
              itemBuilder: (context, index) {
                final day = index - leadingDays + 1;
                final cellDate = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month,
                  day,
                );
                final isCurrentMonth = cellDate.month == _visibleMonth.month;
                final isSelected = _sameDate(cellDate, widget.selectedDate);
                final isToday = _sameDate(cellDate, DateTime.now());
                final colorScheme = Theme.of(context).colorScheme;

                return Center(
                  child: InkWell(
                    key: Key('calendar-day-${_formatDate(cellDate)}'),
                    customBorder: const CircleBorder(),
                    onTap: () => _selectDate(cellDate),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? colorScheme.primary : null,
                        border: isToday && !isSelected
                            ? Border.all(color: colorScheme.primary)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${cellDate.day}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : isCurrentMonth
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.45,
                                ),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _formatDate(widget.selectedDate),
                key: const Key('calendar-selected-date'),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(
      () => _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      ),
    );
  }

  Future<void> _selectDate(DateTime date) async {
    if (date.year != _visibleMonth.year || date.month != _visibleMonth.month) {
      setState(() => _visibleMonth = DateTime(date.year, date.month));
    }
    await widget.onDateSelected(date);
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.state});

  final CalendarState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.planned}: ${formatDuration(state.planned)}'),
            Text('${l10n.actual}: ${formatDuration(state.actual)}'),
            Text('${l10n.variance}: ${formatDuration(state.variance.abs())}'),
          ],
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      key: Key('planned-block-card-${block.id}'),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          '${formatMinute(block.startMinute)} – ${formatMinute(block.endMinute)}',
        ),
        subtitle: Text(
          [
            formatDuration(block.duration),
            if (block.note != null && block.note!.isNotEmpty) block.note!,
          ].join(' · '),
        ),
        onTap: onEdit,
        trailing: IconButton(
          onPressed: onDelete,
          tooltip: l10n.deletePlannedBlock,
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.block == null ? l10n.addPlannedBlock : l10n.editPlannedBlock,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _timeField(
            context: context,
            controller: _start,
            label: l10n.startTime,
            pickerKey: 'start-time-picker',
          ),
          _timeField(
            context: context,
            controller: _end,
            label: l10n.endTime,
            pickerKey: 'end-time-picker',
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

  void _save() {
    final start = parseMinute(_start.text);
    final parsedEnd = parseMinute(_end.text);
    final end = parsedEnd == 0 && start != null && start > 0 ? 1440 : parsedEnd;
    if (start == null || end == null || end <= start) {
      setState(
        () => _error = AppLocalizations.of(context)!.validTimeRangeError,
      );
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.createWeeklyTemplate),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.name),
          ),
          DropdownButtonFormField<int>(
            initialValue: _weekday,
            decoration: InputDecoration(labelText: l10n.weekday),
            items: [
              for (var day = DateTime.monday; day <= DateTime.sunday; day++)
                DropdownMenuItem(
                  value: day,
                  child: Text(_weekdayName(l10n, day)),
                ),
            ],
            onChanged: (value) => setState(() => _weekday = value ?? _weekday),
          ),
          _timeField(
            context: context,
            controller: _start,
            label: l10n.startTime,
            pickerKey: 'start-time-picker',
          ),
          _timeField(
            context: context,
            controller: _end,
            label: l10n.endTime,
            pickerKey: 'end-time-picker',
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
        FilledButton(onPressed: _save, child: Text(l10n.saveAndApply)),
      ],
    );
  }

  void _save() {
    final start = parseMinute(_start.text);
    final parsedEnd = parseMinute(_end.text);
    final end = parsedEnd == 0 && start != null && start > 0 ? 1440 : parsedEnd;
    if (_name.text.trim().isEmpty ||
        start == null ||
        end == null ||
        end <= start) {
      setState(
        () => _error = AppLocalizations.of(context)!.nameAndTimeRangeError,
      );
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

String _weekdayName(AppLocalizations l10n, int weekday) => switch (weekday) {
  DateTime.monday => l10n.weekdayMonday,
  DateTime.tuesday => l10n.weekdayTuesday,
  DateTime.wednesday => l10n.weekdayWednesday,
  DateTime.thursday => l10n.weekdayThursday,
  DateTime.friday => l10n.weekdayFriday,
  DateTime.saturday => l10n.weekdaySaturday,
  DateTime.sunday => l10n.weekdaySunday,
  _ => '',
};

DateTime _dateFromDay(int localDay) =>
    DateTime(1970, 1, 1).add(Duration(days: localDay));

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

bool _sameDate(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String formatMinute(int minute) => minute == 1440
    ? '00:00'
    : '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';

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

Widget _timeField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  required String pickerKey,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        key: Key(pickerKey),
        tooltip: label,
        icon: const Icon(Icons.access_time),
        onPressed: () => _pickTime(context, controller),
      ),
    ),
    keyboardType: TextInputType.datetime,
    inputFormatters: const [_AutoColonTimeInputFormatter()],
  );
}

Future<void> _pickTime(
  BuildContext context,
  TextEditingController controller,
) async {
  final currentMinute = parseMinute(controller.text) ?? 9 * 60;
  final selected = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: currentMinute ~/ 60,
      minute: currentMinute % 60,
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  if (selected == null) return;
  controller.text = formatMinute(selected.hour * 60 + selected.minute);
}

class _AutoColonTimeInputFormatter extends TextInputFormatter {
  const _AutoColonTimeInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 4) return oldValue;

    final formatted = digits.length > 2
        ? '${digits.substring(0, 2)}:${digits.substring(2)}'
        : digits;

    int formattedOffset(int offset) {
      final boundedOffset = offset.clamp(0, newValue.text.length);
      final digitsBeforeCursor = newValue.text
          .substring(0, boundedOffset)
          .replaceAll(RegExp(r'[^0-9]'), '')
          .length;
      final boundedDigits = digitsBeforeCursor > digits.length
          ? digits.length
          : digitsBeforeCursor;
      return boundedDigits > 2 ? boundedDigits + 1 : boundedDigits;
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection(
        baseOffset: formattedOffset(newValue.selection.baseOffset),
        extentOffset: formattedOffset(newValue.selection.extentOffset),
      ),
      composing: TextRange.empty,
    );
  }
}
