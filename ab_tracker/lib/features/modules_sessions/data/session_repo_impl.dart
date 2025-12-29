import '../domain/session.dart';
import '../domain/session_repo.dart';
import 'models/session_model.dart';
import 'session_remote_ds.dart';

class SessionRepoImpl implements SessionRepo {
  final SessionRemoteDS ds;
  SessionRepoImpl(this.ds);

  @override
  Future<List<SessionEntity>> getAll(
          {String? query, int? moduleId, String? date}) =>
      ds.getAll(query: query, moduleId: moduleId, date: date);

  @override
  Future<int> upsert(SessionEntity s) {
    final sm = SessionModel(
        id: s.id,
        moduleId: s.moduleId,
        date: s.date,
        time: s.time,
        type: s.type);
    return ds.upsert(sm);
  }

  @override
  Future<int> delete(int id) => ds.delete(id);
}
