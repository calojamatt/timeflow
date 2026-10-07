# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

No changes yet.

## [1.2.0] - 2026-10-07

### Added

- Reminder service boundary and fake notification implementation.
- Persisted reminder preferences with database schema version 3.
- Android/iOS local notification adapter with timezone-aware scheduling.
- Planned shift reminder scheduling.
- Forgotten open-session detection.
- Reminder coordinator and `/today`/`/calendar` deep-link callback.
- Desktop-safe notification initialization and test coverage.

## [1.1.0] - 2026-10-06

### Added

- Phase 2 planning domain models, Drift schema migration, repository, and use cases.
- Calendar navigation and planned-block management.
- Weekly template creation and application to date-specific planned blocks.
- Planned-versus-actual daily summaries.
- Phase 2 domain, persistence, widget, and screen tests.

## [1.0.0] - 2026-10-06

### Added

- Phase 0 blueprint: architecture overview, ADRs, deployment/sequence diagrams,
  Phase 1 scope, XP process, Definition of Done, and GitFlow delivery process.
- Flutter project scaffold for Android and iOS (package `com.dytsas.timeflow`) (#8)
- Core dependencies (riverpod, drift, go_router) and presentation/domain/data layer folders (#9)
- `WorkSession` domain entity with start/end/elapsed time (#12)
- drift `work_session` table with a single-open-session unique index (#13)
- `WorkSessionRepository` (start/stop/findOpen/getByDay) with drift implementation (#14)
- `StartWork` use case with local-day bucketing (#15)
- `StopWork` use case (#16)
- Today screen with timer state and session list (#17)
- Start/Stop toggle button wired to the use cases (#18)
- Live timer that updates elapsed time every second (#19)
- Session history with start–end time and duration (#20)
- Daily total of worked time for today (#21)
- App restart recovery: an open session resumes with correct elapsed (#22)
- Phone-lock/background recovery: elapsed stays accurate across lock/background (#23)
- Single-active-session enforcement: Start hidden while running, DB rejects a second open session (#24)
- Unit tests for domain logic: WorkSession, use cases, and local-day bucketing (#25)
- Integration tests for the drift repository: CRUD, open/close, and day queries (#26)
- On-device integration test for the Phase 1 vertical slice (Start/Stop, live timer, single-active-session) (#27 #28)

<!--
Template for issue-driven entries (add under Unreleased → Added/Changed/Fixed):

- feat(scope): description of the change (#<issue>)
-->
