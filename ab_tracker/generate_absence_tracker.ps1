# generate_absence_tracker.ps1
# Run at project root (where pubspec.yaml exists)

$ErrorActionPreference = "Stop"

function Ensure-Dir($path) {
  if (!(Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}

function Write-File($path, $content) {
  Ensure-Dir (Split-Path $path)
  # UTF8 without BOM
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
  Write-Host "Wrote: $path"
}

# ====== FOLDERS ======
$dirs = @(
  "lib",
  "lib/core/theme",
  "lib/core/routing",
  "lib/core/widgets",
  "lib/core/utils",
  "lib/core/export",
  "lib/data/db",

  "lib/features/auth/presentation",
  "lib/features/auth/domain",
  "lib/features/auth/data",

  "lib/features/groups/presentation",
  "lib/features/groups/domain/usecases",
  "lib/features/groups/data/models",

  "lib/features/students/presentation",
  "lib/features/students/domain/usecases",
  "lib/features/students/data/models",

  "lib/features/modules_sessions/presentation",
  "lib/features/modules_sessions/domain",
  "lib/features/modules_sessions/data/models",

  "lib/features/attendance/presentation",
  "lib/features/attendance/domain/usecases",
  "lib/features/attendance/data/models"
)

foreach ($d in $dirs) { Ensure-Dir $d }

# ====== FILES + CONTENT ======

Write-File "lib/main.dart" @'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AbsenceTrackerApp()));
}
'@

Write-File "lib/app.dart" @'
import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class AbsenceTrackerApp extends StatelessWidget {
  const AbsenceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Absence Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
'@

Write-File "lib/core/theme/app_theme.dart" @'
import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
    cardTheme: const CardTheme(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
'@

Write-File "lib/core/widgets/stat_card.dart" @'
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
'@

Write-File "lib/core/widgets/search_bar.dart" @'
import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hint,
        suffixIcon: IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.clear),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
'@

Write-File "lib/core/widgets/app_drawer.dart" @'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                        Text('Professeur', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('Mode offline • SQLite', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Divider(),
            _item(context, Icons.dashboard_outlined, 'Dashboard', '/dashboard'),
            _item(context, Icons.groups_outlined, 'Gestion des groupes', '/groups'),
            _item(context, Icons.school_outlined, 'Gestion des étudiants', '/students'),
            _item(context, Icons.book_outlined, 'Modules', '/modules'),
            _item(context, Icons.event_outlined, 'Séances', '/sessions'),
            _item(context, Icons.check_circle_outline, 'Marquage des absences', '/mark'),
            _item(context, Icons.history, 'Historique étudiant', '/history'),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.tonalIcon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
              ),
            )
          ],
        ),
      ),
    );
  }

  static Widget _item(BuildContext c, IconData icon, String title, String route) {
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
'@

Write-File "lib/core/widgets/app_scaffold.dart" @'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';

class AppScaffold extends StatefulWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _indexFromLocation(String loc) {
    if (loc.startsWith('/dashboard')) return 0;
    if (loc.startsWith('/groups')) return 1;
    if (loc.startsWith('/students')) return 2;
    return 0;
  }

  void _go(int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/groups');
        break;
      case 2:
        context.go('/students');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(loc);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Absence Tracker'),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: widget.child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Groupes'),
          NavigationDestination(icon: Icon(Icons.school_outlined), label: 'Étudiants'),
        ],
      ),
    );
  }
}
'@

Write-File "lib/core/routing/app_router.dart" @'
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/attendance/presentation/dashboard_page.dart';
import '../../features/groups/presentation/groups_page.dart';
import '../../features/students/presentation/students_page.dart';
import '../../features/modules_sessions/presentation/modules_page.dart';
import '../../features/modules_sessions/presentation/sessions_page.dart';
import '../../features/attendance/presentation/mark_attendance_page.dart';
import '../../features/attendance/presentation/student_history_page.dart';

import '../widgets/app_scaffold.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', pageBuilder: (c, s) => _fade(const LoginPage())),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: '/dashboard', pageBuilder: (c, s) => _fade(const DashboardPage())),
          GoRoute(path: '/groups', pageBuilder: (c, s) => _slide(const GroupsPage())),
          GoRoute(path: '/students', pageBuilder: (c, s) => _slide(const StudentsPage())),
          GoRoute(path: '/modules', pageBuilder: (c, s) => _slide(const ModulesPage())),
          GoRoute(path: '/sessions', pageBuilder: (c, s) => _slide(const SessionsPage())),
          GoRoute(path: '/mark', pageBuilder: (c, s) => _slide(const MarkAttendancePage())),
          GoRoute(path: '/history', pageBuilder: (c, s) => _slide(const StudentHistoryPage())),
        ],
      ),
    ],
  );

  static CustomTransitionPage _fade(Widget child) => CustomTransitionPage(
        child: child,
        transitionsBuilder: (c, a, s, w) => FadeTransition(opacity: a, child: w),
      );

  static CustomTransitionPage _slide(Widget child) => CustomTransitionPage(
        child: child,
        transitionsBuilder: (c, a, s, w) {
          final offset = Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(a);
          return FadeTransition(
            opacity: a,
            child: SlideTransition(position: offset, child: w),
          );
        },
      );
}
'@

Write-File "lib/data/db/app_database.dart" @'
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'absence_tracker.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE groups(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  filiere TEXT NOT NULL
);
''');

        await db.execute('''
CREATE TABLE students(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  groupId INTEGER NOT NULL,
  massar TEXT NOT NULL,
  firstName TEXT NOT NULL,
  lastName TEXT NOT NULL,
  email TEXT,
  FOREIGN KEY(groupId) REFERENCES groups(id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE modules(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  semester TEXT NOT NULL,
  groupId INTEGER NOT NULL,
  FOREIGN KEY(groupId) REFERENCES groups(id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE sessions(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  moduleId INTEGER NOT NULL,
  date TEXT NOT NULL,
  time TEXT NOT NULL,
  type TEXT NOT NULL,
  FOREIGN KEY(moduleId) REFERENCES modules(id) ON DELETE CASCADE
);
''');

        await db.execute('''
CREATE TABLE absences(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  sessionId INTEGER NOT NULL,
  studentId INTEGER NOT NULL,
  status TEXT NOT NULL,
  note TEXT,
  UNIQUE(sessionId, studentId),
  FOREIGN KEY(sessionId) REFERENCES sessions(id) ON DELETE CASCADE,
  FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE
);
''');
      },
    );
    return _db!;
  }
}
'@

# ====== AUTH (login page only for now) ======
Write-File "lib/features/auth/presentation/login_page.dart" @'
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _user = TextEditingController(text: 'prof');
  final _pass = TextEditingController(text: '1234');
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 450));

    if (_user.text.trim() == 'prof' && _pass.text.trim() == '1234') {
      if (!mounted) return;
      context.go('/dashboard');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Identifiants invalides')),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      const Text('Connexion Professeur',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _user,
                        decoration: const InputDecoration(labelText: 'Nom utilisateur'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pass,
                        decoration: const InputDecoration(labelText: 'Mot de passe'),
                        obscureText: true,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ obligatoire' : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(
                                  height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Se connecter'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Astuce: prof / 1234', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
'@

# ====== PLACEHOLDER PAGES (compile ok) ======
Write-File "lib/features/groups/presentation/groups_page.dart" @'
import 'package:flutter/material.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('Gestion des groupes (à compléter)')),
    );
  }
}
'@

Write-File "lib/features/students/presentation/students_page.dart" @'
import 'package:flutter/material.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('Gestion des étudiants (à compléter)')),
    );
  }
}
'@

Write-File "lib/features/modules_sessions/presentation/modules_page.dart" @'
import 'package:flutter/material.dart';

class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('Modules (à compléter)')),
    );
  }
}
'@

Write-File "lib/features/modules_sessions/presentation/sessions_page.dart" @'
import 'package:flutter/material.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('Séances (à compléter)')),
    );
  }
}
'@

Write-File "lib/features/attendance/presentation/mark_attendance_page.dart" @'
import 'package:flutter/material.dart';

class MarkAttendancePage extends StatelessWidget {
  const MarkAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('Marquage des absences (à compléter)')),
    );
  }
}
'@

Write-File "lib/features/attendance/presentation/student_history_page.dart" @'
import 'package:flutter/material.dart';

class StudentHistoryPage extends StatelessWidget {
  const StudentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('Historique étudiant (à compléter)')),
    );
  }
}
'@

Write-File "lib/features/attendance/presentation/dashboard_page.dart" @'
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: Text('Dashboard (à compléter)')),
    );
  }
}
'@

Write-Host "`n✅ Done. Now run:"
Write-Host "   flutter pub get"
Write-Host "   flutter run"
Write-Host "`nNote: pages are placeholders except Login + routing + DB + theme/widgets."
