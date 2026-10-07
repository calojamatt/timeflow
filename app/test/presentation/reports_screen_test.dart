import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/data/planning_repository_impl.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/main.dart';
import 'package:timeflow/presentation/providers.dart';
import 'package:timeflow/presentation/app_router.dart';

import '../helpers/fake_clock.dart';

void main() {
  testWidgets('shows daily actual, planned, and variance summaries', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2026, 1, 5, 12);
    final localDay = localDayFrom(now);
    final work = DriftWorkSessionRepository(db);
    final session = await work.start(
      startedAtUtc: DateTime(2026, 1, 5, 9).toUtc(),
      localDay: localDay,
    );
    await work.stop(session.id, endedAtUtc: DateTime(2026, 1, 5, 11).toUtc());
    await DriftPlanningRepository(db).createPlannedBlock(
      localDay: localDay,
      startMinute: 9 * 60,
      endMinute: 17 * 60,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FakeClock(now)),
        ],
        child: const TimeFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reports'));
    await tester.pumpAndSettle();

    expect(find.text('Daily summary'), findsOneWidget);
    expect(find.byKey(const Key('report-Actual')), findsOneWidget);
    expect(find.byKey(const Key('report-Planned')), findsOneWidget);
    expect(find.byKey(const Key('report-Variance')), findsOneWidget);
    expect(find.text('2h 0m'), findsNWidgets(2));
    expect(find.text('8h 0m'), findsOneWidget);
    expect(find.text('-6h 0m'), findsOneWidget);
  });

  testWidgets('switches summary period and recalculates date range', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    appRouter.go('/today');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FakeClock(DateTime(2026, 1, 5, 12))),
        ],
        child: const TimeFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reports'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-period')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Week').last);
    await tester.pumpAndSettle();

    expect(find.text('Weekly summary'), findsOneWidget);
    expect(find.text('2026-01-05 – 2026-01-11'), findsOneWidget);
  });

  testWidgets('edits and deletes a closed historical session', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final now = DateTime(2026, 1, 5, 12);
    final start = DateTime(2026, 1, 5, 9).toUtc();
    final work = DriftWorkSessionRepository(db);
    final session = await work.start(
      startedAtUtc: start,
      localDay: localDayFrom(now),
    );
    await work.stop(session.id, endedAtUtc: DateTime(2026, 1, 5, 10).toUtc());

    appRouter.go('/today');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FakeClock(now)),
        ],
        child: const TimeFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reports'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Session actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit session'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Updated note');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Updated note'), findsOneWidget);

    await tester.tap(find.byTooltip('Session actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete session'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(find.text('No sessions for this day'), findsOneWidget);
  });
}
