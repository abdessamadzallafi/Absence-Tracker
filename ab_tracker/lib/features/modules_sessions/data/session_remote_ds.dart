import '../../../../core/api/api_client.dart';
import 'models/session_model.dart';
import 'package:dio/dio.dart';

class SessionRemoteDS {
  final ApiClient api;
  SessionRemoteDS(this.api);

  Future<List<SessionModel>> getAll(
      {String? query, int? moduleId, String? date}) async {
    final response = await api.get(
      '/sessions',
      queryParameters: moduleId != null ? {'moduleId': moduleId} : null,
    );

    if (response.statusCode == 200) {
      final List data = response.data;
      var sessions = data.map((e) => SessionModel.fromMap(e)).toList();

      // Client-side filtering
      if (date != null && date.trim().isNotEmpty) {
        sessions = sessions.where((s) => s.date.startsWith(date.trim())).toList();
      }

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        sessions = sessions.where((s) =>
          s.type.toLowerCase().contains(q) ||
          s.time.toLowerCase().contains(q)
        ).toList();
      }
      
      // Client-side sorting
      sessions.sort((a, b) {
        final dateComp = b.date.compareTo(a.date);
        if (dateComp != 0) return dateComp;
        return b.time.compareTo(a.time);
      });

      return sessions;
    }
    return [];
  }

  Future<int> upsert(SessionModel s) async {
    try {
      if (s.id == null) {
        final response = await api.post('/sessions', data: s.toMap());
        if (response.statusCode == 201 || response.statusCode == 200) {
           return response.data['id'];
        }
      } else {
        final response = await api.put('/sessions/${s.id}', data: s.toMap());
        if (response.statusCode == 200) {
           return s.id!;
        }
      }
    } catch (e) {
      if (e is DioException) {
        // handle error
      }
      rethrow;
    }
    return -1;
  }

  Future<int> delete(int id) async {
    try {
      final response = await api.delete('/sessions/$id');
      if (response.statusCode == 200) {
        return 1;
      }
    } catch (e) {
      rethrow;
    }
    return 0;
  }
}
