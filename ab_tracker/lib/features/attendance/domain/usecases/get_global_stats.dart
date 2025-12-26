import '../attendance.dart';
import '../attendance_repo.dart';

class GetGlobalStats {
  final AttendanceRepo repo;
  const GetGlobalStats(this.repo);

  Future<GlobalStats> call() => repo.getGlobalStats();
}
