import 'clock.dart';
import 'local_day.dart';
import 'work_session.dart';
import 'work_session_repository.dart';

/// Starts a new work session.
class StartWork {
  StartWork(this._clock, this._repository);

  final Clock _clock;
  final WorkSessionRepository _repository;

  /// Starts a session at the current time and returns it.
  ///
  /// Throws [StateError] if a session is already open.
  Future<WorkSession> call({String? note}) async {
    if (await _repository.findOpen() != null) {
      throw StateError('A work session is already open');
    }

    final now = _clock.now();
    return _repository.start(
      startedAtUtc: now.toUtc(),
      localDay: localDayFrom(now),
      note: note,
    );
  }
}
