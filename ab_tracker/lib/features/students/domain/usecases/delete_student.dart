import '../student_repo.dart';

class DeleteStudent {
  final StudentRepo repo;
  const DeleteStudent(this.repo);

  Future<int> call(int id) => repo.delete(id);
}
