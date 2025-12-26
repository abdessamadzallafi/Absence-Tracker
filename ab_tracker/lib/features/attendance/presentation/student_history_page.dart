import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/export/export_service.dart';
import '../../../data/db/app_database.dart';
import '../../students/data/student_local_ds.dart';
import '../../students/data/student_repo_impl.dart';
import '../../students/domain/student.dart';
import '../data/attendance_local_ds.dart';
import '../data/attendance_repo_impl.dart';
import '../domain/usecases/get_student_history.dart';
import '../domain/attendance.dart';

final studentsListProvider = FutureProvider<List<Student>>((ref) async {
  final repo = StudentRepoImpl(StudentLocalDS(AppDatabase.instance));
  return repo.getAll(sortBy: 'lastName', desc: false);
});

final studentHistoryProvider =
    FutureProvider.family<List<StudentHistoryRow>, int>((ref, studentId) async {
  final repo = AttendanceRepoImpl(AttendanceLocalDS(AppDatabase.instance));
  return GetStudentHistory(repo)(studentId);
});

class StudentHistoryPage extends ConsumerStatefulWidget {
  const StudentHistoryPage({super.key});

  @override
  ConsumerState<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends ConsumerState<StudentHistoryPage> {
  int? selectedId;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsListProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (students) {
          if (students.isEmpty)
            return const Center(child: Text('Aucun étudiant.'));

          selectedId ??= students.first.id!;
          final sid = selectedId!;
          final histAsync = ref.watch(studentHistoryProvider(sid));

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: sid,
                      items: students
                          .map((s) => DropdownMenuItem<int>(
                              value: s.id!,
                              child: Text('${s.fullName} (#${s.id})')))
                          .toList(),
                      onChanged: (v) => setState(() => selectedId = v),
                      decoration:
                          const InputDecoration(labelText: 'Choisir étudiant'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final rows =
                          await ref.read(studentHistoryProvider(sid).future);
                      final csvRows = <List<dynamic>>[
                        ['Module', 'Absents', 'Justifiés', 'Dates'],
                        ...rows.map((r) => [
                              r.moduleName,
                              r.absent,
                              r.justified,
                              r.dates.join(' | ')
                            ]),
                      ];
                      final file = await ExportService()
                          .exportCsv('history_student_$sid', csvRows);
                      await ExportService()
                          .shareFile(file, text: 'Historique étudiant #$sid');
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('CSV'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      final rows =
                          await ref.read(studentHistoryProvider(sid).future);
                      final table = <List<String>>[
                        ['Module', 'Absents', 'Justifiés', 'Dates'],
                        ...rows.map((r) => [
                              r.moduleName,
                              '${r.absent}',
                              '${r.justified}',
                              r.dates.join(' | ')
                            ]),
                      ];
                      await ExportService().exportPdfAndShare(
                        filename: 'history_student_$sid',
                        title: 'Historique étudiant #$sid',
                        table: table,
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: histAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Erreur: $e')),
                  data: (rows) {
                    if (rows.isEmpty)
                      return const Center(child: Text('Aucun historique.'));
                    return ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final r = rows[i];
                        return Card(
                          child: ListTile(
                            title: Text(r.moduleName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                            subtitle: Text(
                                'Absents: ${r.absent} • Justifiés: ${r.justified}\nDates: ${r.dates.join(', ')}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
