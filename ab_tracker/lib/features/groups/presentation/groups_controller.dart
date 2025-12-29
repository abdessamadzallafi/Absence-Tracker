import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_provider.dart';
import '../../../data/db/app_database.dart';
import '../data/group_remote_ds.dart';
import '../data/group_repo_impl.dart';
import '../domain/group.dart';
import '../domain/usecases/delete_group.dart';
import '../domain/usecases/get_groups.dart';
import '../domain/usecases/upsert_group.dart';

final groupsControllerProvider =
    AsyncNotifierProvider<GroupsController, List<Group>>(GroupsController.new);

class GroupsController extends AsyncNotifier<List<Group>> {
  String _query = '';

  late GetGroups _get;
  late UpsertGroup _upsert;
  late DeleteGroup _delete;
  late GroupRepoImpl _repo;

  @override
  Future<List<Group>> build() async {
    final api = ref.watch(apiClientProvider);
    _repo = GroupRepoImpl(GroupRemoteDS(api));
    
    _get = GetGroups(_repo);
    _upsert = UpsertGroup(_repo);
    _delete = DeleteGroup(_repo);
    return _get(query: _query);
  }

  void setQuery(String q) {
    _query = q;
    ref.invalidateSelf();
  }

  Future<void> upsert(Group g) async {
    await _upsert(g);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await _delete(id);
    ref.invalidateSelf();
  }
}
