import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/presentation/providers.dart';
import 'package:timeflow/presentation/today_screen.dart';

import '../helpers/fake_clock.dart';

void main() {
  Widget buildApp(AppDatabase db, FakeClock clock) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(clock),
      ],
      child: const MaterialApp(home: TodayScreen()),
    );
  }

  Future<void> pumpAndLoad(WidgetTester tester, Widget app) async {
    await tester.pumpWidget(app);
    await tester.pump();
    await tester.pump();
  }

  testWidgets('renders Idle state with no sessions', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 1, 1, 9));

    await pumpAndLoad(tester, buildApp(db, clock));

    expect(find.text('Idle'), findsOneWidget);
    expect(find.text('No sessions yet'), findsOneWidget);
  });

  testWidgets('renders Running state with elapsed time and session list', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 1, 1, 9));
    final repository = DriftWorkSessionRepository(db);

    await repository.start(
      startedAtUtc: DateTime.utc(2026, 1, 1, 9),
      localDay: 20454,
    );
    clock.advance(const Duration(hours: 1, minutes: 30));

    await pumpAndLoad(tester, buildApp(db, clock));

    expect(find.textContaining('Running'), findsNWidgets(2));
    expect(find.text('01:30:00'), findsOneWidget);
  });

  testWidgets('Start/Stop button toggles and drives the use cases', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 1, 1, 9));

    await pumpAndLoad(tester, buildApp(db, clock));

    expect(find.byTooltip('Start'), findsOneWidget);
    expect(find.byTooltip('Stop'), findsNothing);

    await tester.tap(find.byTooltip('Start'));
    await tester.pump();
    await tester.pump();

    expect(find.byTooltip('Stop'), findsOneWidget);
    expect(find.byTooltip('Start'), findsNothing);
    expect(find.textContaining('Running'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Stop'));
    await tester.pump();
    await tester.pump();

    expect(find.byTooltip('Start'), findsOneWidget);
    expect(find.byTooltip('Stop'), findsNothing);
    expect(find.text('Idle'), findsOneWidget);
  });

  testWidgets('elapsed time updates every second while running', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 1, 1, 9));
    final repository = DriftWorkSessionRepository(db);

    await repository.start(
      startedAtUtc: DateTime.utc(2026, 1, 1, 9),
      localDay: 20454,
    );

    await pumpAndLoad(tester, buildApp(db, clock));

    expect(find.text('00:00:00'), findsOneWidget);

    clock.advance(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('00:00:01'), findsOneWidget);
  });

  testWidgets('elapsed stays accurate when the app is backgrounded', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 1, 1, 9));
    final repository = DriftWorkSessionRepository(db);

    await repository.start(
      startedAtUtc: DateTime.utc(2026, 1, 1, 9),
      localDay: 20454,
    );

    await pumpAndLoad(tester, buildApp(db, clock));
    expect(find.text('00:00:00'), findsOneWidget);

    // Lock/background the phone for 2h15m: the wall clock advances but no
    // ticker fires. A single tick on resume must reflect the full elapsed.
    clock.advance(const Duration(hours: 2, minutes: 15));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('02:15:00'), findsOneWidget);
  });

  testWidgets('hides Start while a session is open', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 1, 1, 9));
    final repository = DriftWorkSessionRepository(db);

    await repository.start(
      startedAtUtc: DateTime.utc(2026, 1, 1, 9),
      localDay: 20454,
    );

    await pumpAndLoad(tester, buildApp(db, clock));

    expect(find.byTooltip('Stop'), findsOneWidget);
    expect(find.byTooltip('Start'), findsNothing);
  });

  testWidgets('session history shows closed session end time and duration', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 1, 1, 14));
    final repository = DriftWorkSessionRepository(db);

    final session = await repository.start(
      startedAtUtc: DateTime.utc(2026, 1, 1, 9),
      localDay: 20454,
    );
    await repository.stop(
      session.id,
      endedAtUtc: DateTime.utc(2026, 1, 1, 11, 30),
    );

    await pumpAndLoad(tester, buildApp(db, clock));

    final tile = find.byType(ListTile);
    expect(tile, findsOneWidget);
    expect(
      find.descendant(of: tile, matching: find.text('02:30:00')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: tile, matching: find.textContaining('–')),
      findsOneWidget,
    );
  });

  testWidgets('today total equals the sum of closed sessions', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 1, 1, 14));
    final repository = DriftWorkSessionRepository(db);
    final day = localDayFrom(clock.now());

    final first = await repository.start(
      startedAtUtc: DateTime.utc(2026, 1, 1, 9),
      localDay: day,
    );
    await repository.stop(first.id, endedAtUtc: DateTime.utc(2026, 1, 1, 10));

    final second = await repository.start(
      startedAtUtc: DateTime.utc(2026, 1, 1, 10, 30),
      localDay: day,
    );
    await repository.stop(second.id, endedAtUtc: DateTime.utc(2026, 1, 1, 12));

    await pumpAndLoad(tester, buildApp(db, clock));

    expect(find.text('Total today: 02:30:00'), findsOneWidget);
  });

  testWidgets('today total includes the open session elapsed time', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 1, 1, 11));
    final repository = DriftWorkSessionRepository(db);
    final day = localDayFrom(clock.now());

    final closed = await repository.start(
      startedAtUtc: DateTime.utc(2026, 1, 1, 9),
      localDay: day,
    );
    await repository.stop(closed.id, endedAtUtc: DateTime.utc(2026, 1, 1, 10));

    await repository.start(
      startedAtUtc: DateTime.utc(2026, 1, 1, 10, 30),
      localDay: day,
    );

    await pumpAndLoad(tester, buildApp(db, clock));

    expect(find.text('Total today: 01:30:00'), findsOneWidget);
  });
}
