import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeflow/domain/work_session.dart';

import 'today_controller.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            onPressed: () => context.go('/calendar'),
            tooltip: 'Calendar',
            icon: const Icon(Icons.calendar_month),
          ),
          IconButton(
            onPressed: () => context.go('/reports'),
            tooltip: 'Reports',
            icon: const Icon(Icons.bar_chart),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(todayControllerProvider.notifier).toggle(),
        tooltip: today.isRunning ? 'Stop' : 'Start',
        child: Icon(today.isRunning ? Icons.stop : Icons.play_arrow),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TimerHeader(state: today),
          const Divider(height: 1),
          Expanded(
            child: today.sessions.isEmpty
                ? const Center(child: Text('No sessions yet'))
                : ListView.builder(
                    itemCount: today.sessions.length,
                    itemBuilder: (context, index) =>
                        _SessionTile(session: today.sessions[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimerHeader extends StatelessWidget {
  const _TimerHeader({required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            state.isRunning ? 'Running' : 'Idle',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            formatDuration(state.isRunning ? state.elapsed : state.total),
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Total today: ${formatDuration(state.total)}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final WorkSession session;

  @override
  Widget build(BuildContext context) {
    final start = formatClockTime(session.startedAtUtc.toLocal());
    final end = session.endedAtUtc;
    final endText = end == null ? 'Running' : formatClockTime(end.toLocal());

    return ListTile(
      title: Text('$start – $endText'),
      trailing: end == null
          ? null
          : Text(formatDuration(end.difference(session.startedAtUtc))),
    );
  }
}

/// Formats [duration] as `HH:MM:SS`.
String formatDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

/// Formats [time] as `HH:MM`.
String formatClockTime(DateTime time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}
