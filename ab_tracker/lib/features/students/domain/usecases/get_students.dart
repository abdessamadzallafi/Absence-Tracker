import '../student.dart';
import '../student_repo.dart';

class GetStudents {
  final StudentRepo repo;
  const GetStudents(this.repo);

  Future<List<Student>> call({
    String? query,
    int? groupId,
    String sortBy = 'lastName',
    bool desc = false,
  }) =>
      repo.getAll(query: query, groupId: groupId, sortBy: sortBy, desc: desc);
}
