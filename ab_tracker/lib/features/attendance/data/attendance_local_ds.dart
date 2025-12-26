import 'package:sqflite/sqflite.dart';
import '../../../data/db/app_database.dart';
import '../domain/attendance.dart';

class AttendanceLocalDS {
  final AppDatabase db;
  AttendanceLocalDS(this.db);

  Future<GlobalStats> globalStats() async {
    final Database d = await db.db;
    final rows = await d.rawQuery('''
SELECT
  SUM(CASE WHEN status='present' THEN 1 ELSE 0 END) as presentCount,
  SUM(CASE WHEN status='absent' THEN 1 ELSE 0 END) as absentCount,
  SUM(CASE WHEN status='justified' THEN 1 ELSE 0 END) as justifiedCount
FROM absences;
''');
    final r = rows.first;
    return GlobalStats(
      present: (r['presentCount'] as int?) ?? 0,
      absent: (r['absentCount'] as int?) ?? 0,
      justified: (r['justifiedCount'] as int?) ?? 0,
    );
  }

  Future<void> upsert({
    required int sessionId,
    required int studentId,
    required AttendanceStatus status,
    String? note,
  }) async {
    final Database d = await db.db;
    await d.insert(
      'absences',
      {
        'sessionId': sessionId,
        'studentId': studentId,
        'status': status.name,
        'note': note
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<int, AttendanceStatus>> sessionAttendance(int sessionId) async {
    final Database d = await db.db;
    final rows =
        await d.query('absences', where: 'sessionId=?', whereArgs: [sessionId]);
    final map = <int, AttendanceStatus>{};
    for (final r in rows) {
      final sid = r['studentId'] as int;
      final st = r['status'] as String;
      map[sid] = AttendanceStatus.values.firstWhere((e) => e.name == st,
          orElse: () => AttendanceStatus.present);
    }
    return map;
  }

  Future<List<StudentHistoryRow>> studentHistory(int studentId) async {
    final Database d = await db.db;

    final rows = await d.rawQuery('''
SELECT m.name as moduleName,
       SUM(CASE WHEN a.status='absent' THEN 1 ELSE 0 END) as absentCount,
       SUM(CASE WHEN a.status='justified' THEN 1 ELSE 0 END) as justifiedCount
FROM absences a
JOIN sessions s ON s.id=a.sessionId
JOIN modules m ON m.id=s.moduleId
WHERE a.studentId=?
GROUP BY m.id
ORDER BY absentCount DESC;
''', [studentId]);

    final result = <StudentHistoryRow>[];

    for (final row in rows) {
      final moduleName = row['moduleName'] as String;

      final dateRows = await d.rawQuery('''
SELECT s.date as d
FROM absences a
JOIN sessions s ON s.id=a.sessionId
JOIN modules m ON m.id=s.moduleId
WHERE a.studentId=? AND m.name=? AND a.status IN ('absent','justified')
ORDER BY s.date DESC;
''', [studentId, moduleName]);

      result.add(
        StudentHistoryRow(
          moduleName: moduleName,
          absent: (row['absentCount'] as int?) ?? 0,
          justified: (row['justifiedCount'] as int?) ?? 0,
          dates: dateRows.map((e) => e['d'] as String).toList(),
        ),
      );
    }

    return result;
  }
}
