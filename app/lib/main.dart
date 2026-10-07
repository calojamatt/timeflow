import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/app_router.dart';
import 'presentation/providers.dart';

void main() {
  runApp(const ProviderScope(child: TimeFlowApp()));
}

class TimeFlowApp extends ConsumerStatefulWidget {
  const TimeFlowApp({super.key});

  @override
  ConsumerState<TimeFlowApp> createState() => _TimeFlowAppState();
}

class _TimeFlowAppState extends ConsumerState<TimeFlowApp> {
  @override
  void initState() {
    super.initState();
    if (!Platform.isAndroid && !Platform.isIOS) return;
    Future.microtask(() {
      ref
          .read(reminderNotificationServiceProvider)
          .initialize(onRoute: (route) => appRouter.go(route));
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TimeFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      routerConfig: appRouter,
    );
  }
}
