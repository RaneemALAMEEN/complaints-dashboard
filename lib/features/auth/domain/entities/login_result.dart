import 'package:complaints/features/auth/domain/entities/user.dart';

class LoginResult {
  final User user;
  final String token;

  LoginResult({
    required this.user,
    required this.token,
  });
}
