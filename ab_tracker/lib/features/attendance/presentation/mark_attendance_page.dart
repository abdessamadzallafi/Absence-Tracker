import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/attendance.dart';
import 'attendance_controller.dart';
import 'dashboard_controller.dart';

class MarkAttendancePage extends ConsumerWidget {
  const MarkAttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(attendanceControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (vm) {
          final ctrl = ref.read(attendanceControllerProvider.notifier);

          if (vm.session == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Marquage des absences',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => ctrl.pickLatestSession(context),
                  icon: const Icon(Icons.event),
                  label: const Text('Choisir la dernière séance'),
                ),
                const SizedBox(height: 10),
                const Text(
                    'Crée: Groupes → Étudiants → Modules → Séances, puis reviens ici.'),
              ],
            );
          }

          return Column(
            children: [
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Séance #${vm.session!.id} • ${vm.session!.type}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  '${vm.session!.date} à ${vm.session!.time}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Retour',
                            onPressed: () => ctrl.resetSession(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            OutlinedButton(
                                onPressed: () =>
                                    ctrl.markAll(AttendanceStatus.present),
                                child: const Text('Tout présent')),
                            const SizedBox(width: 8),
                            OutlinedButton(
                                onPressed: () =>
                                    ctrl.markAll(AttendanceStatus.absent),
                                child: const Text('Tout absent')),
                            const SizedBox(width: 8),
                            OutlinedButton(
                                onPressed: () =>
                                    ctrl.markAll(AttendanceStatus.justified),
                                child: const Text('Tout justifié')),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: () async {
                                await ctrl.save(context);
                                ref.invalidate(dashboardControllerProvider);
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Enregistrer'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: vm.rows.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                'Aucun étudiant dans ce groupe (ID: ${vm.module?.groupId ?? '?'}). \nAjoutez des étudiants à ce groupe ou vérifiez le module.',
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () => ctrl.resetSession(),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Retour'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: vm.rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final r = vm.rows[i];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(r.studentName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16)),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_note,
                                            color: Colors.grey),
                                        onPressed: () =>
                                            ctrl.addNote(context, r.studentId),
                                      )
                                    ],
                                  ),
                                  if (r.note != null && r.note!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        'Note: ${r.note}',
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.blue),
                                      ),
                                    ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: SegmentedButton<AttendanceStatus>(
                                      segments: const [
                                        ButtonSegment(
                                            value: AttendanceStatus.present,
                                            label: Text('Présent',
                                                style:
                                                    TextStyle(fontSize: 12))),
                                        ButtonSegment(
                                            value: AttendanceStatus.absent,
                                            label: Text('Absent',
                                                style:
                                                    TextStyle(fontSize: 12))),
                                        ButtonSegment(
                                            value: AttendanceStatus.justified,
                                            label: Text('Justifié',
                                                style:
                                                    TextStyle(fontSize: 12))),
                                      ],
                                      selected: {r.status},
                                      onSelectionChanged: (set) => ctrl
                                          .setStatus(r.studentId, set.first),
                                      style: ButtonStyle(
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: MaterialStateProperty.all(
                                            EdgeInsets.zero),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
