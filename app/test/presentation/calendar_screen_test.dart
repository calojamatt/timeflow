import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/main.dart';
import 'package:timeflow/presentation/providers.dart';

import '../helpers/fake_clock.dart';

void main() {
  testWidgets('calendar day selector changes the day being reviewed', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(
            FakeClock(DateTime.utc(2026, 1, 5, 9)),
          ),
        ],
        child: const TimeFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Calendar'));
    await tester.pumpAndSettle();

    expect(find.text('2026-01-05'), findsOneWidget);
    expect(find.text('Change day'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byKey(const Key('calendar-day-picker')),
        matching: find.byType(Card),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('calendar-day-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('2026-01-08'), findsOneWidget);
    expect(find.text('No planned blocks'), findsOneWidget);
    final emptyPlanCard = find.byKey(const Key('empty-planned-blocks-card'));
    expect(emptyPlanCard, findsOneWidget);
    expect(
      find.descendant(
        of: emptyPlanCard,
        matching: find.text('No planned blocks'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('adds, edits, and deletes a planned block', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 1, 5, 9));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
        ],
        child: const TimeFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Calendar'));
    await tester.pumpAndSettle();

    expect(find.text('No planned blocks'), findsOneWidget);
    await tester.tap(find.byTooltip('Add planned block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('09:00 – 17:00'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('09:00 – 17:00'),
        matching: find.byType(Card),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('09:00 – 17:00'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '10:00');
    await tester.enterText(find.byType(TextField).at(1), '18:00');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('10:00 – 18:00'), findsOneWidget);
    await tester.tap(find.byTooltip('Delete planned block'));
    await tester.pumpAndSettle();
    expect(find.text('No planned blocks'), findsOneWidget);
  });
}
