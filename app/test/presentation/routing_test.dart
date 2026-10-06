import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/main.dart';
import 'package:timeflow/presentation/providers.dart';

import '../helpers/fake_clock.dart';

import 'package:drift/native.dart';

void main() {
  testWidgets('starts on Today and navigates to Calendar', (tester) async {
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

    expect(find.text('Today'), findsOneWidget);
    await tester.tap(find.byTooltip('Calendar'));
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Planning calendar coming soon'), findsOneWidget);
  });
}
