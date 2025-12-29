import '../../../../core/api/api_client.dart';
import 'models/student_model.dart';
import 'package:dio/dio.dart';

class StudentRemoteDS {
  final ApiClient api;
  StudentRemoteDS(this.api);

  Future<List<StudentModel>> getAll({
    String? query,
    int? groupId,
    String sortBy = 'lastName',
    bool desc = false,
  }) async {
    print('🔍 Fetching students with groupId: $groupId');

    final response = await api.get(
      '/students',
      queryParameters: groupId != null ? {'groupId': groupId} : null,
    );

    print('📡 API Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List data = response.data;
      print('📊 Total students from API: ${data.length}');
      print('📋 Students data: $data');

      var students = data.map((e) => StudentModel.fromMap(e)).toList();

      // Client-side filtering
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        students = students
            .where((s) =>
                s.firstName.toLowerCase().contains(q) ||
                s.lastName.toLowerCase().contains(q) ||
                s.massar.toLowerCase().contains(q))
            .toList();
      }

      // Client-side sorting (if not relying on server default)
      // Server sorts by lastName asc, firstName asc by default.
      if (sortBy == 'lastName') {
        students.sort((a, b) => desc
            ? b.lastName.compareTo(a.lastName)
            : a.lastName.compareTo(b.lastName));
      } else if (sortBy == 'firstName') {
        students.sort((a, b) => desc
            ? b.firstName.compareTo(a.firstName)
            : a.firstName.compareTo(b.firstName));
      }

      print('✅ Returning ${students.length} students after filtering/sorting');
      return students;
    }
    print('❌ API returned non-200 status');
    return [];
  }

  Future<int> upsert(StudentModel s) async {
    try {
      if (s.id == null) {
        final response = await api.post('/students', data: s.toMap());
        if (response.statusCode == 201 || response.statusCode == 200) {
          return response.data['id'];
        }
      } else {
        final response = await api.put('/students/${s.id}', data: s.toMap());
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
      final response = await api.delete('/students/$id');
      if (response.statusCode == 200) {
        return 1;
      }
    } catch (e) {
      rethrow;
    }
    return 0;
  }
}
