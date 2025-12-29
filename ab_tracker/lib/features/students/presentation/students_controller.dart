import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../groups/data/group_remote_ds.dart';
import '../../groups/data/group_repo_impl.dart';
import '../../groups/domain/group.dart';
import '../../groups/domain/usecases/get_groups.dart';
import '../data/student_remote_ds.dart';
import '../data/student_repo_impl.dart';
import '../domain/student.dart';
import '../domain/usecases/delete_student.dart';
import '../domain/usecases/get_students.dart';
import '../domain/usecases/upsert_student.dart';

class StudentsState {
  final List<Group> groups;
  final List<Student> students;
  final int? groupFilterId;
  final String query;
  final String sortBy;
  final bool desc;

  const StudentsState({
    required this.groups,
    required this.students,
    required this.groupFilterId,
    required this.query,
    required this.sortBy,
    required this.desc,
  });

  StudentsState copyWith({
    List<Group>? groups,
    List<Student>? students,
    int? groupFilterId,
    String? query,
    String? sortBy,
    bool? desc,
  }) =>
      StudentsState(
        groups: groups ?? this.groups,
        students: students ?? this.students,
        groupFilterId: groupFilterId ?? this.groupFilterId,
        query: query ?? this.query,
        sortBy: sortBy ?? this.sortBy,
        desc: desc ?? this.desc,
      );
}

final studentsProvider =
    AsyncNotifierProvider.autoDispose<StudentsController, StudentsState>(
        StudentsController.new);

class StudentsController extends AutoDisposeAsyncNotifier<StudentsState> {
  late GetGroups _getGroups;
  late GetStudents _getStudents;
  late UpsertStudent _upsert;
  late DeleteStudent _delete;

  int? _groupId;
  String _query = '';
  String _sortBy = 'lastName';
  bool _desc = false;

  late GroupRepoImpl _groupRepo;
  late StudentRepoImpl _studentRepo;

  @override
  Future<StudentsState> build() async {
    final api = ref.watch(apiClientProvider);

    _groupRepo = GroupRepoImpl(GroupRemoteDS(api));
    _getGroups = GetGroups(_groupRepo);

    _studentRepo = StudentRepoImpl(StudentRemoteDS(api));
    _getStudents = GetStudents(_studentRepo);
    _upsert = UpsertStudent(_studentRepo);
    _delete = DeleteStudent(_studentRepo);

    final groups = await _getGroups();
    final students = await _getStudents(
        query: _query, groupId: _groupId, sortBy: _sortBy, desc: _desc);

    return StudentsState(
      groups: groups,
      students: students,
      groupFilterId: _groupId,
      query: _query,
      sortBy: _sortBy,
      desc: _desc,
    );
  }

  Future<void> refreshAll() async {
    ref.invalidateSelf();
  }

  void setQuery(String q) {
    _query = q;
    ref.invalidateSelf();
  }

  void setGroupFilter(int? id) {
    _groupId = id;
    ref.invalidateSelf();
  }

  void setSort(String sortBy) {
    _sortBy = sortBy;
    ref.invalidateSelf();
  }

  void toggleDesc() {
    _desc = !_desc;
    ref.invalidateSelf();
  }

  Future<void> upsert(Student s) async {
    await _upsert(s);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await _delete(id);
    ref.invalidateSelf();
  }
}
