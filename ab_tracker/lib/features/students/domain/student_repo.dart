import 'student.dart';

abstract class StudentRepo {
  Future<List<Student>> getAll({
    String? query,
    int? groupId,
    String sortBy,
    bool desc,
  });

  Future<int> upsert(Student s);
  Future<int> delete(int id);
}
