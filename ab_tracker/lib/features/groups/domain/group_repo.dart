import 'group.dart';

abstract class GroupRepo {
  Future<List<Group>> getAll({String? query});
  Future<int> upsert(Group g);
  Future<int> delete(int id);
}
