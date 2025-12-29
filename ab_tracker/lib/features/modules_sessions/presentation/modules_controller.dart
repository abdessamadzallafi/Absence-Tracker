import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../groups/data/group_remote_ds.dart';
import '../../groups/data/group_repo_impl.dart';
import '../../groups/domain/group.dart';
import '../../groups/domain/usecases/get_groups.dart';
import '../data/module_remote_ds.dart';
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

  late ModuleRepoImpl _moduleRepo;

  @override
  Future<ModulesState> build() async {
    final api = ref.watch(apiClientProvider);
    final groupsRepo = GroupRepoImpl(GroupRemoteDS(api));
    final groups = await GetGroups(groupsRepo)();

    _moduleRepo = ModuleRepoImpl(ModuleRemoteDS(api));
    final modules = await _moduleRepo.getAll(query: _query, groupId: _groupId);

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
    await _moduleRepo.upsert(m);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await _moduleRepo.delete(id);
    ref.invalidateSelf();
  }
}
