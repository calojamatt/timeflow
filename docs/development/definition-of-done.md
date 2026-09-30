# Definition of Done

A work item is **DONE** only when **all** of the following are true. If any item
is missing, the work returns to **IN PROGRESS**, not to a fake "done" state.

## Every item

- [ ] The acceptance criteria in the issue are met and verifiable.
- [ ] Code is reviewed (self-review for solo work; PR review when available).
- [ ] CI is green (build + test + analyze).

## Code

- [ ] `dart analyze` reports no errors or warnings.
- [ ] `dart format` is clean.
- [ ] New logic is covered by tests (unit for domain, integration for data,
      widget for UI) where the change touches behaviour.

## Behaviour

- [ ] The change works on **both** iOS (simulator) and Android (emulator) —
      or is explicitly scoped to one platform with a reason in the issue.
- [ ] A real user can complete the flow end-to-end on a device.

## Persistence & reliability

- [ ] For any change to time/persistence: the timer and today's total are
      correct after app kill, phone lock, and reboot.
- [ ] The single-active-session invariant holds (DB-level, not just UI-level).

## Documentation

- [ ] Any new architectural decision is added to
      `docs/architecture/decisions.md`.
- [ ] Any change to scope is reflected in `docs/product/phase-1-scope.md`.
