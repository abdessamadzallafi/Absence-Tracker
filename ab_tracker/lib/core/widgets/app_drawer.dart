import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75 > 300
          ? 300
          : MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            color: Theme.of(context).primaryColor,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.person, size: 32),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Professeur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Absence Tracker • Offline',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _item(context, Icons.dashboard_outlined, 'Dashboard',
                    '/dashboard'),
                _item(context, Icons.groups_outlined, 'Gestion des groupes',
                    '/groups'),
                _item(context, Icons.school_outlined, 'Gestion des étudiants',
                    '/students'),
                const Divider(height: 24),
                _item(context, Icons.book_outlined, 'Modules', '/modules'),
                _item(context, Icons.event_outlined, 'Séances', '/sessions'),
                _item(context, Icons.check_circle_outline,
                    'Marquage des absences', '/mark'),
                _item(
                    context, Icons.history, 'Historique étudiant', '/history'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.tonalIcon(
              onPressed: () async {
                await AuthController.logoutFromContext(context);
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  static Widget _item(
      BuildContext c, IconData icon, String title, String route) {
    final isSelected = GoRouterState.of(c).uri.toString().startsWith(route);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFF2563EB) : null),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF2563EB) : null,
          ),
        ),
        tileColor:
            isSelected ? const Color(0xFF2563EB).withOpacity(0.08) : null,
        onTap: () {
          Navigator.pop(c);
          c.go(route);
        },
      ),
    );
  }
}
