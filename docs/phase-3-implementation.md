# Phase 3 — Reminders and Notifications

## Goal

Provide configurable local notifications for planned work and forgotten open
sessions. The feature must work offline and must not place notification-plugin
dependencies in the domain layer.

## Slices

1. Notification service contract and fake implementation.
2. Persisted reminder preferences.
3. Android/iOS permission and channel setup.
4. Planned shift-start scheduling and cancellation.
5. Forgotten-session detection on launch/resume.
6. Notification deep links to `/today` and `/calendar`.
7. Platform tests and device validation.

## Required tests

- Notification service unit tests.
- Preference repository integration tests.
- Schedule/cancel tests.
- Timezone and restart tests.
- Android notification permission and deep-link tests.
- iOS notification permission and deep-link tests.

## Completion criteria

Reminders are configurable, offline, cancellable, restart-safe, and validated on
both mobile platforms. The phase ends with release `v1.2.0`.
