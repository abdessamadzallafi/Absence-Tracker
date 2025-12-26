import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/auth_controller.dart';

import '../../features/attendance/presentation/dashboard_page.dart';
import '../../features/groups/presentation/groups_page.dart';
import '../../features/students/presentation/students_page.dart';
import '../../features/modules_sessions/presentation/modules_page.dart';
import '../../features/modules_sessions/presentation/sessions_page.dart';
import '../../features/attendance/presentation/mark_attendance_page.dart';
import '../../features/attendance/presentation/student_history_page.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/fade_slide_route.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(AuthController.authStream),
    redirect: (context, state) {
      final auth = ProviderScope.containerOf(context, listen: false)
          .read(authStateProvider);
      final loggedIn = auth.isLoggedIn;
      final goingToLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingToLogin) return '/login';
      if (loggedIn && goingToLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (c, s) => FadeSlideRoute.page(child: const LoginPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
              path: '/dashboard',
              pageBuilder: (c, s) =>
                  FadeSlideRoute.page(child: const DashboardPage())),
          GoRoute(
              path: '/groups',
              pageBuilder: (c, s) =>
                  FadeSlideRoute.page(child: const GroupsPage())),
          GoRoute(
              path: '/students',
              pageBuilder: (c, s) =>
                  FadeSlideRoute.page(child: const StudentsPage())),
          GoRoute(
              path: '/modules',
              pageBuilder: (c, s) =>
                  FadeSlideRoute.page(child: const ModulesPage())),
          GoRoute(
              path: '/sessions',
              pageBuilder: (c, s) =>
                  FadeSlideRoute.page(child: const SessionsPage())),
          GoRoute(
              path: '/mark',
              pageBuilder: (c, s) =>
                  FadeSlideRoute.page(child: const MarkAttendancePage())),
          GoRoute(
              path: '/history',
              pageBuilder: (c, s) =>
                  FadeSlideRoute.page(child: const StudentHistoryPage())),
        ],
      ),
    ],
  );
}

/// Petit helper : écouter riverpod comme un stream pour refresh le router.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Permet de lire rapidement authStateProvider dans redirect (sans ref)
extension _ReadProvider on ProviderListenable<AuthState> {
  AuthState read(BuildContext context) {
    // ignore: invalid_use_of_visible_for_testing_member
    final scope = ProviderScope.containerOf(context, listen: false);
    return scope.read(this);
  }
}
