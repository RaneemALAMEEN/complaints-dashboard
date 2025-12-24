import '../sources/employee_remote_data_source.dart';
import '../../domain/repositories/employee_repository.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl(this.remoteDataSource);

  Future<Map<String, dynamic>> registerEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String governmentEntity,
    required String phone,
    required List<int> permissionId,
    required String token,
  }) async {
    final response = await remoteDataSource.registerEmployee(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      governmentEntity: governmentEntity,
      phone: phone,
      permissionId: permissionId,
      token: token,
    );

    return {
      "user": response['data']['user'],
      "governmentEntity": response['data']['newEmployee']['government_entity'],
      "message": response['message'],
    };
  }
}
