import 'package:go_router/go_router.dart';

import 'calendar_placeholder_screen.dart';
import 'today_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/today',
  routes: [
    GoRoute(path: '/today', builder: (context, state) => const TodayScreen()),
    GoRoute(
      path: '/calendar',
      builder: (context, state) => const CalendarPlaceholderScreen(),
    ),
  ],
);
