import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/main.dart';
import 'package:timeflow/presentation/providers.dart';

import '../helpers/fake_clock.dart';

void _usePhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(412, 915);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('inline calendar selection loads that day planned blocks', (
    tester,
  ) async {
    _usePhoneViewport(tester);
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

    expect(find.byKey(const Key('calendar-day-2026-01-05')), findsOneWidget);
    await tester.tap(find.byTooltip('Add planned block'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('09:00 – 17:00'), findsOneWidget);
    await tester.tap(find.byKey(const Key('calendar-day-2026-01-08')));
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
    await tester.tap(find.byKey(const Key('calendar-day-2026-01-05')));
    await tester.pumpAndSettle();
    expect(find.text('09:00 – 17:00'), findsOneWidget);

    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text('February 2026'), findsOneWidget);
    expect(find.text('2026-01-05'), findsOneWidget);
    expect(find.text('09:00 – 17:00'), findsOneWidget);

    await tester.tap(find.byKey(const Key('calendar-day-2026-02-05')));
    await tester.pumpAndSettle();
    expect(find.text('2026-02-05'), findsOneWidget);
    expect(find.text('No planned blocks'), findsOneWidget);
  });

  testWidgets('adds, edits, and deletes a planned block', (tester) async {
    _usePhoneViewport(tester);
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

  testWidgets('accepts a manually entered midnight block end', (tester) async {
    _usePhoneViewport(tester);
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
    await tester.tap(find.byTooltip('Add planned block'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '20:30');
    await tester.enterText(find.byType(TextField).at(1), '00:00');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('20:30 – 00:00'), findsOneWidget);
  });

  testWidgets('automatically inserts a colon in manually typed times', (
    tester,
  ) async {
    _usePhoneViewport(tester);
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
    await tester.tap(find.byTooltip('Add planned block'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '2030');
    await tester.enterText(find.byType(TextField).at(1), '0000');

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].controller!.text, '20:30');
    expect(fields[1].controller!.text, '00:00');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('20:30 – 00:00'), findsOneWidget);
  });

  testWidgets('planned block time picker opens from the end-time field', (
    tester,
  ) async {
    _usePhoneViewport(tester);
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
    await tester.tap(find.byTooltip('Add planned block'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('end-time-picker')));
    await tester.pumpAndSettle();

    expect(find.byType(TimePickerDialog), findsOneWidget);
  });

  testWidgets(
    'selecting midnight in the time picker ends the block at day end',
    (tester) async {
      _usePhoneViewport(tester);
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
      await tester.tap(find.byTooltip('Add planned block'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '20:30');
      await tester.tap(find.byKey(const Key('end-time-picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();

      final pickerFields = find.descendant(
        of: find.byType(TimePickerDialog),
        matching: find.byType(TextField),
      );
      await tester.enterText(pickerFields.first, '0');
      await tester.enterText(pickerFields.last, '0');
      await tester.tap(find.text('OK').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('20:30 – 00:00'), findsOneWidget);
    },
  );
}
