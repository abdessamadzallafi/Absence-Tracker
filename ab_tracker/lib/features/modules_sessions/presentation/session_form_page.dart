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
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_date.text) ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d != null) {
      _date.text = d.toIso8601String().split('T')[0];
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(_time.text.split(':')[0]) ?? 8,
        minute: int.tryParse(_time.text.split(':')[1]) ?? 30,
      ),
    );
    if (t != null) {
      // ignore: use_build_context_synchronously
      _time.text =
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final moduleId = _moduleId;
    if (moduleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un module')),
      );
      return;
    }

    final s = SessionEntity(
      id: widget.initial?.id,
      moduleId: moduleId,
      date: _date.text.trim(),
      time: _time.text.trim(),
      type: _type,
    );
    await ref.read(sessionsProvider.notifier).upsert(s);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(sessionsProvider);

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
            child: Form(
              key: _formKey,
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
                  TextFormField(
                    controller: _date,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Date requise' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _time,
                    readOnly: true,
                    onTap: _pickTime,
                    decoration: const InputDecoration(
                      labelText: 'Heure',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Heure requise' : null,
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
            ),
          );
        },
      ),
    );
  }
}
