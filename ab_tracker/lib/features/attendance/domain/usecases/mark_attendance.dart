import '../attendance.dart';
import '../attendance_repo.dart';

class MarkAttendance {
  final AttendanceRepo repo;
  const MarkAttendance(this.repo);

  Future<void> call({
    required int sessionId,
    required int studentId,
    required AttendanceStatus status,
    String? note,
  }) =>
      repo.markAttendance(
          sessionId: sessionId,
          studentId: studentId,
          status: status,
          note: note);
}
