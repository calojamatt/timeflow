import 'package:drift/drift.dart';
import 'package:timeflow/domain/work_session.dart';
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
