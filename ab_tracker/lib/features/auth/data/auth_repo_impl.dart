import '../domain/auth_repo.dart';
import '../domain/professor.dart';

/// Offline demo: prof / 1234
class AuthRepoImpl implements AuthRepo {
  Professor? _user;

  @override
  Future<Professor?> login(String username, String password) async {
    final ok = username.trim() == 'prof' && password.trim() == '1234';
    _user = ok ? Professor(username: username.trim()) : null;
    return _user;
  }

  @override
  Future<void> logout() async {
    _user = null;
  }

  @override
  Future<Professor?> currentUser() async => _user;
}
