# TimeFlow — Whole-Project Implementation Plan

## Product strategy

TimeFlow is delivered as independent, releasable mobile phases. Every phase
must leave the repository buildable, tested, documented, and ready for the next
phase. The local Drift database remains the source of truth through all phases.

```text
v1.0.0  Phase 1 — Work sessions and Today
v1.1.0  Phase 2 — Planning and Calendar
v1.2.0  Phase 3 — Reminders and notifications
v1.3.0  Phase 4 — Reports and export
v1.4.0  Phase 5 — Backup and release hardening
v2.0.0  Phase 6 — Optional cloud synchronization
```

Each phase uses the same delivery gate:

```text
issues → tests → PRs → CI → Android validation → iOS validation →
release branch → RC tag → release PRs → production tag → handoff
```

## Phase 1 — Work Session Engine

Status: **released as v1.0.0**

Delivered:

- Start/stop work sessions.
- Drift/SQLite local persistence.
- UTC timestamps and local-day bucketing.
- Crash-safe derived timer.
- Today history and daily total.
- Restart/background recovery.
- Single-open-session database invariant.
- Android/iOS project scaffolding and CI.

Handoff to Phase 2:

- Stable `WorkSessionRepository` contract.
- Database schema version 1.
- Test helpers for fake clocks and in-memory databases.

## Phase 2 — Planning and Calendar

Status: **released as v1.1.0**

Delivered:

- `PlannedBlock` and `WeeklyTemplate` domain models.
- Drift schema version 2 and planning indexes.
- Planning repository and CRUD operations.
- Weekly template materialization.
- GoRouter navigation.
- Calendar screen and planned-block management.
- Planned-versus-actual daily summaries.
- Android emulator planning-flow validation.

Exit gate:

- Phase 2 PRs merged and CI green.
- Existing Phase 1 tests remain green.
- Migration and planning persistence tests pass.
- Android emulator flow passes.
- iOS validation is recorded when macOS/Xcode is available.
- `v1.1.0` is tagged and documentation is updated.

Handoff to Phase 3:

- Planned blocks are queryable by local day.
- Weekly templates can be applied to date ranges.
- Calendar route is available at `/calendar`.
- Planned-versus-actual calculation is centralized in the domain layer.

## Phase 3 — Reminders and Notifications

Objective: notify users about upcoming planned work and forgotten open sessions
without requiring cloud connectivity.

Implementation order:

1. Define a framework-independent notification service contract.
2. Add persisted reminder preferences.
3. Integrate Android and iOS local notification permissions.
4. Schedule and cancel shift-start reminders.
5. Detect forgotten open sessions at launch and on resume.
6. Add notification deep links to `/today` and `/calendar`.
7. Validate timezone, restart, permission, and battery behavior.

Exit gate:

- Notifications work offline on Android and iOS.
- Users can disable and configure reminders.
- Stopping work cancels relevant reminders.
- Notification taps navigate correctly.
- Notification tests and device validation pass.

## Phase 4 — Reports and Export

Status: **released as v1.3.0**

Status: **released as v1.3.0; Android validation passed**

Objective: provide reliable historical summaries and portable data.

Implementation order:

1. Add SQL-backed daily, weekly, and monthly aggregation queries.
2. Add report domain view models and variance calculations.
3. Implement Reports screen and daily detail navigation.
4. Add historical session edit/delete with overlap validation.
5. Add CSV export with a documented stable format.
6. Add report, editing, and export tests.

Exit gate:

- Report totals match persisted sessions and plans.
- Open-session behavior is explicit and tested.
- Historical edits preserve invariants.
- CSV opens correctly in spreadsheet software.
- Android and iOS report flows are validated.

## Phase 5 — Backup and Release Hardening

Status: **in progress; backup, restore, data deletion, bilingual UI, and Android signing safeguards implemented**

Objective: protect user data and prepare a public-quality release.

Implementation order:

1. Define backup format and version metadata.
2. Implement local database export/backup.
3. Implement restore with validation and rollback safety.
4. Test restore across schema versions.
5. Add data deletion and privacy controls.
6. Review accessibility, localization, battery, and performance.
7. Prepare store signing, metadata, screenshots, and release artifacts.

Exit gate:

- Backup and restore are verified on Android and iOS.
- Corrupt or incompatible backups fail safely.
- Privacy and data deletion behavior is documented.
- Accessibility and release checks are complete.

## Phase 6 — Optional Cloud Synchronization

Status: **planned; optional after Phase 5**

Objective: add multi-device sync only if local backup and product demand justify
the operational cost.

Required design decisions before coding:

- Backend and hosting model.
- Authentication and device identity.
- Sync protocol and conflict resolution.
- Offline queue and retry behavior.
- Encryption and key management.
- Delete propagation and retention.

Implementation order:

1. Record sync ADRs and threat model.
2. Add a sync boundary behind the repository layer.
3. Add authenticated sync metadata.
4. Implement upload/download queues.
5. Implement deterministic conflict resolution.
6. Add multi-device, offline, failure, and recovery tests.

Exit gate:

- Local-first behavior remains functional without a network.
- Conflicts are deterministic and observable.
- Data is encrypted according to the approved design.
- Sync can be disabled without data loss.

## Phase handoff checklist

Before starting the next phase:

- Previous phase release tag exists.
- Release PRs are merged into `main` and `develop`.
- Changelog and README status are updated.
- Architecture decisions are recorded.
- Tests cover the completed behavior.
- Android validation is recorded.
- iOS validation is recorded or explicitly blocked by the available hardware.
- Next-phase issues and acceptance criteria exist in the GitHub Project.
