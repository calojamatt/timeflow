import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/app_database.dart';

import '../helpers/in_memory_database.dart';

void main() {
  test('creates planning tables in a new database', () async {
    final db = openInMemoryDatabase();
    addTearDown(db.close);

    expect(await db.select(db.plannedBlocks).get(), isEmpty);
    expect(await db.select(db.weeklyTemplates).get(), isEmpty);
  });

  test('persists planned blocks and weekly templates', () async {
    final db = openInMemoryDatabase();
    addTearDown(db.close);

    await db
        .into(db.plannedBlocks)
        .insert(
          PlannedBlocksCompanion.insert(
            id: 'planned-1',
            localDay: 20_000,
            startMinute: 9 * 60,
            endMinute: 17 * 60,
          ),
        );
    await db
        .into(db.weeklyTemplates)
        .insert(
          WeeklyTemplatesCompanion.insert(
            id: 'template-1',
            name: 'Standard week',
            weekday: DateTime.monday,
            startMinute: 9 * 60,
            endMinute: 17 * 60,
          ),
        );

    expect((await db.select(db.plannedBlocks).get()).single.localDay, 20_000);
    expect(
      (await db.select(db.weeklyTemplates).get()).single.name,
      'Standard week',
    );
  });

  test('plans are indexed by local day and weekday', () async {
    final db = openInMemoryDatabase();
    addTearDown(db.close);

    final planned = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'ix_planned_blocks_local_day'",
        )
        .get();
    final templates = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name = 'ix_weekly_templates_weekday'",
        )
        .get();

    expect(planned, hasLength(1));
    expect(templates, hasLength(1));
  });
}
