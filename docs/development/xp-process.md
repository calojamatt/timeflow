# XP Process

TimeFlow is built with **Extreme Programming (XP)** practices adapted for a
solo-plus-agent team. The goal is fast, correct, shippable increments.

## Practices we follow

1. **Micro-iterations (1–3 days).** Each iteration ends with a vertical slice
   running on a real device, not just passing tests.
2. **Vertical slices.** One thin feature wired through presentation → domain → data.
   Example Phase 1 slice: *create app → create WorkSession → persist → start →
   display elapsed → survive restart*.
3. **Test-driven development** on the domain layer (red → green → refactor).
   Data layer covered by integration tests; UI covered by widget tests.
4. **Simple design.** Smallest thing that works. No speculative abstraction.
5. **Refactor mercilessly** within an iteration; keep the design clean as features land.
6. **Continuous integration.** Every push builds and tests automatically.
7. **Weekly demo.** Show working software, not slides.
8. **Lightweight backlog.** Issues are small and actionable; no estimation ceremony.

## Cadence

- Pull the top **READY** issue.
- Build the smallest slice for it, test-first.
- Run the app on device (iOS simulator + Android emulator).
- Open a PR; CI must be green.
- Merge; move issue to **DONE**.

## Workflow board

```
BACKLOG → READY → IN PROGRESS → REVIEW → TESTING → DONE
```

## Vertical slices for Phase 1

1. **Slice 1 — Foundation:** `flutter create app`, folder structure, CI green.
2. **Slice 2 — Persist a session:** create + persist a `WorkSession`, repository tests.
3. **Slice 3 — Start + live timer:** start a session, show elapsed, survive restart.
4. **Slice 4 — Stop + history:** stop a session, list today's sessions.
5. **Slice 5 — Daily total + invariants:** daily total, single-open-session enforcement.
6. **Slice 6 — Validation:** iOS + Android manual validation, polish.

Each slice is a set of issues in the Phase 1 epic.
