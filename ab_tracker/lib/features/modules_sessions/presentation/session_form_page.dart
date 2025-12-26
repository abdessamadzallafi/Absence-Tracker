import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/session.dart';
import 'sessions_controller.dart';

class SessionFormPage extends ConsumerStatefulWidget {
  final SessionEntity? initial;
  const SessionFormPage({super.key, this.initial});

  @override
  ConsumerState<SessionFormPage> createState() => _SessionFormPageState();
}

class _SessionFormPageState extends ConsumerState<SessionFormPage> {
  int? _moduleId;
  late final TextEditingController _date;
  late final TextEditingController _time;
  String _type = 'cours';

  @override
  void initState() {
    super.initState();
    _date = TextEditingController(
        text: widget.initial?.date ?? AppDateUtils.todayIso());
    _time = TextEditingController(text: widget.initial?.time ?? '08:30');
    _type = widget.initial?.type ?? 'cours';
    _moduleId = widget.initial?.moduleId;
  }

  @override
  void dispose() {
    _date.dispose();
    _time.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final moduleId = _moduleId;
    if (moduleId == null) return;

    if (!AppDateUtils.isIsoDate(_date.text.trim())) return;
    if (!AppDateUtils.isTimeHHmm(_time.text.trim())) return;

    final s = SessionEntity(
      id: widget.initial?.id,
      moduleId: moduleId,
      date: _date.text.trim(),
      time: _time.text.trim(),
      type: _type,
    );
    await ref.read(sessionsControllerProvider.notifier).upsert(s);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(sessionsControllerProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text(
              widget.initial == null ? 'Créer séance' : 'Modifier séance')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (state) {
          if (state.modules.isEmpty) {
            return const Center(
                child: Text('Crée un module avant de créer des séances.'));
          }
          _moduleId ??= state.modules.first.id;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                DropdownButtonFormField<int>(
                  value: _moduleId,
                  items: state.modules
                      .map((m) =>
                          DropdownMenuItem(value: m.id!, child: Text(m.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _moduleId = v),
                  decoration: const InputDecoration(labelText: 'Module'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _date,
                  decoration:
                      const InputDecoration(labelText: 'Date (yyyy-MM-dd)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _time,
                  decoration: const InputDecoration(labelText: 'Heure (HH:mm)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(value: 'cours', child: Text('Cours')),
                    DropdownMenuItem(value: 'td', child: Text('TD')),
                    DropdownMenuItem(value: 'tp', child: Text('TP')),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? 'cours'),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
