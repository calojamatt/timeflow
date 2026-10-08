import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @todayTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Clock'**
  String get todayTitle;

  /// No description provided for @navTimeClock.
  ///
  /// In en, this message translates to:
  /// **'Clock'**
  String get navTimeClock;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupTitle;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get navBackup;

  /// No description provided for @changeCalendarDay.
  ///
  /// In en, this message translates to:
  /// **'Change day'**
  String get changeCalendarDay;

  /// No description provided for @startWork.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startWork;

  /// No description provided for @stopWork.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopWork;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @idle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idle;

  /// No description provided for @totalToday.
  ///
  /// In en, this message translates to:
  /// **'Total today: {duration}'**
  String totalToday(String duration);

  /// No description provided for @noSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get noSessionsYet;

  /// No description provided for @noPlannedBlocks.
  ///
  /// In en, this message translates to:
  /// **'No planned blocks'**
  String get noPlannedBlocks;

  /// No description provided for @plannedBlocksTitle.
  ///
  /// In en, this message translates to:
  /// **'Planned blocks'**
  String get plannedBlocksTitle;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @weeklyTemplates.
  ///
  /// In en, this message translates to:
  /// **'Weekly templates'**
  String get weeklyTemplates;

  /// No description provided for @addPlannedBlock.
  ///
  /// In en, this message translates to:
  /// **'Add planned block'**
  String get addPlannedBlock;

  /// No description provided for @editPlannedBlock.
  ///
  /// In en, this message translates to:
  /// **'Edit planned block'**
  String get editPlannedBlock;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @actual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get actual;

  /// No description provided for @variance.
  ///
  /// In en, this message translates to:
  /// **'Variance'**
  String get variance;

  /// No description provided for @deletePlannedBlock.
  ///
  /// In en, this message translates to:
  /// **'Delete planned block'**
  String get deletePlannedBlock;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start (HH:MM)'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End (HH:MM)'**
  String get endTime;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @createWeeklyTemplate.
  ///
  /// In en, this message translates to:
  /// **'Create weekly template'**
  String get createWeeklyTemplate;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @weekday.
  ///
  /// In en, this message translates to:
  /// **'Weekday'**
  String get weekday;

  /// No description provided for @saveAndApply.
  ///
  /// In en, this message translates to:
  /// **'Save & apply'**
  String get saveAndApply;

  /// No description provided for @validTimeRangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-overnight time range'**
  String get validTimeRangeError;

  /// No description provided for @nameAndTimeRangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter a name and valid time range'**
  String get nameAndTimeRangeError;

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunday;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Reporting period'**
  String get reportPeriod;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily summary'**
  String get dailySummary;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly summary'**
  String get weeklySummary;

  /// No description provided for @monthlySummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly summary'**
  String get monthlySummary;

  /// No description provided for @couldNotLoadReport.
  ///
  /// In en, this message translates to:
  /// **'Could not load report'**
  String get couldNotLoadReport;

  /// No description provided for @csvReadyToShare.
  ///
  /// In en, this message translates to:
  /// **'CSV ready to share'**
  String get csvReadyToShare;

  /// No description provided for @couldNotExportReport.
  ///
  /// In en, this message translates to:
  /// **'Could not export report'**
  String get couldNotExportReport;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @noSessionsForDay.
  ///
  /// In en, this message translates to:
  /// **'No sessions for this day'**
  String get noSessionsForDay;

  /// No description provided for @couldNotLoadSessions.
  ///
  /// In en, this message translates to:
  /// **'Could not load sessions'**
  String get couldNotLoadSessions;

  /// No description provided for @deleteSessionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete session?'**
  String get deleteSessionQuestion;

  /// No description provided for @deleteSessionBody.
  ///
  /// In en, this message translates to:
  /// **'This recorded work time will be removed.'**
  String get deleteSessionBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @sessionActions.
  ///
  /// In en, this message translates to:
  /// **'Session actions'**
  String get sessionActions;

  /// No description provided for @editSession.
  ///
  /// In en, this message translates to:
  /// **'Edit session'**
  String get editSession;

  /// No description provided for @deleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get deleteSession;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @endLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endLabel;

  /// No description provided for @endMustFollowStart.
  ///
  /// In en, this message translates to:
  /// **'End must be after start'**
  String get endMustFollowStart;

  /// No description provided for @couldNotUpdateSession.
  ///
  /// In en, this message translates to:
  /// **'Could not update session'**
  String get couldNotUpdateSession;

  /// No description provided for @couldNotDeleteSession.
  ///
  /// In en, this message translates to:
  /// **'Could not delete session'**
  String get couldNotDeleteSession;

  /// No description provided for @backupIntro.
  ///
  /// In en, this message translates to:
  /// **'TimeFlow stores your work data on this device. Create a JSON backup and save it somewhere safe. Restoring replaces all current TimeFlow data on this device.'**
  String get backupIntro;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackup;

  /// No description provided for @restoreFromFile.
  ///
  /// In en, this message translates to:
  /// **'Restore from file'**
  String get restoreFromFile;

  /// No description provided for @backupContents.
  ///
  /// In en, this message translates to:
  /// **'Backups include work sessions, planned blocks, weekly templates, and reminder preferences. TimeFlow does not upload this data unless you choose a sharing destination.'**
  String get backupContents;

  /// No description provided for @privacyControls.
  ///
  /// In en, this message translates to:
  /// **'Privacy controls'**
  String get privacyControls;

  /// No description provided for @deleteAllLocalDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Delete all locally stored sessions, plans, templates, and reminder preferences. This does not remove copies you previously shared or saved outside TimeFlow.'**
  String get deleteAllLocalDataDescription;

  /// No description provided for @deleteAllLocalData.
  ///
  /// In en, this message translates to:
  /// **'Delete all local data'**
  String get deleteAllLocalData;

  /// No description provided for @replaceLocalDataQuestion.
  ///
  /// In en, this message translates to:
  /// **'Replace local data?'**
  String get replaceLocalDataQuestion;

  /// No description provided for @replaceLocalDataBody.
  ///
  /// In en, this message translates to:
  /// **'The selected backup will replace all work sessions, plans, templates, and reminder preferences on this device. This cannot be undone.'**
  String get replaceLocalDataBody;

  /// No description provided for @replaceData.
  ///
  /// In en, this message translates to:
  /// **'Replace data'**
  String get replaceData;

  /// No description provided for @deleteAllDataQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete all local data?'**
  String get deleteAllDataQuestion;

  /// No description provided for @deleteAllDataBody.
  ///
  /// In en, this message translates to:
  /// **'All sessions, plans, templates, and reminder preferences on this device will be permanently deleted. This cannot be undone.'**
  String get deleteAllDataBody;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @backupReadyToSave.
  ///
  /// In en, this message translates to:
  /// **'Backup ready to save'**
  String get backupReadyToSave;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestored;

  /// No description provided for @allLocalDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All local TimeFlow data deleted'**
  String get allLocalDataDeleted;

  /// No description provided for @couldNotCreateBackup.
  ///
  /// In en, this message translates to:
  /// **'Could not create backup'**
  String get couldNotCreateBackup;

  /// No description provided for @couldNotRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Could not restore backup'**
  String get couldNotRestoreBackup;

  /// No description provided for @couldNotDeleteLocalData.
  ///
  /// In en, this message translates to:
  /// **'Could not delete all local data'**
  String get couldNotDeleteLocalData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
