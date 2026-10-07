import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/domain/local_day.dart';

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
    final (from, to) = _bounds(_date, _period);
    final report = ref.watch(
      reportSummaryProvider((
        fromLocalDay: localDayFrom(from),
        toLocalDay: localDayFrom(to),
      )),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<_ReportPeriod>(
            key: const Key('report-period'),
            initialValue: _period,
            decoration: const InputDecoration(labelText: 'Reporting period'),
            items: const [
              DropdownMenuItem(value: _ReportPeriod.day, child: Text('Day')),
              DropdownMenuItem(value: _ReportPeriod.week, child: Text('Week')),
              DropdownMenuItem(
                value: _ReportPeriod.month,
                child: Text('Month'),
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
            error: (error, stack) => Text('Could not load report: $error'),
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
                          _periodTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _Metric(
                          label: 'Actual',
                          value: _formatDuration(summary.actual),
                        ),
                        _Metric(
                          label: 'Planned',
                          value: _formatDuration(summary.planned),
                        ),
                        _Metric(
                          label: 'Variance',
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

  String get _periodTitle => switch (_period) {
    _ReportPeriod.day => 'Daily summary',
    _ReportPeriod.week => 'Weekly summary',
    _ReportPeriod.month => 'Monthly summary',
  };

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) setState(() => _date = selected);
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
