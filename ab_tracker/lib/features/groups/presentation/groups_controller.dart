import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../data/group_local_ds.dart';
import '../data/group_repo_impl.dart';
import '../domain/group.dart';
import '../domain/usecases/delete_group.dart';
import '../domain/usecases/get_groups.dart';
import '../domain/usecases/upsert_group.dart';

final groupsControllerProvider =
    AsyncNotifierProvider<GroupsController, List<Group>>(GroupsController.new);

class GroupsController extends AsyncNotifier<List<Group>> {
  String _query = '';

  late final AppDatabase _db;
  late final GetGroups _get;
  late final UpsertGroup _upsert;
  late final DeleteGroup _delete;

  @override
  Future<List<Group>> build() async {
    _db = AppDatabase.instance;
    final repo = GroupRepoImpl(GroupLocalDS(_db));
    _get = GetGroups(repo);
    _upsert = UpsertGroup(repo);
    _delete = DeleteGroup(repo);
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
