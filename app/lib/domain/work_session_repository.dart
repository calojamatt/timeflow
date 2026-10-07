import 'work_session.dart';

/// Contract for persisting [WorkSession]s. Implemented by the data layer.
abstract interface class WorkSessionRepository {
  /// Starts a new open session and returns it with its generated id.
  Future<WorkSession> start({
    required DateTime startedAtUtc,
    required int localDay,
    String? note,
  });

  /// Closes the session with [id], returning the closed session.
  ///
  /// Throws [StateError] if no such session exists or it is already closed.
  Future<WorkSession> stop(String id, {required DateTime endedAtUtc});

  /// Returns the currently open session, or `null` if none.
  Future<WorkSession?> findOpen();

  /// Returns all sessions belonging to [localDay], ordered by start time.
  Future<List<WorkSession>> getByDay(int localDay);

  /// Returns sessions in an inclusive local-day range, ordered chronologically.
  Future<List<WorkSession>> getBetweenDays({
    required int fromLocalDay,
    required int toLocalDay,
  });

  /// Updates a closed historical session after validating time and overlap.
  Future<WorkSession> updateHistorical(WorkSession session);

  /// Deletes a closed historical session.
  Future<void> deleteHistorical(String id);
}
