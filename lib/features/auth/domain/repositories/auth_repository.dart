import '../entities/login_result.dart';

abstract class AuthRepository {
  Future<LoginResult> login(String email, String password);
}
