import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';
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

  testWidgets('renders Idle state with no sessions', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 1, 1, 9));

    await tester.pumpWidget(buildApp(db, clock));
    await tester.pumpAndSettle();

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

    await tester.pumpWidget(buildApp(db, clock));
    await tester.pumpAndSettle();

    expect(find.text('Running'), findsNWidgets(2));
    expect(find.text('01:30:00'), findsOneWidget);
  });
}
