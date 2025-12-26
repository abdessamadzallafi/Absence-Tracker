import 'package:sqflite/sqflite.dart';
import '../../../data/db/app_database.dart';
import 'models/session_model.dart';

class SessionLocalDS {
  final AppDatabase db;
  SessionLocalDS(this.db);

  Future<List<SessionModel>> getAll(
      {String? query, int? moduleId, String? date}) async {
    final Database d = await db.db;
    final where = <String>[];
    final args = <Object?>[];

    if (moduleId != null) {
      where.add('moduleId=?');
      args.add(moduleId);
    }

    if (date != null && date.trim().isNotEmpty) {
      where.add('date=?');
      args.add(date.trim());
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      where.add('(type LIKE ? OR time LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = await d.query(
      'sessions',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, time DESC',
    );
    return rows.map(SessionModel.fromMap).toList();
  }

  Future<int> upsert(SessionModel s) async {
    final Database d = await db.db;
    if (s.id == null) return d.insert('sessions', s.toMap());
    return d.update('sessions', s.toMap(), where: 'id=?', whereArgs: [s.id]);
  }

  Future<int> delete(int id) async {
    final Database d = await db.db;
    return d.delete('sessions', where: 'id=?', whereArgs: [id]);
  }
}
