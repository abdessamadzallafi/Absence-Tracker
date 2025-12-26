import 'module.dart';

abstract class ModuleRepo {
  Future<List<ModuleEntity>> getAll({String? query, int? groupId});
  Future<int> upsert(ModuleEntity m);
  Future<int> delete(int id);
}
