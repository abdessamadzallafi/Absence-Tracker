import '../group_repo.dart';

class DeleteGroup {
  final GroupRepo repo;
  const DeleteGroup(this.repo);

  Future<int> call(int id) => repo.delete(id);
}
