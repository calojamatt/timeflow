import 'package:drift/drift.dart';
import 'package:timeflow/domain/planned_block.dart';
import 'package:timeflow/domain/planning_repository.dart';
import 'package:timeflow/domain/weekly_template.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';

/// Drift-backed implementation of [PlanningRepository].
class DriftPlanningRepository implements PlanningRepository {
  DriftPlanningRepository(this._db, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  @override
  Future<PlannedBlock> createPlannedBlock({
    required int localDay,
    required int startMinute,
    required int endMinute,
    String? note,
  }) async {
    final block = PlannedBlock(
      id: _uuid.v4(),
      localDay: localDay,
      startMinute: startMinute,
      endMinute: endMinute,
      note: note,
    );
    await _db.into(_db.plannedBlocks).insert(_toBlockRow(block));
    return block;
  }

  @override
  Future<PlannedBlock> updatePlannedBlock(PlannedBlock block) async {
    final updated =
        await (_db.update(_db.plannedBlocks)
              ..where((table) => table.id.equals(block.id)))
            .write(_toBlockCompanion(block));
    if (updated == 0) {
      throw StateError('No planned block with id "${block.id}"');
    }
    return block;
  }

  @override
  Future<void> deletePlannedBlock(String id) async {
    final deleted = await (_db.delete(
      _db.plannedBlocks,
    )..where((table) => table.id.equals(id))).go();
    if (deleted == 0) {
      throw StateError('No planned block with id "$id"');
    }
  }

  @override
  Future<List<PlannedBlock>> getPlannedBlocksForDay(int localDay) async {
    final rows =
        await (_db.select(_db.plannedBlocks)
              ..where((table) => table.localDay.equals(localDay))
              ..orderBy([(table) => OrderingTerm.asc(table.startMinute)]))
            .get();
    return rows.map(_fromBlockRow).toList();
  }

  @override
  Future<List<PlannedBlock>> getPlannedBlocksBetween({
    required int fromLocalDay,
    required int toLocalDay,
  }) async {
    if (toLocalDay < fromLocalDay) {
      throw ArgumentError.value(toLocalDay, 'toLocalDay');
    }
    final rows =
        await (_db.select(_db.plannedBlocks)
              ..where(
                (table) =>
                    table.localDay.isBetweenValues(fromLocalDay, toLocalDay),
              )
              ..orderBy([
                (table) => OrderingTerm.asc(table.localDay),
                (table) => OrderingTerm.asc(table.startMinute),
              ]))
            .get();
    return rows.map(_fromBlockRow).toList();
  }

  @override
  Future<WeeklyTemplate> createWeeklyTemplate({
    required String name,
    required int weekday,
    required int startMinute,
    required int endMinute,
    String? note,
  }) async {
    final template = WeeklyTemplate(
      id: _uuid.v4(),
      name: name,
      weekday: weekday,
      startMinute: startMinute,
      endMinute: endMinute,
      note: note,
    );
    await _db.into(_db.weeklyTemplates).insert(_toTemplateRow(template));
    return template;
  }

  @override
  Future<WeeklyTemplate> updateWeeklyTemplate(WeeklyTemplate template) async {
    final updated =
        await (_db.update(_db.weeklyTemplates)
              ..where((table) => table.id.equals(template.id)))
            .write(_toTemplateCompanion(template));
    if (updated == 0) {
      throw StateError('No weekly template with id "${template.id}"');
    }
    return template;
  }

  @override
  Future<void> deleteWeeklyTemplate(String id) async {
    final deleted = await (_db.delete(
      _db.weeklyTemplates,
    )..where((table) => table.id.equals(id))).go();
    if (deleted == 0) {
      throw StateError('No weekly template with id "$id"');
    }
  }

  @override
  Future<List<WeeklyTemplate>> getWeeklyTemplates({int? weekday}) async {
    final query = _db.select(_db.weeklyTemplates);
    if (weekday != null) {
      query.where((table) => table.weekday.equals(weekday));
    }
    final rows =
        await (query..orderBy([
              (table) => OrderingTerm.asc(table.weekday),
              (table) => OrderingTerm.asc(table.startMinute),
            ]))
            .get();
    return rows.map(_fromTemplateRow).toList();
  }

  @override
  Future<List<PlannedBlock>> applyWeeklyTemplate({
    required String templateId,
    required int fromLocalDay,
    required int toLocalDay,
  }) async {
    if (toLocalDay < fromLocalDay) {
      throw ArgumentError.value(toLocalDay, 'toLocalDay');
    }
    final row = await (_db.select(
      _db.weeklyTemplates,
    )..where((table) => table.id.equals(templateId))).getSingleOrNull();
    if (row == null) {
      throw StateError('No weekly template with id "$templateId"');
    }
    final template = _fromTemplateRow(row);
    final blocks = <PlannedBlock>[];
    await _db.transaction(() async {
      for (var day = fromLocalDay; day <= toLocalDay; day++) {
        if (_weekdayFromLocalDay(day) != template.weekday) continue;
        blocks.add(
          await createPlannedBlock(
            localDay: day,
            startMinute: template.startMinute,
            endMinute: template.endMinute,
            note: template.note,
          ),
        );
      }
    });
    return blocks;
  }

  int _weekdayFromLocalDay(int localDay) =>
      DateTime.utc(1970, 1, 1).add(Duration(days: localDay)).weekday;

  PlannedBlockRow _toBlockRow(PlannedBlock block) => PlannedBlockRow(
    id: block.id,
    localDay: block.localDay,
    startMinute: block.startMinute,
    endMinute: block.endMinute,
    note: block.note,
  );

  PlannedBlocksCompanion _toBlockCompanion(PlannedBlock block) =>
      PlannedBlocksCompanion(
        localDay: Value(block.localDay),
        startMinute: Value(block.startMinute),
        endMinute: Value(block.endMinute),
        note: Value(block.note),
      );

  PlannedBlock _fromBlockRow(PlannedBlockRow row) => PlannedBlock(
    id: row.id,
    localDay: row.localDay,
    startMinute: row.startMinute,
    endMinute: row.endMinute,
    note: row.note,
  );

  WeeklyTemplateRow _toTemplateRow(WeeklyTemplate template) =>
      WeeklyTemplateRow(
        id: template.id,
        name: template.name,
        weekday: template.weekday,
        startMinute: template.startMinute,
        endMinute: template.endMinute,
        note: template.note,
      );

  WeeklyTemplatesCompanion _toTemplateCompanion(WeeklyTemplate template) =>
      WeeklyTemplatesCompanion(
        name: Value(template.name),
        weekday: Value(template.weekday),
        startMinute: Value(template.startMinute),
        endMinute: Value(template.endMinute),
        note: Value(template.note),
      );

  WeeklyTemplate _fromTemplateRow(WeeklyTemplateRow row) => WeeklyTemplate(
    id: row.id,
    name: row.name,
    weekday: row.weekday,
    startMinute: row.startMinute,
    endMinute: row.endMinute,
    note: row.note,
  );
}
