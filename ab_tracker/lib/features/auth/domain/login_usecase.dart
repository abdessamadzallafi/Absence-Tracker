import 'auth_repo.dart';
import 'professor.dart';

class LoginUsecase {
  final AuthRepo repo;
  const LoginUsecase(this.repo);

  Future<Professor?> call(String username, String password) {
    return repo.login(username, password);
  }
}
