import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/search_bar.dart';
import '../domain/session.dart';
import 'session_form_page.dart';
import 'sessions_controller.dart';

class SessionsPage extends ConsumerWidget {
  const SessionsPage({super.key});

  Future<void> _openForm(BuildContext context, {SessionEntity? initial}) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => SessionFormPage(initial: initial)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(sessionsProvider);

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
                    flex: 3,
                    child: AppSearchBar(
                      hint: 'Filtrer type/heure...',
                      onChanged: (q) =>
                          ref.read(sessionsProvider.notifier).setQuery(q),
                      onClear: () =>
                          ref.read(sessionsProvider.notifier).setQuery(''),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButton<int?>(
                      value: state.moduleFilterId,
                      isExpanded: true,
                      hint: const Text('Module'),
                      onChanged: (v) => ref
                          .read(sessionsProvider.notifier)
                          .setModuleFilter(v),
                      items: [
                        const DropdownMenuItem<int?>(
                            value: null, child: Text('Tous')),
                        ...state.modules.map((m) => DropdownMenuItem<int?>(
                            value: m.id,
                            child:
                                Text(m.name, overflow: TextOverflow.ellipsis))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed:
                        state.modules.isEmpty ? null : () => _openForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: state.sessions.isEmpty
                    ? EmptyState(
                        title: 'Aucune séance',
                        subtitle: state.modules.isEmpty
                            ? 'Crée un module d’abord.'
                            : 'Crée une séance pour marquer des absences.',
                        icon: Icons.event_outlined,
                      )
                    : ListView.separated(
                        itemCount: state.sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final s = state.sessions[i];
                          return Card(
                            child: ListTile(
                              title: Text('${s.date} • ${s.time}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                              subtitle: Text(
                                  'Type: ${s.type} • moduleId: ${s.moduleId}'),
                              trailing: SizedBox(
                                width: 96,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () =>
                                          _openForm(context, initial: s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => ref
                                          .read(sessionsProvider.notifier)
                                          .delete(s.id!),
                                    ),
                                  ],
                                ),
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
