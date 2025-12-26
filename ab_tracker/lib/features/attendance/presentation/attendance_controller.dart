import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../modules_sessions/data/module_local_ds.dart';
import '../../modules_sessions/data/module_repo_impl.dart';
import '../../modules_sessions/data/session_local_ds.dart';
import '../../modules_sessions/data/session_repo_impl.dart';
import '../../modules_sessions/domain/module.dart';
import '../../modules_sessions/domain/session.dart';
import '../../students/data/student_local_ds.dart';
import '../../students/data/student_repo_impl.dart';

import '../data/attendance_local_ds.dart';
import '../data/attendance_repo_impl.dart';
import '../domain/attendance.dart';
import '../domain/usecases/get_session_attendance.dart';
import '../domain/usecases/mark_attendance.dart';

class AttendanceRowVM {
  final int studentId;
  final String studentName;
  AttendanceStatus status;
  String? note;

  AttendanceRowVM({
    required this.studentId,
    required this.studentName,
    required this.status,
    this.note,
  });
}

class MarkAttendanceVM {
  final SessionEntity? session;
  final ModuleEntity? module;
  final List<AttendanceRowVM> rows;

  const MarkAttendanceVM(
      {required this.session, required this.module, required this.rows});
}

final attendanceControllerProvider =
    AsyncNotifierProvider<AttendanceController, MarkAttendanceVM>(
        AttendanceController.new);

class AttendanceController extends AsyncNotifier<MarkAttendanceVM> {
  SessionEntity? _session;

  late final AttendanceRepoImpl _attendanceRepo;
  late final GetSessionAttendance _getSessionAtt;
  late final MarkAttendance _mark;

  @override
  Future<MarkAttendanceVM> build() async {
    _attendanceRepo =
        AttendanceRepoImpl(AttendanceLocalDS(AppDatabase.instance));
    _getSessionAtt = GetSessionAttendance(_attendanceRepo);
    _mark = MarkAttendance(_attendanceRepo);
    return const MarkAttendanceVM(session: null, module: null, rows: []);
  }

  Future<void> pickLatestSession(BuildContext context) async {
    final sessionRepo = SessionRepoImpl(SessionLocalDS(AppDatabase.instance));
    final sessions = await sessionRepo.getAll();
    if (sessions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Aucune séance. Crée une séance d’abord.')),
        );
      }
      return;
    }
    _session = sessions.first;
    await _loadRows();
  }

  Future<void> _loadRows() async {
    final s = _session!;
    final moduleRepo = ModuleRepoImpl(ModuleLocalDS(AppDatabase.instance));
    final modules = await moduleRepo.getAll();
    final module = modules.firstWhere((m) => m.id == s.moduleId);

    final studentRepo = StudentRepoImpl(StudentLocalDS(AppDatabase.instance));
    final students = await studentRepo.getAll(
        groupId: module.groupId, sortBy: 'lastName', desc: false);

    final existing = await _getSessionAtt(s.id!);

    final rows = students.map((st) {
      final status = existing[st.id!] ?? AttendanceStatus.present;
      return AttendanceRowVM(
          studentId: st.id!, studentName: st.fullName, status: status);
    }).toList();

    state = AsyncData(MarkAttendanceVM(session: s, module: module, rows: rows));
  }

  void setStatus(int studentId, AttendanceStatus status) {
    final vm = state.value;
    if (vm == null) return;
    final rows = vm.rows.map((r) {
      if (r.studentId == studentId) {
        return AttendanceRowVM(
            studentId: r.studentId,
            studentName: r.studentName,
            status: status,
            note: r.note);
      }
      return r;
    }).toList();

    state = AsyncData(
        MarkAttendanceVM(session: vm.session, module: vm.module, rows: rows));
  }

  void markAll(AttendanceStatus status) {
    final vm = state.value;
    if (vm == null) return;
    final rows = vm.rows
        .map((r) => AttendanceRowVM(
            studentId: r.studentId,
            studentName: r.studentName,
            status: status,
            note: r.note))
        .toList();
    state = AsyncData(
        MarkAttendanceVM(session: vm.session, module: vm.module, rows: rows));
  }

  Future<void> addNote(BuildContext context, int studentId) async {
    final vm = state.value;
    if (vm == null) return;

    final row = vm.rows.firstWhere((e) => e.studentId == studentId);
    final ctrl = TextEditingController(text: row.note ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Note / Justification'),
        content: TextField(
            controller: ctrl,
            decoration:
                const InputDecoration(hintText: 'Ex: Certificat médical')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(_, true), child: const Text('OK')),
        ],
      ),
    );

    if (ok == true) {
      final note = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
      final rows = vm.rows.map((r) {
        if (r.studentId == studentId) {
          return AttendanceRowVM(
              studentId: r.studentId,
              studentName: r.studentName,
              status: r.status,
              note: note);
        }
        return r;
      }).toList();
      state = AsyncData(
          MarkAttendanceVM(session: vm.session, module: vm.module, rows: rows));
    }
  }

  Future<void> save(BuildContext context) async {
    final vm = state.value;
    if (vm == null || vm.session?.id == null) return;

    for (final r in vm.rows) {
      await _mark(
        sessionId: vm.session!.id!,
        studentId: r.studentId,
        status: r.status,
        note: r.note,
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Marquage enregistré ✅')));
    }
  }
}
