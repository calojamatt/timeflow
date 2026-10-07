# Phase 4 — Reports and Export

## Goal

Provide daily, weekly, and monthly summaries with planned-versus-actual
comparison and CSV export.

## Slices

1. SQL aggregation query layer.
2. Report domain models and variance rules.
3. Reports screen and date-range navigation.
4. Historical session edit/delete validation.
5. CSV export and share flow.
6. Report, edit, export, and device tests.

## Progress (2026-10-07)

- [x] Period-based SQLite aggregation for actual and planned time, including
  open-session elapsed time and invalid-range validation.
- [x] Daily, weekly, and monthly period selection and report navigation from
  Today and Calendar.
- [x] Repository integration tests and Reports screen/widget tests.
- [ ] Per-day detail, historical session edit/delete, CSV export/share, and
  full Pixel 10 Pro interaction validation remain before the `v1.3.0` release.

## Required tests

- Aggregation integration tests.
- Open-session and timezone tests.
- Historical overlap validation tests.
- Reports widget tests.
- CSV format and round-trip tests.
- Android/iOS export validation.

## Completion criteria

Reports reconcile with stored data, edits preserve invariants, and CSV export is
portable. The phase ends with release `v1.3.0`.
