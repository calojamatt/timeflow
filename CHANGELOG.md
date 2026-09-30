# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Phase 0 blueprint: architecture overview, ADRs, deployment/sequence diagrams,
  Phase 1 scope, XP process, Definition of Done, and GitFlow delivery process.
- Flutter project scaffold for Android and iOS (package `com.dytsas.timeflow`) (#8)
- Core dependencies (riverpod, drift, go_router) and presentation/domain/data layer folders (#9)
- `WorkSession` domain entity with start/end/elapsed time (#12)
- drift `work_session` table with a single-open-session unique index (#13)

<!--
Template for issue-driven entries (add under Unreleased → Added/Changed/Fixed):

- feat(scope): description of the change (#<issue>)
-->
