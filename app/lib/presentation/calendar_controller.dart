import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/domain/planned_block.dart';
import 'package:timeflow/domain/work_session.dart';

import 'providers.dart';

class CalendarState {
  const CalendarState({
    required this.localDay,
    required this.blocks,
    required this.actual,
    required this.loading,
  });

  final int localDay;
  final List<PlannedBlock> blocks;
  final Duration actual;
  final bool loading;

  Duration get planned =>
      blocks.fold(Duration.zero, (total, block) => total + block.duration);

  Duration get variance => actual - planned;
}

final calendarControllerProvider =
    NotifierProvider<CalendarController, CalendarState>(CalendarController.new);

class CalendarController extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final day = localDayFrom(ref.read(clockProvider).now());
    Future.microtask(() => load(day));
    return CalendarState(
      localDay: day,
      blocks: const [],
      actual: Duration.zero,
      loading: true,
    );
  }

  Future<void> load(int localDay) async {
    state = CalendarState(
      localDay: localDay,
      blocks: state.blocks,
      actual: state.actual,
      loading: true,
    );
    final blocks = await ref
        .read(planningRepositoryProvider)
        .getPlannedBlocksForDay(localDay);
    final sessions = await ref
        .read(workSessionRepositoryProvider)
        .getByDay(localDay);
    final now = ref.read(clockProvider).now();
    state = CalendarState(
      localDay: localDay,
      blocks: blocks,
      actual: _total(sessions, now),
      loading: false,
    );
  }

  Future<void> selectDay(DateTime day) => load(localDayFrom(day));

  Future<void> saveBlock({
    String? id,
    required int startMinute,
    required int endMinute,
    String? note,
  }) async {
    final repository = ref.read(planningRepositoryProvider);
    if (id == null) {
      await repository.createPlannedBlock(
        localDay: state.localDay,
        startMinute: startMinute,
        endMinute: endMinute,
        note: note,
      );
    } else {
      await repository.updatePlannedBlock(
        PlannedBlock(
          id: id,
          localDay: state.localDay,
          startMinute: startMinute,
          endMinute: endMinute,
          note: note,
        ),
      );
    }
    await load(state.localDay);
  }

  Future<void> deleteBlock(String id) async {
    await ref.read(planningRepositoryProvider).deletePlannedBlock(id);
    await load(state.localDay);
  }

  Duration _total(List<WorkSession> sessions, DateTime now) => sessions.fold(
    Duration.zero,
    (total, session) => total + session.elapsedAt(now),
  );
}
