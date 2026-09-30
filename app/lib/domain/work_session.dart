/// A recorded period of work.
///
/// A work session is a *record* with a start and an optional end — not a
/// running counter. While [endedAtUtc] is `null` the session is open and its
/// elapsed time is derived from [startedAtUtc] on demand (ADR-0006).
class WorkSession {
  WorkSession({
    required this.id,
    required this.startedAtUtc,
    this.endedAtUtc,
    required this.localDay,
    this.note,
  }) : assert(
         endedAtUtc == null || !endedAtUtc.isBefore(startedAtUtc),
         'endedAtUtc must not be before startedAtUtc',
       );

  /// Stable identifier.
  final String id;

  /// When the session began (UTC instant).
  final DateTime startedAtUtc;

  /// When the session ended (UTC instant). `null` while the session is open.
  final DateTime? endedAtUtc;

  /// The device-local day this session belongs to (days since epoch),
  /// bucketed by start day. See ADR-0005.
  final int localDay;

  /// Optional user note.
  final String? note;

  /// Whether the session is still running.
  bool get isOpen => endedAtUtc == null;

  /// The elapsed time at [now]: `end - start` when closed, `now - start` when
  /// open.
  Duration elapsedAt(DateTime now) =>
      (endedAtUtc ?? now).difference(startedAtUtc);

  /// Returns a closed copy of this session ending at [endedAtUtc].
  ///
  /// Throws [StateError] if the session is already closed.
  WorkSession stop(DateTime endedAtUtc) {
    if (!isOpen) {
      throw StateError('Cannot stop session "$id": it is already closed');
    }
    return WorkSession(
      id: id,
      startedAtUtc: startedAtUtc,
      endedAtUtc: endedAtUtc,
      localDay: localDay,
      note: note,
    );
  }
}
