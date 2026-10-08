import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:timeflow/data/app_database.dart';
import 'package:timeflow/data/drift_backup_repository.dart';
import 'package:timeflow/data/native_backup_file_service.dart';
import 'package:timeflow/data/planning_repository_impl.dart';
import 'package:timeflow/data/report_repository_impl.dart';
import 'package:timeflow/data/share_plus_csv_service.dart';
import 'package:timeflow/domain/csv_share_service.dart';
import 'package:timeflow/domain/export_report_csv.dart';
import 'package:timeflow/domain/report_repository.dart';
import 'package:timeflow/domain/report_summary.dart';
import 'package:timeflow/domain/backup_file_service.dart';
import 'package:timeflow/domain/backup_repository.dart';
import 'package:timeflow/data/local_reminder_notification_service.dart';
import 'package:timeflow/domain/reminder.dart';
import 'package:timeflow/domain/reminder_scheduler.dart';
import 'package:timeflow/data/work_session_repository_impl.dart';
import 'package:timeflow/domain/clock.dart';
import 'package:timeflow/domain/planning_repository.dart';
import 'package:timeflow/domain/start_work.dart';
import 'package:timeflow/domain/stop_work.dart';
import 'package:timeflow/domain/work_session_repository.dart';
import 'package:timeflow/domain/work_session.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => DriftBackupRepository(ref.watch(databaseProvider)),
);

final backupFileServiceProvider = Provider<BackupFileService>(
  (ref) => NativeBackupFileService(),
);

final workSessionRepositoryProvider = Provider<WorkSessionRepository>((ref) {
  return DriftWorkSessionRepository(ref.watch(databaseProvider));
});

final workSessionHistoryProvider =
    FutureProvider.family<List<WorkSession>, int>(
      (ref, localDay) =>
          ref.watch(workSessionRepositoryProvider).getByDay(localDay),
    );

final planningRepositoryProvider = Provider<PlanningRepository>((ref) {
  return DriftPlanningRepository(ref.watch(databaseProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return DriftReportRepository(ref.watch(databaseProvider));
});

final reportSummaryProvider =
    FutureProvider.family<ReportSummary, ({int fromLocalDay, int toLocalDay})>((
      ref,
      period,
    ) {
      return ref
          .watch(reportRepositoryProvider)
          .getSummary(
            fromLocalDay: period.fromLocalDay,
            toLocalDay: period.toLocalDay,
            now: ref.watch(clockProvider).now(),
          );
    });

final csvShareServiceProvider = Provider<CsvShareService>(
  (ref) => SharePlusCsvShareService(),
);

final exportReportCsvProvider = Provider<ExportReportCsv>((ref) {
  return ExportReportCsv(
    ref.watch(workSessionRepositoryProvider),
    ref.watch(planningRepositoryProvider),
    ref.watch(csvShareServiceProvider),
  );
});

final reminderNotificationServiceProvider =
    Provider<ReminderNotificationService>(
      (ref) =>
          defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS
          ? LocalReminderNotificationService()
          : FakeReminderNotificationService(),
    );

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
