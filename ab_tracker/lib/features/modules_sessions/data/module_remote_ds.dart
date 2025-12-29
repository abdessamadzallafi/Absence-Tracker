import '../../../../core/api/api_client.dart';
import 'models/module_model.dart';
import 'package:dio/dio.dart';

class ModuleRemoteDS {
  final ApiClient api;
  ModuleRemoteDS(this.api);

  Future<List<ModuleModel>> getAll({String? query, int? groupId}) async {
    final response = await api.get(
      '/modules',
      queryParameters: groupId != null ? {'groupId': groupId} : null,
    );

    if (response.statusCode == 200) {
      final List data = response.data;
      var modules = data.map((e) => ModuleModel.fromMap(e)).toList();

      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        modules = modules.where((m) =>
          m.name.toLowerCase().contains(q) ||
          m.semester.toLowerCase().contains(q)
        ).toList();
      }
      return modules;
    }
    return [];
  }

  Future<int> upsert(ModuleModel m) async {
    try {
      if (m.id == null) {
        final response = await api.post('/modules', data: m.toMap());
        if (response.statusCode == 201 || response.statusCode == 200) {
           return response.data['id'];
        }
      } else {
        final response = await api.put('/modules/${m.id}', data: m.toMap());
        if (response.statusCode == 200) {
           return m.id!;
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
      final response = await api.delete('/modules/$id');
      if (response.statusCode == 200) {
        return 1;
      }
    } catch (e) {
      rethrow;
    }
    return 0;
  }
}
