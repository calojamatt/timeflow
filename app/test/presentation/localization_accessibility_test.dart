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
          home: const TodayScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Inactivo'), findsOneWidget);
    expect(find.byTooltip('Calendario'), findsOneWidget);
    expect(
      tester.getSemantics(find.byTooltip('Calendario')).tooltip,
      'Calendario',
    );
    expect(tester.getSemantics(find.byTooltip('Informes')).tooltip, 'Informes');
    expect(
      tester.getSemantics(find.byTooltip('Copia y restauración')).tooltip,
      'Copia y restauración',
    );
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
          home: const ReportsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Informes'), findsOneWidget);
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
          home: const BackupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Copia y restauración'), findsOneWidget);
    expect(find.text('Crear copia de seguridad'), findsOneWidget);
    expect(find.text('Controles de privacidad'), findsOneWidget);
    expect(find.text('Eliminar todos los datos locales'), findsOneWidget);
  });
}
