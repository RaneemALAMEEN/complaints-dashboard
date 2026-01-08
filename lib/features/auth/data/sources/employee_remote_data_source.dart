import 'package:dio/dio.dart';

class EmployeeRemoteDataSource {
  final Dio dio;

  EmployeeRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> registerEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String governmentEntity,
    required String phone,
    required List<int> permissionId,
    required String token, // توكن الادمن
  }) async {
    try {
      final response = await dio.post(
        '/api/auth/registerAdmin',
        data: {
          "first_name": firstName,
          "last_name": lastName,
          "email": email,
          "password": password,
          "government_entity": governmentEntity,
          "phone": phone,
          "permission_id": permissionId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.data;
    } catch (e, stackTrace) {
      print('RegisterEmployee Error: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }
}
