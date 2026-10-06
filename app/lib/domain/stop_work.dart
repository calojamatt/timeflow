import 'clock.dart';
import 'work_session.dart';
import 'work_session_repository.dart';

/// Stops the currently open work session.
class StopWork {
  StopWork(this._clock, this._repository);

  final Clock _clock;
  final WorkSessionRepository _repository;

  /// Stops the open session at the current time and returns the closed session.
  ///
  /// Throws [StateError] if no session is open.
  Future<WorkSession> call() async {
    final open = await _repository.findOpen();
    if (open == null) {
      throw StateError('No work session is open');
    }
    return _repository.stop(open.id, endedAtUtc: _clock.now().toUtc());
  }
}
