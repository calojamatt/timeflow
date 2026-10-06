# Phase 5 — Backup and Release Hardening

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
