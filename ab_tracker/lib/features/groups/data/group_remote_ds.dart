import '../../../../core/api/api_client.dart';
import 'models/group_model.dart';
import 'package:dio/dio.dart';

class GroupRemoteDS {
  final ApiClient api;
  GroupRemoteDS(this.api);

  Future<List<GroupModel>> getAll({String? query}) async {
    final response = await api.get('/groups');
    if (response.statusCode == 200) {
      final List data = response.data;
      var groups = data.map((e) => GroupModel.fromMap(e)).toList();
      
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        groups = groups.where((g) => 
          g.name.toLowerCase().contains(q) || 
          g.filiere.toLowerCase().contains(q)
        ).toList();
      }
      return groups;
    }
    return [];
  }

  Future<int> upsert(GroupModel g) async {
    try {
      if (g.id == null) {
        // Create
        final response = await api.post('/groups', data: g.toMap());
        if (response.statusCode == 201 || response.statusCode == 200) {
           return response.data['id'];
        }
      } else {
        // Update
        final response = await api.put('/groups/${g.id}', data: g.toMap());
        if (response.statusCode == 200) {
           return g.id!;
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
      final response = await api.delete('/groups/$id');
      if (response.statusCode == 200) {
        return 1;
      }
    } catch (e) {
      rethrow;
    }
    return 0;
  }
}
