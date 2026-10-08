import 'package:go_router/go_router.dart';

import 'calendar_screen.dart';
import 'backup_screen.dart';
import 'reports_screen.dart';
import 'today_screen.dart';
import 'main_navigation_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/today',
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          MainNavigationShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(
          path: '/today',
          builder: (context, state) => const TodayScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: '/backup',
          builder: (context, state) => const BackupScreen(),
        ),
      ],
    ),
  ],
);
