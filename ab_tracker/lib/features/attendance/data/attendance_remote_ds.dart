import '../../../../core/api/api_client.dart';
import '../domain/attendance.dart';
import 'package:dio/dio.dart';

class AttendanceRemoteDS {
  final ApiClient api;
  AttendanceRemoteDS(this.api);

  Future<GlobalStats> globalStats() async {
    try {
      final response = await api.get('/attendance/stats');
      if (response.statusCode == 200) {
        final data = response.data;
        return GlobalStats(
          present: data['present'] ?? 0,
          absent: data['absent'] ?? 0,
          justified: data['justified'] ?? 0,
        );
      }
    } catch (e) {
      if (e is DioException) {
        // handle error
      }
    }
    return const GlobalStats(present: 0, absent: 0, justified: 0);
  }

  Future<void> upsert({
    required int sessionId,
    required int studentId,
    required AttendanceStatus status,
    String? note,
  }) async {
    try {
      await api.post('/attendance/mark', data: {
        'sessionId': sessionId,
        'studentId': studentId,
        'status': status.name,
        'note': note,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<int, AttendanceStatus>> sessionAttendance(int sessionId) async {
    try {
      final response = await api.get('/attendance/session/$sessionId');
      if (response.statusCode == 200) {
        final List data = response.data;
        final map = <int, AttendanceStatus>{};
        for (final item in data) {
          final studentId = item['student']['id'] as int;
          final statusStr = item['status'] as String;
          map[studentId] = AttendanceStatus.values.firstWhere(
            (e) => e.name == statusStr,
            orElse: () => AttendanceStatus.present,
          );
        }
        return map;
      }
    } catch (e) {
      rethrow;
    }
    return {};
  }

  Future<List<StudentHistoryRow>> studentHistory(int studentId) async {
    try {
      final response = await api.get('/attendance/student/$studentId/history');
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) {
          final datesList = (e['dates'] as List).map((d) => d['date'].toString()).toList();
          return StudentHistoryRow(
            moduleName: e['moduleName'],
            absent: e['absent'] is int ? e['absent'] : 0,
            justified: e['justified'] is int ? e['justified'] : 0,
            dates: datesList,
          );
        }).toList();
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }
}
