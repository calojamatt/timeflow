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
- [x] Daily session detail with validated historical edit/delete actions.
- [x] CSV export/share for actual and planned rows.
- [ ] Final end-to-end Pixel 10 Pro validation and release gates remain before
  the `v1.3.0` release.

### CSV format

Exports use RFC 4180-compatible UTF-8 CSV with the columns `Date`, `Type`,
`Start`, `End`, `Duration seconds`, and `Note`. Date is the stored device-local
day bucket; actual timestamps are rendered in the device timezone. Open
sessions end at export time. Planned rows export their local start/end clock
times and planned duration. The CSV uses CRLF line endings and standard quoting.

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
