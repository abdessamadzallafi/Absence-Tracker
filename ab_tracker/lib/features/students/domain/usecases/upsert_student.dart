import '../student.dart';
import '../student_repo.dart';

class UpsertStudent {
  final StudentRepo repo;
  const UpsertStudent(this.repo);

  Future<int> call(Student s) => repo.upsert(s);
}
