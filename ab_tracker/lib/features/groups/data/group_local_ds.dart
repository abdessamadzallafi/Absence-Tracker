import 'package:sqflite/sqflite.dart';
import '../../../data/db/app_database.dart';
import 'models/group_model.dart';

class GroupLocalDS {
  final AppDatabase db;
  GroupLocalDS(this.db);

  Future<List<GroupModel>> getAll({String? query}) async {
    final Database d = await db.db;

    final where = <String>[];
    final args = <Object?>[];

    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      where.add('(name LIKE ? OR filiere LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = await d.query(
      'groups',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name ASC',
    );
    return rows.map(GroupModel.fromMap).toList();
  }

  Future<int> upsert(GroupModel g) async {
    final Database d = await db.db;
    if (g.id == null) return d.insert('groups', g.toMap());
    return d.update('groups', g.toMap(), where: 'id=?', whereArgs: [g.id]);
  }

  Future<int> delete(int id) async {
    final Database d = await db.db;
    return d.delete('groups', where: 'id=?', whereArgs: [id]);
  }
}
