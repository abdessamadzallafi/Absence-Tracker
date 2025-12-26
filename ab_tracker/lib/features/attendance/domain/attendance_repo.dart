import 'attendance.dart';

abstract class AttendanceRepo {
  Future<GlobalStats> getGlobalStats();
  Future<void> markAttendance({
    required int sessionId,
    required int studentId,
    required AttendanceStatus status,
    String? note,
  });

  Future<Map<int, AttendanceStatus>> getSessionAttendance(int sessionId);
  Future<List<StudentHistoryRow>> getStudentHistory(int studentId);
}
