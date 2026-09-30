import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';
import 'package:timeflow/domain/clock.dart';
import 'package:timeflow/domain/start_work.dart';
import 'package:timeflow/domain/stop_work.dart';
import 'package:timeflow/domain/work_session_repository.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final workSessionRepositoryProvider = Provider<WorkSessionRepository>((ref) {
  return DriftWorkSessionRepository(ref.watch(databaseProvider));
});

final startWorkProvider = Provider<StartWork>((ref) {
  return StartWork(
    ref.watch(clockProvider),
    ref.watch(workSessionRepositoryProvider),
  );
});

final stopWorkProvider = Provider<StopWork>((ref) {
  return StopWork(
    ref.watch(clockProvider),
    ref.watch(workSessionRepositoryProvider),
  );
});
