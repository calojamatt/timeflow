import 'package:drift/drift.dart';
import 'package:timeflow/domain/work_session.dart';
import 'package:timeflow/domain/local_day.dart';
import 'package:timeflow/domain/work_session_repository.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';

/// Drift-backed implementation of [WorkSessionRepository].
class DriftWorkSessionRepository implements WorkSessionRepository {
  DriftWorkSessionRepository(this._db, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  @override
  Future<WorkSession> start({
    required DateTime startedAtUtc,
    required int localDay,
    String? note,
  }) async {
    final session = WorkSession(
      id: _uuid.v4(),
      startedAtUtc: startedAtUtc,
      localDay: localDay,
      note: note,
    );
    await _db.into(_db.workSessions).insert(_toRow(session));
    return session;
  }

  @override
  Future<WorkSession> stop(String id, {required DateTime endedAtUtc}) async {
    final session = await _byId(id);
    if (session == null) {
      throw StateError('No work session with id "$id"');
    }
    final closed = session.stop(endedAtUtc);
    await (_db.update(_db.workSessions)..where((t) => t.id.equals(id))).write(
      WorkSessionsCompanion(endedAtUtc: Value(endedAtUtc)),
    );
    return closed;
  }

  @override
  Future<WorkSession?> findOpen() async {
    final row = await (_db.select(
      _db.workSessions,
    )..where((t) => t.endedAtUtc.isNull())).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<List<WorkSession>> getByDay(int localDay) async {
    final rows =
        await (_db.select(_db.workSessions)
              ..where((t) => t.localDay.equals(localDay))
              ..orderBy([(t) => OrderingTerm.asc(t.startedAtUtc)]))
            .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<WorkSession>> getBetweenDays({
    required int fromLocalDay,
    required int toLocalDay,
  }) async {
    if (toLocalDay < fromLocalDay) {
      throw ArgumentError.value(toLocalDay, 'toLocalDay');
    }
    final rows =
        await (_db.select(_db.workSessions)
              ..where(
                (t) => t.localDay.isBetweenValues(fromLocalDay, toLocalDay),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.startedAtUtc)]))
            .get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<WorkSession> updateHistorical(WorkSession session) async {
    final end = session.endedAtUtc;
    if (end == null) throw ArgumentError('An open session cannot be edited');
    if (!end.isAfter(session.startedAtUtc)) {
      throw ArgumentError('Session end must be after its start');
    }
    if (session.localDay != localDayFrom(session.startedAtUtc)) {
      throw ArgumentError('Session local day must match its start time');
    }

    return _db.transaction(() async {
      final existing = await _byId(session.id);
      if (existing == null) {
        throw StateError('No work session with id "${session.id}"');
      }
      if (existing.isOpen) throw StateError('An open session cannot be edited');
      final others = await (_db.select(
        _db.workSessions,
      )..where((t) => t.id.isNotValue(session.id))).get();
      for (final row in others) {
        final other = _fromRow(row);
        final overlaps =
            (other.endedAtUtc == null ||
                session.startedAtUtc.isBefore(other.endedAtUtc!)) &&
            other.startedAtUtc.isBefore(end);
        if (overlaps) {
          throw StateError('Historical sessions cannot overlap');
        }
      }
      await (_db.update(
        _db.workSessions,
      )..where((t) => t.id.equals(session.id))).write(
        WorkSessionsCompanion(
          startedAtUtc: Value(session.startedAtUtc),
          endedAtUtc: Value(end),
          localDay: Value(session.localDay),
          note: Value(session.note),
        ),
      );
      return session;
    });
  }

  @override
  Future<void> deleteHistorical(String id) async {
    await _db.transaction(() async {
      final session = await _byId(id);
      if (session == null) throw StateError('No work session with id "$id"');
      if (session.isOpen) throw StateError('An open session cannot be deleted');
      await (_db.delete(_db.workSessions)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<WorkSession?> _byId(String id) async {
    final row = await (_db.select(
      _db.workSessions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  WorkSessionRow _toRow(WorkSession s) => WorkSessionRow(
    id: s.id,
    startedAtUtc: s.startedAtUtc,
    endedAtUtc: s.endedAtUtc,
    localDay: s.localDay,
    note: s.note,
  );

  WorkSession _fromRow(WorkSessionRow r) => WorkSession(
    id: r.id,
    startedAtUtc: r.startedAtUtc,
    endedAtUtc: r.endedAtUtc,
    localDay: r.localDay,
    note: r.note,
  );
}
