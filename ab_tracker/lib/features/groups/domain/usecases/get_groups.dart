import '../group.dart';
import '../group_repo.dart';

class GetGroups {
  final GroupRepo repo;
  const GetGroups(this.repo);

  Future<List<Group>> call({String? query}) => repo.getAll(query: query);
}
