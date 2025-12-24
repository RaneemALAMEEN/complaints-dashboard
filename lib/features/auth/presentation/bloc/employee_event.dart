import 'package:equatable/equatable.dart';

abstract class EmployeeEvent extends Equatable {
  const EmployeeEvent();

  @override
  List<Object?> get props => [];
}

class RegisterEmployeeRequested extends EmployeeEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String governmentEntity;
  final String phone;
  final List<int> permissionId;
  final String token;

  const RegisterEmployeeRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.governmentEntity,
    required this.phone,
    required this.permissionId,
    required this.token,
  });

  @override
  List<Object?> get props =>
      [firstName, lastName, email, password, governmentEntity, phone, permissionId, token];
}
