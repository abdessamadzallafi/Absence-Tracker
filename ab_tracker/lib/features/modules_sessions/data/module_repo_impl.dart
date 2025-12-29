import '../domain/module.dart';
import '../domain/module_repo.dart';
import 'models/module_model.dart';
import 'module_remote_ds.dart';

class ModuleRepoImpl implements ModuleRepo {
  final ModuleRemoteDS ds;
  ModuleRepoImpl(this.ds);

  @override
  Future<List<ModuleEntity>> getAll({String? query, int? groupId}) =>
      ds.getAll(query: query, groupId: groupId);

  @override
  Future<int> upsert(ModuleEntity m) {
    final mm = ModuleModel(
        id: m.id, name: m.name, semester: m.semester, groupId: m.groupId);
    return ds.upsert(mm);
  }

  @override
  Future<int> delete(int id) => ds.delete(id);
}
