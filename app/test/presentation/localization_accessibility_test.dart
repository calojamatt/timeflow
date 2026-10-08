import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/l10n/app_localizations.dart';
import 'package:timeflow/presentation/providers.dart';
import 'package:timeflow/presentation/today_screen.dart';
import 'package:timeflow/presentation/reports_screen.dart';
import 'package:timeflow/presentation/backup_screen.dart';
import 'package:timeflow/presentation/main_navigation_shell.dart';

import '../helpers/fake_clock.dart';

void main() {
  testWidgets('uses Spanish translations and accessible action names', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(
            FakeClock(DateTime.utc(2026, 10, 8, 12)),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const MainNavigationShell(
            location: '/today',
            child: TodayScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reloj'), findsNWidgets(2));
    expect(find.text('Inactivo'), findsOneWidget);
    expect(find.byTooltip('Calendario'), findsOneWidget);
    expect(find.text('Calendario'), findsOneWidget);
    expect(find.text('Informes'), findsOneWidget);
    expect(find.text('Copia'), findsOneWidget);
    expect(find.byTooltip('Copia y restauración'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('localizes reports and privacy controls in Spanish', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FakeClock(DateTime.utc(2026, 10, 8, 12));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MainNavigationShell(
            location: '/reports',
            child: ReportsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Informes'), findsNWidgets(2));
    expect(find.text('Resumen diario'), findsOneWidget);
    expect(find.text('Real'), findsOneWidget);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(clock),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MainNavigationShell(
            location: '/backup',
            child: BackupScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Copia y restauración'), findsOneWidget);
    expect(find.text('Crear copia de seguridad'), findsOneWidget);
    expect(find.text('Controles de privacidad'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Eliminar todos los datos locales'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Eliminar todos los datos locales'), findsOneWidget);
  });
}
