# Phase 5 — Backup and Release Hardening

Status: **source released as `v1.4.0`** (`v1.4.0-rc.1` was the RC) — Phase 4
release `v1.3.0` is complete. Code/repository gates pass; signed production
store artifacts remain gated on owner credentials and platform validation.
Phase 5 board:
[Project #7](https://github.com/users/calojamatt/projects/7); issues #100–#105.

## Goal

Protect local user data and prepare TimeFlow for public distribution.

## Slices

1. Versioned backup format.
2. Local backup creation.
3. Restore validation and rollback safety.
4. Cross-version migration tests.
5. Data deletion and privacy controls.
6. Accessibility, localization, performance, and battery review.
7. Store signing and release artifact preparation.

## Progress (2026-10-08)

- [x] Define a versioned JSON envelope with format version, export timestamp,
  and source database schema metadata.
- [x] Validate all records before writing, reject corrupt/unsupported data, and
  transactionally replace all four persisted data sets.
- [x] Read schema 1 and 2 backups by defaulting tables introduced in later
  schema migrations; the current writer emits schema 3.
- [x] Add native share and JSON file picker UI; restoration requires explicit
  replace confirmation.
- [x] Add domain, repository, rollback, migration, and Backup screen tests.
- [x] Add a confirmation-gated all-local-data deletion flow and cancel scheduled
  notifications when the user clears app data.
- [x] Full Flutter suite now passes 103 tests; analyzer and Android debug APK
  build pass after the privacy slice.
- [x] Localize app screens in English and Spanish and add semantic-label
  coverage for navigation actions and 1.5× text scaling.
- [x] Add an idle-state ticker smoke test to guard against unnecessary periodic
  wakeups when no work session is running.
- [x] Document privacy behavior, align app metadata with the release tag, and
  require a private maintainer keystore for Android release packaging.
- [x] Verify an unsigned release build is blocked with an actionable signing
  error instead of silently producing a debug-signed release.
- [x] Prepare `1.4.0+5` app version, create release PRs #109/#110, RC tag
  `v1.4.0-rc.1`, production source tag `v1.4.0`, and GitHub release.
- [x] Pixel 10 Pro AVD integration runs passed individually for app navigation
  (Backup & Restore and Reports), Today start/run/stop, and Calendar navigation.
- [ ] Additional screen-reader/text-scale device review, supply production
  signing credentials, prepare signed artifacts, and complete final `v1.4.0`
  gates.

The Android release build was intentionally tested without a keystore and is
blocked with the expected actionable signing configuration message. Debug APK
builds do not need these secrets. A production upload key must be supplied by
the release owner; it is not generated or committed by this implementation.

The GitHub release is a source release and contains no signed production APK or
AAB. Issue #104 remains open for the release owner's signing credentials,
signed-artifact verification, and iOS/macOS device validation. Phase 6 remains
optional/deferred until sync requirements and security decisions are approved.

### Pixel 10 Pro interaction run (2026-10-08)

Device: `Pixel_10_Pro` AVD, Android 17 / API 37 (`emulator-5554`). Each file was
run separately to avoid the emulator disconnect observed when Flutter tears
down a multi-file integration invocation:

| Test file | Interaction flow | Result |
|---|---|---|
| `integration_test/app_test.dart` | Boot Today → open Backup & Restore → return → open Reports and check summary metrics | Passed |
| `integration_test/work_session_flow_test.dart` | Start → running timer/Start hidden → stop → Idle | Passed |
| `integration_test/planning_flow_test.dart` | Today → Calendar → planned summary and template/add actions visible | Passed |

The AVD remained connected after each isolated run. These flows complement the
automated screen/widget tests for backup creation/restore confirmation, CSV
export, history edit/delete, and clear-data confirmation.

### Backup compatibility policy

The portable envelope is `timeflow-backup`, format version 1. The `data` object
contains `workSessions`, `plannedBlocks`, `weeklyTemplates`, and
`reminderPreferences`. Source schema versions 1–3 are accepted; schema 1 gains
empty planning/template tables and schema 1–2 gain default reminder settings.
Unknown format/schema versions, malformed values, overlapping sessions, and
multiple open sessions are rejected before any database mutation. Restore
replaces all data in one SQLite transaction, preserving the prior contents if
any insert fails.

## Required tests

- Backup/restore integration tests.
- Corrupt and incompatible backup tests.
- Schema-version compatibility tests.
- Accessibility widget tests.
- Performance and battery smoke tests.
- Android/iOS release-candidate validation.

## Completion criteria

Users can recover their data safely, understand data handling, and install a
production-quality release. The phase ends with release `v1.4.0`.
