import 'package:flutter/material.dart';

/// Temporary route entry point for the Phase 2 Calendar screen.
///
/// Planned-block functionality is implemented in the following Phase 2 slice.
class CalendarPlaceholderScreen extends StatelessWidget {
  const CalendarPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: const Center(child: Text('Planning calendar coming soon')),
    );
  }
}
