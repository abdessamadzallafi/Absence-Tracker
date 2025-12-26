import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/db/app_database.dart';
import '../../groups/data/group_local_ds.dart';
import '../../groups/data/group_repo_impl.dart';
import '../../groups/domain/group.dart';
import '../../groups/domain/usecases/get_groups.dart';
import '../data/student_local_ds.dart';
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

final studentsControllerProvider =
    AsyncNotifierProvider<StudentsController, StudentsState>(
        StudentsController.new);

class StudentsController extends AsyncNotifier<StudentsState> {
  late final AppDatabase _db;

  late final GetGroups _getGroups;
  late final GetStudents _getStudents;
  late final UpsertStudent _upsert;
  late final DeleteStudent _delete;

  int? _groupId;
  String _query = '';
  String _sortBy = 'lastName';
  bool _desc = false;

  @override
  Future<StudentsState> build() async {
    _db = AppDatabase.instance;

    final groupsRepo = GroupRepoImpl(GroupLocalDS(_db));
    _getGroups = GetGroups(groupsRepo);

    final studentRepo = StudentRepoImpl(StudentLocalDS(_db));
    _getStudents = GetStudents(studentRepo);
    _upsert = UpsertStudent(studentRepo);
    _delete = DeleteStudent(studentRepo);

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
