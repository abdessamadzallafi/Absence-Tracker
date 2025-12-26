import 'session.dart';

abstract class SessionRepo {
  Future<List<SessionEntity>> getAll(
      {String? query, int? moduleId, String? date});
  Future<int> upsert(SessionEntity s);
  Future<int> delete(int id);
}
