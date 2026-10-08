# Phase 5 — Backup and Release Hardening

Status: **in progress** — Phase 4 release `v1.3.0` is complete. Phase 5 board:
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
- [x] Pixel 10 Pro integration smoke test reached Backup & Restore and Reports;
  the AVD disconnected/crashed during teardown in the broader local integration
  run, so CI/device rerun remains part of the review gate.
- [ ] Additional screen-reader/text-scale device review, supply production
  signing credentials, prepare signed artifacts, and complete final `v1.4.0`
  gates.

The Android release build was intentionally tested without a keystore and is
blocked with the expected actionable signing configuration message. Debug APK
builds do not need these secrets. A production upload key must be supplied by
the release owner; it is not generated or committed by this implementation.

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
