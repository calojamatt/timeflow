import 'package:drift/native.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/data/planning_repository_impl.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/domain/csv_share_service.dart';
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

  testWidgets('custom range drives summary totals and CSV export bounds', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final work = DriftWorkSessionRepository(db);
    final planning = DriftPlanningRepository(db);

    final jan5 = localDayFrom(DateTime(2026, 1, 5));
    final jan8 = localDayFrom(DateTime(2026, 1, 8));
    final jan9 = localDayFrom(DateTime(2026, 1, 9));
    final jan5Session = await work.start(
      startedAtUtc: DateTime(2026, 1, 5, 9).toUtc(),
      localDay: jan5,
    );
    await work.stop(
      jan5Session.id,
      endedAtUtc: DateTime(2026, 1, 5, 11).toUtc(),
    );
    final jan8Session = await work.start(
      startedAtUtc: DateTime(2026, 1, 8, 9).toUtc(),
      localDay: jan8,
    );
    await work.stop(
      jan8Session.id,
      endedAtUtc: DateTime(2026, 1, 8, 12).toUtc(),
    );
    final jan9Session = await work.start(
      startedAtUtc: DateTime(2026, 1, 9, 9).toUtc(),
      localDay: jan9,
    );
    await work.stop(
      jan9Session.id,
      endedAtUtc: DateTime(2026, 1, 9, 10).toUtc(),
    );
    await planning.createPlannedBlock(
      localDay: jan5,
      startMinute: 9 * 60,
      endMinute: 12 * 60,
    );
    await planning.createPlannedBlock(
      localDay: jan8,
      startMinute: 10 * 60,
      endMinute: 12 * 60,
    );
    await planning.createPlannedBlock(
      localDay: jan9,
      startMinute: 9 * 60,
      endMinute: 15 * 60,
    );
    final share = _FakeCsvShareService();

    appRouter.go('/today');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FakeClock(DateTime(2026, 1, 10, 12))),
          csvShareServiceProvider.overrideWithValue(share),
        ],
        child: const TimeFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reports'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-period')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom range').last);
    await tester.pumpAndSettle();

    expect(find.byType(DateRangePickerDialog), findsNothing);
    await tester.tap(find.byKey(const Key('report-select-date')));
    await tester.pumpAndSettle();
    expect(find.byType(DateRangePickerDialog), findsOneWidget);
    await tester.tap(find.text('5').first);
    await tester.tap(find.text('8').first);
    await tester.tap(find.text('Save').last);
    await tester.pumpAndSettle();

    expect(find.text('2026-01-05 – 2026-01-08'), findsOneWidget);
    expect(find.byKey(const Key('report-Actual')), findsOneWidget);
    expect(find.text('5h 0m'), findsNWidgets(2));
    expect(find.text('0h 0m'), findsOneWidget);
    expect(find.byTooltip('Session actions'), findsNothing);

    await tester.tap(find.byTooltip('Export CSV'));
    await tester.pumpAndSettle();

    expect(share.fileName, 'timeflow-report-20260105-20260108.csv');
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

  testWidgets('exports the selected period through the share boundary', (
    tester,
  ) async {
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
    await DriftPlanningRepository(db).createPlannedBlock(
      localDay: localDayFrom(now),
      startMinute: 11 * 60,
      endMinute: 12 * 60,
    );
    final share = _FakeCsvShareService();

    appRouter.go('/today');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(FakeClock(now)),
          csvShareServiceProvider.overrideWithValue(share),
        ],
        child: const TimeFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reports'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Export CSV'));
    await tester.pumpAndSettle();

    expect(find.text('CSV ready to share'), findsOneWidget);
    expect(share.fileName, 'timeflow-report-20260105-20260105.csv');
    final rows = const CsvDecoder().convert(share.content!);
    expect(rows.map((row) => row[1]), ['Type', 'Actual', 'Planned']);
  });
}

class _FakeCsvShareService implements CsvShareService {
  String? fileName;
  String? content;

  @override
  Future<void> shareCsv({
    required String fileName,
    required String content,
  }) async {
    this.fileName = fileName;
    this.content = content;
  }
}
