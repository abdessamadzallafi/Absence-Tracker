import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/db/app_database.dart';
import '../../groups/data/group_local_ds.dart';
import '../../groups/data/group_repo_impl.dart';
import '../../groups/domain/group.dart';
import '../../groups/domain/usecases/get_groups.dart';
import '../data/module_local_ds.dart';
import '../data/module_repo_impl.dart';
import '../domain/module.dart';

class ModulesState {
  final List<Group> groups;
  final List<ModuleEntity> modules;
  final int? groupFilterId;
  final String query;

  const ModulesState(
      {required this.groups,
      required this.modules,
      required this.groupFilterId,
      required this.query});
}

final modulesControllerProvider =
    AsyncNotifierProvider<ModulesController, ModulesState>(
        ModulesController.new);

class ModulesController extends AsyncNotifier<ModulesState> {
  String _query = '';
  int? _groupId;

  late final AppDatabase _db;

  @override
  Future<ModulesState> build() async {
    _db = AppDatabase.instance;
    final groupsRepo = GroupRepoImpl(GroupLocalDS(_db));
    final groups = await GetGroups(groupsRepo)();

    final moduleRepo = ModuleRepoImpl(ModuleLocalDS(_db));
    final modules = await moduleRepo.getAll(query: _query, groupId: _groupId);

    return ModulesState(
        groups: groups,
        modules: modules,
        groupFilterId: _groupId,
        query: _query);
  }

  void setQuery(String q) {
    _query = q;
    ref.invalidateSelf();
  }

  void setGroupFilter(int? id) {
    _groupId = id;
    ref.invalidateSelf();
  }

  Future<void> upsert(ModuleEntity m) async {
    final repo = ModuleRepoImpl(ModuleLocalDS(_db));
    await repo.upsert(m);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    final repo = ModuleRepoImpl(ModuleLocalDS(_db));
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
