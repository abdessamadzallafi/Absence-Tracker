import 'package:sqflite/sqflite.dart';
import '../../../data/db/app_database.dart';
import 'models/student_model.dart';

class StudentLocalDS {
  final AppDatabase db;
  StudentLocalDS(this.db);

  Future<List<StudentModel>> getAll({
    String? query,
    int? groupId,
    String sortBy = 'lastName',
    bool desc = false,
  }) async {
    final Database d = await db.db;

    final where = <String>[];
    final args = <Object?>[];

    if (groupId != null) {
      where.add('groupId=?');
      args.add(groupId);
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      where.add('(firstName LIKE ? OR lastName LIKE ? OR massar LIKE ?)');
      args.addAll([q, q, q]);
    }

    final rows = await d.query(
      'students',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: '$sortBy ${desc ? 'DESC' : 'ASC'}',
    );
    return rows.map(StudentModel.fromMap).toList();
  }

  Future<int> upsert(StudentModel s) async {
    final Database d = await db.db;
    if (s.id == null) return d.insert('students', s.toMap());
    return d.update('students', s.toMap(), where: 'id=?', whereArgs: [s.id]);
  }

  Future<int> delete(int id) async {
    final Database d = await db.db;
    return d.delete('students', where: 'id=?', whereArgs: [id]);
  }
}
