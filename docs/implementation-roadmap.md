# TimeFlow — Implementation Roadmap

This document reconciles the original product conversation in
`timeflow_chatgpt.md` with the current repository implementation. It is the
working plan for finishing the current release and implementing the pending
product phases.

## 1. Current product direction

TimeFlow is a local-first, offline-capable mobile application for recording
working time:

- Start and stop actual work sessions.
- Review today's sessions and total worked time.
- Define planned working hours separately from actual work.
- Compare planned and actual time.
- Receive work and forgotten-session reminders.
- Review weekly and monthly reports.
- Export and back up data locally.
- Keep cloud synchronization optional and deferred.

The application targets Android and iOS from one Flutter codebase.

## 2. Implemented architecture

The current code follows Clean Architecture with three layers:

```text
presentation → domain ← data
```

### Presentation layer

Location: `app/lib/presentation/`

Implemented:

- `TodayScreen`
- `TodayController`
- Riverpod providers
- Live timer repainting once per second
- Start/Stop control
- Current-day session history
- Daily total display

The UI does not access SQLite directly. It calls providers and domain use
cases.

### Domain layer

Location: `app/lib/domain/`

Implemented:

- `WorkSession`
- `StartWork`
- `StopWork`
- `Clock` abstraction and test clock
- Local-day calculation
- `WorkSessionRepository` contract

Business rules currently include:

- A session has a start and optional end.
- An open session is identified by `endedAtUtc == null`.
- A closed session cannot be stopped again.
- End time cannot precede start time.
- Sessions are assigned to the local day on which they start.
- Elapsed time is calculated from persisted timestamps.

### Data layer

Location: `app/lib/data/`

Implemented:

- Drift/SQLite database
- `work_sessions` table
- `DriftWorkSessionRepository`
- UTC timestamp persistence
- Local-day indexed query value
- Database-level single-open-session constraint
- In-memory database support for tests

The database is currently schema version 1.

### Reliability strategy

The timer is not a background counter. The application persists the start
timestamp immediately and derives elapsed time using:

```text
(endedAtUtc ?? now) - startedAtUtc
```

This allows recovery after app termination, phone lock, backgrounding, and
device restart without relying on a continuously running process.

### Testing and delivery

Implemented:

- Domain unit tests
- Drift repository integration tests
- Widget tests
- Integration-test vertical slice
- Flutter analyzer and formatter checks
- Android debug build in CI
- SonarQube scanning workflow

The original Phase 1 issues `#3` through `#28` are closed, and PRs `#29`
through `#49` are merged. PR `#31` was superseded by the SonarQube work in PR
`#49`.

## 3. Phase 1 — Finish and release the current slice

### Current status

The Phase 1 functionality is implemented, but release closure is still
pending. The current branch also contains the app logo work in PR `#51`.
PR `#50` contains an Android emulator rendering fix and a smoke-test fix.

### Remaining implementation work

#### 1. Merge and integrate pending PRs

- Review and merge PR `#50`.
- Review and merge PR `#51`.
- Rebase the working branch on the updated `develop` branch.
- Confirm CI, formatting, analysis, tests, and Android build.

#### 2. Complete device validation

Android validation must cover:

- App startup.
- Start and stop.
- Live timer progression.
- Background and phone-lock recovery.
- App kill and relaunch recovery.
- Database persistence.
- Rendering on the supported emulator/device configuration.

iOS validation requires macOS and Xcode because it cannot be completed on the
current Fedora/Linux development machine. It must cover the same behavior on an
iOS simulator or physical device.

#### 3. Harden the user flow

Add:

- Initial loading state while the database is queried.
- Disabled Start/Stop control while an operation is running.
- Duplicate-tap protection.
- User-visible error messages for failed operations.
- Recovery behavior for database errors.
- Tests for sessions crossing midnight.
- Tests for an invalid/backward system-clock change.
- Database migration test coverage.

#### 4. Release preparation

- Replace the default Flutter text in `app/README.md`.
- Update the root README phase status.
- Update the changelog for the release.
- Create `release/1.0.0`.
- Run the complete release validation suite.
- Tag `v1.0.0`.
- Build and verify the Android release artifact.
- Produce the iOS archive from macOS.

### Phase 1 acceptance criteria

- A user can start and stop work offline.
- A running session survives app termination and device restart.
- The single-open-session rule is enforced by both UI and database.
- Today's history and total are correct.
- Android validation passes on a real device or emulator.
- iOS validation passes on a simulator or real device.
- The release documentation and artifacts are complete.

## 4. Phase 2 — Planning and calendar

### Objective

Allow users to define planned hours independently from actual work sessions and
compare both values.

### Proposed implementation slices

#### P2.1 — Planned-work domain model

Add:

- `PlannedBlock` entity.
- `WeeklyTemplate` entity.
- Planned-work repository contract.
- Create, update, delete, and query use cases.

Rules should validate start/end times, duration, local-day ownership, and any
future overnight-shift behavior.

#### P2.2 — Database schema and migration

Add Drift tables for:

```text
planned_blocks
weekly_templates
```

Increase the schema version and add a migration from version 1. Test both a new
database and an existing Phase 1 database.

#### P2.3 — Navigation foundation

Use the existing `go_router` dependency and add routes:

```text
/today
/calendar
/reports
/settings
```

The Today screen must remain the default route.

#### P2.4 — Calendar screen

Implement:

- Month or week calendar view.
- Day selection.
- Planned blocks for the selected day.
- Actual work total for the selected day.
- Planned-versus-actual variance.
- Editing and deletion of planned blocks.

#### P2.5 — Phase 2 tests

- Domain unit tests.
- Repository integration tests.
- Schema migration tests.
- Calendar widget tests.
- Planned-versus-actual calculation tests.

### Phase 2 acceptance criteria

- Users can create planned hours without creating actual sessions.
- Planned and actual time remain separate records.
- Calendar data survives app restart.
- Daily variance is calculated correctly.
- Existing Phase 1 data remains readable after migration.

## 5. Phase 3 — Reminders and notifications

### Objective

Notify users about planned shifts and potentially forgotten open sessions.

### Proposed implementation slices

#### P3.1 — Notification service

Evaluate and add `flutter_local_notifications` for local notifications. Keep the
notification service behind an application interface so domain code does not
depend on a Flutter plugin.

#### P3.2 — Reminder preferences

Persist settings for:

- Reminders enabled/disabled.
- Shift-start lead time.
- Forgotten-session threshold.
- Weekday-specific schedules.

#### P3.3 — Platform behavior

Implement and verify:

- Android notification permission.
- iOS notification authorization.
- Time-zone changes.
- App restart behavior.
- Battery optimization limitations.
- Notification cancellation after stopping work.

#### P3.4 — Notification navigation

Notification taps should deep-link to the appropriate screen, normally
`/today` or `/calendar`.

#### P3.5 — Phase 3 tests

- Scheduling and cancellation.
- Disabled preferences.
- Forgotten-session detection.
- Time-zone changes.
- App restart recovery.
- Deep-link routing.

### Phase 3 acceptance criteria

- Notifications are local and work without cloud connectivity.
- Users can control reminder behavior.
- Stopping a session cancels any relevant forgotten-session reminder.
- Tapping a notification opens the correct screen.

## 6. Phase 4 — Reports and export

### Objective

Provide useful historical summaries and data export.

### Proposed implementation slices

#### P4.1 — Reporting queries

Implement daily, weekly, and monthly queries for:

- Actual total.
- Planned total.
- Planned-versus-actual variance.
- Session count.
- Per-day detail.

Prefer SQL aggregation in Drift for report queries rather than loading all rows
into the UI.

#### P4.2 — Reports screen

Add:

- Weekly summary.
- Monthly summary.
- Daily detail.
- Planned-versus-actual visualization.
- Basic charts only after the data queries are stable.

#### P4.3 — Historical session management

Implement:

- Delete a past session.
- Edit start/end times.
- Validation for invalid durations.
- Validation for overlapping sessions.
- Recalculation of affected totals.

#### P4.4 — Export

Implement CSV export first:

```text
date,start,end,duration,note
```

PDF export can follow if it remains a confirmed product requirement.

### Phase 4 acceptance criteria

- Reports are correct for daily, weekly, and monthly ranges.
- Open sessions are handled consistently in current-day reports.
- Exported CSV data can be opened by spreadsheet software.
- Historical edits preserve database invariants.

## 7. Phase 5 — Backup and release hardening

### Objective

Protect user data and prepare the app for a broader public release.

### Proposed implementation slices

- Local database backup.
- Restore workflow.
- Import/export validation.
- Schema compatibility checks.
- Data deletion workflow.
- Privacy policy and data-retention documentation.
- Accessibility review.
- Localization foundation.
- Performance and battery review.
- Crash-reporting decision.
- Store metadata, screenshots, and signing configuration.

Backup and restore must be tested across schema versions and should not depend
on cloud sync.

## 8. Phase 6 — Optional cloud synchronization

Cloud sync is intentionally deferred until local persistence, backup, and
reports are stable.

Before implementation, decide:

- Backend and hosting model.
- Authentication.
- Device identity.
- Conflict resolution.
- Offline upload queue.
- Encryption requirements.
- Delete propagation.
- Retention and recovery policy.

The repository boundary already provides a suitable place to introduce sync
without coupling the domain to a backend. Cloud synchronization must remain
optional; the local database remains the source of truth until a future design
explicitly changes that rule.

## 9. Recommended delivery order

1. Merge PRs `#50` and `#51`.
2. Finish Phase 1 hardening and device validation.
3. Release `v1.0.0`.
4. Create and implement Phase 2 issues.
5. Implement planned hours and calendar.
6. Implement reminders and deep links.
7. Implement reports and CSV export.
8. Implement local backup/restore and release hardening.
9. Re-evaluate whether cloud synchronization is necessary.

Each phase should follow the existing XP workflow:

```text
BACKLOG → READY → IN PROGRESS → REVIEW → TESTING → DONE
```

Every slice should include tests, documentation updates, a working vertical
flow, and validation on the supported mobile platforms where applicable.
