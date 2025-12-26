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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Séance #${vm.session!.id} • ${vm.session!.type} • ${vm.session!.date} ${vm.session!.time}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  OutlinedButton(
                      onPressed: () => ctrl.markAll(AttendanceStatus.present),
                      child: const Text('Tout présent')),
                  const SizedBox(width: 8),
                  OutlinedButton(
                      onPressed: () => ctrl.markAll(AttendanceStatus.absent),
                      child: const Text('Tout absent')),
                  const SizedBox(width: 8),
                  OutlinedButton(
                      onPressed: () => ctrl.markAll(AttendanceStatus.justified),
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
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: vm.rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = vm.rows[i];
                    return Card(
                      child: ListTile(
                        title: Text(r.studentName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(
                            'Statut: ${r.status.name}${r.note != null ? ' • Note: ${r.note}' : ''}'),
                        onLongPress: () => ctrl.addNote(context, r.studentId),
                        trailing: SegmentedButton<AttendanceStatus>(
                          segments: const [
                            ButtonSegment(
                                value: AttendanceStatus.present,
                                label: Text('Présent')),
                            ButtonSegment(
                                value: AttendanceStatus.absent,
                                label: Text('Absent')),
                            ButtonSegment(
                                value: AttendanceStatus.justified,
                                label: Text('Justifié')),
                          ],
                          selected: {r.status},
                          onSelectionChanged: (set) =>
                              ctrl.setStatus(r.studentId, set.first),
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
