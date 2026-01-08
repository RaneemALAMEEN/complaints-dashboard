import 'package:complaints/core/models/permission.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  final String token;

  AuthSuccess(this.user, this.token);
}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}
