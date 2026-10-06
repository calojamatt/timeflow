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
