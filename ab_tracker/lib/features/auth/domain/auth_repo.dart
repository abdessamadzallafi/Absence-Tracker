import 'professor.dart';

abstract class AuthRepo {
  Future<Professor?> login(String username, String password);
  Future<void> logout();
  Future<Professor?> currentUser();
}
