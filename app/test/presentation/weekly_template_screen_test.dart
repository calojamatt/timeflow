import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/main.dart';
import 'package:timeflow/presentation/providers.dart';

import '../helpers/fake_clock.dart';

void main() {
  testWidgets('saves and applies a weekly template', (tester) async {
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
    await tester.tap(find.byTooltip('Weekly templates'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Standard week');
    await tester.tap(find.text('Save & apply'));
    await tester.pumpAndSettle();

    expect(find.text('09:00 – 17:00'), findsOneWidget);
  });
}
