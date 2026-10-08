import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:timeflow/l10n/app_localizations.dart';

/// Provides consistent top-level navigation on every main application screen.
class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({
    required this.location,
    required this.child,
    super.key,
  });

  final String location;
  final Widget child;

  static const _destinations = ['/today', '/calendar', '/reports', '/backup'];

  int get _selectedIndex {
    if (location.startsWith('/calendar')) return 1;
    if (location.startsWith('/reports')) return 2;
    if (location.startsWith('/backup')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: colors.primaryContainer,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? colors.primary
                  : colors.onSurfaceVariant,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              color: states.contains(WidgetState.selected)
                  ? colors.primary
                  : colors.onSurfaceVariant,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w500,
            );
          }),
        ),
        child: NavigationBar(
          key: const Key('main-navigation'),
          selectedIndex: _selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) => context.go(_destinations[index]),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.access_time),
              selectedIcon: const Icon(Icons.access_time_filled),
              label: l10n.navTimeClock,
              tooltip: l10n.todayTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: const Icon(Icons.calendar_month),
              label: l10n.navCalendar,
              tooltip: l10n.calendarTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: l10n.navReports,
              tooltip: l10n.reportsTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.backup_outlined),
              selectedIcon: const Icon(Icons.backup),
              label: l10n.navBackup,
              tooltip: l10n.backupTitle,
            ),
          ],
        ),
      ),
    );
  }
}
