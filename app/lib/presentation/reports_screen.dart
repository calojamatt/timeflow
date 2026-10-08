import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/l10n/app_localizations.dart';

import 'providers.dart';
import 'history_sessions_section.dart';

enum _ReportPeriod { day, week, month }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late DateTime _date;
  _ReportPeriod _period = _ReportPeriod.day;

  @override
  void initState() {
    super.initState();
    _date = ref.read(clockProvider).now().toLocal();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (from, to) = _bounds(_date, _period);
    final periodTitle = switch (_period) {
      _ReportPeriod.day => l10n.dailySummary,
      _ReportPeriod.week => l10n.weeklySummary,
      _ReportPeriod.month => l10n.monthlySummary,
    };
    final report = ref.watch(
      reportSummaryProvider((
        fromLocalDay: localDayFrom(from),
        toLocalDay: localDayFrom(to),
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsTitle),
        actions: [
          IconButton(
            tooltip: l10n.exportCsv,
            onPressed: () => _exportCsv(from: from, to: to),
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<_ReportPeriod>(
            key: const Key('report-period'),
            initialValue: _period,
            decoration: InputDecoration(labelText: l10n.reportPeriod),
            items: [
              DropdownMenuItem(
                value: _ReportPeriod.day,
                child: Text(l10n.periodDay),
              ),
              DropdownMenuItem(
                value: _ReportPeriod.week,
                child: Text(l10n.periodWeek),
              ),
              DropdownMenuItem(
                value: _ReportPeriod.month,
                child: Text(l10n.periodMonth),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _period = value);
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('report-select-date'),
            onPressed: _selectDate,
            icon: const Icon(Icons.event),
            label: Text(_formatRange(from, to)),
          ),
          const SizedBox(height: 16),
          report.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text(l10n.couldNotLoadReport),
            data: (summary) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          periodTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _Metric(
                          label: l10n.actual,
                          value: _formatDuration(summary.actual),
                        ),
                        _Metric(
                          label: l10n.planned,
                          value: _formatDuration(summary.planned),
                        ),
                        _Metric(
                          label: l10n.variance,
                          value: _formatDuration(
                            summary.variance,
                            signed: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_period == _ReportPeriod.day)
                  HistorySessionsSection(localDay: localDayFrom(from)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) setState(() => _date = selected);
  }

  Future<void> _exportCsv({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      await ref
          .read(exportReportCsvProvider)
          .call(
            fromLocalDay: localDayFrom(from),
            toLocalDay: localDayFrom(to),
            now: ref.read(clockProvider).now(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.csvReadyToShare),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotExportReport),
          ),
        );
      }
    }
  }

  (DateTime, DateTime) _bounds(DateTime date, _ReportPeriod period) {
    final day = DateTime(date.year, date.month, date.day);
    return switch (period) {
      _ReportPeriod.day => (day, day),
      _ReportPeriod.week => (
        day.subtract(Duration(days: day.weekday - DateTime.monday)),
        day.add(Duration(days: DateTime.sunday - day.weekday)),
      ),
      _ReportPeriod.month => (
        DateTime(day.year, day.month),
        DateTime(day.year, day.month + 1).subtract(const Duration(days: 1)),
      ),
    };
  }

  String _formatRange(DateTime from, DateTime to) => from == to
      ? _formatDate(from)
      : '${_formatDate(from)} – ${_formatDate(to)}';

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, key: Key('report-$label')),
      ],
    ),
  );
}

String _formatDuration(Duration duration, {bool signed = false}) {
  final minutes = duration.inMinutes;
  final sign = signed && minutes > 0 ? '+' : '';
  final absolute = minutes.abs();
  return '$sign${minutes < 0 ? '-' : ''}${absolute ~/ 60}h ${absolute % 60}m';
}
