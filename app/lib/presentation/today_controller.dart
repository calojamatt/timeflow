import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/domain/work_session.dart';

import 'providers.dart';

/// Immutable UI state for the Today screen.
class TodayState {
  const TodayState({
    required this.openSession,
    required this.sessions,
    required this.now,
  });

  final WorkSession? openSession;
  final List<WorkSession> sessions;
  final DateTime now;

  bool get isRunning => openSession != null;

  Duration get elapsed => openSession?.elapsedAt(now) ?? Duration.zero;

  Duration get total =>
      sessions.fold(Duration.zero, (sum, s) => sum + s.elapsedAt(now));
}

final todayControllerProvider = NotifierProvider<TodayController, TodayState>(
  TodayController.new,
);

class TodayController extends Notifier<TodayState> {
  Timer? _ticker;

  @override
  TodayState build() {
    final now = ref.read(clockProvider).now();
    ref.onDispose(_stopTicker);
    Future.microtask(load);
    return TodayState(openSession: null, sessions: const [], now: now);
  }

  Future<void> load() async {
    final repository = ref.read(workSessionRepositoryProvider);
    final now = ref.read(clockProvider).now();
    final open = await repository.findOpen();
    final day = open?.localDay ?? localDayFrom(now);
    final sessions = await repository.getByDay(day);
    open == null ? _stopTicker() : _startTicker();
    state = TodayState(openSession: open, sessions: sessions, now: now);
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    final now = ref.read(clockProvider).now();
    state = TodayState(
      openSession: state.openSession,
      sessions: state.sessions,
      now: now,
    );
  }

  /// Starts a new work session (no-op if one is already open).
  Future<void> start() async {
    await ref.read(startWorkProvider).call();
    await load();
  }

  /// Stops the open work session (no-op if none is open).
  Future<void> stop() async {
    await ref.read(stopWorkProvider).call();
    await load();
  }

  /// Toggles between start and stop based on the current state.
  Future<void> toggle() async {
    if (state.isRunning) {
      await stop();
    } else {
      await start();
    }
  }
}
