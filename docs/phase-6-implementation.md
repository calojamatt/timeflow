# Phase 6 — Optional Cloud Synchronization

## Goal

Add multi-device synchronization only after local persistence and backup are
proven reliable.

## Prerequisites

- Phase 5 backup and restore are complete.
- Sync business requirements are approved.
- Authentication, encryption, conflict, and retention decisions are recorded
  as ADRs.

## Slices

1. Sync architecture and threat model.
2. Sync boundary behind repositories.
3. Authentication and device identity.
4. Offline upload/download queues.
5. Conflict resolution.
6. Encryption and deletion propagation.
7. Multi-device and failure validation.

## Required tests

- Offline queue tests.
- Retry and partial-failure tests.
- Conflict resolution tests.
- Multi-device integration tests.
- Authentication and authorization tests.
- Encryption and deletion tests.

## Completion criteria

The app remains fully useful offline, conflicts are deterministic, and sync can
be disabled without losing local data. This phase ends with the first `2.0.0`
release only after the operational design is approved.
