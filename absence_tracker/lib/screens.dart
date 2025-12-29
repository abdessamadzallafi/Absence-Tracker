import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Groupes")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddGroupDialog(),
          );
        },
      ),
      body: FutureBuilder(
        future: provider.loadGroups(),
        builder: (_, snapshot) {
          return ListView.builder(
            itemCount: provider.groups.length,
            itemBuilder: (_, i) {
              final g = provider.groups[i];
              return ListTile(
                title: Text(g["name"]),
                subtitle: Text(g["filiere"] ?? ""),
              );
            },
          );
        },
      ),
    );
  }
}

class AddGroupDialog extends StatelessWidget {
  final name = TextEditingController();
  final filiere = TextEditingController();

  AddGroupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return AlertDialog(
      title: const Text("Ajouter Groupe"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: "Nom")),
          TextField(controller: filiere, decoration: const InputDecoration(labelText: "Filière")),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () async {
            await provider.addGroup(name.text, filiere.text);
            Navigator.pop(context);
          },
          child: const Text("Enregistrer"),
        )
      ],
    );
  }
}
