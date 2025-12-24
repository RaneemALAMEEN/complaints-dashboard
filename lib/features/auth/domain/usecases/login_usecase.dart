import 'package:complaints/features/auth/domain/entities/login_result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResult> call({
    required String email,
    required String password,
  }) {
    // positional arguments لأن login() في Repository positional
    return repository.login(email, password);
  }
}
