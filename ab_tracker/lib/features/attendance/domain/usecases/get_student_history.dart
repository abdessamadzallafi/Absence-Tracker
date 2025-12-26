import '../attendance.dart';
import '../attendance_repo.dart';

class GetStudentHistory {
  final AttendanceRepo repo;
  const GetStudentHistory(this.repo);

  Future<List<StudentHistoryRow>> call(int studentId) =>
      repo.getStudentHistory(studentId);
}
