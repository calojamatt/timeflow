import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timeflow/main.dart' as app;

/// Smoke test that boots the app on a real device/emulator.
///
/// Run with: `flutter test integration_test` (requires a connected device).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots and renders', (tester) async {
    app.main();

    await pumpUntilVisible(tester, find.text('Idle'));

    expect(find.text('Time Clock'), findsOneWidget);
    await tester.tap(find.byTooltip('Backup & Restore'));
    await pumpUntilVisible(tester, find.text('Backup & Restore'));
    expect(find.text('Create backup'), findsOneWidget);
    expect(find.text('Restore from file'), findsOneWidget);
    await tester.tap(find.byTooltip('Time Clock'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reports'));
    await pumpUntilVisible(tester, find.text('Daily summary'));
    expect(find.text('Actual'), findsOneWidget);
    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Variance'), findsOneWidget);
  });
}

Future<void> pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for the requested UI state');
}
