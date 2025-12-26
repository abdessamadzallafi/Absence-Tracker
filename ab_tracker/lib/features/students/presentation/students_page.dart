import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/search_bar.dart';
import '../domain/student.dart';
import 'student_details_page.dart';
import 'student_form_page.dart';
import 'students_controller.dart';

class StudentsPage extends ConsumerWidget {
  const StudentsPage({super.key});

  Future<void> _openForm(BuildContext context, {Student? s}) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => StudentFormPage(initial: s)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studentsControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (state) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppSearchBar(
                      hint: 'Rechercher nom/prénom/massar...',
                      onChanged: (q) => ref
                          .read(studentsControllerProvider.notifier)
                          .setQuery(q),
                      onClear: () => ref
                          .read(studentsControllerProvider.notifier)
                          .setQuery(''),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int?>(
                    value: state.groupFilterId,
                    hint: const Text('Groupe'),
                    onChanged: (v) => ref
                        .read(studentsControllerProvider.notifier)
                        .setGroupFilter(v),
                    items: [
                      const DropdownMenuItem<int?>(
                          value: null, child: Text('Tous')),
                      ...state.groups.map((g) => DropdownMenuItem<int?>(
                          value: g.id, child: Text(g.name))),
                    ],
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    tooltip: 'Tri',
                    onSelected: (v) => ref
                        .read(studentsControllerProvider.notifier)
                        .setSort(v),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'lastName', child: Text('Nom')),
                      PopupMenuItem(value: 'firstName', child: Text('Prénom')),
                      PopupMenuItem(value: 'massar', child: Text('Massar')),
                    ],
                    child: const Icon(Icons.sort),
                  ),
                  IconButton(
                    tooltip: 'ASC/DESC',
                    onPressed: () => ref
                        .read(studentsControllerProvider.notifier)
                        .toggleDesc(),
                    icon: const Icon(Icons.swap_vert),
                  ),
                  FilledButton.icon(
                    onPressed:
                        state.groups.isEmpty ? null : () => _openForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: state.students.isEmpty
                    ? EmptyState(
                        title: 'Aucun étudiant',
                        subtitle: state.groups.isEmpty
                            ? 'Crée d’abord un groupe.'
                            : 'Ajoute des étudiants puis marque les absences.',
                        icon: Icons.school_outlined,
                        action: state.groups.isEmpty
                            ? null
                            : FilledButton.icon(
                                onPressed: () => _openForm(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter étudiant'),
                              ),
                      )
                    : ListView.separated(
                        itemCount: state.students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final s = state.students[i];
                          return Card(
                            child: ListTile(
                              leading: Hero(
                                tag: 'st_${s.id}',
                                child: CircleAvatar(
                                    child: Text(s.firstName.isNotEmpty
                                        ? s.firstName[0]
                                        : '?')),
                              ),
                              title: Text(s.fullName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                              subtitle: Text(
                                  'Massar: ${s.massar} • Groupe: ${s.groupId}'),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        StudentDetailsPage(student: s)),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _openForm(context, s: s),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => ref
                                        .read(
                                            studentsControllerProvider.notifier)
                                        .delete(s.id!),
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
