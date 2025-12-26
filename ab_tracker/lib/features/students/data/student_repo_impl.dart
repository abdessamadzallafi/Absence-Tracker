import '../domain/student.dart';
import '../domain/student_repo.dart';
import 'models/student_model.dart';
import 'student_local_ds.dart';

class StudentRepoImpl implements StudentRepo {
  final StudentLocalDS ds;
  StudentRepoImpl(this.ds);

  @override
  Future<List<Student>> getAll({
    String? query,
    int? groupId,
    String sortBy = 'lastName',
    bool desc = false,
  }) =>
      ds.getAll(query: query, groupId: groupId, sortBy: sortBy, desc: desc);

  @override
  Future<int> upsert(Student s) {
    final m = StudentModel(
      id: s.id,
      groupId: s.groupId,
      massar: s.massar,
      firstName: s.firstName,
      lastName: s.lastName,
      email: s.email,
    );
    return ds.upsert(m);
  }

  @override
  Future<int> delete(int id) => ds.delete(id);
}
