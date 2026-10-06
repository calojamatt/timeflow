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

    // The controller loads today's sessions via drift on a background
    // isolate, which pumpAndSettle does not track. Pump real frames so the
    // initial load completes before the test tears the database down.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump();

    expect(find.text('Today'), findsOneWidget);
  });
}
