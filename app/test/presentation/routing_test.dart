import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/main.dart';
import 'package:timeflow/presentation/providers.dart';

import '../helpers/fake_clock.dart';

import 'package:drift/native.dart';

void main() {
  testWidgets('keeps navigation visible and switches active destinations', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(
            FakeClock(DateTime.utc(2026, 1, 1, 9)),
          ),
        ],
        child: const TimeFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Time Clock'), findsOneWidget);
    expect(find.byKey(const Key('main-navigation')), findsOneWidget);
    expect(
      tester
          .widget<NavigationBar>(find.byKey(const Key('main-navigation')))
          .selectedIndex,
      0,
    );
    await tester.tap(find.byTooltip('Calendar'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Calendar')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<NavigationBar>(find.byKey(const Key('main-navigation')))
          .selectedIndex,
      1,
    );
    expect(find.byKey(const Key('calendar-day-card')), findsOneWidget);
    expect(find.byKey(const Key('calendar-day-2026-01-01')), findsOneWidget);
    expect(find.text('No planned blocks'), findsOneWidget);

    await tester.tap(find.byTooltip('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Daily summary'), findsOneWidget);
    expect(
      tester
          .widget<NavigationBar>(find.byKey(const Key('main-navigation')))
          .selectedIndex,
      2,
    );

    await tester.tap(find.byTooltip('Backup & Restore'));
    await tester.pumpAndSettle();
    expect(find.text('Create backup'), findsOneWidget);
    expect(
      tester
          .widget<NavigationBar>(find.byKey(const Key('main-navigation')))
          .selectedIndex,
      3,
    );
  });
}
