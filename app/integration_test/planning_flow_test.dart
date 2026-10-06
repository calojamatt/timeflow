import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timeflow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('planning flow opens the Calendar screen', (tester) async {
    app.main();
    await _pumpUntilVisible(tester, find.text('Idle'));
    await tester.tap(find.byTooltip('Calendar'));
    await _pumpUntilVisible(tester, find.text('Calendar'));

    expect(find.textContaining('Planned:'), findsOneWidget);
    expect(find.byTooltip('Add planned block'), findsOneWidget);
    expect(find.byTooltip('Weekly templates'), findsOneWidget);
  });
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for the requested UI state');
}
