import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timeflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('planning flow navigates the inline month calendar', (
    tester,
  ) async {
    app.main();
    await _pumpUntilVisible(tester, find.text('Idle'));
    await tester.tap(find.byTooltip('Calendar'));
    await _pumpUntilVisible(tester, find.textContaining('Planned:'));

    expect(find.textContaining('Planned:'), findsOneWidget);
    expect(find.byTooltip('Add planned block'), findsOneWidget);
    expect(find.byTooltip('Weekly templates'), findsOneWidget);
    expect(find.byKey(const Key('calendar-day-card')), findsOneWidget);

    final selectedDay = DateTime.now().toLocal();
    final nextMonth = DateTime(selectedDay.year, selectedDay.month + 1);
    final selectedDayLabel = _formatDate(selectedDay);
    final nextMonthDayLabel = _formatDate(nextMonth);
    final calendarLocalizations = MaterialLocalizations.of(
      tester.element(find.byKey(const Key('calendar-day-card'))),
    );
    final nextMonthTitle = calendarLocalizations.formatMonthYear(nextMonth);

    expect(find.text(selectedDayLabel), findsOneWidget);
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    expect(find.text(nextMonthTitle), findsOneWidget);
    expect(find.text(selectedDayLabel), findsOneWidget);

    await tester.tap(find.byKey(Key('calendar-day-$nextMonthDayLabel')));
    await tester.pumpAndSettle();
    expect(find.text(nextMonthDayLabel), findsOneWidget);
    expect(find.byTooltip('Add planned block'), findsOneWidget);
  });
}

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for the requested UI state');
}
