# TimeFlow — Architecture Overview

## 1. Context

TimeFlow is a local-first, offline-capable work-time register for iOS and Android.
The app records **work sessions** (start/stop), lets the user plan hours, and
reports actual vs. planned time.

This document describes the Phase 1 architecture. Later phases extend it without
changing its foundations.

## 2. Goals

- Work fully offline.
- Survive app restarts, phone lock, and reboots with an accurate timer.
- Keep the domain model independent of UI and persistence.
- Be testable: unit-test the domain, integration-test the data layer.
- Be ready for future features (planning, reminders, reports, sync) without rework.

## 3. Architectural style

**Layered / Clean Architecture** with three layers:

```
presentation  →  domain  ←  data
```

- **presentation** — Flutter widgets + state management (Riverpod). Knows nothing
  about SQLite, HTTP, or file formats.
- **domain** — pure Dart entities, value objects, and use cases. No framework,
  no I/O. This is where all time logic lives and is unit-tested.
- **data** — repositories, data sources (SQLite via drift), and mappings.
  Implements the domain's repository contracts.

Dependency rule: **dependencies point inward**. Presentation depends on domain;
data depends on domain. Domain depends on nothing.

## 4. Key components

| Layer | Component | Responsibility |
|---|---|---|
| presentation | `TodayScreen`, `TimerControl`, `SessionList` | Render state, dispatch intents |
| presentation | `TodayController` (Riverpod) | Hold UI state, call use cases |
| domain | `WorkSession` (entity) | Start/end/duration, open/closed |
| domain | `Clock` (interface) | Abstract "now" for testability |
| domain | `StartWork`, `StopWork`, `GetDaySummary` (use cases) | Business rules |
| data | `WorkSessionRepository` (impl) | Persist/query via drift |
| data | `AppDatabase` (drift) | SQLite schema, migrations |

## 5. The core domain: WorkSession

A work session is a **record with a start and an optional end**, not a counter.

```dart
class WorkSession {
  final String id;
  final DateTime startedAtUtc;  // when the session began (UTC instant)
  final DateTime? endedAtUtc;   // null while the session is open
  final int localDay;           // device-local day (days since epoch), set at start
  final String? note;

  bool get isOpen => endedAtUtc == null;
  Duration elapsedAt(DateTime now) => (endedAtUtc ?? now).difference(startedAtUtc);
}
```

Rules:
- At most **one open session** at any time (enforced at the DB level).
- The live timer is **derived** from `startedAtUtc`; nothing ticks in the background.
- `localDay` is computed once at start so "today's sessions" is a cheap indexed query.

## 6. Data persistence

- **drift** (SQLite) is the local store. See `decisions.md` ADR-0002.
- Schema (Phase 1): a single `work_session` table.
- A unique partial index guarantees a single open session:
  ```sql
  CREATE UNIQUE INDEX ux_one_open_session ON work_session((1)) WHERE ended_at IS NULL;
  ```

## 7. Runtime behavior (crash-safety)

1. User taps **Start** → a `WorkSession` row is **written immediately** with
   `started_at` and `ended_at = NULL`.
2. The UI shows elapsed time computed from `now - started_at` on every tick
   (a `Timer` only repaints; it stores nothing).
3. If the app is killed, locked, or the phone reboots, the open row is still there.
4. On next launch, the app finds the open row and resumes the live timer from the
   stored start — no drift, no loss.
5. User taps **Stop** → the row is updated with `ended_at`.

## 8. Future extensions

- **Planning (Phase 2)** — `planned_block` + `weekly_template` tables, calendar view.
- **Reminders (Phase 3)** — local notifications (flutter_local_notifications),
  including a "forgot to stop" check at launch.
- **Reports (Phase 4)** — SQL aggregations over `work_session` by local day/week/month.
- **Sync (Phase 6)** — a sync boundary behind the repository, conflict resolution,
  end-to-end encryption.

## 9. Diagrams

| Diagram | File | Purpose |
|---|---|---|
| Component / layering | [diagrams/architecture.mmd](diagrams/architecture.mmd) | The three layers and their dependencies |
| Deployment | [diagrams/deployment.mmd](diagrams/deployment.mmd) | Where code runs: device, SQLite, app stores, future sync |
| Sequence — work session | [diagrams/sequence-work-session.mmd](diagrams/sequence-work-session.mmd) | Start/Stop flow through all layers |
| Sequence — recovery | [diagrams/sequence-recovery.mmd](diagrams/sequence-recovery.mmd) | Timer resume after kill/lock/reboot |
