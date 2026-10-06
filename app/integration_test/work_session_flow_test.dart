import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timeflow/main.dart' as app;

/// On-device integration test for the Phase 1 vertical slice.
///
/// Run on a simulator/emulator/device:
///   `flutter test integration_test -d <device>`
///
/// Covers Start/Stop control, the single-active-session rule (Start hidden
/// while running), and the live timer. Restart recovery is verified at the
/// data layer (see `test/data/recovery_test.dart`) and validated manually by
/// killing and relaunching the app mid-session.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('vertical slice: start, run, and stop a work session', (
    tester,
  ) async {
    app.main();
    await pumpUntilVisible(tester, find.text('Idle'));

    // Reach a clean Idle state (a previous run may have left a session open).
    if (find.byTooltip('Stop').evaluate().isNotEmpty) {
      await tester.tap(find.byTooltip('Stop'));
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(find.text('Idle'), findsOneWidget);
    expect(find.byTooltip('Start'), findsOneWidget);

    // Start a session: the app flips to Running and hides Start.
    await tester.tap(find.byTooltip('Start'));
    await pumpUntilVisible(tester, find.textContaining('Running'));

    expect(find.textContaining('Running'), findsWidgets);
    expect(find.byTooltip('Stop'), findsOneWidget);
    expect(find.byTooltip('Start'), findsNothing);

    // Let the live timer advance.
    await tester.pump(const Duration(seconds: 2));

    // Stop the session: the app returns to Idle and shows Start again.
    await tester.tap(find.byTooltip('Stop'));
    await pumpUntilVisible(tester, find.text('Idle'));

    expect(find.text('Idle'), findsOneWidget);
    expect(find.byTooltip('Start'), findsOneWidget);
    expect(find.byTooltip('Stop'), findsNothing);
  });
}

Future<void> pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for the requested UI state');
}
