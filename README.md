# TimeFlow

TimeFlow is a **local-first, cross-platform mobile app** to register your working time: clock in, clock out, and review your worked hours per day, week, and month — with planned-vs-actual comparison and reminders.

Built with **Flutter** for **iOS and Android**.

## What it does

- **Clock in / clock out** to record actual working periods (work sessions).
- **Today screen** with a live timer, session history, and daily total.
- **Planning & calendar** for planned hours, kept separate from actuals so the app can compare them.
- **Reminders** (shift start, "you forgot to stop").
- **Reports** with weekly/monthly summaries and per-day detail.

Everything works **offline**. Data lives on the device; cloud sync is a later, optional phase.

## Core principles

1. **Local-first** — the device database is the single source of truth.
2. **Offline & crash-safe** — the timer is derived from a persisted start timestamp, never from a running background counter.
3. **Clean architecture** — `presentation / domain / data`; the UI never touches the database.
4. **A work session is a record, not a counter** — `start`, `end`, `duration`.
5. **Planned ≠ actual** — planned hours are a separate entity so variance is measurable.

## Repository layout

```
timeflow/
├── README.md
├── docs/
│   ├── architecture/
│   │   ├── overview.md
│   │   ├── decisions.md
│   │   └── diagrams/architecture.mmd
│   ├── product/phase-1-scope.md
│   └── development/
│       ├── xp-process.md
│       └── definition-of-done.md
├── .github/
│   ├── ISSUE_TEMPLATE/
│   └── workflows/
└── app/            # Flutter project — added after Phase 0 design is approved
```

## Phases

| Phase | Name | Status |
|---|---|---|
| 0 | Blueprint | ✅ Completed |
| 1 | Work Session Engine + Today | ✅ Implemented — release candidate |
| 2 | Planning & Calendar | 🚧 In implementation |
| 3 | Reminders | ⬜ |
| 4 | Reports & Export | ⬜ |
| 5 | Release hardening | ⬜ |
| 6 | Cloud sync (optional) | ⬜ |

## Development process

TimeFlow is built with **Extreme Programming (XP)** in short micro-iterations. See [docs/development/xp-process.md](docs/development/xp-process.md) and [docs/development/definition-of-done.md](docs/development/definition-of-done.md).

## Getting started

```sh
cd app
flutter pub get
flutter run
```

See [docs/architecture/overview.md](docs/architecture/overview.md) for the technical design and
[docs/implementation-roadmap.md](docs/implementation-roadmap.md) for the pending phases.
