import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/planning_repository_impl.dart';
import 'package:timeflow/domain/planned_block.dart';

import '../helpers/in_memory_database.dart';

void main() {
  late final db = openInMemoryDatabase();
  late final repository = DriftPlanningRepository(db);

  tearDown(() async {
    await db.delete(db.plannedBlocks).go();
    await db.delete(db.weeklyTemplates).go();
  });

  tearDownAll(db.close);

  test('creates, queries, updates, and deletes planned blocks', () async {
    final created = await repository.createPlannedBlock(
      localDay: 20_000,
      startMinute: 9 * 60,
      endMinute: 17 * 60,
      note: 'Office',
    );

    final loaded = (await repository.getPlannedBlocksForDay(20_000)).single;
    expect(loaded.id, created.id);
    expect(loaded.startMinute, created.startMinute);
    expect(loaded.endMinute, created.endMinute);
    expect(loaded.note, created.note);

    final updated = PlannedBlock(
      id: created.id,
      localDay: created.localDay,
      startMinute: 10 * 60,
      endMinute: 18 * 60,
      note: created.note,
    );
    await repository.updatePlannedBlock(updated);
    expect(
      (await repository.getPlannedBlocksForDay(20_000)).single.startMinute,
      10 * 60,
    );

    await repository.deletePlannedBlock(created.id);
    expect(await repository.getPlannedBlocksForDay(20_000), isEmpty);
  });

  test('queries blocks by inclusive day range and start time', () async {
    await repository.createPlannedBlock(
      localDay: 20_002,
      startMinute: 12 * 60,
      endMinute: 13 * 60,
    );
    await repository.createPlannedBlock(
      localDay: 20_001,
      startMinute: 14 * 60,
      endMinute: 15 * 60,
    );
    await repository.createPlannedBlock(
      localDay: 20_001,
      startMinute: 9 * 60,
      endMinute: 10 * 60,
    );

    final blocks = await repository.getPlannedBlocksBetween(
      fromLocalDay: 20_001,
      toLocalDay: 20_002,
    );
    expect(blocks.map((block) => block.startMinute), [
      9 * 60,
      14 * 60,
      12 * 60,
    ]);
  });

  test('creates and filters weekly templates', () async {
    final monday = await repository.createWeeklyTemplate(
      name: 'Standard',
      weekday: DateTime.monday,
      startMinute: 9 * 60,
      endMinute: 17 * 60,
    );
    await repository.createWeeklyTemplate(
      name: 'Weekend',
      weekday: DateTime.saturday,
      startMinute: 10 * 60,
      endMinute: 14 * 60,
    );

    expect((await repository.getWeeklyTemplates()).length, 2);
    final loaded = (await repository.getWeeklyTemplates(
      weekday: monday.weekday,
    )).single;
    expect(loaded.id, monday.id);
    expect(loaded.name, monday.name);
  });

  test('applies a weekly template to matching dates', () async {
    final template = await repository.createWeeklyTemplate(
      name: 'Mondays',
      weekday: DateTime.monday,
      startMinute: 9 * 60,
      endMinute: 17 * 60,
    );
    final blocks = await repository.applyWeeklyTemplate(
      templateId: template.id,
      fromLocalDay: 20_000,
      toLocalDay: 20_006,
    );

    expect(blocks, hasLength(1));
    expect(blocks.single.localDay, 20_003);
    final stored = await repository.getPlannedBlocksForDay(20_003);
    expect(stored, hasLength(1));
    expect(stored.single.id, blocks.single.id);
  });

  test('rejects unknown records and invalid ranges', () async {
    expect(
      () => repository.getPlannedBlocksBetween(
        fromLocalDay: 20_001,
        toLocalDay: 20_000,
      ),
      throwsArgumentError,
    );
    expect(() => repository.deletePlannedBlock('missing'), throwsStateError);
  });
}
