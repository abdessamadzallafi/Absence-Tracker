import '../domain/attendance.dart';
import '../domain/attendance_repo.dart';
import 'attendance_local_ds.dart';

class AttendanceRepoImpl implements AttendanceRepo {
  final AttendanceLocalDS ds;
  AttendanceRepoImpl(this.ds);

  @override
  Future<GlobalStats> getGlobalStats() => ds.globalStats();

  @override
  Future<void> markAttendance({
    required int sessionId,
    required int studentId,
    required AttendanceStatus status,
    String? note,
  }) =>
      ds.upsert(
          sessionId: sessionId,
          studentId: studentId,
          status: status,
          note: note);

  @override
  Future<Map<int, AttendanceStatus>> getSessionAttendance(int sessionId) =>
      ds.sessionAttendance(sessionId);

  @override
  Future<List<StudentHistoryRow>> getStudentHistory(int studentId) =>
      ds.studentHistory(studentId);
}
