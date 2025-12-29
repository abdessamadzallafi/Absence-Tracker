import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Étudiants")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddStudentDialog(),
          );
        },
      ),
      body: FutureBuilder(
        future: provider.loadStudents(),
        builder: (_, snapshot) {
          return ListView.builder(
            itemCount: provider.students.length,
            itemBuilder: (_, i) {
              final s = provider.students[i];
              return ListTile(
                title: Text("${s["firstName"]} ${s["lastName"]}"),
                subtitle: Text(s["massar"] ?? ""),
              );
            },
          );
        },
      ),
    );
  }
}

class AddStudentDialog extends StatelessWidget {
  final first = TextEditingController();
  final last = TextEditingController();
  final massar = TextEditingController();
  final groupId = TextEditingController();

  AddStudentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return AlertDialog(
      title: const Text("Ajouter Étudiant"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: first, decoration: const InputDecoration(labelText: "Prénom")),
          TextField(controller: last, decoration: const InputDecoration(labelText: "Nom")),
          TextField(controller: massar, decoration: const InputDecoration(labelText: "CNE/Massar")),
          TextField(controller: groupId, decoration: const InputDecoration(labelText: "ID Groupe")),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
        ElevatedButton(
          onPressed: () async {
            await provider.addStudent(
              groupId: int.parse(groupId.text),
              first: first.text,
              last: last.text,
              massar: massar.text,
            );
            Navigator.pop(context);
          },
          child: const Text("Enregistrer"),
        )
      ],
    );
  }
}
