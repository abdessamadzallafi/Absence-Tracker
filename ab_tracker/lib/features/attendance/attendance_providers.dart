import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/db/app_database.dart';

import '../students/data/student_local_ds.dart';
import '../students/data/student_repo_impl.dart';
import '../students/domain/student_repo.dart';

import '../attendance/data/attendance_local_ds.dart';
import '../attendance/data/attendance_repo_impl.dart';
import '../attendance/domain/attendance_repo.dart';
import '../attendance/domain/usecases/get_global_stats.dart';
import '../attendance/domain/usecases/get_student_history.dart';

final studentLocalDsProvider =
    Provider((ref) => StudentLocalDS(AppDatabase.instance));
final studentRepoProvider = Provider<StudentRepo>(
    (ref) => StudentRepoImpl(ref.watch(studentLocalDsProvider)));

final attendanceLocalDsProvider =
    Provider((ref) => AttendanceLocalDS(AppDatabase.instance));
final attendanceRepoProvider = Provider<AttendanceRepo>(
    (ref) => AttendanceRepoImpl(ref.watch(attendanceLocalDsProvider)));

final getGlobalStatsProvider =
    Provider((ref) => GetGlobalStats(ref.watch(attendanceRepoProvider)));
final getStudentHistoryProvider =
    Provider((ref) => GetStudentHistory(ref.watch(attendanceRepoProvider)));
