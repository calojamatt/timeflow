import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/domain/day_plan_summary.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/domain/planned_block.dart';

import 'providers.dart';

class CalendarState {
  const CalendarState({
    required this.localDay,
    required this.blocks,
    required this.summary,
    required this.loading,
  });

  final int localDay;
  final List<PlannedBlock> blocks;
  final DayPlanSummary summary;
  final bool loading;

  Duration get planned => summary.planned;

  Duration get actual => summary.actual;

  Duration get variance => summary.variance;
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
      summary: const DayPlanSummary(
        planned: Duration.zero,
        actual: Duration.zero,
      ),
      loading: true,
    );
  }

  Future<void> load(int localDay) async {
    state = CalendarState(
      localDay: localDay,
      blocks: state.blocks,
      summary: state.summary,
      loading: true,
    );
    final blocks = await ref
        .read(planningRepositoryProvider)
        .getPlannedBlocksForDay(localDay);
    final sessions = await ref
        .read(workSessionRepositoryProvider)
        .getByDay(localDay);
    final now = ref.read(clockProvider).now();
    final summary = calculateDayPlanSummary(
      plannedBlocks: blocks,
      sessions: sessions,
      now: now,
    );
    state = CalendarState(
      localDay: localDay,
      blocks: blocks,
      summary: summary,
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

  Future<void> saveTemplateAndApply({
    required String name,
    required int weekday,
    required int startMinute,
    required int endMinute,
    String? note,
  }) async {
    final repository = ref.read(planningRepositoryProvider);
    final template = await repository.createWeeklyTemplate(
      name: name,
      weekday: weekday,
      startMinute: startMinute,
      endMinute: endMinute,
      note: note,
    );
    await repository.applyWeeklyTemplate(
      templateId: template.id,
      fromLocalDay: state.localDay,
      toLocalDay: state.localDay + 6,
    );
    await load(state.localDay);
  }
}
