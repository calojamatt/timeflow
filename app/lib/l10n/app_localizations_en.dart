// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get todayTitle => 'Time Clock';

  @override
  String get navTimeClock => 'Clock';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get backupTitle => 'Backup & Restore';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navReports => 'Reports';

  @override
  String get navBackup => 'Backup';

  @override
  String get changeCalendarDay => 'Change day';

  @override
  String get startWork => 'Start';

  @override
  String get stopWork => 'Stop';

  @override
  String get running => 'Running';

  @override
  String get inProgress => 'In progress';

  @override
  String get idle => 'Idle';

  @override
  String totalToday(String duration) {
    return 'Total today: $duration';
  }

  @override
  String get noSessionsYet => 'No sessions yet';

  @override
  String get noPlannedBlocks => 'No planned blocks';

  @override
  String get selectDate => 'Select date';

  @override
  String get weeklyTemplates => 'Weekly templates';

  @override
  String get addPlannedBlock => 'Add planned block';

  @override
  String get editPlannedBlock => 'Edit planned block';

  @override
  String get planned => 'Planned';

  @override
  String get actual => 'Actual';

  @override
  String get variance => 'Variance';

  @override
  String get deletePlannedBlock => 'Delete planned block';

  @override
  String get startTime => 'Start (HH:MM)';

  @override
  String get endTime => 'End (HH:MM)';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get createWeeklyTemplate => 'Create weekly template';

  @override
  String get name => 'Name';

  @override
  String get weekday => 'Weekday';

  @override
  String get saveAndApply => 'Save & apply';

  @override
  String get validTimeRangeError => 'Enter a valid non-overnight time range';

  @override
  String get nameAndTimeRangeError => 'Enter a name and valid time range';

  @override
  String get weekdayMonday => 'Monday';

  @override
  String get weekdayTuesday => 'Tuesday';

  @override
  String get weekdayWednesday => 'Wednesday';

  @override
  String get weekdayThursday => 'Thursday';

  @override
  String get weekdayFriday => 'Friday';

  @override
  String get weekdaySaturday => 'Saturday';

  @override
  String get weekdaySunday => 'Sunday';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get reportPeriod => 'Reporting period';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get dailySummary => 'Daily summary';

  @override
  String get weeklySummary => 'Weekly summary';

  @override
  String get monthlySummary => 'Monthly summary';

  @override
  String get couldNotLoadReport => 'Could not load report';

  @override
  String get csvReadyToShare => 'CSV ready to share';

  @override
  String get couldNotExportReport => 'Could not export report';

  @override
  String get sessions => 'Sessions';

  @override
  String get noSessionsForDay => 'No sessions for this day';

  @override
  String get couldNotLoadSessions => 'Could not load sessions';

  @override
  String get deleteSessionQuestion => 'Delete session?';

  @override
  String get deleteSessionBody => 'This recorded work time will be removed.';

  @override
  String get delete => 'Delete';

  @override
  String get sessionActions => 'Session actions';

  @override
  String get editSession => 'Edit session';

  @override
  String get deleteSession => 'Delete session';

  @override
  String get startLabel => 'Start';

  @override
  String get endLabel => 'End';

  @override
  String get endMustFollowStart => 'End must be after start';

  @override
  String get couldNotUpdateSession => 'Could not update session';

  @override
  String get couldNotDeleteSession => 'Could not delete session';

  @override
  String get backupIntro =>
      'TimeFlow stores your work data on this device. Create a JSON backup and save it somewhere safe. Restoring replaces all current TimeFlow data on this device.';

  @override
  String get createBackup => 'Create backup';

  @override
  String get restoreFromFile => 'Restore from file';

  @override
  String get backupContents =>
      'Backups include work sessions, planned blocks, weekly templates, and reminder preferences. TimeFlow does not upload this data unless you choose a sharing destination.';

  @override
  String get privacyControls => 'Privacy controls';

  @override
  String get deleteAllLocalDataDescription =>
      'Delete all locally stored sessions, plans, templates, and reminder preferences. This does not remove copies you previously shared or saved outside TimeFlow.';

  @override
  String get deleteAllLocalData => 'Delete all local data';

  @override
  String get replaceLocalDataQuestion => 'Replace local data?';

  @override
  String get replaceLocalDataBody =>
      'The selected backup will replace all work sessions, plans, templates, and reminder preferences on this device. This cannot be undone.';

  @override
  String get replaceData => 'Replace data';

  @override
  String get deleteAllDataQuestion => 'Delete all local data?';

  @override
  String get deleteAllDataBody =>
      'All sessions, plans, templates, and reminder preferences on this device will be permanently deleted. This cannot be undone.';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get backupReadyToSave => 'Backup ready to save';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get allLocalDataDeleted => 'All local TimeFlow data deleted';

  @override
  String get couldNotCreateBackup => 'Could not create backup';

  @override
  String get couldNotRestoreBackup => 'Could not restore backup';

  @override
  String get couldNotDeleteLocalData => 'Could not delete all local data';
}
