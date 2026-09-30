# Architecture Decision Records (ADRs)

TimeFlow records significant architectural decisions here. Each ADR states the
context, the decision, and the consequences.

Status legend: **Proposed** → **Accepted** → **Superseded**.

---

## ADR-0001 — Cross-platform framework: Flutter

- **Status:** Accepted
- **Date:** 2026-09-30

**Context.** The app must run on iOS and Android from a single codebase. The
candidates were Flutter and React Native. Requirements that matter most:
offline reliability, background/notification behaviour, a testable domain layer,
and long-term maintainability.

**Decision.** Use **Flutter** (Dart).

**Consequences.**
- One codebase for both platforms; no web/desktop commitment made now.
- Dart's strong typing keeps the domain layer clean and unit-testable.
- A single plugin ecosystem (`drift`, `riverpod`, `flutter_local_notifications`,
  `go_router`) covers persistence, state, notifications, and routing.
- Trade-off: less reuse of existing JS/RN ecosystem; mitigated because we don't
  need JS-native modules.

---

## ADR-0002 — Local persistence: drift (SQLite)

- **Status:** Accepted
- **Date:** 2026-09-30

**Context.** We need a reliable, offline, queryable store with real migrations.
Candidates: drift, Isar, Hive, plain `sqflite`.

**Decision.** Use **drift** (SQLite) for structured data.

**Consequences.**
- Type-safe queries and compile-time-checked SQL.
- Real schema migrations, essential as phases add tables.
- SQL aggregations power the Phase 4 reports.
- Trade-off: relational model is more upfront than a key-value store, but the
  data is inherently relational (sessions, plans, templates).

---

## ADR-0003 — State management: Riverpod

- **Status:** Accepted
- **Date:** 2026-09-30

**Context.** We need DI and reactive state that is testable without a widget tree.

**Decision.** Use **Riverpod** for state management and dependency injection.

**Consequences.**
- Compile-time safety for providers.
- Repositories/use cases are easy to override with fakes in tests.
- Avoids the boilerplate and framework coupling of `setState`-centric approaches.

---

## ADR-0004 — Clean architecture layering

- **Status:** Accepted
- **Date:** 2026-09-30

**Context.** The UI must never talk to the database directly, and time logic must
be testable in isolation.

**Decision.** Enforce three layers — `presentation`, `domain`, `data` — with
dependencies pointing inward. The domain is pure Dart with no framework imports.

**Consequences.**
- High unit-test coverage of business rules without Flutter.
- Adding sync later becomes an implementation detail behind the repository contract.
- Slightly more ceremony per feature; acceptable given the product's growth path.

---

## ADR-0005 — Time model: UTC instants + precomputed local day

- **Status:** Accepted
- **Date:** 2026-09-30

**Context.** Durations must be correct across DST changes and travel, and
"which day does this session belong to?" must be cheap to answer.

**Decision.**
- Store absolute times as **UTC instants** (`DateTime.utc`).
- Store a **`local_day`** integer (days since epoch in the device's timezone)
  computed once at session start.

**Consequences.**
- `now - started_at` is always a monotonic wall-clock difference; DST-safe.
- Day bucketing is an indexed integer lookup, not a per-row timezone conversion.
- Trade-off: if the user changes timezone mid-session, `local_day` stays as the
  start-day; documented as intended (bucket by start day).

---

## ADR-0006 — Timer strategy: derive, don't count

- **Status:** Accepted
- **Date:** 2026-09-30

**Context.** A timer that only works while the app runs in the foreground is
unacceptable; we need crash/lock/reboot safety.

**Decision.** **Never** run a background counter. Persist `started_at`; compute
elapsed on demand (`ended_at ?? now` minus `started_at`). A UI `Timer` only
triggers repaints.

**Consequences.**
- Zero battery cost; no background execution permissions needed in Phase 1.
- Accurate across kills, locks, and reboots by construction.
- UI tick frequency is purely cosmetic.

---

## ADR-0007 — Sync deferred to Phase 6

- **Status:** Accepted
- **Date:** 2026-09-30

**Context.** Multi-device sync and cloud backup were considered early.

**Decision.** **Defer** cloud sync. Keep the device database as the single source
of truth and add local backup/restore in Phase 5.

**Consequences.**
- Faster time-to-first-release.
- Design a repository boundary now so sync is additive later.
- Trade-off: no automatic off-device backup until Phase 5; mitigated with export
  (Phase 4) and local backup (Phase 5).

---

## ADR-0008 — Routing: go_router

- **Status:** Accepted
- **Date:** 2026-09-30

**Context.** Reminders (Phase 3) need deep links into screens (e.g. notification
→ Today).

**Decision.** Use **go_router** for navigation.

**Consequences.**
- URL/route-based navigation enabling notification deep links.
- Declarative route table that scales as screens are added.
