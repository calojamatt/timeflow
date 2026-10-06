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

    expect(find.text('Today'), findsOneWidget);
  });
}

Future<void> pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for the requested UI state');
}
