import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_provider.dart';

import '../students/data/student_remote_ds.dart';
import '../students/data/student_repo_impl.dart';
import '../students/domain/student_repo.dart';

import '../attendance/data/attendance_remote_ds.dart';
import '../attendance/data/attendance_repo_impl.dart';
import '../attendance/domain/attendance_repo.dart';
import '../attendance/domain/usecases/get_global_stats.dart';
import '../attendance/domain/usecases/get_student_history.dart';

final studentRemoteDsProvider =
    Provider((ref) => StudentRemoteDS(ref.watch(apiClientProvider)));
final studentRepoProvider = Provider<StudentRepo>(
    (ref) => StudentRepoImpl(ref.watch(studentRemoteDsProvider)));

final attendanceRemoteDsProvider =
    Provider((ref) => AttendanceRemoteDS(ref.watch(apiClientProvider)));
final attendanceRepoProvider = Provider<AttendanceRepo>(
    (ref) => AttendanceRepoImpl(ref.watch(attendanceRemoteDsProvider)));

final getGlobalStatsProvider =
    Provider((ref) => GetGlobalStats(ref.watch(attendanceRepoProvider)));
final getStudentHistoryProvider =
    Provider((ref) => GetStudentHistory(ref.watch(attendanceRepoProvider)));
