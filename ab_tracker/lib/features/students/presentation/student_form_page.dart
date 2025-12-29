import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
import '../domain/student.dart';
import 'students_controller.dart';

class StudentFormPage extends ConsumerStatefulWidget {
  final Student? initial;
  const StudentFormPage({super.key, this.initial});

  @override
  ConsumerState<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends ConsumerState<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _massar;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;

  int? _groupId;

  @override
  void initState() {
    super.initState();
    _massar = TextEditingController(text: widget.initial?.massar ?? '');
    _firstName = TextEditingController(text: widget.initial?.firstName ?? '');
    _lastName = TextEditingController(text: widget.initial?.lastName ?? '');
    _email = TextEditingController(text: widget.initial?.email ?? '');
    _groupId = widget.initial?.groupId;
  }

  @override
  void dispose() {
    _massar.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final groupId = _groupId;
    if (groupId == null) return;

    final s = Student(
      id: widget.initial?.id,
      groupId: groupId,
      massar: _massar.text.trim(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
    );

    await ref.read(studentsProvider.notifier).upsert(s);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(studentsProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.initial == null
              ? 'Ajouter étudiant'
              : 'Modifier étudiant')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (state) {
          if (state.groups.isEmpty) {
            return const Center(
                child: Text('Crée un groupe avant d’ajouter des étudiants.'));
          }

          _groupId ??= state.groups.first.id;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  DropdownButtonFormField<int>(
                    value: _groupId,
                    items: state.groups
                        .map((g) => DropdownMenuItem(
                            value: g.id!,
                            child: Text('${g.name} • ${g.filiere}')))
                        .toList(),
                    onChanged: (v) => setState(() => _groupId = v),
                    decoration: const InputDecoration(labelText: 'Groupe'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _massar,
                    decoration: const InputDecoration(labelText: 'Massar/CNE'),
                    validator: Validators.requiredText,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _firstName,
                    decoration: const InputDecoration(labelText: 'Prénom'),
                    validator: Validators.requiredText,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lastName,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: Validators.requiredText,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    decoration:
                        const InputDecoration(labelText: 'Email (optionnel)'),
                    validator: Validators.email,
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
