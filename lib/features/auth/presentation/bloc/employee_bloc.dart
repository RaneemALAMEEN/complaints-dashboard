import 'package:complaints/features/auth/domain/repositories/employee_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'employee_event.dart';
import 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository repository;

  EmployeeBloc(this.repository) : super(EmployeeInitial()) {
    on<RegisterEmployeeRequested>((event, emit) async {
      emit(EmployeeLoading());
      try {
        final result = await repository.registerEmployee(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          password: event.password,
          governmentEntity: event.governmentEntity,
          phone: event.phone,
          permissionId: event.permissionId,
          token: event.token,
        );
        emit(EmployeeSuccess(result));
      } catch (e) {
        emit(EmployeeFailure('فشل إنشاء الحساب: ${e.toString()}'));
      }
    });
  }
}
