import '../group.dart';
import '../group_repo.dart';

class UpsertGroup {
  final GroupRepo repo;
  const UpsertGroup(this.repo);

  Future<int> call(Group g) => repo.upsert(g);
}
