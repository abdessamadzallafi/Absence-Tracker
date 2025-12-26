import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/search_bar.dart';
import '../domain/group.dart';
import 'group_form_page.dart';
import 'groups_controller.dart';

class GroupsPage extends ConsumerWidget {
  const GroupsPage({super.key});

  Future<void> _openForm(BuildContext context, {Group? g}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupFormPage(initial: g)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(groupsControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppSearchBar(
                  hint: 'Rechercher groupe / filière...',
                  onChanged: (q) =>
                      ref.read(groupsControllerProvider.notifier).setQuery(q),
                  onClear: () =>
                      ref.read(groupsControllerProvider.notifier).setQuery(''),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return EmptyState(
                    title: 'Aucun groupe',
                    subtitle: 'Ajoute un groupe pour commencer.',
                    icon: Icons.groups_outlined,
                    action: FilledButton.icon(
                      onPressed: () => _openForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un groupe'),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final g = list[i];
                    return Card(
                      child: ListTile(
                        title: Text(g.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(g.filiere),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Modifier',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _openForm(context, g: g),
                            ),
                            IconButton(
                              tooltip: 'Supprimer',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => ref
                                  .read(groupsControllerProvider.notifier)
                                  .delete(g.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
