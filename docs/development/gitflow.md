# GitFlow & Delivery Process

TimeFlow uses **GitFlow** for branching and **Extreme Programming (XP)** for the
development loop. This document is the single source of truth for how work moves
from an issue to a release.

## Branching model

| Branch | Purpose | Never commit to directly |
|---|---|---|
| `main` | Production-ready code. Tagged releases only. | ✗ |
| `develop` | Integration branch (default). All features land here. | ✗ |
| `feature/<issue>-<slug>` | One branch per issue, cut from `develop`. | — |
| `release/<semver>` | Stabilisation branch for a release candidate, cut from `develop`. | ✗ |
| `hotfix/<semver>` | Urgent production fix, cut from `main`. | ✗ |

Branch names follow `feature/8-create-flutter-project` (issue number + short slug).

## Branch protection

A repository **ruleset** enforces the following on `main` and `develop`:

- Branch **deletion is blocked** (after a PR merge the branch cannot be deleted).
- **Direct pushes are blocked** — all changes must arrive via a pull request.
- **Force pushes are blocked** (`non_fast_forward`).

Consequence: never `git push` to `main`/`develop`; always open a PR and merge it.

## Commit convention

**Conventional Commits** with the issue number so the PR links automatically:

```
<type>(<scope>): <description> (#<issue>)
```

Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`, `style`, `perf`, `build`.

Examples:
- `feat(work-session): implement WorkSession entity (#12)`
- `test(work-session): unit-test elapsedAt for open and closed sessions (#12)`
- `ci: scope working-directory to Flutter steps (#11)`

## Per-issue workflow

1. Move the issue on the board: `BACKLOG → READY → IN PROGRESS`.
2. Create the feature branch from `develop`:
   ```sh
   git checkout develop && git pull
   git checkout -b feature/<issue>-<slug>
   ```
3. Implement with **tests immediately** (TDD). Unit/widget tests as each
   component is written; **integration tests last**.
4. Conventional commits referencing the issue number.
5. Push and open a **PR** against `develop` (`gh pr create`), linked via
   `Closes #<issue>`.
6. CI must be green (`dart format`, `dart analyze`, `flutter test`).
7. Board: move to `REVIEW`.
8. **The owner reviews the changes and merges the PR manually** (squash).
   The agent never merges. On merge, `Closes #<issue>` closes the issue and the
   board moves to `DONE`.

## Deliverables per issue

- Working code with tests (unit/widget now, integration last).
- Conventional commits with the issue number.
- A `CHANGELOG.md` entry (under **Unreleased**) describing the change.
- A PR whose description checks off the issue's acceptance criteria.

## Release process (end of a phase / milestone)

At the end of Phase 1, we cut **release 1.0.0**:

1. `git checkout -b release/1.0.0 develop`
2. **create-rc** — tag `v1.0.0-rc.1`; run the full suite including integration tests.
3. Fix anything found on the release branch (no new features).
4. **create-pr** — PR `release/1.0.0` → `main` and → `develop`.
5. Finalise `CHANGELOG.md`: move **Unreleased** → `1.0.0` with a date.
6. Merge to `main` (owner merges manually), tag `v1.0.0`, merge back to `develop`.

## Changelog

`CHANGELOG.md` follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Every issue adds
an entry under **Unreleased**; releases move those entries into a dated section.

## Definition of Done

See [definition-of-done.md](definition-of-done.md).
