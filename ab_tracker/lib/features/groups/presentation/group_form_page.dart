import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
import '../domain/group.dart';
import 'groups_controller.dart';

class GroupFormPage extends ConsumerStatefulWidget {
  final Group? initial;
  const GroupFormPage({super.key, this.initial});

  @override
  ConsumerState<GroupFormPage> createState() => _GroupFormPageState();
}

class _GroupFormPageState extends ConsumerState<GroupFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _filiere;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _filiere = TextEditingController(text: widget.initial?.filiere ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _filiere.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final g = Group(
      id: widget.initial?.id,
      name: _name.text.trim(),
      filiere: _filiere.text.trim(),
    );
    await ref.read(groupsControllerProvider.notifier).upsert(g);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Scaffold(
      appBar:
          AppBar(title: Text(isEdit ? 'Modifier groupe' : 'Ajouter groupe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                    labelText: 'Nom groupe (GI1, IA2...)'),
                validator: Validators.requiredText,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _filiere,
                decoration: const InputDecoration(labelText: 'Filière'),
                validator: Validators.requiredText,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
