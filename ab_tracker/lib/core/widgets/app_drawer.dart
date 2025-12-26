import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(radius: 22, child: Icon(Icons.person)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Professeur',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        Text('SQLite • Offline',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Divider(),
            _item(context, Icons.dashboard_outlined, 'Dashboard', '/dashboard'),
            _item(context, Icons.groups_outlined, 'Gestion des groupes',
                '/groups'),
            _item(context, Icons.school_outlined, 'Gestion des étudiants',
                '/students'),
            _item(context, Icons.book_outlined, 'Modules', '/modules'),
            _item(context, Icons.event_outlined, 'Séances', '/sessions'),
            _item(context, Icons.check_circle_outline, 'Marquage des absences',
                '/mark'),
            _item(context, Icons.history, 'Historique étudiant', '/history'),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.tonalIcon(
                onPressed: () async {
                  await AuthController.logoutFromContext(context);
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget _item(
      BuildContext c, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(c);
        c.go(route);
      },
    );
  }
}
