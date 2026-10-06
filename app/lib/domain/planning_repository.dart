import 'planned_block.dart';
import 'weekly_template.dart';

/// Persistence contract for planned work and reusable weekly schedules.
abstract interface class PlanningRepository {
  Future<PlannedBlock> createPlannedBlock({
    required int localDay,
    required int startMinute,
    required int endMinute,
    String? note,
  });

  Future<PlannedBlock> updatePlannedBlock(PlannedBlock block);

  Future<void> deletePlannedBlock(String id);

  Future<List<PlannedBlock>> getPlannedBlocksForDay(int localDay);

  Future<List<PlannedBlock>> getPlannedBlocksBetween({
    required int fromLocalDay,
    required int toLocalDay,
  });

  Future<WeeklyTemplate> createWeeklyTemplate({
    required String name,
    required int weekday,
    required int startMinute,
    required int endMinute,
    String? note,
  });

  Future<WeeklyTemplate> updateWeeklyTemplate(WeeklyTemplate template);

  Future<void> deleteWeeklyTemplate(String id);

  Future<List<WeeklyTemplate>> getWeeklyTemplates({int? weekday});

  /// Materializes a template into date-specific planned blocks.
  Future<List<PlannedBlock>> applyWeeklyTemplate({
    required String templateId,
    required int fromLocalDay,
    required int toLocalDay,
  });
}
