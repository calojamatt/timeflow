# TimeFlow — Phase 2 Implementation: Planning & Calendar

## Objective

Allow users to define planned working hours independently from actual
`WorkSession` records, review those plans in a calendar, and compare planned
time with actual time.

Phase 2 must preserve the Phase 1 principles:

- Local-first and fully offline.
- Drift/SQLite remains the device source of truth.
- Domain logic remains independent of Flutter and persistence.
- Planned time and actual time remain separate concepts.
- Existing Phase 1 data must survive the schema migration unchanged.

## Scope

### In scope

- Planned work blocks for a specific local calendar day.
- Weekly planning templates.
- Create, update, list, and delete planned blocks.
- Applying a weekly template to selected dates.
- Calendar navigation and day selection.
- Planned, actual, and variance totals for a selected day.
- Database migration from schema version 1 to version 2.
- Unit, integration, widget, migration, and device validation.

### Out of scope

- Notifications and reminders; Phase 3.
- Weekly/monthly reporting dashboards; Phase 4.
- Cloud synchronization; Phase 6.
- Multiple jobs or projects.
- Break tracking.
- Overnight planned shifts in the first Phase 2 iteration.

## Architecture

The existing dependency direction remains:

```text
presentation → domain ← data
```

Suggested additions:

```text
app/lib/domain/planned_block.dart
app/lib/domain/weekly_template.dart
app/lib/domain/planning_repository.dart
app/lib/domain/planning_use_cases.dart

app/lib/data/planning_repository_impl.dart
app/lib/presentation/calendar_screen.dart
app/lib/presentation/calendar_controller.dart
```

The implementation may split use cases into separate files if that matches the
existing style. The UI must not access Drift directly.

## Domain model

### PlannedBlock

```text
id: String
localDay: int
startMinute: int
endMinute: int
note: String?
```

`startMinute` and `endMinute` are minutes from midnight in the device-local
calendar day. This is preferable to UTC timestamps for a planned calendar
entry: the user plans a local schedule rather than recording an absolute
instant.

Initial validation:

- `startMinute` is between 0 and 1439.
- `endMinute` is between 1 and 1440.
- `endMinute` is greater than `startMinute`.
- `localDay` is a valid day index.
- `id` is stable and unique.

Overnight blocks are deliberately deferred. They can be added later with an
explicit model decision rather than silently assigning time to two days.

### WeeklyTemplate

A weekly template represents a reusable schedule:

```text
id: String
name: String
weekday: int       # 1 = Monday, 7 = Sunday
startMinute: int
endMinute: int
note: String?
```

The first implementation may store one row per weekday/time block. Applying a
template creates date-specific planned blocks; it must not turn the calendar
into a live view of mutable template rows.

## Persistence design

Increase the Drift schema version from `1` to `2`.

Suggested tables:

```sql
planned_blocks (
  id TEXT PRIMARY KEY,
  local_day INTEGER NOT NULL,
  start_minute INTEGER NOT NULL,
  end_minute INTEGER NOT NULL,
  note TEXT NULL
)

weekly_templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  weekday INTEGER NOT NULL,
  start_minute INTEGER NOT NULL,
  end_minute INTEGER NOT NULL,
  note TEXT NULL
)
```

Suggested indexes:

```sql
CREATE INDEX ix_planned_blocks_local_day
  ON planned_blocks(local_day);

CREATE INDEX ix_weekly_templates_weekday
  ON weekly_templates(weekday);
```

Migration requirements:

1. Open a version 1 database containing work sessions.
2. Add the Phase 2 tables without altering existing rows.
3. Verify the database opens as version 2.
4. Verify work-session queries and the single-open-session index still work.
5. Verify a newly created database has all tables.

## Use cases and repository contract

The domain repository should expose operations equivalent to:

- `createPlannedBlock`
- `updatePlannedBlock`
- `deletePlannedBlock`
- `getPlannedBlocksForDay`
- `getPlannedBlocksBetween`
- `createWeeklyTemplate`
- `updateWeeklyTemplate`
- `deleteWeeklyTemplate`
- `getWeeklyTemplate`
- `applyWeeklyTemplate`

The actual method names should follow the existing Dart naming conventions.

The planned-versus-actual summary should combine:

```text
planned = sum(planned block durations)
actual  = sum(work-session elapsed durations)
variance = actual - planned
```

The summary belongs behind a domain/application boundary. It may use separate
repository queries; the calendar widget should receive a prepared view model,
not perform calculations itself.

## Navigation and UI

Use the existing `go_router` dependency.

Initial routes:

```text
/today       existing Today screen
/calendar    new planning calendar
```

The Today screen remains the default route. The calendar should provide:

- Current month or week view.
- Selected local day.
- Planned blocks for that day.
- Actual total for that day.
- Planned total for that day.
- Variance indicator.
- Add, edit, and delete planned block actions.

Keep the first UI simple. A month/day list is acceptable if a full calendar
widget adds unnecessary dependency or maintenance cost.

## Implementation order

```text
Issue 29 — Domain model and rules
        ↓
Issue 30 — Drift schema and migration
        ↓
Issue 31 — Repository and planning use cases
        ↓
Issue 32 — go_router navigation foundation
        ↓
Issue 33 — Calendar screen and planned-block UI
        ↓
Issue 34 — Planned-versus-actual summary
        ↓
Issue 35 — Tests, migration validation, and device slice
```

Each issue should be implemented as a small vertical slice with tests and a
Conventional Commit. Issues may be renumbered automatically by GitHub; the
titles and dependency order are the source of truth.

## Acceptance criteria for Phase 2

- Users can create planned hours without creating actual work sessions.
- Planned and actual data are stored separately.
- Planned blocks survive app restart.
- Existing Phase 1 work sessions survive migration.
- Users can select a calendar day and view its plan and actual total.
- Planned, actual, and variance totals are correct.
- Users can edit and delete planned blocks.
- Weekly templates can be saved and applied to dates.
- `dart format`, `dart analyze`, and `flutter test` pass.
- Android validation passes for the Phase 2 vertical slice.
- iOS validation is performed on macOS/Xcode before Phase 2 release.

## Delivery summary

Phase 2 adds the planning side of TimeFlow without changing the existing work
session engine. Drift schema version 2 introduces planned blocks and weekly
templates; the domain exposes validated planning operations; the presentation
layer adds calendar navigation and day summaries; and tests prove migration,
planning persistence, and planned-versus-actual calculations.
