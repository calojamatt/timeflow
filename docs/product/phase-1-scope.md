# Phase 1 — Scope

## Objective

Ship the smallest complete vertical slice of TimeFlow: record actual work time on
the device, reliably and offline.

## In scope

- **Start** a work session.
- **Stop** a work session.
- **Persist** sessions locally (SQLite via drift).
- **Live timer** showing elapsed time of the current session.
- **Daily total** of worked time for today.
- **Session history** for the current day.
- **Recovery** across app restart, phone lock, and reboot.
- **Single active session** invariant.

## Out of scope (deferred)

| Feature | Phase |
|---|---|
| Planned hours / calendar | 2 |
| Weekly templates | 2 |
| Reminders / notifications | 3 |
| Weekly & monthly reports | 4 |
| Export (CSV/PDF) | 4 |
| Multiple jobs/projects | 5+ |
| Breaks | 5+ |
| Cloud sync | 6 |
| Editing past sessions (full) | 4 (delete only in Phase 1) |

## User stories (Phase 1)

1. As a user, I can start a work session so that my time is recorded.
2. As a user, I can stop a work session so that its duration is finalised.
3. As a user, I see a live elapsed timer while a session is active.
4. As a user, I see today's sessions and total on the Today screen.
5. As a user, if the app is closed, locked, or my phone restarts, my running
   session and today's data are still correct.

## Acceptance criteria

- Starting creates exactly one open session (persisted immediately).
- A second Start while one is open is impossible (UI hides it **and** DB enforces it).
- Stopping sets `ended_at`; elapsed equals `end - start`.
- Elapsed time is accurate across a phone lock, app kill, and reboot.
- Today's total equals the sum of today's sessions (open session counts elapsed).
- All domain rules are covered by unit tests; persistence by integration tests.

## Definition of Done

See [../development/definition-of-done.md](../development/definition-of-done.md).
