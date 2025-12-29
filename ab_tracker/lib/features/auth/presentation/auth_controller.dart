import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';

import '../../auth/data/auth_repo_impl.dart';
import '../domain/auth_repo.dart';
import '../domain/login_usecase.dart';
import '../domain/professor.dart';

class AuthState {
  final bool isLoggedIn;
  final Professor? user;
  const AuthState({required this.isLoggedIn, required this.user});
}


final authRepoProvider = Provider<AuthRepo>((ref) {
  final api = ref.watch(apiClientProvider);
  return AuthRepoImpl(apiClient: api);
});
final loginUsecaseProvider =
    Provider((ref) => LoginUsecase(ref.watch(authRepoProvider)));

final authStateProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;
  AuthController(this.ref)
      : super(const AuthState(isLoggedIn: false, user: null));

  static Stream<AuthState> get authStream => _controller.stream;
  static final _controller = StreamController<AuthState>.broadcast();

  Future<void> login(String u, String p) async {
    final uc = ref.read(loginUsecaseProvider);
    final user = await uc(u, p);
    state = AuthState(isLoggedIn: user != null, user: user);
    _controller.add(state);
  }

  Future<void> logout() async {
    await ref.read(authRepoProvider).logout();
    state = const AuthState(isLoggedIn: false, user: null);
    _controller.add(state);
  }

  /// helper static pour drawer
  static Future<void> logoutStatic(ProviderContainer c) async {
    await c.read(authStateProvider.notifier).logout();
  }

  static Future<void> logoutFromContext(BuildContext context) async {
    final container = ProviderScope.containerOf(context, listen: false);
    await container.read(authStateProvider.notifier).logout();
  }
}
