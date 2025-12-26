import '../domain/group.dart';
import '../domain/group_repo.dart';
import 'group_local_ds.dart';
import 'models/group_model.dart';

class GroupRepoImpl implements GroupRepo {
  final GroupLocalDS ds;
  GroupRepoImpl(this.ds);

  @override
  Future<List<Group>> getAll({String? query}) => ds.getAll(query: query);

  @override
  Future<int> upsert(Group g) {
    final m = GroupModel(id: g.id, name: g.name, filiere: g.filiere);
    return ds.upsert(m);
  }

  @override
  Future<int> delete(int id) => ds.delete(id);
}
