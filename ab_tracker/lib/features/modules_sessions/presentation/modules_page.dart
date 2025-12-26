import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/search_bar.dart';
import '../domain/module.dart';
import 'modules_controller.dart';

class ModulesPage extends ConsumerWidget {
  const ModulesPage({super.key});

  Future<void> _openForm(
      BuildContext context, WidgetRef ref, ModulesState state,
      {ModuleEntity? m}) async {
    if (state.groups.isEmpty) return;

    int groupId = m?.groupId ?? state.groups.first.id!;
    final name = TextEditingController(text: m?.name ?? '');
    final sem = TextEditingController(text: m?.semester ?? 'S1');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(m == null ? 'Ajouter module' : 'Modifier module'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: groupId,
                items: state.groups
                    .map((g) =>
                        DropdownMenuItem(value: g.id!, child: Text(g.name)))
                    .toList(),
                onChanged: (v) => setState(() => groupId = v!),
                decoration: const InputDecoration(labelText: 'Groupe'),
              ),
              const SizedBox(height: 10),
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nom module')),
              const SizedBox(height: 10),
              TextField(
                  controller: sem,
                  decoration:
                      const InputDecoration(labelText: 'Semestre (S1/S2...)')),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(_, false),
                child: const Text('Annuler')),
            FilledButton(
                onPressed: () => Navigator.pop(_, true),
                child: const Text('Enregistrer')),
          ],
        );
      }),
    );

    if (ok == true) {
      final nm = name.text.trim();
      final sm = sem.text.trim();
      if (nm.isEmpty || sm.isEmpty) return;
      await ref.read(modulesControllerProvider.notifier).upsert(
            ModuleEntity(id: m?.id, name: nm, semester: sm, groupId: groupId),
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(modulesControllerProvider);

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
                      hint: 'Rechercher module / semestre...',
                      onChanged: (q) => ref
                          .read(modulesControllerProvider.notifier)
                          .setQuery(q),
                      onClear: () => ref
                          .read(modulesControllerProvider.notifier)
                          .setQuery(''),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<int?>(
                    value: state.groupFilterId,
                    hint: const Text('Groupe'),
                    onChanged: (v) => ref
                        .read(modulesControllerProvider.notifier)
                        .setGroupFilter(v),
                    items: [
                      const DropdownMenuItem<int?>(
                          value: null, child: Text('Tous')),
                      ...state.groups.map((g) => DropdownMenuItem<int?>(
                          value: g.id, child: Text(g.name))),
                    ],
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: state.groups.isEmpty
                        ? null
                        : () => _openForm(context, ref, state),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: state.modules.isEmpty
                    ? EmptyState(
                        title: 'Aucun module',
                        subtitle: state.groups.isEmpty
                            ? 'Crée un groupe d’abord.'
                            : 'Ajoute un module.',
                        icon: Icons.book_outlined,
                      )
                    : ListView.separated(
                        itemCount: state.modules.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final m = state.modules[i];
                          return Card(
                            child: ListTile(
                              title: Text(m.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                              subtitle: Text(
                                  'Semestre: ${m.semester} • Groupe: ${m.groupId}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () =>
                                        _openForm(context, ref, state, m: m),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => ref
                                        .read(
                                            modulesControllerProvider.notifier)
                                        .delete(m.id!),
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
