import 'package:equatable/equatable.dart';

abstract class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeSuccess extends EmployeeState {
  final Map<String, dynamic> data;

  const EmployeeSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class EmployeeFailure extends EmployeeState {
  final String message;

  const EmployeeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
