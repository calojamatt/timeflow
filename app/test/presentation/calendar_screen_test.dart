import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/main.dart';
import 'package:timeflow/presentation/providers.dart';

import '../helpers/fake_clock.dart';

void main() {
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
