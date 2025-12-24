import 'package:complaints/features/auth/data/sources/employee_remote_data_source.dart';


abstract class EmployeeRepository {
  Future<Map<String, dynamic>> registerEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String governmentEntity,
    required String phone,
    required List<int> permissionId,
    required String token,
  });
}
