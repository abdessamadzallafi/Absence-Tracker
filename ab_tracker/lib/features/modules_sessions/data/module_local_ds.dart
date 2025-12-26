import 'package:sqflite/sqflite.dart';
import '../../../data/db/app_database.dart';
import 'models/module_model.dart';

class ModuleLocalDS {
  final AppDatabase db;
  ModuleLocalDS(this.db);

  Future<List<ModuleModel>> getAll({String? query, int? groupId}) async {
    final Database d = await db.db;
    final where = <String>[];
    final args = <Object?>[];

    if (groupId != null) {
      where.add('groupId=?');
      args.add(groupId);
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = '%${query.trim()}%';
      where.add('(name LIKE ? OR semester LIKE ?)');
      args.addAll([q, q]);
    }

    final rows = await d.query(
      'modules',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name ASC',
    );
    return rows.map(ModuleModel.fromMap).toList();
  }

  Future<int> upsert(ModuleModel m) async {
    final Database d = await db.db;
    if (m.id == null) return d.insert('modules', m.toMap());
    return d.update('modules', m.toMap(), where: 'id=?', whereArgs: [m.id]);
  }

  Future<int> delete(int id) async {
    final Database d = await db.db;
    return d.delete('modules', where: 'id=?', whereArgs: [id]);
  }
}
