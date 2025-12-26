import '../attendance.dart';
import '../attendance_repo.dart';

class GetSessionAttendance {
  final AttendanceRepo repo;
  const GetSessionAttendance(this.repo);

  Future<Map<int, AttendanceStatus>> call(int sessionId) =>
      repo.getSessionAttendance(sessionId);
}
